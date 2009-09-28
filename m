Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8DA136B00A6
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 12:32:12 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8S371mQ017546
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Sep 2009 12:07:01 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C5A2045DE53
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 12:07:00 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 964DE45DE4E
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 12:07:00 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CE691DB8043
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 12:07:00 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id F1D4FE1800E
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 12:06:59 +0900 (JST)
Date: Mon, 28 Sep 2009 12:04:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: No more bits in vm_area_struct's vm_flags.
Message-Id: <20090928120450.c2d8a4e2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4AC0234F.2080808@crca.org.au>
References: <4AB9A0D6.1090004@crca.org.au>
	<20090924100518.78df6b93.kamezawa.hiroyu@jp.fujitsu.com>
	<4ABC80B0.5010100@crca.org.au>
	<20090925174009.79778649.kamezawa.hiroyu@jp.fujitsu.com>
	<4AC0234F.2080808@crca.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nigel Cunningham <ncunningham@crca.org.au>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 28 Sep 2009 12:45:35 +1000
Nigel Cunningham <ncunningham@crca.org.au> wrote:
> KAMEZAWA Hiroyuki wrote:
> > On Fri, 25 Sep 2009 18:34:56 +1000
> > Nigel Cunningham <ncunningham@crca.org.au> wrote:
> >> Hi.
> >>
> >> KAMEZAWA Hiroyuki wrote:
> >>>> I have some code in TuxOnIce that needs a bit too (explicitly mark the
> >>>> VMA as needing to be atomically copied, for GEM objects), and am not
> >>>> sure what the canonical way to proceed is. Should a new unsigned long be
> >>>> added? The difficulty I see with that is that my flag was used in
> >>>> shmem_file_setup's flags parameter (drm_gem_object_alloc), so that
> >>>> function would need an extra parameter too..
> >>> Hmm, how about adding vma->vm_flags2 ?
> >> The difficulty there is that some functions pass these flags as arguments.
> >>
> > Ah yes. But I wonder some special flags, which is rarey used, can be moved
> > to vm_flags2...
> > 
> > For example,
> > 
> >  #define VM_SEQ_READ     0x00008000      /* App will access data sequentially */
> >  #define VM_RAND_READ    0x00010000      /* App will not benefit from clustered reads */
> > are all capsuled under
> > mm.h
> >  117 #define VM_READHINTMASK                 (VM_SEQ_READ | VM_RAND_READ)
> >  118 #define VM_ClearReadHint(v)             (v)->vm_flags &= ~VM_READHINTMASK
> >  119 #define VM_NormalReadHint(v)            (!((v)->vm_flags & VM_READHINTMASK))
> >  120 #define VM_SequentialReadHint(v)        ((v)->vm_flags & VM_SEQ_READ)
> >  121 #define VM_RandomReadHint(v)            ((v)->vm_flags & VM_RAND_READ)
> > 
> > Or
> > 
> > 105 #define VM_PFN_AT_MMAP  0x40000000      /* PFNMAP vma that is fully mapped at mmap time */
> > is only used under special situation.
> > 
> > etc..
> > 
> > They'll be able to be moved to other(new) flag field, IIUC.
> 
CCing Fengguang.

Breif Summary of thread:
 Now, vm->vm_flags has no more avialable bits. Then, I proposed Nigel
 to move some flags from vm->vm_flags to other flags as vm->vm_????.
 It seems readahead-hints are candidates for this......

> I'm working on a patch to do this, and am looking at is_mergeable_vma,
> which is invoked via can_vma_merge_after from vma_merge from
> madvise_behaviour (which potentially modifies these hint flags). Should
> those hints be considered in that function? (Do I need to pass the hints
> in as well and check they're equal?)

I think it should be handled.
But, yes it implies to add a new argument to several functions in mmap.c
and maybe a patch will be ugly.

How about addding this check ?

is_mergeable_vma(...)
....
  if (vma->vm_hints)
	return 0;

And not calling vma_merge() at madvice(ACCESS_PATTERN_HINT).

I wonder there are little chances when madice(ACCESS_PATTERN_HINT) is
given against mapped-file-vma...

> 
> By the way, VM_ClearReadHint and VM_NormalReadHint are currently unused.
>  madvise_behaviour manipulates the flags directly (in preparing
> potential replacement values). Not sure if something should be done
> about that.
> 
> By the way #2, in response to the later message in this thread, I'm
> calling the new var vma->vm_hints, and have put it at the end of the
> struct at the moment. Is that a good place?
> 
I think it seems nice. But please before entries under CONFIG.
How about just after vm_private_data ?

Regards,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
