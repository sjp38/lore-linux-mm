Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6E7DC6005A4
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 00:34:09 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o055Y6xv026380
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 5 Jan 2010 14:34:06 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C47145DE58
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 14:34:06 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E644345DE51
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 14:34:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B1C471DB8063
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 14:34:05 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 539611DB8040
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 14:34:05 +0900 (JST)
Date: Tue, 5 Jan 2010 14:30:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
Message-Id: <20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LFD.2.00.1001042052210.3630@localhost.localdomain>
References: <20100104182429.833180340@chello.nl>
	<20100104182813.753545361@chello.nl>
	<20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com>
	<20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001042052210.3630@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Jan 2010 21:10:29 -0800 (PST)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Tue, 5 Jan 2010, KAMEZAWA Hiroyuki wrote:
> > 
> > Then, my patch dropped speculative trial of page fault and did synchronous
> > job here. I'm still considering how to insert some barrier to delay calling
> > remove_vma() until all page fault goes. One idea was reference count but
> > it was said not-enough crazy.
> 
> What lock would you use to protect the vma lookup (in order to then 
> increase the refcount)? A sequence lock with RCU lookup of the vma?
> 

Ah, I just used reference counter to show "how many threads are in
page fault to this vma now". Below is from my post.

==
+			rb_node = rcu_dereference(rb_node->rb_left);
+		} else
+			rb_node = rcu_dereference(rb_node->rb_right);
+	}
+	if (vma) {
+		if ((vma->vm_start <= addr) && (addr < vma->vm_end)) {
+			if (!atomic_inc_not_zero(&vma->refcnt))
+				vma = NULL;
+		} else
+			vma = NULL;
+	}
+	rcu_read_unlock();

...
+void vma_put(struct vm_area_struct *vma)
+{
+	if ((atomic_dec_return(&vma->refcnt) == 1) &&
+	    waitqueue_active(&vma->wait_queue))
+		wake_up(&vma->wait_queue);
+	return;
+}
==

And wait for this reference count to be good number before calling
remove_vma()
==
+/* called when vma is unlinked and wait for all racy access.*/
+static void invalidate_vma_before_free(struct vm_area_struct *vma)
+{
+	atomic_dec(&vma->refcnt);
+	wait_event(vma->wait_queue, !atomic_read(&vma->refcnt));
+}
+
....
 		 * us to remove next before dropping the locks.
 		 */
 		__vma_unlink(mm, next, vma);
+		invalidate_vma_before_free(next);
 		if (file)
 			__remove_shared_vm_struct(next, file, mapping);

etc....
==
Above codes are a bit heavy(and buggy). I have some fixes.

> Sounds doable. But it also sounds way more expensive than the current VM 
> fault handling, which is pretty close to optimal for single-threaded 
> cases.. That RCU lookup might be cheap, but just the refcount is generally 
> going to be as expensive as a lock.
>
For single-threaded apps, my patch will have no benefits.
(but will not make anything worse.)
I'll add CONFIG and I wonder I can enable speculave_vma_lookup
only after mm_struct is shared.(but the patch may be messy...)

> Are there some particular mappings that people care about more than 
> others? If we limit the speculative lookup purely to anonymous memory, 
> that might simplify the problem space?
> 

I wonder, for usual people who don't write highly optimized programs,
some small benefit of skipping mmap_sem is to reduce mmap_sem() ping-pong
after doing fork()->exec(). This can cause some jitter to the application.
So, I'm glad if I can help file-backed vmas.

> [ From past experiences, I suspect DB people would be upset and really 
>   want it for the general file mapping case.. But maybe the main usage 
>   scenario is something else this time? ]
> 

I'd like to hear use cases of really heavy users, too. Christoph ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
