Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0349C76191
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 23:51:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 879F422CC2
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 23:51:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="thhM7y8K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 879F422CC2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D3236B0005; Thu, 25 Jul 2019 19:51:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 060406B0006; Thu, 25 Jul 2019 19:51:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1A1E8E0002; Thu, 25 Jul 2019 19:51:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A43926B0005
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 19:51:18 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id t18so21756061pgu.20
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 16:51:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=dnWpmDquviv2T4rhOaKwfYrYkAK4O04dPwOKTktYaOs=;
        b=SMCN8WWoq1w8VT4PsGWWEYw1tFZuow8NAGQtGlxFAgg8M944A4K/qAhd+DazNCMaUe
         jWMvedy0LEKRjpF8E7xUU28b62jEPfqqkjmoEiPC88qGKwONPiq5zgx1KYQvUeVwiFth
         CpQLlLZ2yqF5FWEnkZR17Cqo2JEw2s2Rfw+fxJaA0osfA2mgMO9L1VN3tPe5sytnLA5R
         nsS7p+Nz4kC16s1l0Jd292HarmM5LJQXtSokgVipcMONkuPPBTAHoItdVuFPKzWaUNAc
         uuFE3D/KYS8pCn8j3Nu9nBOWOU54GJ0mHc531DgU62niIDdG3PxboJgnjEvTrcUANGWs
         xMzQ==
X-Gm-Message-State: APjAAAVzCj9MjSgnwiIlJxsrV3kYV/v7cMnnSOIioNGfl5RVBsJcdSp4
	Ad3R4LNJ34svk0HCki85O72c3/dw0kJCFIOXvoonOmKtcJBoCfp72jLH2wEhToHoX56pF4DUSIE
	NfE9nzjuRociHoZ14Hm8X0nzZfO0Vw9qqA30DiplbJKu1+0sy5nfZMGyV8WL3386O+Q==
X-Received: by 2002:a17:90a:cf8f:: with SMTP id i15mr43701927pju.110.1564098678286;
        Thu, 25 Jul 2019 16:51:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbmt3jLciyKj9n9jraRgZjIxpQ8YoqtAkis8v6QAFBx8mfnIKQ8BylqodjvB2HvI3hZezL
X-Received: by 2002:a17:90a:cf8f:: with SMTP id i15mr43701902pju.110.1564098677621;
        Thu, 25 Jul 2019 16:51:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564098677; cv=none;
        d=google.com; s=arc-20160816;
        b=Fy1sNgW7MxwgPT425xfyAULuobNve0HYvwBaPbmEq9chKmNM07rfa23qyH5RqkC4Jm
         xhFrDsnqcpsxH7bHz9gHmll5JP6PDrJjro4pHp+bSB877SG1wXfDaswm1s3EUe8NTKJp
         vyXiYttmNmo2kf9IFl4q3FOT3iCa3V6Lk1JG/OvEcV9iV4q1RiM3ax0D7iXB3nje8Uzj
         b6nltyr3kQHjBJbttZreaTny5qmlfZtBTxVon4YrS/38I048lQGvvexY4tSl3DaTZAji
         ae88mlsBM+zrt/Qm8jvguXDA8oPh3xdmlVBkHaDM6ePwzjTQZxOi6kb0znEv0XFLKJVT
         FYFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=dnWpmDquviv2T4rhOaKwfYrYkAK4O04dPwOKTktYaOs=;
        b=JlIbIUcN9l5UfC0jdwZRPDTps0j+YTMjHeUmSpZkOXU+pbVrWMfc4bqVqPMxF8M59A
         suqX/L+U10TijjV1aqrIbAhyDCvARLTmP5jaYXbtqnlQVj9dyEZD8c+mkwwgb5IGKD6A
         Uk6mpAvkgdipdFJIqLMyOyGjCiD+elm7FnAxaw3AHyf9B7L8jPkMrWxLxbFltLEd0pbq
         ag41pdFrCvGwA6t7EcZ4ZUX05L7DEl5bRwGPK6Rf1GMhmR0ts0M6QtbIwVA6IDXooci1
         HQ9vNV83mgGdPyOcmqPB+CXOHlEszLSIoH9WFr5fDgDMM1UCXcVWoW4Zbqzz/w6gbVtF
         jRrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=thhM7y8K;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id p91si16484043plb.61.2019.07.25.16.51.17
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 16:51:17 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 198.137.202.133 as permitted sender) client-ip=198.137.202.133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=thhM7y8K;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=dnWpmDquviv2T4rhOaKwfYrYkAK4O04dPwOKTktYaOs=; b=thhM7y8KKCymntW36Aear/ueL
	3yz70nHaio9xlpXUE8ytrM21+KRWlKYUO2me8Mk/zwg4dNq8qcIbXPODdZ3avIukc6wI4Du1LVxJo
	8d1pMsg8sILIf8rByVRmAQ97UlVSAGve0hNP8Dta041us0ooVAroMXcDN5q2rfpeqs8Cagem+5I4q
	y3hKbtksNNtRMWUff6W/Ox/dcr02eeOTKMs0+Ppw+OF5ZS/b0lmJgEWJ4IJSBnI5xhrF1wuSURU26
	3xH6xb2WP2EIEfqSnTrwl6B7YDyLh/Av21TfBdp1uc+nk3LC460dz8qRyPdxcv9fhXcA2E7WtL7xm
	XkQJkJjEA==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=[192.168.1.17])
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hqnW0-0005yk-GJ; Thu, 25 Jul 2019 23:51:16 +0000
Subject: Re: mmotm 2019-07-24-21-39 uploaded (mm/memcontrol)
To: Andrew Morton <akpm@linux-foundation.org>
Cc: broonie@kernel.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org,
 sfr@canb.auug.org.au, Chris Down <chris@chrisdown.name>
References: <20190725044010.4tE0dhrji%akpm@linux-foundation.org>
 <4831a203-8853-27d7-1996-280d34ea824f@infradead.org>
 <20190725163959.3d759a7f37ba40bb7f75244e@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <704b25d9-08bd-8418-f6b3-d8ba4c4cecfa@infradead.org>
Date: Thu, 25 Jul 2019 16:51:15 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190725163959.3d759a7f37ba40bb7f75244e@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/25/19 4:39 PM, Andrew Morton wrote:
> On Thu, 25 Jul 2019 15:02:59 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:
> 
>> On 7/24/19 9:40 PM, akpm@linux-foundation.org wrote:
>>> The mm-of-the-moment snapshot 2019-07-24-21-39 has been uploaded to
>>>
>>>    http://www.ozlabs.org/~akpm/mmotm/
>>>
>>> mmotm-readme.txt says
>>>
>>> README for mm-of-the-moment:
>>>
>>> http://www.ozlabs.org/~akpm/mmotm/
>>>
>>> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
>>> more than once a week.
>>>
>>> You will need quilt to apply these patches to the latest Linus release (5.x
>>> or 5.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
>>> http://ozlabs.org/~akpm/mmotm/series
>>>
>>
>> on i386:
>>
>> ld: mm/memcontrol.o: in function `mem_cgroup_handle_over_high':
>> memcontrol.c:(.text+0x6235): undefined reference to `__udivdi3'
> 
> Thanks.  This?


Yes, that works.  Thanks.

Acked-by: Randy Dunlap <rdunlap@infradead.org>


> --- a/mm/memcontrol.c~mm-throttle-allocators-when-failing-reclaim-over-memoryhigh-fix-fix
> +++ a/mm/memcontrol.c
> @@ -2414,8 +2414,9 @@ void mem_cgroup_handle_over_high(void)
>  	 */
>  	clamped_high = max(high, 1UL);
>  
> -	overage = ((u64)(usage - high) << MEMCG_DELAY_PRECISION_SHIFT)
> -		/ clamped_high;
> +	overage = (u64)(usage - high) << MEMCG_DELAY_PRECISION_SHIFT;
> +	do_div(overage, clamped_high);
> +
>  	penalty_jiffies = ((u64)overage * overage * HZ)
>  		>> (MEMCG_DELAY_PRECISION_SHIFT + MEMCG_DELAY_SCALING_SHIFT);
>  
> _
> 


-- 
~Randy

