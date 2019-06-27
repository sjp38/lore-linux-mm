Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7966DC48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 15:53:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 269EA2063F
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 15:53:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="XycpPK1C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 269EA2063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CF226B0003; Thu, 27 Jun 2019 11:53:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87EDC8E0003; Thu, 27 Jun 2019 11:53:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 746B18E0002; Thu, 27 Jun 2019 11:53:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 400936B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 11:53:30 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c17so1812899pfb.21
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 08:53:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=IB0Lsqqxe3Za1ul6K6Pq1h1ixj5UtpjRHMz7zj1j1YM=;
        b=B9FY3s8ODwzL09GxlmMTQlA41zl5hRK/dfog4D+MKiE5+O5qV+nBHcxdE7fp0fSyRL
         hZGAJLTl8XanVWh1sK6183bYWhAeGgR+HhhTWV/lcWYFceVojGyKmytEXkzM5lzv3afU
         S7PGPUIjH+PzgGWNv528I8XkaNzZrKceNzggJrZrAu1XmbqxfaCE1nimtvjAE144y10f
         khXI3scWoDG0H2beBO1txIrOF5YF0rMZ/nISJFbUHvu6/ShBhmADMu4YAAqsmPEVNIEm
         UPLbd2Y8vceEeNXejF6QOXuSmFpcXj2fthxR2t/tvqnFtnzbWA6sL6sL/tI3W8Bp003L
         malw==
X-Gm-Message-State: APjAAAXUB0ViSHRxeiYKHcoxvOVa8XyAAHQ6/PrXdOfmR3jxOvrh20Vs
	RamWCTRk8j/A/uoHlaneAcvYFFytQKwxU26nx39YE3czIvYAlJZp+Py3Ch8mYjMi33g6l6D1m/8
	FCWusJ5bxVmPH8bl30vXUILEFosqTdMaA7K2bPa+bPoSJkyMpOr3uI7O1N61DxoSSTQ==
X-Received: by 2002:a17:902:684:: with SMTP id 4mr5513067plh.138.1561650809793;
        Thu, 27 Jun 2019 08:53:29 -0700 (PDT)
X-Received: by 2002:a17:902:684:: with SMTP id 4mr5512978plh.138.1561650808825;
        Thu, 27 Jun 2019 08:53:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561650808; cv=none;
        d=google.com; s=arc-20160816;
        b=T2rMLv+P0xyLP9J/5dLmiYFrq+G09cTVoxRkqCicTyxL/wHhy8/BSvPEERSwyiH40x
         5QgaOXa/VTloT/imWveLIWYA3yWewHdIv1LZYRZiRO0pI8nuId/+jHaFpalNjfNZ0jHZ
         abD7Vq/W/V6odgKyRhbeG4pZJXFQOkUGRPdmEz86gogTFFGSgl1IZ/xZVqZAFOrsWJhT
         fGeWb0PLx/Mu8h2f4GczXLqeK0FHZ9ceZafVoa75Qj5KqDteffK1ChObHyr44CHgdHUK
         Up2J0O2NhjxG+Wq0hoRdoQIYa0EGmKjEZisS+jmjsGEgXTJatV+EIOT6jkyJ7zxpC6J1
         lRyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=IB0Lsqqxe3Za1ul6K6Pq1h1ixj5UtpjRHMz7zj1j1YM=;
        b=pG39eamkj5hqPGKiQFTZHHCMk71JgZcKJEfTHrqjhZglNk4Q/bcW6frO113gW9aqJ2
         dxyQbGpRB93Rj2CF0gbFPWfUIVZZ1oyY1DbtkHITcT8/lb+BL7L44b/7wx2zmhq86H2b
         M/JfK4hce6QCoLWrhWqGAKbv/05lyrRkVPF5GfYpeCzfvN1e9WAaA1D2FT4z6mnGzlGW
         3uqpeaG7eUnXrpR8reUpXDTXZzOzJ760Ei/MtlEp5EZ55BWaMh+HxZVVhsO8eyaKuELA
         stMw4arnRvJaoS3RLPAOmv4JNwBgK2l7CqVUzY1af62xLct7ClcI8P8xwo82LRuw45Jb
         ynTw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=XycpPK1C;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cu14sor6049975pjb.27.2019.06.27.08.53.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 08:53:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=XycpPK1C;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=IB0Lsqqxe3Za1ul6K6Pq1h1ixj5UtpjRHMz7zj1j1YM=;
        b=XycpPK1CI5JMKTpIwljMWofpXCFUnjuMSbTxvj3tSwU+N6pesTsiguF6tXP2YOv/RK
         0SV0Pc++fA7yQT4iMOsmk5EaUwppi2O0YX2prmAFBNEKsX2gYDmiJ5Ry7PHA3n5rVq31
         kbGxWSIcc0U2t95vEEjJWLkRnyUBsNj/UQg2A=
X-Google-Smtp-Source: APXvYqzyQ8VhCfbGmiP5t6hfyuPjbzTLkDZwV/chxJREBt2vwgawqo7kscJ4w+dvLcJmYjU/wFp1aw==
X-Received: by 2002:a17:90a:ad41:: with SMTP id w1mr6845225pjv.52.1561650808121;
        Thu, 27 Jun 2019 08:53:28 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id b8sm8013075pff.20.2019.06.27.08.53.27
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 27 Jun 2019 08:53:27 -0700 (PDT)
Date: Thu, 27 Jun 2019 08:53:26 -0700
From: Kees Cook <keescook@chromium.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Florian Weimer <fweimer@redhat.com>, Jann Horn <jannh@google.com>
Subject: Re: [PATCH] mm/gup: Remove some BUG_ONs from get_gate_page()
Message-ID: <201906270853.CB6DA7BC8@keescook>
References: <a1d9f4efb75b9d464e59fd6af00104b21c58f6f7.1561610798.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a1d9f4efb75b9d464e59fd6af00104b21c58f6f7.1561610798.git.luto@kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 09:47:30PM -0700, Andy Lutomirski wrote:
> If we end up without a PGD or PUD entry backing the gate area, don't
> BUG -- just fail gracefully.
> 
> It's not entirely implausible that this could happen some day on
> x86.  It doesn't right now even with an execute-only emulated
> vsyscall page because the fixmap shares the PUD, but the core mm
> code shouldn't rely on that particular detail to avoid OOPSing.
> 
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  mm/gup.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index ddde097cf9e4..9883b598fd6f 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -585,11 +585,14 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
>  		pgd = pgd_offset_k(address);
>  	else
>  		pgd = pgd_offset_gate(mm, address);
> -	BUG_ON(pgd_none(*pgd));
> +	if (pgd_none(*pgd))
> +		return -EFAULT;
>  	p4d = p4d_offset(pgd, address);
> -	BUG_ON(p4d_none(*p4d));
> +	if (p4d_none(*p4d))
> +		return -EFAULT;
>  	pud = pud_offset(p4d, address);
> -	BUG_ON(pud_none(*pud));
> +	if (pud_none(*pud))
> +		return -EFAULT;
>  	pmd = pmd_offset(pud, address);
>  	if (!pmd_present(*pmd))
>  		return -EFAULT;
> -- 
> 2.21.0
> 

-- 
Kees Cook

