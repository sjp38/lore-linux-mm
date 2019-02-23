Return-Path: <SRS0=E+cj=Q6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5F25C43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 01:58:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8923220685
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 01:58:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Ie/8s49T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8923220685
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E0178E014C; Fri, 22 Feb 2019 20:58:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18E8E8E014B; Fri, 22 Feb 2019 20:58:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 056F38E014C; Fri, 22 Feb 2019 20:58:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD3638E014B
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 20:58:48 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id n197so3062048qke.0
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 17:58:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=AcTsxVH/dj9oDoSMw1XFXDLofkXFVjmsgOC5gtdi62U=;
        b=S+lk7L7hLPEg2nTYdRdkx2fnVK2Ef1FQJW0O4OldOucMOAKkI7+xdlf5DTOtXc9lfP
         ZN0Bt4wQ+X+NEZX4zVj4r++3o6S0TYCD5MUiRyAm8By1BOqzevSz4uG6wOMF/7Rc6OJq
         l8C70V91qvkWBhQQDElLNYPOj85LBS/9gTlLnbfvOgS+luqWnHMe/t3EeGxw5ekxC3SM
         TExM8mf0Evc8ujpjL2iGqC1Avt6IQiRQvYR3kCHJ/gkKdomNnrzYWIdakEAFfcD/989s
         U/l3swN2WoC5/LRHlliSXCoiijnUO+MuqVkwNNiLiMvullvng4Hhdsu+0GQLkDID3QCa
         zetA==
X-Gm-Message-State: AHQUAuaXwDaYMD9ihBXf+B3JyO68UyMCYU16w88tA0k4OPtGGakf4YbU
	FAcOrTfg9L/o5XiRch8gi+D5YTQif3whvEKEfmmVPi0CgPPgfCy6mOCphQbtkKuzsYOlqHM8ozG
	sPI6VIGxdO4uZ492xUf1lTdqcoM+kzsgP8QHAx9I9KjezvigGEXchaYfPz/w1YNCdeSr/4+ZyWj
	aZQYVm2a/EhNTTzFbcDTVwR5POhe46KXtpY/K+ur3GFmqQ8fyH8WKcJyiGZW+nrsH2hG5pcv+jk
	ooHAr1Y3MYjDv/e6zzQ3YYsndtUfbv4YkOZaB8dS2ZuivaDLV5B9mMdNTinHgFlXzqJBHBxehS5
	YACYWRseXazJkxj63YbRkYDjP9sjDqBCYu2fLkUZqGo1npJcsCKLYNpIF7hrHEzwghYNysX2OSE
	O
X-Received: by 2002:ac8:354e:: with SMTP id z14mr5545896qtb.131.1550887128604;
        Fri, 22 Feb 2019 17:58:48 -0800 (PST)
X-Received: by 2002:ac8:354e:: with SMTP id z14mr5545876qtb.131.1550887127961;
        Fri, 22 Feb 2019 17:58:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550887127; cv=none;
        d=google.com; s=arc-20160816;
        b=fIPtZGGYjyD1RXfTvDybi5h5oDthMSrrwn07wmm1dmPsTCI+6jHfB6ldZv4kmX0fd9
         WIb6J17EquyQi30FqYjgq8p7Jhwv2IrFBnxaq19a/eGpRSait6RkLC4ReM+Tz9SRHnDq
         bvbskduxZPQtcb3hJ4VfapzS4YG0DB5Er6EeHMsZ+5GfZEOJY+0pvRZ8AEcoR9/+Xfb7
         NFZItBhGNkd4fnNEbRegN3s4aKImerXB0UCQDZ0FYFU0ypPrUP8mAB0w1Y3QDgMT6OhT
         +nANdf0xx/sEdIk0tcytZe85uyNY4lBR1VpJ4iVZzU1WYfY7WdEIVxxK8MKI5I6uPeum
         c5Fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=AcTsxVH/dj9oDoSMw1XFXDLofkXFVjmsgOC5gtdi62U=;
        b=aX9g2rPjhXSRlZf/0pH0g5kfigVfmZcjidF3Oql5HdyhAoJhZ8EbHGEH4QmopM8O0X
         EqvylT27ZrNQDsgis6KnzlmM7anqfvbNiM4FKBm4ATGZWwTpxxtSJIgDL9Ju9eUXjRpB
         SGGbMh9F6wT0/UYDMdv2xL0GI//x6KRv7I16VSZt5twk7x0uOxzhZuXDjRF2rjL4tUDy
         5TefDssjyJ1Bu6POsqXEpLnoiJADBpAF5qjBSBTcFQC+3y2hCxD2APkg+Lsvu4JosqvR
         nyjrY7JLPqADaTEztsM5GG0kC9Qw6LJRh1hfalCEuX40OsYpxan26bagwrH626I0/rXp
         IMZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="Ie/8s49T";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c192sor1822695qka.132.2019.02.22.17.58.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 17:58:47 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="Ie/8s49T";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=AcTsxVH/dj9oDoSMw1XFXDLofkXFVjmsgOC5gtdi62U=;
        b=Ie/8s49TjZxjGpE9jKyPAKAyZ5nlRUNizr9PZzLALgsQQRAFH5COwAgljMhdPDyN4o
         y84Y3MEEWUZxTFG/cICCZihtxTui8D8TGHet0YeTTq87wydME71FyXCm48VGAKyGAOMz
         MotQnd/BMNAF+vo5UYaHZkrByTkhojceE/GQ2Z+J6htxK06RttAVqv2hlWQFL0I1RsEz
         yH//RPvuEmVfM8sd9XoDxjP9e0MFA+yzFKoTOLux784hSAar7jcV+eiiD1P1WcvIJGDi
         BvT37ZuCqLfb1dBGdqUfnLPA5AfdROQ0kTd5sU0kv2GnRM5+7vBzDBAHd8MAewGIiD+C
         IjAg==
X-Google-Smtp-Source: AHgI3IYkN3BUiZdb10ssD2dxWJ4RV5+TMn/xeW/caPAUpT1xr2PsZ0uItJMWkqPxJcjmW7BBKfL7wA==
X-Received: by 2002:a37:4f45:: with SMTP id d66mr5261335qkb.81.1550887127150;
        Fri, 22 Feb 2019 17:58:47 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id s21sm2022743qki.94.2019.02.22.17.58.45
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 17:58:46 -0800 (PST)
Subject: Re: io_submit with slab free object overwritten
To: Jens Axboe <axboe@kernel.dk>
Cc: viro@zeniv.linux.org.uk, hare@suse.com, bcrl@kvack.org,
 linux-aio@kvack.org, Linux-MM <linux-mm@kvack.org>
References: <4a56fc9f-27f7-5cb5-feed-a4e33f05a5d1@lca.pw>
 <cd3bac6a-02b2-351e-3f81-322c2e0ca03e@kernel.dk>
From: Qian Cai <cai@lca.pw>
Message-ID: <77a5bb3e-c292-f946-3216-27311e843d52@lca.pw>
Date: Fri, 22 Feb 2019 20:58:44 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <cd3bac6a-02b2-351e-3f81-322c2e0ca03e@kernel.dk>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/22/19 5:40 PM, Jens Axboe wrote:
> Can you try this one? We only need to write it for polled, and for polled
> the caller is the one that will reap the iocb. Hence it's safe to write
> it after submission if we are marked polled.

It works fine.

