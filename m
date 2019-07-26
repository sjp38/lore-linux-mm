Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BCC9C76190
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 12:09:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B4EF229F9
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 12:09:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B4EF229F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 959766B0003; Fri, 26 Jul 2019 08:09:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 909C06B0005; Fri, 26 Jul 2019 08:09:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81FEB6B0006; Fri, 26 Jul 2019 08:09:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 379F16B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 08:09:56 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id s18so25560048wru.16
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 05:09:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=ujp4drtW9kIvLMDisWyKepvmJXNTYAyAgOb5yWKMd+Q=;
        b=DNL1M3RQsR6xmJdiplY9W5tMimzSYoJc8AjJjkVtGThF56yDaoFTMo00DicCAVnlQg
         N9nU/7BTVslNgDWGxRJbiREb0SLRjSCNyJ/xKo4NDuKKjN4yvYcZnCmJ5spNKuqPLOjv
         QejXwriElAudWj2TZ5DlvjhUo5xhAXSoVCnANLu20rcIqJ6rqvuqLtLhOGrEMyD9xsxy
         k5U3cOXsbmh/g4Sv2GZdap4RLOjTr0HYzOrNZJwlHG/bLs758vqzDUQFMbrJ3qaw8sip
         8SpCgzTHaSQlHOvgLlmu8YR2NqOexxe4m/LXTl/6GeN5zbPzMdFFkvQNIU7yGb4tjuQ3
         5FpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWyPRdtI250ujrvMTe+VCdTSNwC0LQjv0nC/TxzMLiPaB3Fg66R
	CTzMmEL4yfRvPSCryaqPRdq/LhWj4EoJC3OLwdOsJalwl96uuefwl8DNVOxnFoq8nLKc0m9LZPE
	8l4TiNWKSc7dJi5Q0tdkCKlql2/CzTfQqlnIjb3t7laqyIvyBS8QB2z/ANeQ0i/b7Jg==
X-Received: by 2002:adf:fe09:: with SMTP id n9mr106454041wrr.41.1564142995821;
        Fri, 26 Jul 2019 05:09:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPtI+5Zi0iZXR5YjIMlM4yFXG3AArpkzfpaQutEicLt9puYLTVUEBKcgAvhioDnmIUPKYB
X-Received: by 2002:adf:fe09:: with SMTP id n9mr106453979wrr.41.1564142995080;
        Fri, 26 Jul 2019 05:09:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564142995; cv=none;
        d=google.com; s=arc-20160816;
        b=QvbL0sDga+sVGem/eGsuDRtc6WtQ1aCesZMp79nI8v2PhPb0HVKBFdmzm1ikbaAIgK
         aVoC/tqF052XsKqlgIFfM0auln1wHwMDVrGdpbxvCRHH75ZzgawEaBrEfRUoNdw+GyOC
         VEHUe8BeGQ/IEMbZRoea2WpWa0bSy15d5hnfis2rjj61UjFJygyCu757uxjC9gGE6d+o
         wBjow8cbLAkVE4KU9inKKuabn3eCqwrWPHhdqivqvCIJsMHsZFpAyDmBkQ33fvaUc5lY
         B273hjTJF3Qmm4Jxa/zCtF71Zg1H13MCjFijE4WQSFEgcLdI4pI2+uDqX3yMVhqg4iQ/
         Ltew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=ujp4drtW9kIvLMDisWyKepvmJXNTYAyAgOb5yWKMd+Q=;
        b=aouEVvdxIGeBLCJKi3He0A5YNjbpgqFZekC4847NtzSbku9/wJihknT8avX0HBik/M
         i4fc81yDB4qZWRKex+ByRrUr5pvgQOs9+ZKK1pcrHnObeKONirOxjYTeQpCs6YFfOtD7
         E8hJdjV9SH03PR17eR2AMztwjoEF2LQRR6dVFIS0/3zRuzCK2hHXV5xKNJyziDeIapDI
         fMOo22CFnPV4yrQxFa4bjIJHX5cMc6dpu5MbxEr6pGUX37Fci35wlQVwYcxgnUssxYsF
         qlicv+cGPCjwXQsn8rOSmDpO5X1XaRv0PW1NJykeW0AxTV9cda+TN6pgmKeBumxh8AWV
         Nbtw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id t16si14956071wmj.164.2019.07.26.05.09.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 26 Jul 2019 05:09:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef1cb8.dip0.t-ipconnect.de ([217.239.28.184] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hqz2l-0001Ny-AA; Fri, 26 Jul 2019 14:09:51 +0200
Date: Fri, 26 Jul 2019 14:09:50 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
cc: linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, 
    linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/7] vmpressure: Use spinlock_t instead of struct
 spinlock
In-Reply-To: <20190704153803.12739-3-bigeasy@linutronix.de>
Message-ID: <alpine.DEB.2.21.1907261409260.1791@nanos.tec.linutronix.de>
References: <20190704153803.12739-1-bigeasy@linutronix.de> <20190704153803.12739-3-bigeasy@linutronix.de>
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

On Thu, 4 Jul 2019, Sebastian Andrzej Siewior wrote:

Polite reminder ...

> For spinlocks the type spinlock_t should be used instead of "struct
> spinlock".
> 
> Use spinlock_t for spinlock's definition.
> 
> Cc: linux-mm@kvack.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
>  include/linux/vmpressure.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
> index 61e6fddfb26fd..6d28bc433c1cf 100644
> --- a/include/linux/vmpressure.h
> +++ b/include/linux/vmpressure.h
> @@ -17,7 +17,7 @@ struct vmpressure {
>  	unsigned long tree_scanned;
>  	unsigned long tree_reclaimed;
>  	/* The lock is used to keep the scanned/reclaimed above in sync. */
> -	struct spinlock sr_lock;
> +	spinlock_t sr_lock;
>  
>  	/* The list of vmpressure_event structs. */
>  	struct list_head events;
> -- 
> 2.20.1
> 
> 

