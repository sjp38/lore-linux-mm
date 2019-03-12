Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DBD2C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 08:24:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58DBB2147C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 08:24:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="CIHutHnn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58DBB2147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E02008E0003; Tue, 12 Mar 2019 04:24:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB12A8E0002; Tue, 12 Mar 2019 04:24:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA0B28E0003; Tue, 12 Mar 2019 04:24:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id A0E868E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 04:24:42 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id w19so1230477ioa.15
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 01:24:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=rGAiRbtq+VcPEjfZc07majMhQMIey9VMYwpLoxf4dbk=;
        b=o66kPTV13wKoQwKmPYC+Iv2LggWFjfU6nJcMQbb4HjtpYA6VTyA6PpHa0IqfoLsnee
         +w/XY6g1EOR8oKlaH7znM7sGm7/gPVb1YuQ/xRceyi9FZxab2BcgmFpZiIT4DJZn04uH
         TKJ+/cSQkB/k91WITQ8ch3R3tpFLTOWFia/QbPly+5wlIBS2oXl/XO+7YblR6/5p/aJv
         EX77HE/HIOOIIsgXyQPAu/Ggon4xRBs5Xs4Z6iP18+26IBhokHmC6RsmAQXViefLxQoX
         BIOvxNHjRsoiZ8pfJ/KZR2Vbdyx4tOmYfgxwfx5LpTM9l0bMRsBTGY3N2JgOnXF8oClU
         9gcg==
X-Gm-Message-State: APjAAAVu9Ao5ca5QpwOYinJ01C48sWaZJDrmiA03QGV8e9b6SBKISA0+
	gbvjjcc+yY7JcsEsLGp7jE2TQVVoHQPpUyQMQlV5Hm3QImAm3/zjcF6YGPHmp5AJoPEkpIHYT3O
	L1Y4b0+/XBRiRav7NrADqgvc0rQNkwHiyNm44clGTqAksdMYAwyXoPDT66tRe6msZYg==
X-Received: by 2002:a6b:dd16:: with SMTP id f22mr19203498ioc.148.1552379082288;
        Tue, 12 Mar 2019 01:24:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3U2tfADiifKar1mMM6E6AQ0QxTkUz5zxtl9eZMPxMPivxe3E5nsOamsM3c2Df/8nWEZib
X-Received: by 2002:a6b:dd16:: with SMTP id f22mr19203476ioc.148.1552379081508;
        Tue, 12 Mar 2019 01:24:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552379081; cv=none;
        d=google.com; s=arc-20160816;
        b=J+TXm+QYriPLaajEkfFCfiYPOMIVGgtBDIij5bpyfjK4piqp+nWt3dUcj/zBuk7qnL
         da3zmL3/Qminhi1EPTxYo9k0TNbBnsUdVSaq9Pp10C/3WJC5q69hYsbhD5n2E8VtGgdq
         qPMBgaRNrqm90MRdM81xcVBGLaiwZ9tMNsiMylWW4QXNBkNMtT2McX3aVku2DLJi3YQu
         /cevgSzVfvlXG09Ox11xJWI44BeoKgUiPK7U9rAwnn2E4gBtkkcXIwSKscyGr/k0Ilfx
         rVUZG66O/za+joD1294+Wudqrr7EHil4FIUn9WRt4HsJnxxxDeVy809UaOiinAK6CTVB
         0jsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=rGAiRbtq+VcPEjfZc07majMhQMIey9VMYwpLoxf4dbk=;
        b=WKtNKBU2k5jt7srLkq2VWz2ZnBBgXZ1HwrXUZ/tCaAakw5x9fXLupD+eeXun7b4jDp
         RNl03P/oXT4yMgvmDMD7f/uKIgCysBhpcRSmFrybaNq+XYsTLBGgSdqxbistg8QNPNvM
         skDoKLaGQ4yOxxVU0gjHzNfXupQ1DXhBGn8Mi+NROUeu0fHtD+IfM6kguGmluc9YFnWr
         QNo7G4Nvoe5iRsXw6qJCx6iAexKnjM72LilBOvD7iU6TmjEfKCas33H2L4PAKH4Nnpwj
         2SzeVB+xDUEXNzVZyER2LyKaE+Mr6iCB1+zzHA/ZglTBadzdFgxaKdDoEXhImZRZg4W3
         76Rg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=CIHutHnn;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id h6si3897116iog.159.2019.03.12.01.24.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 01:24:39 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=CIHutHnn;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=rGAiRbtq+VcPEjfZc07majMhQMIey9VMYwpLoxf4dbk=; b=CIHutHnn4giEGHZb2Mti4DCts
	IvV+lt+bmunxRAZpD0WJgZ3GKsjdkRqQpzWE+YitroqCrEfGSs/vaarJRTpOhQS+mODGbdHUEPm2+
	3Nx9Gr9bdVYJTZ7X8u0FGVATNrmAC8ievM2IgYcFcvHQCS3s0jej3EMrUFf6ZRLyAfkfutmOoawhu
	8WJp//U18p+3zw/kRmCEca9PYqR88OziKuRRgTlJYhkwI7iK2dJ5+sX5Aok6mCxLl6BuvzWZd+CdO
	qYwTW5QBk0O/x+9pUJrULRfRKOLWm/l6GvggKPK87YL2QFguOxUzxErcrUa1N4WVv/0YX5NIG9ZSr
	LGMOhF/2w==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h3ci5-0002Lu-NF; Tue, 12 Mar 2019 08:24:30 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id E7F3F20297BBE; Tue, 12 Mar 2019 09:24:25 +0100 (CET)
Date: Tue, 12 Mar 2019 09:24:25 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] mm,oom: Teach lockdep about oom_lock.
Message-ID: <20190312082425.GH32494@hirez.programming.kicks-ass.net>
References: <1552040522-9085-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190308110325.GF5232@dhcp22.suse.cz>
 <0ada8109-19a7-6d9c-8420-45f32811c6aa@i-love.sakura.ne.jp>
 <20190308115413.GI5232@dhcp22.suse.cz>
 <20190308115802.GJ5232@dhcp22.suse.cz>
 <20190308150105.GZ32494@hirez.programming.kicks-ass.net>
 <20190308151327.GU5232@dhcp22.suse.cz>
 <dd3c9f12-84e9-7cf8-1d24-02a9cfbcd509@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dd3c9f12-84e9-7cf8-1d24-02a9cfbcd509@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 09, 2019 at 03:02:22PM +0900, Tetsuo Handa wrote:
> @@ -1120,8 +1122,13 @@ void pagefault_out_of_memory(void)
>  	if (mem_cgroup_oom_synchronize(true))
>  		return;
>  
> -	if (!mutex_trylock(&oom_lock))
> +	if (!mutex_trylock(&oom_lock)) {
		/*
		 * Explain why we still need this on the fail back.
		 */
> +		oom_reclaim_acquire(GFP_KERNEL, 0);
> +		oom_reclaim_release(GFP_KERNEL, 0);
>  		return;
> +	}

	/*
	 * This changes the try-lock to a regular lock; because .....
	 * text goes here.
	 */

> +	oom_reclaim_release(GFP_KERNEL, 0);
> +	oom_reclaim_acquire(GFP_KERNEL, 0);
>  	out_of_memory(&oc);
>  	mutex_unlock(&oom_lock);
>  }
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6d0fa5b..e8853a19 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3793,6 +3793,8 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>  		schedule_timeout_uninterruptible(1);
>  		return NULL;
>  	}

idem

> +	oom_reclaim_release(gfp_mask, order);
> +	oom_reclaim_acquire(gfp_mask, order);
>  
>  	/*
>  	 * Go through the zonelist yet one more time, keep very high watermark

these things might seem 'obvious' now, but I'm sure that the next time I
see this I'll go WTF?!

