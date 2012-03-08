Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 9A0CF6B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 16:40:52 -0500 (EST)
Date: Thu, 8 Mar 2012 13:40:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hugetlbfs: lockdep annotate root inode properly
Message-Id: <20120308134050.f53a0b2f.akpm@linux-foundation.org>
In-Reply-To: <20120308211926.GB6546@boyd>
References: <1331198116-13670-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<20120308130256.c7855cbd.akpm@linux-foundation.org>
	<20120308211926.GB6546@boyd>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tyler Hicks <tyhicks@canonical.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, davej@redhat.com, jboyer@redhat.com, linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mimi Zohar <zohar@linux.vnet.ibm.com>, David Gibson <david@gibson.dropbear.id.au>

On Thu, 8 Mar 2012 15:19:27 -0600
Tyler Hicks <tyhicks@canonical.com> wrote:

> > 
> > 
> > Sigh.  Was lockdep_annotate_inode_mutex_key() sufficiently
> > self-explanatory to justify leaving it undocumented?
> > 
> > <goes off and reads e096d0c7e2e>
> > 
> > OK, the patch looks correct given the explanation in e096d0c7e2e, but
> > I'd like to understand why it becomes necessary only now.
> > 
> > > NOTE: This patch also require 
> > > http://thread.gmane.org/gmane.linux.file-systems/58795/focus=59565
> > > to remove the lockdep warning
> > 
> > And that patch has been basically ignored.
> 
> Al commented on it here:
> 
> https://lkml.org/lkml/2012/2/16/518
> 
> He said that while my patch is correct, taking i_mutex inside mmap_sem
> is still wrong.

OK, thanks, yup.  Taking i_mutex in file_operations.mmap() is wrong.

Is hugetlbfs actually deadlockable because of this, or is it the case
that the i_mutex->mmap_sem ordering happens to never happen for this
filesystem?  Although we shouldn't go and create incompatible lock
ranking rules for different filesystems!

So we need to pull the i_mutex out of hugetlbfs_file_mmap().  What's it
actually trying to do in there?  If we switch to
i_size_read()/i_size_write() then AFAICT the problem comes down to
hugetlb_reserve_pages().

hugetlb_reserve_pages() fiddles with i_mapping->private_list and the fs
owns private_list and is free to use a lock other than i_mutex to
protect it.  (In fact i_mapping.private_lock is the usual lock for
private_list).



So from a quick scan here I'm thinking that a decent fix is to remove
the i_mutex locking from hugetlbfs_file_mmap(), switch
hugetlbfs_file_mmap() to i_size_read/write then use a hugetlb-private
lock to protect i_mapping->private_list.  region_chg() will do
GFP_KERNEL allocations under that lock, so some care is needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
