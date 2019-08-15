Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2E47C31E40
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 10:02:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2CB02171F
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 10:02:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2CB02171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E8B56B026D; Thu, 15 Aug 2019 06:02:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 59A066B026E; Thu, 15 Aug 2019 06:02:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 487946B026F; Thu, 15 Aug 2019 06:02:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0147.hostedemail.com [216.40.44.147])
	by kanga.kvack.org (Postfix) with ESMTP id 211C16B026D
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 06:02:23 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id C0E7E181AC9AE
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 10:02:22 +0000 (UTC)
X-FDA: 75824222124.19.jelly99_318d5feb95353
X-HE-Tag: jelly99_318d5feb95353
X-Filterd-Recvd-Size: 2316
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 10:02:20 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 60E7028;
	Thu, 15 Aug 2019 03:02:19 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 9271E3F706;
	Thu, 15 Aug 2019 03:02:18 -0700 (PDT)
Date: Thu, 15 Aug 2019 11:02:16 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH -next] mm/kmemleak: record the current memory pool size
Message-ID: <20190815100215.GB9352@arrakis.emea.arm.com>
References: <1565809631-28933-1-git-send-email-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1565809631-28933-1-git-send-email-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 03:07:11PM -0400, Qian Cai wrote:
> The only way to obtain the current memory pool size for a running kernel
> is to check back the kernel config file which is inconvenient. Record it
> in the kernel messages.
> 
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>  mm/kmemleak.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index b8bbe9ac5472..1f74f8bcb4eb 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -1967,7 +1967,8 @@ static int __init kmemleak_late_init(void)
>  		mutex_unlock(&scan_mutex);
>  	}
>  
> -	pr_info("Kernel memory leak detector initialized\n");
> +	pr_info("Kernel memory leak detector initialized (mem pool size: %d)\n",
> +		mem_pool_free_count);

I wouldn't actually call it the "memory pool size" as I see the size as
a constant set at config time. What about "memory pool available"?

(even this one is not entirely accurate since we have a
mem_pool_free_list but I expect such list not to have too many elements
at the late_initcall time)

If you change the printed string:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

