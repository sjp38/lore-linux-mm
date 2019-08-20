Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FF06C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:12:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D184214DA
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:12:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D184214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D31C06B0007; Tue, 20 Aug 2019 05:12:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE2DD6B0008; Tue, 20 Aug 2019 05:12:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF8046B000A; Tue, 20 Aug 2019 05:12:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0153.hostedemail.com [216.40.44.153])
	by kanga.kvack.org (Postfix) with ESMTP id 99F986B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 05:12:34 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 33EA08248AC0
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:12:34 +0000 (UTC)
X-FDA: 75842240628.20.paper77_33754fde7095b
X-HE-Tag: paper77_33754fde7095b
X-Filterd-Recvd-Size: 3321
Received: from Galois.linutronix.de (Galois.linutronix.de [193.142.43.55])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:12:33 +0000 (UTC)
Received: from p5de0b6c5.dip0.t-ipconnect.de ([93.224.182.197] helo=nanos.glx-home)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1i00Bp-00089o-HM; Tue, 20 Aug 2019 11:12:29 +0200
Date: Tue, 20 Aug 2019 11:12:13 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Song Liu <songliubraving@fb.com>
cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, 
    stable@vger.kernel.org, Joerg Roedel <jroedel@suse.de>, 
    Dave Hansen <dave.hansen@linux.intel.com>, 
    Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] x86/mm/pti: in pti_clone_pgtable() don't increase addr
 by PUD_SIZE
In-Reply-To: <20190820075128.2912224-1-songliubraving@fb.com>
Message-ID: <alpine.DEB.2.21.1908201106260.2223@nanos.tec.linutronix.de>
References: <20190820075128.2912224-1-songliubraving@fb.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 Aug 2019, Song Liu wrote:

> pti_clone_pgtable() increases addr by PUD_SIZE for pud_none(*pud) case.
> This is not accurate because addr may not be PUD_SIZE aligned.

You fail to explain how this happened. The code before the 32bit support
did always increase by PMD_SIZE. The 32bit support broke that.
 
> In our x86_64 kernel, pti_clone_pgtable() fails to clone 7 PMDs because
> of this issuse, including PMD for the irq entry table. For a memcache
> like workload, this introduces about 4.5x more iTLB-load and about 2.5x
> more iTLB-load-misses on a Skylake CPU.

This information is largely irrelevant. What matters is the fact that this
got broken and incorrectly forwards the address by PUD_SIZE which is wrong
if address is not PUD_SIZE aligned.

> This patch fixes this issue by adding PMD_SIZE to addr for pud_none()
> case.

  git grep 'This patch' Documentation/process/submitting-patches.rst

> Cc: stable@vger.kernel.org # v4.19+
> Fixes: 16a3fe634f6a ("x86/mm/pti: Clone kernel-image on PTE level for 32 bit")
> Signed-off-by: Song Liu <songliubraving@fb.com>
> Cc: Joerg Roedel <jroedel@suse.de>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> ---
>  arch/x86/mm/pti.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
> index b196524759ec..5a67c3015f59 100644
> --- a/arch/x86/mm/pti.c
> +++ b/arch/x86/mm/pti.c
> @@ -330,7 +330,7 @@ pti_clone_pgtable(unsigned long start, unsigned long end,
>  
>  		pud = pud_offset(p4d, addr);
>  		if (pud_none(*pud)) {
> -			addr += PUD_SIZE;
> +			addr += PMD_SIZE;

The right fix is to skip forward to the next PUD boundary instead of doing
this in a loop with PMD_SIZE increments.

Thanks,

	tglx


