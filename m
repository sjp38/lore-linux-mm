Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E457D6B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:00:58 -0400 (EDT)
Date: Fri, 13 Mar 2009 12:59:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 12556] pgoff_t type not wide enough (32-bit with LFS
 and/or LBD)
Message-Id: <20090313125909.99637b18.akpm@linux-foundation.org>
In-Reply-To: <20090313141538.3255210803F@picon.linux-foundation.org>
References: <bug-12556-27@http.bugzilla.kernel.org/>
	<20090313141538.3255210803F@picon.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Marc Aurele La France <tsi@ualberta.ca>
Cc: bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 13 Mar 2009 07:15:38 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12556

> On 32-bit archs, CONFIG_LBD allows for block devices larger than 2TB (with a
> 512-byte sector size), while CONFIG_LFS allows for files larger than 16TB (with
> a 4K block size).  However, reads (through the cache) of such things beyond the
> first 16TB result in bogus data.  Writes, oddly enough, are OK.  This is
> because the pgoff_t type is not wide enough.  See read_dev_sector()'s call to
> read_mapping_page() in fs/partitions/check.c for an example.
> 
> A Q&D fix for this is to have that snippet in include/linux/types.h read ...
> 
> /*
>  * The type of an index into the pagecache.  Use a #define so asm/types.h
>  * can override it.
>  */
> #ifndef pgoff_t
> #if defined(CONFIG_LBD) || defined(CONFIG_LSF)
> #define pgoff_t u64
> #else
> #define pgoff_t unsigned long
> #endif
> #endif
> 

ouch.

We never had any serious intention of implementing 64-bit pagecache
indexes on 32-bit architectures.  I added pgoff_t mainly for code
clarity reasons (it was getting nutty in there), with a vague
expectation that we would need to use a 64-bit type one day.

And, yes, the need to be able to manipulate block devices via the
pagecache does mean that this day is upon us.

A full implementation is quite problematic.  Such a change affects each
filesystem, many of which are old and crufty and which nobody
maintains.  The cost of bugs in there (and there will be bugs) is
corrupted data in rare cases for few people, which is bad.

Perhaps what we should do is to add a per-filesystem flag which says
"this fs is OK with 64-bit page indexes", and turn that on within each
filesystem as we convert and test them.  Add checks to the VFS to
prevent people from extending files to more than 16TB on unverified
filesystems.  Hopefully all of this infrastructure is already in place
via super_block.s_maxbytes, and we can just forget about >16TB _files_.

And fix up the core VFS if there are any problems, and get pagecache IO
reviewed, tested and working for the blockdev address_spaces.

I expect it's all pretty simple, actually.  Mainly a matter of doing a
few hours code review to clean up those places where we accidentally
copy a pgoff_t to or from a long type.

The fact that the kernel apparently already works correctly when one simply
makes pgoff_t a u64 is surprising and encouraging and unexpected.  I
bet it doesn't work 100% properly!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
