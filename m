Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 382066B0253
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 15:50:01 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id 124so591016pfg.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 12:50:01 -0800 (PST)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id fl1si21478075pad.15.2016.03.02.12.50.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 12:50:00 -0800 (PST)
Received: by mail-pf0-x22f.google.com with SMTP id 124so590855pfg.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 12:50:00 -0800 (PST)
Date: Wed, 2 Mar 2016 12:49:52 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Problems with swapping in v4.5-rc on POWER
In-Reply-To: <alpine.LSU.2.11.1602260157430.10399@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1603021226300.31251@eggly.anvils>
References: <alpine.LSU.2.11.1602241716220.15121@eggly.anvils> <877fhttmr1.fsf@linux.vnet.ibm.com> <alpine.LSU.2.11.1602242136270.6876@eggly.anvils> <alpine.LSU.2.11.1602251322130.8063@eggly.anvils> <alpine.LSU.2.11.1602260157430.10399@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Hugh Dickins <hughd@google.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@ozlabs.org>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Fri, 26 Feb 2016, Hugh Dickins wrote:
> On Thu, 25 Feb 2016, Hugh Dickins wrote:
> > On Wed, 24 Feb 2016, Hugh Dickins wrote:
> > > On Thu, 25 Feb 2016, Aneesh Kumar K.V wrote:
> > > > 
> > > > Can you test the impact of the merge listed below ?(ie, revert the merge and see if
> > > > we can reproduce and also verify with merge applied). This will give us a
> > > > set of commits to look closer. We had quiet a lot of page table
> > > > related changes going in this merge window. 
> > > > 
> > > > f689b742f217b2ffe7 ("Pull powerpc updates from Michael Ellerman:")
> > > > 
> > > > That is the merge commit that added _PAGE_PTE. 
> > > 
> > > Another experiment running on it at the moment, I'd like to give that
> > > a few more hours, and then will try the revert you suggest.  But does
> > > that merge revert cleanly, did you try?  I'm afraid of interactions,
> > > whether obvious or subtle, with the THP refcounting rework.  Oh, since
> > > I don't have THP configured on, maybe I can ignore any issues from that.
> > 
> > That revert worked painlessly, only a very few and simple conflicts,
> > I ran that under load for 12 hours, no problem seen.
> > 
> > I've now checked out an f689b742 tree and started on that, just to
> > confirm that it fails fairly quickly I hope; and will then proceed
> > to git bisect, giving that as bad and 37cea93b as good.
> > 
> > Given the uncertainty of whether 12 hours is really long enough to be
> > sure, and perhaps difficulties along the way, I don't rate my chances
> > of a reliable bisection higher than 60%, but we'll see.
> 
> I'm sure you won't want a breathless report from me on each bisection
> step, but I ought to report that: contrary to our expectations, the
> f689b742 survived without error for 12 hours, so appears to be good.
> I'll bisect between there and v4.5-rc1.

The bisection completed this morning (log appended below):
not a satisfactory conclusion, it's pointing to a davem/net merge.

I was uncomfortable when I marked that point bad in the first place:
it ran for 9 hours before hitting a compiler error, which was nearly
twice as long as the longest I'd seen before (5 hours), and
uncomfortably close to the 12 hours I've been taking as good.

My current thinking is that the powerpc merge that you indicated,
that I found to be "good", is the one that contains the bad commit;
but that the bug is very rare to manifest in that kernel, and my test
of the davem/net merge happened to be unusually unlucky to hit it.

Then some other later change makes it significantly easier to hit;
and identifying that change may make it much easier to pin down
what the original bug is.

So I've replayed the bisection up to that point, marked the davem/net
merge as good this time, and set off again in the hope that it will
lead somewhere more enlightening.  But prepared for disappointment.

Hugh

git bisect start
# good: [f689b742f217b2ffe7925f8a6521b208ee995309] Merge tag 'powerpc-4.5-1' of git://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux
git bisect good f689b742f217b2ffe7925f8a6521b208ee995309
# bad: [92e963f50fc74041b5e9e744c330dca48e04f08d] Linux 4.5-rc1
git bisect bad 92e963f50fc74041b5e9e744c330dca48e04f08d
# bad: [7f36f1b2a8c4f55f8226ed6c8bb4ed6de11c4015] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide
git bisect bad 7f36f1b2a8c4f55f8226ed6c8bb4ed6de11c4015
# bad: [6606b342febfd470b4a33acb73e360eeaca1d9bb] Merge git://www.linux-watchdog.org/linux-watchdog
git bisect bad 6606b342febfd470b4a33acb73e360eeaca1d9bb
# good: [d0021d3bdfe9d551859bca1f58da0e6be8e26043] Merge remote-tracking branch 'asoc/topic/wm8960' into asoc-next
git bisect good d0021d3bdfe9d551859bca1f58da0e6be8e26043
# good: [e3315b439c30c208582ac64e58f0c0d36b83181e] ALSA: oxfw: allocate own address region for SCS.1 series
git bisect good e3315b439c30c208582ac64e58f0c0d36b83181e
# good: [3da834e3e5a4a5d26882955298b55a9ed37a00bc] clk: remove duplicated COMMON_CLK_NXP record from clk/Kconfig
git bisect good 3da834e3e5a4a5d26882955298b55a9ed37a00bc
# bad: [e535d74bc50df2357d3253f8f3ca48c66d0d892a] Merge tag 'docs-4.5' of git://git.lwn.net/linux
git bisect bad e535d74bc50df2357d3253f8f3ca48c66d0d892a
# bad: [4e5448a31d73d0e944b7adb9049438a09bc332cb] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
git bisect bad 4e5448a31d73d0e944b7adb9049438a09bc332cb
# good: [b70ce2ab41cb67ab3d661eda078f7c4029bbca95] dts: hisi: fixes no syscon fault when init mdio
git bisect good b70ce2ab41cb67ab3d661eda078f7c4029bbca95
# good: [4a658527271bce43afb1cf4feec89afe6716ca59] xen-netback: delete NAPI instance when queue fails to initialize
git bisect good 4a658527271bce43afb1cf4feec89afe6716ca59
# good: [c6894dec8ea9ae05747124dce98b3b5c2e69b168] bridge: fix lockdep addr_list_lock false positive splat
git bisect good c6894dec8ea9ae05747124dce98b3b5c2e69b168
# good: [36beca6571c941b28b0798667608239731f9bc3a] sparc64: Fix numa node distance initialization
git bisect good 36beca6571c941b28b0798667608239731f9bc3a
# good: [750afbf8ee9c6a1c74a1fe5fc9852146b1d72687] bgmac: Fix reversed test of build_skb() return value.
git bisect good 750afbf8ee9c6a1c74a1fe5fc9852146b1d72687
# good: [5a18d263f8d27418c98b8e8551dadfe975c054e3] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc
git bisect good 5a18d263f8d27418c98b8e8551dadfe975c054e3
# first bad commit: [4e5448a31d73d0e944b7adb9049438a09bc332cb] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
