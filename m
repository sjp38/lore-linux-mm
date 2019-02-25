Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D7C8C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 15:13:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63DD520842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 15:13:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63DD520842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01C7D8E000F; Mon, 25 Feb 2019 10:13:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0E148E000B; Mon, 25 Feb 2019 10:13:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFD998E000F; Mon, 25 Feb 2019 10:13:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id B8ACA8E000B
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 10:13:34 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id y63so7066766yby.6
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 07:13:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mLOpBX/5F2G/oYRLBjL46VTONps8ne40eaQPtNsdmSA=;
        b=TdWFZAp0BtnKhX//KLaFtFHcr2qBl8JWYk7UtffpIXwIJRFy6lhBM2L5EnsNKut7cj
         Wann07QYXMUkOvIdFWdNiWjH8xuYAZhpTmt39WdyVdo8K0jL45UFRBLXYY6Sike+A0a7
         c4hneeuGuOeCLjEHEg+0VUW0sf5doSffcOw/hq9KflWacx0vOW2gZJYkWAChByoCOH6Z
         ysssXlX1kSqurN3U4FOT3VuIVzoLqcaq9Oc+hgtgr5QFAAZFAgeodU18eeTKM+tzguoX
         CvA4qu1n74ZDcajQ6UUMVU3r7Za4WPdPWZACWO3pUISVrRphMPbIaGQ6l+PAK9ppgD4h
         s56Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuboi1HNgXm1ZL52ZM6vn9EcM9rJsDL+yoCJOH8aN02XDycQg1kp
	5lQvYMcP/dSM3SgnFZJG64LXDUgOLvNuU3+PaqmwRriwBTJoWUn5qgXM/YBUZIbWJgKwU7gHqrp
	fJi5oSVACMeLnZ/iZrRTFRBiUJ9XJIm6m8f09KHwdPgJ347N4f+SWuYfg64PJZSlBTx7zuqT0+6
	Gn1bKR/SLoJXqLO8ho474X8F6ti494aa/z0/Yt2jBReqdNUs+ahrDYqYtO0d0/39cA3IKb7Jh35
	xJ3YdmQ7N9jLpIRUN8wlIt1pjkzeyitk5tYg5rRseX2AcooAoK83PZVSg0NRVCjdtqQ6ltX4+Y0
	MlqO6Rx4nXXxQeX/Suv6jjJInA7mZ4G5JAOB+TzPD9Lhh4cHi3/esCcHlyIKjBu+LP6Z+4o2ow=
	=
X-Received: by 2002:a81:4c8:: with SMTP id 191mr13569014ywe.322.1551107614453;
        Mon, 25 Feb 2019 07:13:34 -0800 (PST)
X-Received: by 2002:a81:4c8:: with SMTP id 191mr13568959ywe.322.1551107613718;
        Mon, 25 Feb 2019 07:13:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551107613; cv=none;
        d=google.com; s=arc-20160816;
        b=ihWLi47U8JBFaMi8hCySXozBs+dH8WZrajQ1agPMAYPkeysWquijCR03knS2o4yiGT
         UtBPm63ej9Hk93Kxtrnm3Ic+k7ioPcuCL/ibGVOsBiJgFKrV+GUOv9PPy//DRpqAx6i2
         N15Vry4rx2vfVlNjdZAhU8Wl+TOOWtpzuAiIIhQ/QzFfdSYeu1Jc77mMJlvLG9Nif0qg
         qc97+mZfg9s0OqDpDyHlGzpmAvpO3CUzx4+scAdlGMQ1ASMrPA3Wi2Viykr9Ko+ttIIv
         FLDJ2oOxqWot2HOPLjx/joB/yEXiOiruSKmDLfF4QA/LrzcoijTY3hsGp47jfmGUkqrr
         TqNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mLOpBX/5F2G/oYRLBjL46VTONps8ne40eaQPtNsdmSA=;
        b=IwiDlhv0VJwpfzACcazn57nB/0JP9FpsgvRRBvsd0/FyPVsro+ZiRW99VIkb43oDQH
         4V+LeoVYRe8jqQmGb8Iblvpo9qHeru3l99pXMyGNyqGpNyt/V+2g8eDlpcB/DGWjN7xM
         779D2Lzr5DoZgVflKGiCV1ZrdOID7Kn3fdKWajGQ/cywEx8rObE0JGMNSsC3b2DuGe1N
         ew63TQiKoimciYv1sUo4J6ENPAVOCOWJLK0ENGdsBvN/E2p4ZEBmxcFCU4fPdBoYXU9y
         bjPEOHT/a4DEBdDhmpalKNDKQbv8921cnMf8wZ5zI+KHV3P1x+XZdubsnm16Q1lhhike
         wInA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 187sor4429154ybv.168.2019.02.25.07.13.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 07:13:33 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IbBIanNK2b3dpslqnh41Yv7lJlDw1srmmXUhrXwKis2NIknvuv1xT3UKPK34/bm430n1JCdCw==
X-Received: by 2002:a25:2044:: with SMTP id g65mr14459634ybg.406.1551107613278;
        Mon, 25 Feb 2019 07:13:33 -0800 (PST)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:200::1:8bb9])
        by smtp.gmail.com with ESMTPSA id g39sm3766859ywk.50.2019.02.25.07.13.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 07:13:32 -0800 (PST)
Date: Mon, 25 Feb 2019 10:13:30 -0500
From: Dennis Zhou <dennis@kernel.org>
To: Peng Fan <peng.fan@nxp.com>
Cc: "dennis@kernel.org" <dennis@kernel.org>,
	"tj@kernel.org" <tj@kernel.org>, "cl@linux.com" <cl@linux.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"van.freenix@gmail.com" <van.freenix@gmail.com>
Subject: Re: [PATCH 1/2] percpu: km: remove SMP check
Message-ID: <20190225151330.GA49611@dennisz-mbp.dhcp.thefacebook.com>
References: <20190224132518.20586-1-peng.fan@nxp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190224132518.20586-1-peng.fan@nxp.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 24, 2019 at 01:13:43PM +0000, Peng Fan wrote:
> percpu-km could only be selected by NEED_PER_CPU_KM which
> depends on !SMP, so CONFIG_SMP will be false when choose percpu-km.
> 
> Signed-off-by: Peng Fan <peng.fan@nxp.com>
> ---
>  mm/percpu-km.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/percpu-km.c b/mm/percpu-km.c
> index 0f643dc2dc65..66e5598be876 100644
> --- a/mm/percpu-km.c
> +++ b/mm/percpu-km.c
> @@ -27,7 +27,7 @@
>   *   chunk size is not aligned.  percpu-km code will whine about it.
>   */
>  
> -#if defined(CONFIG_SMP) && defined(CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK)
> +#if defined(CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK)
>  #error "contiguous percpu allocation is incompatible with paged first chunk"
>  #endif
>  
> -- 
> 2.16.4
> 

Hi,

I think keeping CONFIG_SMP makes this easier to remember dependencies
rather than having to dig into the config. So this is a NACK from me.

Thanks,
Dennis

