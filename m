Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB435C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 14:07:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 314C72175B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 14:07:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gQqOxS/4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 314C72175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=roeck-us.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D2528E002E; Thu,  7 Feb 2019 09:07:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 682A78E0002; Thu,  7 Feb 2019 09:07:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 548F28E002E; Thu,  7 Feb 2019 09:07:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14B038E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 09:07:35 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id w17so6471781plp.23
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 06:07:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:subject:to:cc:references
         :from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=KbX6XmglqS34HBQmaEvNBhlf/+2fvBOoS5l5WH2o2d0=;
        b=Co9Lb+FnUjCsGfXtKuVPhE+A+SKWpDvIOCRVWvjB5GnkH06xX1oZ70oC9DvDWIgu/E
         kOc4QHWNdcfSTOYzbrnP6Btc6yEViQpNheEPNNeHO/Z3pwG8F+BrM8TzllQqbVfbHlCE
         CP9uhhe01dlU05C+XQmQi2MVI5LYDtZ01u2N0uebOQYM8iOi2gvNQGkykz6oHQmQsaLv
         KPXHLaIzJL/gEPuRvFP4lzvcI3hzpAYbcaA2d7aJzsfFbz15/Dt3+GUoVfF4qM/G95NS
         s1XS2UDpkkS+Pw+/8lQoRT6JLsBykoqrAiIWHFNVNVGsKUg5pyg106OApv66pAXWTrOm
         +NUw==
X-Gm-Message-State: AHQUAubt2h51y3bRfXBprnU6oVrINfzEKb1YhS+fDoYhtF3IzvWhrkpj
	jIk6i2elq3e7fY2QL6tOBBTtVTojtn3SfG5duXJpWxHixocHRCcTiKbK8QmH6Kl0AgIT9bblPFc
	nnjS8hQ5OdaS8ykXmiKdrv+ZEZjd9dTdgeJDOeElBxwErEQ+x6touCvg6GJkhBG7Oojyf+HtHZy
	qltLyi6o6RWaDXLf+HxAzI30f33S0by80CAypVJMrvKHQCpLVRZ3RfHLSgovAgA8+mjHmkWl0Xa
	i3onkOMOKzOELa7bPynAjb6/WYBoqYAEZtCLvEYf8ZK//nbM2RuYKop9Iw4BKDxH+PUkA5wpD4i
	SWTJcE0aR2N+dMumm/Ct9WpfxdWYgaYl4JsjB98P/nIZWbLUcVofrXNEbJwY+hKwDHfIdn0HfQ=
	=
X-Received: by 2002:a17:902:5a8d:: with SMTP id r13mr9123819pli.190.1549548454724;
        Thu, 07 Feb 2019 06:07:34 -0800 (PST)
X-Received: by 2002:a17:902:5a8d:: with SMTP id r13mr9123699pli.190.1549548453446;
        Thu, 07 Feb 2019 06:07:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549548453; cv=none;
        d=google.com; s=arc-20160816;
        b=J8UWpvlbh9wPpQSS2H7+iIUJWjlY43OOgHNXR3SoWDwhsu7SPQNTDZ4wwN9BeToH6x
         HmEKOc0VGq6XSn2hyASuL6eBbTpzipfQXNvh+SWTAgPf/dJAeyuCcVRUBY2JG3T9RUZx
         q2IETrGtJi4ZKsuuR1rTLzT/SpwvNmSAbjz428PXJubBbq6PV6Zi4Wkda69jV32UHQf1
         giVIwe7ahsfdflVq/H6ZmYb8/Mb1AbscEolJDy1w72iH+QJls0qqtgOht5K+Wvg11J3U
         Y3My5gf6nbHOWdhyVGAz4ZN0MVDMyZS1ANLO5eBKLXQlgjbPqDU4qA6DK5U1uQBdA1Mg
         WSUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject:sender
         :dkim-signature;
        bh=KbX6XmglqS34HBQmaEvNBhlf/+2fvBOoS5l5WH2o2d0=;
        b=TonKGscG2/2GHm59+HBm2U8oYdvXOwpNNR3CuD2z2HM4/vwfnxo9Joxc0mEYeHPlrt
         x3jr0PwzCnNaqS7c2LuqJXUVFNndH5XGwqqLPfFXw3T1Ez2LdBMnqY9wKsS1JE92gZsv
         stOraIxBWSog8sygrXQesgUePBqRToRy+xPi1mz2g8SE228oJAOqQHNqG5rEzU02zOGl
         qEs3/6XcgpNpC2CbaJw3VItsbXbqhhXDsvHDgq8PCoParGpgmiCkTh1MBqlyiY8qvsEX
         U2Tb1i7OjWmsgGR8Mxi1dHAsv4C0f2b/PEziuuqFZn6uZ/5A6M5DygwxIHKc6AoiQkLm
         0i6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="gQqOxS/4";
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p186sor13768366pgp.79.2019.02.07.06.07.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 06:07:33 -0800 (PST)
Received-SPF: pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="gQqOxS/4";
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=KbX6XmglqS34HBQmaEvNBhlf/+2fvBOoS5l5WH2o2d0=;
        b=gQqOxS/4tuEI9GIBDfGk68GsQV8FS8aDvwGEj89CoF7oqN5x18d9PKtZg3/Gdarj8u
         UrNaaNyIIIgx5eTVAR/ZdIcen42/3zlCrdJd/rMna9u9pAbgD36P1TULc4FmMyFA76nU
         0P2m15Rxh9puSQuB9TAlRupnhQvjO+B14qd0atpeK/rKwSPMJ4n1hcXS1DqrxQ327etD
         VQlHi4Y1ragLgBKUtXafCorh0yjvEiylR2xRGG9I4HVRse3RvDDqfqKiPenZZELbl4SJ
         hKmCpqfVNPWMRN0KkQclsaLjYJa3EtJ6m2QrrIujhtXbtBynXJ6bfXzBo2udH1JpWY6O
         JRdg==
X-Google-Smtp-Source: AHgI3IYO6mzGpGwEPrXnnp1P8FWF+2hbsbrcsM4aEN+03xBjKG9pmu8Fotj5oATo1lQ9ZjZFMBGvrQ==
X-Received: by 2002:a63:698a:: with SMTP id e132mr1617385pgc.136.1549548452718;
        Thu, 07 Feb 2019 06:07:32 -0800 (PST)
Received: from server.roeck-us.net ([2600:1700:e321:62f0:329c:23ff:fee3:9d7c])
        by smtp.gmail.com with ESMTPSA id a70sm8372646pfj.7.2019.02.07.06.07.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 06:07:31 -0800 (PST)
Subject: Re: [PATCH] mm/swap.c: workaround for_each_cpu() bug on UP kernel.
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Metcalf <chris.d.metcalf@gmail.com>,
 Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org
References: <1549533189-9177-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
From: Guenter Roeck <linux@roeck-us.net>
Message-ID: <344b9779-2866-5c0c-6155-f03fff38f8c9@roeck-us.net>
Date: Thu, 7 Feb 2019 06:07:29 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <1549533189-9177-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/7/19 1:53 AM, Tetsuo Handa wrote:
> Since for_each_cpu(cpu, mask) added by commit 2d3854a37e8b767a ("cpumask:
> introduce new API, without changing anything") did not evaluate the mask
> argument if NR_CPUS == 1 due to CONFIG_SMP=n, lru_add_drain_all() is
> hitting WARN_ON() at __flush_work() added by commit 4d43d395fed12463
> ("workqueue: Try to catch flush_work() without INIT_WORK().")
> by unconditionally calling flush_work() [1].
> 
> We should fix for_each_cpu() etc. but we need enough grace period for
> allowing people to test and fix unexpected behaviors including build
> failures. Therefore, this patch temporarily duplicates flush_work() for
> NR_CPUS == 1 case. This patch will be reverted after for_each_cpu() etc.
> are fixed.
> 
> [1] https://lkml.kernel.org/r/18a30387-6aa5-6123-e67c-57579ecc3f38@roeck-us.net
> 
> Reported-by: Guenter Roeck <linux@roeck-us.net>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

I agree with the fix/workaround. I tried a complete build with fixed macros,
but that doesn't work because (at least) x86 assumes that the "mask" parameter
is _not_ evaluated for non-SMP builds - arch/x86/kernel/cpu/cacheinfo.c
passes cpu_llc_shared_mask(cpu) as parameter, and that is only defined
for SMP builds.

On the plus side, I did not find any other issues, but that doesn't mean
much since various build and boot tests in -next fail for other reasons.

Acked-by: Guenter Roeck <linux@roeck-us.net>

Guenter

> ---
>   mm/swap.c | 5 +++++
>   1 file changed, 5 insertions(+)
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 4929bc1..e5e8e15 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -694,11 +694,16 @@ void lru_add_drain_all(void)
>   			INIT_WORK(work, lru_add_drain_per_cpu);
>   			queue_work_on(cpu, mm_percpu_wq, work);
>   			cpumask_set_cpu(cpu, &has_work);
> +#if NR_CPUS == 1
> +			flush_work(work);
> +#endif
>   		}
>   	}
>   
> +#if NR_CPUS != 1
>   	for_each_cpu(cpu, &has_work)
>   		flush_work(&per_cpu(lru_add_drain_work, cpu));
> +#endif
>   
>   	mutex_unlock(&lock);
>   }
> 

