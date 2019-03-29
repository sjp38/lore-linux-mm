Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A690C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 18:10:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B06720811
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 18:10:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MZABh0Gx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B06720811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC2956B000D; Fri, 29 Mar 2019 14:10:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C98F86B000E; Fri, 29 Mar 2019 14:10:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B61C26B0010; Fri, 29 Mar 2019 14:10:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 78E566B000D
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 14:10:52 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id u2so2148061pgi.10
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 11:10:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=cfnDbEyF8f3jK6rE9tvOedJ62dm6dAUPE3LAW9VXfgY=;
        b=rmDXMQlDP9oWcurU/1XSEE3BUIuIC6KFp3W7/6Zp9LS2mzrqwCFrJ6XbCSzMZ+c09d
         ZYfFyxhGtGxhB5YuFsIYLoXsMUYTcudw3oGsQE44GxpHLYa4LguRGZwcaV0s7uP69Iuu
         nDjheyQdwHCGhv86Ipvv5gn55hWTkw40avQldjNJeMrpLeQ9VIEeFC/9bJfcMGtIQCiZ
         adVGpBvAVRIDkt+ca1hNt/XxOXQ1+8klUNLG2Hm4iRHDcytcJpDu1XaR3svXVPR/Lb78
         ycZoQUg2Ulx5NT85mhGe49QMBDXxlfgxKLDIZPO4wdBVZbHAKGHbEzPl0FE90uwQK6sI
         cHPw==
X-Gm-Message-State: APjAAAVszObjv8b2nsWW1fymBfDtqpJscxKcfS85PZzbDXw8gqdq92Eo
	4zvPs2EmJyYkcgv6BqtION/aCDJmQi76pwXVU5KAZWLi4vyipr0J+9rZ0YoBsibVs/v29BMWDFR
	qwI3NV3qSD03anyoMwmD8Q64Zt2HN7DwIGYO6yZhRcamxejS9CTzdw8f4FoqQVRDkpg==
X-Received: by 2002:a17:902:bb05:: with SMTP id l5mr30526070pls.311.1553883052161;
        Fri, 29 Mar 2019 11:10:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzofgkH+JZEGOUa14r7k7B9ZIlp5qcWfwiLj/EYJXtQZ56KxSBo0D2ZX8arswa385AhsTq7
X-Received: by 2002:a17:902:bb05:: with SMTP id l5mr30526025pls.311.1553883051560;
        Fri, 29 Mar 2019 11:10:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553883051; cv=none;
        d=google.com; s=arc-20160816;
        b=S3vXWuaoNtRiU97MzJFF9N4Dh2S2y4qkzMj1NC9Tn183heB687wRUbJIqOBzbwqVJ+
         pv49CbeYUphGTxVbbAcoa/18k+nNCvmLyUB78qInwWMTtNAVfCN6ElM42zomg0TSN+Lq
         l4y40acNTm/ust89qLT+N8py8hCRPXMq10E/jCOnWPUtVaDHX+lM4MhGPe37ZwyB+XIl
         VUWtrLZVJM3aqOzdlFas5FPbhD9Jxap4yP36nuEfKOOWH/RexTaVweQ1y/VtkyA3rufI
         zjZKosRAGSTG4vSVZeqSClg0TmLMhNXIH2CPhGIGIk9YdJtFnFIq7a1ca4C9Ffi1s2fh
         RGeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=cfnDbEyF8f3jK6rE9tvOedJ62dm6dAUPE3LAW9VXfgY=;
        b=Jfi2gnLZfFfskW3MEguAHABjEA3de1x+TxF0Y5t1DRpnw/hnom7wiH0iBIUjap5NT9
         wfKCedHlzwYIXJKHusOODT4tBHipOTUyzLwES9TLDVm0jnNyyVTU6Z4wSBmzva/4sUz5
         BE7zc15J9GTG4qqFqkexltdzycc9TUck/NmjE8OQaujbN7MYLAPqJfJWSPk8kPae/iLs
         xa6YtYNcz2x09LEn0N2p1+xEBBithV868CnBZqd2S4jGDVcII7+4JzXi3f2tNCfdcy/5
         f5mi6IxulM0ckh1uBTOAjRDOLdmugYhbhMuKFcGFhwyeeexLWIDqrfZ7SZgQOm+3wkAe
         xEPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MZABh0Gx;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l13si2327690pgp.571.2019.03.29.11.10.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 11:10:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MZABh0Gx;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=cfnDbEyF8f3jK6rE9tvOedJ62dm6dAUPE3LAW9VXfgY=; b=MZABh0GxYIsd0IG3di5ESr7MF
	kO1b00Kb7MBoGMvrXcbbFpww+LlgET3S5/IqOTrn2i0yWF2kmNAFXCmMtNnDKMLcykhULTvjVBVRe
	s1xeA3aopEJUHlGDOFG0J/z5YtpuIyqtVGHsESTEHMkblFGMp2ZtQtmZyxk3KmG5jkn85RGtuysv/
	DRgUUL8Kr0++WAbXLoYVm4Iq2yA2WRuYll0NRZPeNE86DoJ7SEVMyZTz1j/7hhcMZFi6UZJ5x10Tm
	2DMYHcq9LgQ4Qlr1+xGDCERojwGxMaHIAK/H+aNj/Nrj3iqssx59dQTAy1Lu0PW9jTiVnQuKi0cKe
	jwaHh6N1g==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h9vxq-0002dh-29; Fri, 29 Mar 2019 18:10:50 +0000
Subject: Re: [PATCH] gcov: include linux/module.h for within_module
To: Nick Desaulniers <ndesaulniers@google.com>
Cc: Peter Oberparleiter <oberpar@linux.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Greg Hackmann <ghackmann@android.com>, Tri Vo <trong@android.com>,
 Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org,
 kbuild test robot <lkp@intel.com>, LKML <linux-kernel@vger.kernel.org>
References: <201903291603.7podsjD7%lkp@intel.com>
 <20190329174541.79972-1-ndesaulniers@google.com>
 <9f1ad3e1-fad7-2fb4-31c0-d31832468143@infradead.org>
 <CAKwvOdmv4_8pN5r8EO8c59WN+EE7ZPST8qHKMg7SzPH1rzaqag@mail.gmail.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <eea3ce6a-732b-5c1d-9975-eddaeee21cf5@infradead.org>
Date: Fri, 29 Mar 2019 11:10:49 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <CAKwvOdmv4_8pN5r8EO8c59WN+EE7ZPST8qHKMg7SzPH1rzaqag@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/29/19 11:09 AM, Nick Desaulniers wrote:
> On Fri, Mar 29, 2019 at 11:01 AM Randy Dunlap <rdunlap@infradead.org> wrote:
>>
>> On 3/29/19 10:45 AM, Nick Desaulniers wrote:
>>> Fixes commit 8c3d220cb6b5 ("gcov: clang support")
>>>
>>> Cc: Greg Hackmann <ghackmann@android.com>
>>> Cc: Tri Vo <trong@android.com>
>>> Cc: Peter Oberparleiter <oberpar@linux.ibm.com>
>>> Cc: linux-mm@kvack.org
>>> Cc: kbuild-all@01.org
>>> Reported-by: kbuild test robot <lkp@intel.com>
>>> Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
>>> Signed-off-by: Nick Desaulniers <ndesaulniers@google.com>
>>
>> Reported-by: Randy Dunlap <rdunlap@infradead.org>
>> see https://lore.kernel.org/linux-mm/20190328225107.ULwYw%25akpm@linux-foundation.org/T/#mee26c00158574326e807480fc39dfcbd7bebd5fd
>>
>> Did you test this?
> 
> Yes, built with gcc 7.3 and
> defconfig
> +
> CONFIG_GCOV_KERNEL=y
> CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
> CONFIG_GCOV_FORMAT_4_7=y
> 
>> kernel/gcov/gcc_4_7.c includes local "gcov.h",
>> which includes <linux/module.h>, so why didn't that work or why
>> does this patch work?
> 
> Good point. May be something in the configs from 0-day bot.  Boarding
> a plane for Bangkok, but can dig further once landed.
> 
> Maybe module support was disabled?

Yes, I reported the problem with CONFIG_MODULES not enabled.


-- 
~Randy

