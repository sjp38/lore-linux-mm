Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9B13C76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 18:31:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 894FA227C1
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 18:31:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 894FA227C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32EC58E000A; Tue, 23 Jul 2019 14:31:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DF9F8E0002; Tue, 23 Jul 2019 14:31:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CE398E000A; Tue, 23 Jul 2019 14:31:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E6B338E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 14:31:10 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 91so22448049pla.7
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 11:31:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=46tdGvqvoqxUIPeOgCWCop/dIrP81hhCst66zWIrm18=;
        b=ACfVILdWTWwsm9XD1iDM/Jxqu6cfU10gli2VnsPv3Dt7VqJT2CA73JnfB6yuUUy5pP
         pKI4yGL2fPO6zRh2RIfqu7crGxixM2jBQN1VK5+EhpLfF0ncAV84E8KvNFfE4p/I2sY+
         QFPM8ZZyZzuUzykNw6LM02n8JR3Vcgq51d2rwRjbHgKsOcbnxyPcREEExpTCo60QVbjf
         EO5zfDo5ErOtwQCTrrNvo0VDW4h2+18lq5GGSkFtK0TGDShvcI00qzUMMsbHj78PhVfR
         Sz3q6HI3cF6b2LR6imruhbjEaDyW1Yi2b77H+iJpwZS5HNLvJ3UcaJxBK4c4PTLQjjQG
         jfew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW8fBc3L2a9sEVsHLpxi/XpI0P0ZJvb31/pJ8YV19l1tvyXL3ix
	DFLQYEcoY8Ei2Qs/i6sz5acpmOi14F5EQnSMEvs6iDbq7l25ImOv1TWHKnz/AyHCMbkij0G034X
	Zm1X1qtyRqPqc6E74rRkaU9ULcGLEW1olLr59CPmrGcfyLo5AdglPKqYcTHJekMg=
X-Received: by 2002:a17:902:8c98:: with SMTP id t24mr83913703plo.320.1563906670644;
        Tue, 23 Jul 2019 11:31:10 -0700 (PDT)
X-Received: by 2002:a17:902:8c98:: with SMTP id t24mr83913651plo.320.1563906670008;
        Tue, 23 Jul 2019 11:31:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563906670; cv=none;
        d=google.com; s=arc-20160816;
        b=ez7bPS9bKKCI8P90M9Gbp+FWOcvDnb0tvToxc3/TOGMo/9hc3wCNqJ1xIpNIZ6oL/A
         01xYYw262ydHYoj+W77+Kzp4RivnN2FztW7TqZCgmEMsxesiow/rmIYdOeqhiSPdNWrt
         S6ULpYUhCteVAZcAr0SCIPwSWHN3sAyZrs0RRVhXOnGcfCZfsirfl5N4WAJpJjmyBoV4
         9hRM9HODcNLJBJsRN+e48t6bhY7WUG5V18EgA0ktR7A01Epo5fAEo337DEo/pHm/wxNP
         PzKnLxAeTiVdEq8DQgYM83/qe4P+V7HNgWbiPO5dc6BobYP0OCcWmMhJmOw6Te+1O/E8
         zwDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=46tdGvqvoqxUIPeOgCWCop/dIrP81hhCst66zWIrm18=;
        b=oB0ovWBPJVJfZDtm46NBTZIuBs5YNFmSNEyP6rLyzSX+sMzkeN/toTRnBvi6UrjykS
         sGaJ/lDHX13CAucfLLuml9NvPGX4NhmLZisc/jpC1caFn4wyiGCMazF4HuTNQTK0pwaF
         uLbBaf98dvqsWPA4/Q3gwAfmq6mNIattNx4HzaN16b7hbR+oGRj88cMFhgrAFhR/A833
         cRfAUJyF00S3t04pA/SA4zAlsc4UiOhn/FOxPD+F7awBGHcerjoqJYl+rDA0iCUw31+s
         YJ/mxLLIvIheEgzLEGQ11zUk3Lmcmz+3Kn44jVQuy3lEMkgmVTg1VAmJzGCt25QmnpT7
         dAFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id fr3sor54392743pjb.14.2019.07.23.11.31.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 11:31:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqxo1DzIE0Lf6y7298mhooH13TsAceAasGh822+s662eZYiSCxHuKtu/K9AIM0ZUgGMR0qZCOw==
X-Received: by 2002:a17:90a:d151:: with SMTP id t17mr82706672pjw.60.1563906669597;
        Tue, 23 Jul 2019 11:31:09 -0700 (PDT)
Received: from dennisz-mbp ([2620:10d:c091:500::cff2])
        by smtp.gmail.com with ESMTPSA id r1sm41232037pgv.70.2019.07.23.11.31.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 11:31:08 -0700 (PDT)
Date: Tue, 23 Jul 2019 14:31:06 -0400
From: Dennis Zhou <dennis@kernel.org>
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Cc: dennis@kernel.org, tj@kernel.org, cl@linux.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [PATCH] percpu: Fix a typo
Message-ID: <20190723183106.GA85597@dennisz-mbp>
References: <20190721095633.10979-1-christophe.jaillet@wanadoo.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190721095633.10979-1-christophe.jaillet@wanadoo.fr>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 21, 2019 at 11:56:33AM +0200, Christophe JAILLET wrote:
> s/perpcu/percpu/
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> ---
>  mm/percpu.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/percpu.c b/mm/percpu.c
> index 9821241fdede..febf7c7c888e 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -2220,7 +2220,7 @@ static void pcpu_dump_alloc_info(const char *lvl,
>   * @base_addr: mapped address
>   *
>   * Initialize the first percpu chunk which contains the kernel static
> - * perpcu area.  This function is to be called from arch percpu area
> + * percpu area.  This function is to be called from arch percpu area
>   * setup path.
>   *
>   * @ai contains all information necessary to initialize the first
> -- 
> 2.20.1
> 

Applied to for-5.4 with a slightly more descriptive title.

Thanks,
Dennis

