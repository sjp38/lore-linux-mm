Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 93A656B0038
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 00:37:03 -0400 (EDT)
Received: by pddn5 with SMTP id n5so47089365pdd.2
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 21:37:03 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id yx9si13063619pac.109.2015.03.29.21.37.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Mar 2015 21:37:01 -0700 (PDT)
Received: by pacwz10 with SMTP id wz10so104287490pac.2
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 21:37:01 -0700 (PDT)
Date: Sun, 29 Mar 2015 21:36:52 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: arm/ksm: Unable to handle kernel paging request in get_ksm_page()
 and ksm_scan_thread()
In-Reply-To: <5518BDC7.2090407@huawei.com>
Message-ID: <alpine.LSU.2.11.1503292113280.1525@eggly.anvils>
References: <55140869.7060507@huawei.com> <55161D0E.9070604@huawei.com> <alpine.LSU.2.11.1503291701580.1052@eggly.anvils> <5518AAE5.8060308@huawei.com> <5518BDC7.2090407@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, neilb@suse.de, heiko.carstens@de.ibm.com, dhowells@redhat.com, izik.eidus@ravellosystems.com, aarcange@redhat.com, chrisw@sous-sol.org, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, weiyuan.wei@huawei.com

On Mon, 30 Mar 2015, Xishi Qiu wrote:
> On 2015/3/30 9:46, Xishi Qiu wrote:
> > On 2015/3/30 8:43, Hugh Dickins wrote:
> >> On Sat, 28 Mar 2015, Xishi Qiu wrote:
> >>> On 2015/3/26 21:23, Xishi Qiu wrote:
> >>>
> >>>> Here are two panic logs from smart phone test, and the kernel version is v3.10.
> >>>>
> >>>> log1 is "Unable to handle kernel paging request at virtual address c0704da020", it should be ffffffc0704da020, right?
> >>
> >> That one was an oops at get_ksm_page+0x34/0x150: I'm pretty sure that
> >> comes from the "kpfn = ACCESS_ONCE(stable_node->kpfn)" line, that the
> >> stable_node pointer (in x21 or x22) has upper bits cleared; which
> >> suggests corruption of the rmap_item supposed to point to it.
> >>
> >> get_ksm_page() is tricky with ACCESS_ONCEs against page migration,
> >> and the structures tricky with unions; but pointers overlay pointers
> >> in those unions, I don't see any way we might pick up an address with
> >> the upper 24 or 32 bits cleared due to that.
> >>
> >>>> and log2 is "Unable to handle kernel paging request at virtual address 1e000796", it should be ffffffc01e000796, right?
> >>
> >> And this one was an oops at ksm_scan_thread+0x4ac/0xce0; as is the oops
> >> you posted below.  Which contains lots of hex numbers, but very little
> >> info I can work from.
> >>
> >> Please make a CONFIG_DEBUG_INFO=y build of one of the kernels you're
> >> hitting this with, then use the disassembler (objdump -ld perhaps) to
> >> identify precisely which line of ksm.c that is oopsing on: the compiler
> >> will have inlined more interesting functions into ksm_scan_thread, so
> >> I haven't a clue where it's actually oopsing.
> >>
> >> Maybe we'll find that it's also oopsing on a kernel virtual address
> >> from an rmap_item, maybe we won't.
> >>
> >> And I don't read arm64 assembler at all, so I shall be rather limited
> >> in what I can tell you, I'm afraid.
> >>
> >>>>
> >>>> I cann't repeat the panic by test, so could anyone tell me this is the 
> >>>> bug of ksm or other reason?
> >>
> >> I've not heard of any problem like this with KSM on other architectures.
> >> Maybe it is making some assumption which is invalid on arm64, but I'd
> >> have thought we'd have heard about that before now.  My guess is that
> >> something in your kernel is stamping on KSM's structures.
> >>
> >> A relevant experiment (after identifying the oops line in your current
> >> kernel) might be to switch from CONFIG_SLAB=y to CONFIG_SLUB=y or vice
> >> versa.  I doubt SLAB or SLUB is to blame, but changing allocator might
> >> shake things up in a way that either hides the problem, or shifts it
> >> elsewhere.
> >>
> >> Hugh
> >>
> > 
> > Hi Hugh,
> > 
> > Thanks for your reply. There are 3 cases as follows, at first I think maybe
> > something causes the oops, but all of the cases are relevant to "rmap_item",
> > so I have no idea.
> > 
> > 1. ksm_scan_thread+0xa88/0xce0 -> unstable_tree_search_insert() -> tree_rmap_item = rb_entry(*new, struct rmap_item, node);
> > 
> > 2. ksm_scan_thread+0x4ac/0xce0 -> get_next_rmap_item() -> if ((rmap_item->address & PAGE_MASK) == addr)
> > 
> > 3. get_ksm_page+0x34/0x150 -> get_ksm_page() -> kpfn = ACCESS_ONCE(stable_node->kpfn);

So, something is zeroing bytes inside a struct rmap_item.
I say bytes because the pointer in your third dump was ff00000000000000
when it should have been a good struct rmap_item *rmap_list.
But I have no idea what, I'm afraid.

There has to be some reason it's struct rmap_item that's vulnerable;
but I haven't spotted a likely culprit in ksm.c.

If you're using CONFIG_SLUB=y, then "slabinfo -a | grep ksm_rmap_item"
would show what is sharing the same cache as the rmap_items, which may
suggest somewhere to look.  (slabinfo comes from tools/vm/slabinfo.c;
I think cache merging has been extended from SLUB to SLAB in later
kernels, but not in v3.10.)

As I said before, it is worth switching SLAB<->SLUB, just to see
what if any difference that makes.  Or are you using SLOB (that
might be significant)?  If so, please try SLUB or SLAB.

> > 
> > Thanks,
> > Xishi Qiu
> > 
> 
> The kernel is v3.10.59

3.10.61-gxxxxxxx-dirty is what your dumps show, but perhaps you know
that -gxxxxxxx-dirty is taking it back to v3.10.59.

I'd like to think that you've run this test on other kernels, and can
therefore bisect to find where it goes wrong; but suspect I'll be
disappointed to learn this is the first you've tried.

Sorry, no ideas.
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
