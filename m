Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5A9B060021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 22:16:34 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBS3GVpo027852
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Dec 2009 12:16:32 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C2CB045DE50
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 12:16:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 99DD545DE4E
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 12:16:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FCD41DB8038
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 12:16:31 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FBB11DB8037
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 12:16:31 +0900 (JST)
Date: Mon, 28 Dec 2009 12:13:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC PATCH] asynchronous page fault.
Message-Id: <20091228121318.780fd104.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091228025839.GF3601@balbir.in.ibm.com>
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
	<1261912796.15854.25.camel@laptop>
	<20091228005746.GE3601@balbir.in.ibm.com>
	<20091228100514.ec6f9949.kamezawa.hiroyu@jp.fujitsu.com>
	<20091228025839.GF3601@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Dec 2009 08:28:39 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-12-28 10:05:14]:

> >   - rb-tree's rb_left and rb_right don't points to memory other than
> >     rb-tree. (or NULL)  And vmas are not freed/reused while rcu_read_lock().
> >     Then, we don't dive into unknown memory.
> >   - Then, we can skip rcu_assign_pointer().
> >
> 
> We can, but the data being on read-side is going to be out-of-date
> more than without the use of rcu_assign_pointer(). Do we need variants
> like to rcu_rb_next() to avoid overheads for everyone?
> 
I myself can't know how often out-of-date data can be seen (because I use x86).

But, I feel that we don't see broken tree so often. Because...
  - Single-threaded apps never see broken tree.
  - Even if rb-tree modification frequently happens, tree rotation is not
    very often and sub-trees tend to be stable as a chunk.

Hmm, adding barrier like this ?

static inline void
__vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
                struct vm_area_struct *prev)
{
        prev->vm_next = vma->vm_next;
        rb_erase(&vma->vm_rb, &mm->mm_rb);
        if (mm->mmap_cache == vma)
                mm->mmap_cache = prev;
	smp_wb(); <==============================================(new)
}



Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
