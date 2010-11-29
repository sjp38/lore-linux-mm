Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4C69E8D0007
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 10:23:09 -0500 (EST)
Date: Mon, 29 Nov 2010 10:22:30 -0500
From: Kyle McMartin <kyle@mcmartin.ca>
Subject: Re: [PATCH 1/2] mm: page allocator: Adjust the per-cpu counter
 threshold when memory is low
Message-ID: <20101129152230.GH15818@bombadil.infradead.org>
References: <1288169256-7174-1-git-send-email-mel@csn.ul.ie>
 <1288169256-7174-2-git-send-email-mel@csn.ul.ie>
 <20101126160619.GP22651@bombadil.infradead.org>
 <20101129095618.GB13268@csn.ul.ie>
 <20101129131626.GF15818@bombadil.infradead.org>
 <20101129150824.GF13268@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101129150824.GF13268@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Kyle McMartin <kyle@mcmartin.ca>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 29, 2010 at 03:08:24PM +0000, Mel Gorman wrote:
> Ouch! I have been unable to create an exact copy of your kernel source as
> I'm not running Fedora. From a partial conversion of a source RPM, I saw no
> changes related to mm/vmscan.c. Is this accurate? I'm trying to establish
> if this is a mainline bug as well.
> 

Sorry, if you extract the source rpm you should get the patched
sources... Aside from a few patches to mm/mmap for execshield, mm/* is
otherwise untouched from the latest stable 2.6.35 kernels.

If you git clone git://pkgs.fedoraproject.org/kernel and check out the
origin/f14/master branch, it has all the patches we apply (based on the
'ApplyPatch' lines in kernel.spec

> Second, I see all the stack traces are marked with "?" making them
> unreliable. Is that anything to be concerned about?
> 

Hrm, I don't think it is, I think the ones with '?' are just artifacts
because we don't have a proper unwinder. Oh! Thanks! I just found a bug
in our configs... We don't have CONFIG_FRAME_POINTER set because
CONFIG_DEBUG_KERNEL got unset in the 'production' configs... I'll fix
that up.

> I see that one user has reported that the patches fixed the problem for him
> but I fear that this might be a co-incidence or that the patches close a
> race of some description. Specifically, I'm trying to identify if there is
> a situation where kswapd() constantly loops checking watermarks and never
> calling cond_resched(). This could conceivably happen if kswapd() is always
> checking sleeping_prematurely() at a higher order where as balance_pgdat()
> is always checks the watermarks at the lower order. I'm not seeing how this
> could happen in 2.6.35.6 though. If Fedora doesn't have special changes,
> it might mean that these patches do need to go into -stable as the
> cost of zone_page_state_snapshot() is far higher on larger machines than
> previously reported.
> 

Yeah, I am a bit surprised as well. Luke seems to have quite a large
machine... I haven't seen any kswapd lockups there on my 18G machine
using the same kernel. :< (Possibly it's just not stressed enough
though.)

Thanks for looking into this!
	Kyle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
