Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5496C282DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 15:46:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97D90218CD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 15:46:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="e0tqHuoQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97D90218CD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35E4F6B0007; Tue, 23 Apr 2019 11:46:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30DF16B0008; Tue, 23 Apr 2019 11:46:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FBAC6B000A; Tue, 23 Apr 2019 11:46:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC0AA6B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:46:01 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i14so9930728pfd.10
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 08:46:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=9NNCwHmbRpdEn6eFr9PBTWdRMDfTap2B4jvrrMqdzmo=;
        b=KcMBpyWc3kivDn8mpbOEBAYt6bw2XYjr+4HfbTKh1O/EzcbelT2G8PHe9w8OmS9gnW
         RxJt3yxGM+pVqtONmiry6Yl24pT2ssTBXvdOMwO4fdUZiQW7Yy/PgepV2ZavHs2JOwci
         WQWzKS+MXtmS4fPCIFLblUk5mBmpQnHIs5ImhdHO6bMk/vgfl40NTX6QqQ7Azhr5ICOY
         n7vsyDLlGV3B/sKZYHmtX0reFCPqsYTnfaXOAlMOQJnH95eVTKa+auUe24mScNvLNZKG
         rat7kME6CL0jad6svInJxtkpPKdCdWipWTprdZ+wlpaZ1vZr1zp86gIBHyanw7/Sozra
         GMvA==
X-Gm-Message-State: APjAAAUBfUBD5gOyBGCg0KUSFicFOEAdL4VARz063njDMNC+5iu5P7nD
	EfnGHw3ReefyO2n8OOejGdC5cOVPoZY5BjrcmViVLUTHYiBHuqyI8j67K2w2MYzA/McPIqcV+w8
	HLMd+gMyY2Wrid37hVY/WRfNDgETsK6lfdZ2LwhqIDARvjGkRZj4UDhAaLrPl/lOdhQ==
X-Received: by 2002:aa7:92d5:: with SMTP id k21mr27468795pfa.223.1556034361553;
        Tue, 23 Apr 2019 08:46:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4jVme4Jy9qmeq9Tm5FAH+Ne4P9V4c+zgJ3cAGloUB86ZuBguCHV/Eebrr1gU1T5CEmyWm
X-Received: by 2002:aa7:92d5:: with SMTP id k21mr27468597pfa.223.1556034359810;
        Tue, 23 Apr 2019 08:45:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556034359; cv=none;
        d=google.com; s=arc-20160816;
        b=kDRjsR1bg6GwIYFWL6rcI9knnYAlT5DWkUzW2J/oEFtu5+ClskJhgXdIlbCKi/xgW6
         KLKOyNMuBFVb9AqDGjmEHTEO/coj9kJe9JgnEEvsjAUb+3vJAcqvHsrCredhssOufPMS
         sPPTBKqhhSQPdgDNxao43gM0sG+B483jQpXooNmIbi2LBwJc1c2XQ+EHJDt9nn0kZMpq
         GfFHFT/pJqBGSu6cPcMBMCy9NttYZWOmurTR9+7sILCiRfDQ5QnppvskqtQhgxwhmR7X
         P4Z3KAJcPsmDheELr5RKtXZBAoc9DqQTbngMT/cEUQh5eo76TjkONCnLe6VlfNi7pNds
         UfFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=9NNCwHmbRpdEn6eFr9PBTWdRMDfTap2B4jvrrMqdzmo=;
        b=bpLsYSV4IkC6WrRBy+Ydvd4HiRlktFnBMIBVo137Hza7LnwbHIgwoSdM2UlYCjQIiK
         X8zCUQSRyn0/PrkjL/1qVDEJ5qaO6ZLAaANENfNxj70yN+t63DispY3TQngHqMf3eARe
         n0gDoSnwywa23aVMdwRAKo/rEsOcdKEEj84nzOHN5rK2zesgZWbL103V53pehsdwId+6
         cq+tC56+L8NqX2RTkJl3vHBX/soa5KbdRdf/GpOd0qG4RqjuHBnnWJ/F3rblOP+4iklP
         YCsl896AcAtbg/CmlAkX8IGakHNsNm7tBDXUeBHBzNvTCF7GTc258tfh2Go+HrLpB2pl
         nUdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=e0tqHuoQ;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o64si16458499pfa.274.2019.04.23.08.45.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 08:45:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=e0tqHuoQ;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=9NNCwHmbRpdEn6eFr9PBTWdRMDfTap2B4jvrrMqdzmo=; b=e0tqHuoQ5ZYSoe3n8LkEi470N
	SPB6Cb5TAQEToUHk0u6AKK5ZSYn0iAiDEnDR3qjUMeoZYXconzfxrq5pi1GqeNZr4l7i7QOfPfwZo
	+w8O1ieR6ab6N3EBNnvYytL1CVygjALEgMAr4AClAQZcHw8Du/znuvVY9KAziwH6cFDZQgGD1xWVh
	AVURoPaeB8V7R9OzTCM/ulmvDz9oNZQoGH8WZ954XCo+y2eUAQOZ+Posl+OZ85HNbVSIp1JJqefri
	B0R8mJ4tMQWDFI03n10MGJ6znbwvAyhVlGQtUiwtEqam3Gt1+DwGQnA5UjojWN7zJaZm8Sh8XR1qf
	JYxCVuO1Q==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=dragon.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIxcF-0003oT-QV; Tue, 23 Apr 2019 15:45:51 +0000
Subject: Re: mmotm 2019-04-19-14-53 uploaded (objtool)
To: Peter Zijlstra <peterz@infradead.org>
Cc: akpm@linux-foundation.org, broonie@kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
 mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
 Josh Poimboeuf <jpoimboe@redhat.com>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Andy Lutomirski <luto@kernel.org>
References: <20190419215358.WMVFXV3bT%akpm@linux-foundation.org>
 <af3819b4-008f-171e-e721-a9a20f85d8d1@infradead.org>
 <20190423082448.GY11158@hirez.programming.kicks-ass.net>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <9b6de597-110c-aa83-4c58-3dbe937948cf@infradead.org>
Date: Tue, 23 Apr 2019 08:45:49 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190423082448.GY11158@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/23/19 1:24 AM, Peter Zijlstra wrote:
> On Fri, Apr 19, 2019 at 09:36:46PM -0700, Randy Dunlap wrote:
>> On 4/19/19 2:53 PM, akpm@linux-foundation.org wrote:
>>> The mm-of-the-moment snapshot 2019-04-19-14-53 has been uploaded to
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
>>
>> on x86_64:
>>
>>   CC      lib/strncpy_from_user.o
>> lib/strncpy_from_user.o: warning: objtool: strncpy_from_user()+0x315: call to __ubsan_handle_add_overflow() with UACCESS enabled
>>   CC      lib/strnlen_user.o
>> lib/strnlen_user.o: warning: objtool: strnlen_user()+0x337: call to __ubsan_handle_sub_overflow() with UACCESS enabled
> 
> Lemme guess, you're using GCC < 8 ? That had a bug where UBSAN
> considered signed overflow UB when using -fno-strict-overflow or
> -fwrapv.

Correct.  7.4.0.

Patch works for me.  Thanks.

Acked-by: Randy Dunlap <rdunlap@infradead.org> # build-tested


> Now, we could of course allow this symbol, but I found only the below
> was required to make allyesconfig build without issue.
> 
> Andy, Linus?
> 
> (note: the __put_user thing is from this one:
> 
>   drivers/gpu/drm/i915/i915_gem_execbuffer.c:	if (unlikely(__put_user(offset, &urelocs[r-stack].presumed_offset))) {
> 
>  where (ptr) ends up non-trivial due to UBSAN)
> 
> ---
> 
> diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
> index 22ba683afdc2..c82abd6e4ca3 100644
> --- a/arch/x86/include/asm/uaccess.h
> +++ b/arch/x86/include/asm/uaccess.h
> @@ -427,10 +427,11 @@ do {									\
>  ({								\
>  	__label__ __pu_label;					\
>  	int __pu_err = -EFAULT;					\
> -	__typeof__(*(ptr)) __pu_val;				\
> -	__pu_val = x;						\
> +	__typeof__(*(ptr)) __pu_val = (x);			\
> +	__typeof__(ptr) __pu_ptr = (ptr);			\
> +	__typeof__(size) __pu_size = (size);			\
>  	__uaccess_begin();					\
> -	__put_user_size(__pu_val, (ptr), (size), __pu_label);	\
> +	__put_user_size(__pu_val, __pu_ptr, __pu_size, __pu_label);	\
>  	__pu_err = 0;						\
>  __pu_label:							\
>  	__uaccess_end();					\
> diff --git a/lib/strncpy_from_user.c b/lib/strncpy_from_user.c
> index 58eacd41526c..07045bc4872e 100644
> --- a/lib/strncpy_from_user.c
> +++ b/lib/strncpy_from_user.c
> @@ -26,7 +26,7 @@
>  static inline long do_strncpy_from_user(char *dst, const char __user *src, long count, unsigned long max)
>  {
>  	const struct word_at_a_time constants = WORD_AT_A_TIME_CONSTANTS;
> -	long res = 0;
> +	unsigned long res = 0;
>  
>  	/*
>  	 * Truncate 'max' to the user-specified limit, so that
> diff --git a/lib/strnlen_user.c b/lib/strnlen_user.c
> index 1c1a1b0e38a5..0729378ad3e9 100644
> --- a/lib/strnlen_user.c
> +++ b/lib/strnlen_user.c
> @@ -28,7 +28,7 @@
>  static inline long do_strnlen_user(const char __user *src, unsigned long count, unsigned long max)
>  {
>  	const struct word_at_a_time constants = WORD_AT_A_TIME_CONSTANTS;
> -	long align, res = 0;
> +	unsigned long align, res = 0;
>  	unsigned long c;
>  
>  	/*
> 


-- 
~Randy

