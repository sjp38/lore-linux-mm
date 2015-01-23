Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id EDDC76B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 10:32:51 -0500 (EST)
Received: by mail-we0-f181.google.com with SMTP id k48so6518953wev.12
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 07:32:51 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id wn10si3549081wjb.172.2015.01.23.07.32.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jan 2015 07:32:50 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] ARM: use default ioremap alignment for SMP or LPAE
Date: Fri, 23 Jan 2015 16:31:51 +0100
Message-ID: <52689548.6W7Vnxiz8L@wuerfel>
In-Reply-To: <20150123145235.GB21789@e104818-lin.cambridge.arm.com>
References: <1421911075-8814-1-git-send-email-s.dyasly@samsung.com> <3060178.HEZJjJCl1e@wuerfel> <20150123145235.GB21789@e104818-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, "nicolas.pitre@linaro.org" <nicolas.pitre@linaro.org>, Russell King <linux@arm.linux.org.uk>, Sergey Dyasly <s.dyasly@samsung.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Will Deacon <Will.Deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, James Bottomley <JBottomley@parallels.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Arnd Bergmann <arnd.bergmann@linaro.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Andrew Morton <akpm@linux-foundation.org>

On Friday 23 January 2015 14:52:36 Catalin Marinas wrote:
> On Thu, Jan 22, 2015 at 11:03:00AM +0000, Arnd Bergmann wrote:
> > Unrelated to this question however is whether we want to keep
> > supersection mappings as a performance optimization to save TLBs.
> > It seems useful to me, but not critical.
> 
> Currently in Linux we allow 16MB mappings only if the phys address is
> over 32-bit and !LPAE which makes it unlikely for normal RAM with
> pre-LPAE hardware.

Ah, I missed this part when looking at the code.

> IIRC a bigger problem was that supersections are optional in the
> architecture but there was no CPUID bit field in ARMv6 (and early ARMv7)
> to check for their presence. The ID_MMFR3 contains this information but
> for example on early Cortex-A8 that bitfield was reserved and the TRM
> states "unpredictable" on read (so probably zero in practice).
> 
> On newer ARMv7 (not necessarily with LPAE), we could indeed revisit the
> 16MB section mapping but it won't go well with single zImage if you want
> to support earlier ARMv7 or ARMv6.

I see. If there is desire to have it as an optimization, we could do
it for armv7ve-only kernels. We don't currently have an build-time
option for those, but we should introduce one anyway, in order to
better make use of the idiv instructions and to prevent one from
enabling LPAE on a multiplatform kernel that contains pre-lpae armv7
machines (Cortex a8/a9/a5, and some others I'm not sure about).

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
