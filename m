Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4390FC74A35
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 18:29:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 131A72087F
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 18:29:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 131A72087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1E418E0087; Wed, 10 Jul 2019 14:29:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CD8B8E0032; Wed, 10 Jul 2019 14:29:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E2D78E0087; Wed, 10 Jul 2019 14:29:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A9C98E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 14:29:53 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id o2so809977lji.14
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 11:29:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=V64pBGGyvpGpIrNKWa5fgZ6XjkccPPsATaZLEP7yVGI=;
        b=Q9HEcYlHGH0YY4nYl5OqrvbyCviLxORwLt3IVPPsDbPHurbhO8yqeSDTTlvH1zaidK
         wqyDCJOeNsIdgIrm/XXp7bYZbqER/JmgBCFDsDiPmcoPOouGgyzGz7YniC8TZC7fjpgk
         nXTB0G9CH+6/8xN4k2gy72xuHMenEFENZAsgtfTvQ8vlmVNJYLdBCrY32YwBnIk1SKBp
         nbjV+QND31rGCTo8F15suntwqpX7OBsADXeRs0sSyzBIMwzy1qGYqSJPUBVIY38tBATc
         pO67BmGA7j8oKpjJsMPrc1ATHczeUxSqj/037A7OHuDcRA0Z4a0nHzEOWMF00y/8REty
         cRMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWQ0r4maFIUDM2bmO666ZQzGTGmHMGelMCN3KLas3UtlldFT9LE
	Udigdee4RHhKZHM7GtuJ/O3jXNyTXRlqxumw0AyKCjstkM8aZbh2p7l1V6C49jetr1d/Sk9vo0t
	fa7exJiNmO3/oZMjdyqPfvAAE10GTSv021jIOIRmocBCokIrWs4HhexRuevSizASNEQ==
X-Received: by 2002:a2e:9951:: with SMTP id r17mr17976660ljj.125.1562783391360;
        Wed, 10 Jul 2019 11:29:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHLJucUSrTekSzKov4u6HPeSKPPQ0Ef5QwMwjuRTUFDZDAjOneycFn+u69endi5MMy1CYU
X-Received: by 2002:a2e:9951:: with SMTP id r17mr17976632ljj.125.1562783390606;
        Wed, 10 Jul 2019 11:29:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562783390; cv=none;
        d=google.com; s=arc-20160816;
        b=ylQSEK6xdJlWSoMXV1jRWQvqwhxPXSgpRCGnMjqUgIUMRc6pb30RPA2ihBJEN+JCgP
         l5hJlLfgtrNOQdDl4D6ROfGKKRsbLS/lanqnAbXGtOs/KISqkxW5qwHjs3hLgaxy4MTi
         LYpOQRloURcLjzF7Uo80PBNBzMFwINEKaizY4DH82D/6FvinNLISG05IjhNcILiNWwQq
         CrKY0q42CNxp9nmQbzNyxxbsr5Bu6AaUhIg14zg2AU1nSgKllMRoL4jTPOaE/R46FkK2
         68X14bOy5z6yCoDSc3j1N41TVqK85I8o46GxH34G2XjfFqas0LPhYzkbIAThbjnI916Q
         +Uew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=V64pBGGyvpGpIrNKWa5fgZ6XjkccPPsATaZLEP7yVGI=;
        b=V+JNoGlsI6HBYodqOqHPn7mQPdr4Cou/5RQ9jIlxZbMyt0KkZiEn9wC2Tcas+5SKTt
         vspeUZnlj/R9GvsqsM1mj1eNqtPFUlaOJ0iSDsOXNpsC3sbtEo5KsGz19jInPSu5tGJi
         n770UGuUq2s7t6xZVDYL4eWYsIk6Z2+x6opygtd7H111C3lCaC94y4O5ynCVJiKBCsOl
         meE3k8RIRpjmX7tCxUILaa+p4oQR4+e5FR1HCnbaHlJFwfhsfvtJQSP6K8T2kxe9KZts
         q6LOh0Wpre6qSE50xXA5ZDls9wE/JPF2EuYFk0SI8bqlmIlZgY8dUTZV1eS9DR4tvOdQ
         EbcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id v16si2580807ljj.47.2019.07.10.11.29.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jul 2019 11:29:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1hlHLb-0006Lj-N7; Wed, 10 Jul 2019 21:29:43 +0300
Subject: Re: [PATCH v5 0/5] Add object validation in ksize()
To: Marco Elver <elver@google.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>,
 Alexander Potapenko <glider@google.com>,
 Andrey Konovalov <andreyknvl@google.com>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Mark Rutland <mark.rutland@arm.com>, Kees Cook <keescook@chromium.org>,
 Stephen Rothwell <sfr@canb.auug.org.au>, Qian Cai <cai@lca.pw>,
 kasan-dev@googlegroups.com, linux-mm@kvack.org,
 kbuild test robot <lkp@intel.com>
References: <20190708170706.174189-1-elver@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <75963ba0-7ed2-9e4a-171b-d2cb5d16af2b@virtuozzo.com>
Date: Wed, 10 Jul 2019 21:29:38 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190708170706.174189-1-elver@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/8/19 8:07 PM, Marco Elver wrote:
> This version fixes several build issues --
> Reported-by: kbuild test robot <lkp@intel.com>
> 
> Previous version here:
> http://lkml.kernel.org/r/20190627094445.216365-1-elver@google.com
> 
> Marco Elver (5):
>   mm/kasan: Introduce __kasan_check_{read,write}
>   mm/kasan: Change kasan_check_{read,write} to return boolean
>   lib/test_kasan: Add test for double-kzfree detection
>   mm/slab: Refactor common ksize KASAN logic into slab_common.c
>   mm/kasan: Add object validation in ksize()
> 

Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

