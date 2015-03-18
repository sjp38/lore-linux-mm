Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 418AA6B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 10:12:08 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so44377494pdb.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 07:12:08 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id xx7si36296455pab.72.2015.03.18.07.12.07
        for <linux-mm@kvack.org>;
        Wed, 18 Mar 2015 07:12:07 -0700 (PDT)
Message-ID: <550987AD.8020409@intel.com>
Date: Wed, 18 Mar 2015 07:11:57 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm: protect suid binaries against rowhammer with
 copy-on-read mappings
References: <20150318083040.7838.76933.stgit@zurg>
In-Reply-To: <20150318083040.7838.76933.stgit@zurg>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>

On 03/18/2015 01:30 AM, Konstantin Khlebnikov wrote:
> +		/*
> +		 * Read-only SUID/SGID binares are mapped as copy-on-read
> +		 * this protects them against exploiting with Rowhammer.
> +		 */
> +		if (!(file->f_mode & FMODE_WRITE) &&
> +		    ((inode->i_mode & S_ISUID) || ((inode->i_mode & S_ISGID) &&
> +			    (inode->i_mode & S_IXGRP)))) {
> +			vm_flags &= ~(VM_SHARED | VM_MAYSHARE);
> +			vm_flags |= VM_COR;
> +		}

I think we probably need to come to _some_ sort of understanding in the
kernel of how much we are willing to do to thwart these kinds of
attacks.  I suspect it's a very deep rabbit hole.

For this particular case, I don't see how this would be effective.  The
existing exploit which you reference attacks PTE pages which are
unmapped in to the user address space.  I'm confused how avoiding
mapping a page in to an attacker's process can keep it from being exploited.

Right now, there's a relatively small number of pages that will get
COW'd for a SUID binary.  This greatly increases the number which could
allow spraying of these (valuable) copy-on-read pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
