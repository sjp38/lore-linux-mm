Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C002B8D0007
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 10:58:20 -0500 (EST)
Date: Mon, 29 Nov 2010 15:58:01 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] mm: page allocator: Adjust the per-cpu counter
	threshold when memory is low
Message-ID: <20101129155801.GG13268@csn.ul.ie>
References: <1288169256-7174-1-git-send-email-mel@csn.ul.ie> <1288169256-7174-2-git-send-email-mel@csn.ul.ie> <20101126160619.GP22651@bombadil.infradead.org> <20101129095618.GB13268@csn.ul.ie> <20101129131626.GF15818@bombadil.infradead.org> <20101129150824.GF13268@csn.ul.ie> <20101129152230.GH15818@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101129152230.GH15818@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
To: Kyle McMartin <kyle@mcmartin.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 29, 2010 at 10:22:30AM -0500, Kyle McMartin wrote:
> On Mon, Nov 29, 2010 at 03:08:24PM +0000, Mel Gorman wrote:
> > Ouch! I have been unable to create an exact copy of your kernel source as
> > I'm not running Fedora. From a partial conversion of a source RPM, I saw no
> > changes related to mm/vmscan.c. Is this accurate? I'm trying to establish
> > if this is a mainline bug as well.
> > 
> 
> Sorry, if you extract the source rpm you should get the patched
> sources... Aside from a few patches to mm/mmap for execshield, mm/* is
> otherwise untouched from the latest stable 2.6.35 kernels.
> 

Perfect, that correlates with what I saw so this is probably a
mainline issue.

> If you git clone git://pkgs.fedoraproject.org/kernel and check out the
> origin/f14/master branch, it has all the patches we apply (based on the
> 'ApplyPatch' lines in kernel.spec
> 
> > Second, I see all the stack traces are marked with "?" making them
> > unreliable. Is that anything to be concerned about?
> > 
> 
> Hrm, I don't think it is, I think the ones with '?' are just artifacts
> because we don't have a proper unwinder. Oh! Thanks! I just found a bug
> in our configs... We don't have CONFIG_FRAME_POINTER set because
> CONFIG_DEBUG_KERNEL got unset in the 'production' configs... I'll fix
> that up.
> 

Ordinarily I'd expect it to be from the lack of a unwinder but if FRAME_POINTER
is there (which you say in a follow-up mail that is), it can be a bit of
a concern. There is some real weirness as it is. Take on of Luke's
examples where it appears to be locked up in

[ 5015.448127] Pid: 185, comm: kswapd1 Tainted: P 2.6.35.6-48.fc14.x86_64 #1 X8DA3/X8DA3
[ 5015.448127] RIP: 0010:[<ffffffff81469130>]  [<ffffffff81469130>] _raw_spin_unlock_irqrestore+0x18/0x19

I am at a loss to explain under what circumstances that can even happen!
Is there any possibility RIP is being translated to the wrong symbol possibly
via an userspace decoder of the oops or similar? Is there any possibility
the stack is being corrupted if the swap subsystem is on a complicated
software stack?

> > I see that one user has reported that the patches fixed the problem for him
> > but I fear that this might be a co-incidence or that the patches close a
> > race of some description. Specifically, I'm trying to identify if there is
> > a situation where kswapd() constantly loops checking watermarks and never
> > calling cond_resched(). This could conceivably happen if kswapd() is always
> > checking sleeping_prematurely() at a higher order where as balance_pgdat()
> > is always checks the watermarks at the lower order. I'm not seeing how this
> > could happen in 2.6.35.6 though. If Fedora doesn't have special changes,
> > it might mean that these patches do need to go into -stable as the
> > cost of zone_page_state_snapshot() is far higher on larger machines than
> > previously reported.
> > 
> 
> Yeah, I am a bit surprised as well. Luke seems to have quite a large
> machine... I haven't seen any kswapd lockups there on my 18G machine
> using the same kernel. :< (Possibly it's just not stressed enough
> though.)
> 

He reports his machine as 24-way but with his model of CPU it could
still be 2-socket which I ordinarily would not have expected to suffer
so badly from zone_page_state_snapshot(). I would have predicted that
the patches being thrown about in the thread "Free memory never fully
used, swapping" to be more relevant to kswapd failing to go to sleep :/

Andrew, this patch was a performance fix but is a report saying that it
fixes a functional regression in Fedora enough to push a patch torwards
stable even though an explanation as to *why* it fixes the problem is missing?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
