Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id C28986B007E
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 17:45:28 -0500 (EST)
Date: Thu, 8 Mar 2012 14:45:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hugetlbfs: lockdep annotate root inode properly
Message-Id: <20120308144526.addeaaf1.akpm@linux-foundation.org>
In-Reply-To: <20120308223333.GA21766@redhat.com>
References: <1331198116-13670-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<20120308130256.c7855cbd.akpm@linux-foundation.org>
	<20120308211926.GB6546@boyd>
	<20120308134050.f53a0b2f.akpm@linux-foundation.org>
	<20120308214951.GB23916@ZenIV.linux.org.uk>
	<20120308141938.1d04afb7.akpm@linux-foundation.org>
	<20120308223333.GA21766@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Tyler Hicks <tyhicks@canonical.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, jboyer@redhat.com, linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mimi Zohar <zohar@linux.vnet.ibm.com>, David Gibson <david@gibson.dropbear.id.au>

On Thu, 8 Mar 2012 17:33:34 -0500
Dave Jones <davej@redhat.com> wrote:

> On Thu, Mar 08, 2012 at 02:19:38PM -0800, Andrew Morton wrote:
>  > On Thu, 8 Mar 2012 21:49:52 +0000
>  > Al Viro <viro@ZenIV.linux.org.uk> wrote:
>  > 
>  > > > So we need to pull the i_mutex out of hugetlbfs_file_mmap().
>  > > 
>  > > IIRC, you have a patch in your tree doing just that...
>  > 
>  > Nope.
>  > 
>  > But it seems that you've recently seen such a patch - can you recall
>  > where?
> 
> this ? https://lkml.org/lkml/2012/2/23/64
> 

Thanks, yes, probably that.  Needs the i_size_read()/write() changes.

I worry a bit about the region handling code in mm/hugetlb.c.  

 * The region data structures are protected by a combination of the mmap_sem
 * and the hugetlb_instantion_mutex.  To access or modify a region the caller
 * must either hold the mmap_sem for write, or the mmap_sem for read and
 * the hugetlb_instantiation mutex:

I hope that's true - it would be nice to have some debug assertions in
the various region_foo() functions to verify that the required locks are
held.

But if that code is all nice and tight, I guess that removing that
i_mutex acquisition will be pretty simple.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
