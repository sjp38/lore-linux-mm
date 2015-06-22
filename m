Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 782216B006C
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 04:34:33 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so134331386pdj.0
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 01:34:33 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id mx8si12202140pdb.23.2015.06.22.01.34.32
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Jun 2015 01:34:32 -0700 (PDT)
Message-ID: <5587C883.9080304@synopsys.com>
Date: Mon, 22 Jun 2015 14:04:11 +0530
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
MIME-Version: 1.0
Subject: Re: [arc-linux-dev] [PATCH] stmmac: explicitly zero des0 & des1 on
 init
References: <1434476441-18241-1-git-send-email-abrodkin@synopsys.com>	 <C2D7FE5348E1B147BCA15975FBA23075665A5DED@IN01WEMBXB.internal.synopsys.com> <1434960510.4269.25.camel@synopsys.com>
In-Reply-To: <1434960510.4269.25.camel@synopsys.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peppe.cavallaro@st.com" <peppe.cavallaro@st.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "arc-linux-dev@synopsys.com" <arc-linux-dev@synopsys.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "arnd@arndb.de" <arnd@arndb.de>

On Monday 22 June 2015 01:38 PM, Alexey Brodkin wrote:
> Hi all,
> 
> On Wed, 2015-06-17 at 07:03 +0000, Vineet Gupta wrote:
> +CC linux-arch, linux-mm, Arnd and Marek
> 
> On Tuesday 16 June 2015 11:11 PM, Alexey Brodkin wrote:
> 
> Current implementtion of descriptor init procedure only takes care about
> ownership flag. While it is perfectly possible to have underlying memory
> filled with garbage on boot or driver installation.
> 
> And randomly set flags in non-zeroed des0 and des1 fields may lead to
> unpredictable behavior of the GMAC DMA block.
> 
> Solution to this problem is as simple as explicit zeroing of both des0
> and des1 fields of all buffer descriptors.
> 
> Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com><mailto:abrodkin@synopsys.com>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com><mailto:peppe.cavallaro@st.com>
> Cc: arc-linux-dev@synopsys.com<mailto:arc-linux-dev@synopsys.com>
> Cc: linux-kernel@vger.kernel.org<mailto:linux-kernel@vger.kernel.org>
> Cc: stable@vger.kernel.org<mailto:stable@vger.kernel.org>
> 
> FWIW, this was causing sporadic/random networking flakiness on ARC SDP platform (scheduled for upstream inclusion in next window)
> 
> This also leads to an interesting question - should arch/*/dma_alloc_coherent() and friends unconditionally zero out memory (vs. the current semantics of letting only doing it based on gfp, as requested by driver). This is the second instance we ran into stale descriptor memory, the first one was in dw_mmc driver which was recently fixed in upstream as well (although debugged independently by Alexey and using the upstream fix)
> 
> http://www.spinics.net/lists/linux-mmc/msg31600.html
> 
> The pros is better out of box experience (despite buggy drivers) while the cons are they remain broken and perhaps increased boot time due to extra memzero....
> 
> Probably if we already have dma_zalloc_coherent() that does explicit zeroing of returned memory then there's no need to do implicit zeroing in dma_alloc_coherent()?


The question is, when drivers don't have dma_zalloc_coherent() - meaning they
don't pass __GFP_ZERO, which causes these random issues, do we need to be more
conservative in arch code (ARC at least is) or do we need to debug and fix these
drivers - one by one.

FWIW, ARC needs to fix __GFP_ZERO case, since we are doing memzero twice.

-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
