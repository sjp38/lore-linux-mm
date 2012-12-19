Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id C924F6B002B
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 07:16:51 -0500 (EST)
Date: Wed, 19 Dec 2012 13:16:48 +0100
From: Petr Holasek <pholasek@redhat.com>
Subject: Re: mm, ksm: NULL ptr deref in unstable_tree_search_insert
Message-ID: <20121219121647.GB4381@thinkpad-work.redhat.com>
References: <50D1158F.5070905@oracle.com>
 <alpine.LNX.2.00.1212181728400.1091@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1212181728400.1091@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 18 Dec 2012, Hugh Dickins wrote:
> On Tue, 18 Dec 2012, Sasha Levin wrote:
> 
> > Hi all,
> > 
> > While fuzzing with trinity inside a KVM tools guest, running latest linux-next kernel, I've
> > stumbled on the following:
> > 
> > [  127.959264] BUG: unable to handle kernel NULL pointer dereference at 0000000000000110
> > [  127.960379] IP: [<ffffffff81185b60>] __lock_acquire+0xb0/0xa90
...

> > 88 e9 b9 09 00 00 90 <48> 81 3b 60 59 22 86 b8 01 00 00 00 44 0f 44 e8 41 83 fc 01 77
> > [  127.978032] RIP  [<ffffffff81185b60>] __lock_acquire+0xb0/0xa90
> > [  127.978032]  RSP <ffff8800137abb78>
> > [  127.978032] CR2: 0000000000000110
> > [  127.978032] ---[ end trace 3dc1b0c5db8c1230 ]---
> > 
> > The relevant piece of code is:
> > 
> > 	static struct page *get_mergeable_page(struct rmap_item *rmap_item)
> > 	{
> > 	        struct mm_struct *mm = rmap_item->mm;
> > 	        unsigned long addr = rmap_item->address;
> > 	        struct vm_area_struct *vma;
> > 	        struct page *page;
> > 	
> > 	        down_read(&mm->mmap_sem);
> > 
> > Where 'mm' is NULL. I'm not really sure how it happens though.
> 
> Thanks, yes, I got that, and it's not peculiar to fuzzing at all:
> I'm testing the fix at the moment, but just hit something else too
> (ksmd oops on NULL p->mm in task_numa_fault i.e. task_numa_placement).
> 
> For the moment, you're safer not to run KSM: configure it out or don't
> set it to run.  Fixes to follow later, I'll try to remember to Cc you.
> 

Hello all,

I've also tried fuzzing with trinity inside of kvm guest when tested KSM
patch, but applied on top of 3.7-rc8, but didn't trigger that oops. So
going to do the same testing on linux-next.

Hugh, does it seem like bug in unstable_tree_search_insert() you mentioned
in yesterday email of something else?

Thank you for your testing && feedback!

Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
