Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 61F806B0044
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 19:43:24 -0500 (EST)
Date: Mon, 3 Dec 2012 16:43:22 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: protect against concurrent vma expansion
Message-Id: <20121203164322.b967d461.akpm@linux-foundation.org>
In-Reply-To: <CANN689FfWVV4MyTUPKZQgQAWW9Dfdw9f0fqx98kc+USKj9g7TA@mail.gmail.com>
References: <1354344987-28203-1-git-send-email-walken@google.com>
	<20121203150110.39c204ff.akpm@linux-foundation.org>
	<CANN689FfWVV4MyTUPKZQgQAWW9Dfdw9f0fqx98kc+USKj9g7TA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

On Mon, 3 Dec 2012 16:35:01 -0800
Michel Lespinasse <walken@google.com> wrote:

> On Mon, Dec 3, 2012 at 3:01 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Fri, 30 Nov 2012 22:56:27 -0800
> > Michel Lespinasse <walken@google.com> wrote:
> >
> >> expand_stack() runs with a shared mmap_sem lock. Because of this, there
> >> could be multiple concurrent stack expansions in the same mm, which may
> >> cause problems in the vma gap update code.
> >>
> >> I propose to solve this by taking the mm->page_table_lock around such vma
> >> expansions, in order to avoid the concurrency issue. We only have to worry
> >> about concurrent expand_stack() calls here, since we hold a shared mmap_sem
> >> lock and all vma modificaitons other than expand_stack() are done under
> >> an exclusive mmap_sem lock.
> >>
> >> I previously tried to achieve the same effect by making sure all
> >> growable vmas in a given mm would share the same anon_vma, which we
> >> already lock here. However this turned out to be difficult - all of the
> >> schemes I tried for refcounting the growable anon_vma and clearing
> >> turned out ugly. So, I'm now proposing only the minimal fix.
> >
> > I think I don't understand the problem fully.  Let me demonstrate:
> >
> > a) vma_lock_anon_vma() doesn't take a lock which is specific to
> >    "this" anon_vma.  It takes anon_vma->root->mutex.  That mutex is
> >    shared with vma->vm_next, yes?  If so, we have no problem here?
> >    (which makes me suspect that the races lies other than where I think
> >    it lies).
> 
> So, the first thing I need to mention is that this fix is NOT for any
> problem that has been reported (and in particular, not for Sasha's
> trinity fuzzing issue). It's just me looking at the code and noticing
> I haven't gotten locking right for the case of concurrent stack
> expansion.
> 
> Regarding vma and vma->vm_next sharing the same root anon_vma mutex -
> this will often be the case, but not always. find_mergeable_anon_vma()
> will try to make it so, but it could fail if there was another vma
> in-between at the time the stack's anon_vmas got assigned (either a
> non-stack vma that later gets unmapped, or another stack vma that
> didn't get its own anon_vma assigned yet).
> 
> > b) I can see why a broader lock is needed in expand_upwards(): it
> >    plays with a different vma: vma->vm_next.  But expand_downwards()
> >    doesn't do that - it only alters "this" vma.  So I'd have thought
> >    that vma_lock_anon_vma("this" vma) would be sufficient.
> 
> The issue there is that vma_gap_update() accesses vma->vm_prev, so the
> issue is actually symetrical with expand_upwards().
> 
> > What are the performance costs of this change?
> 
> It's expected to be small. glibc doesn't use expandable stacks for the
> threads it creates, so having multiple growable stacks is actually
> uncommon (another reason why the problem hasn't been observed in
> practice). Because of this, I don't expect the page table lock to get
> bounced between threads, so the cost of taking it should be small
> (compared to the cost of delivering the #PF, let alone handling it in
> software).
> 
> But yes, the initial idea of forcing all growable vmas in an mm to
> share the same root anon_vma sounded much more appealing at first.
> Unfortunately I haven't been able to make that work in a simple enough
> way to be comfortable submitting it this late in the release cycle :/

hm, OK.  Could you please cook up a new changelog which explains these
things to the next puzzled reader and send it along?

Ingo is playing in the same area with "mm/rmap: Convert the struct
anon_vma::mutex to an rwsem", but as that patch changes
vma_lock_anon_vma() to use down_write(), I expect it won't affect
anything.  But please check it over.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
