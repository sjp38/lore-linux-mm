Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75BBBC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 09:36:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36D6422C7E
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 09:36:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=rasmusvillemoes.dk header.i=@rasmusvillemoes.dk header.b="X3hvdlGJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36D6422C7E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rasmusvillemoes.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB6E06B0006; Fri, 26 Jul 2019 05:36:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A40466B0007; Fri, 26 Jul 2019 05:36:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 909208E0002; Fri, 26 Jul 2019 05:36:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 242AF6B0006
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 05:36:13 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id f24so5415823lfk.6
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 02:36:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=cCNyX4EgHWf9DOLoNQ+h4Aw5GdNoi9VaZ75yal80M50=;
        b=HnyMr8jwO/72Kky5lQidanjH1/hd222dPeQ37VQr6bfUjEAXeBypq18HFqrx8rpbSU
         tIo5TBXTMZsj9DCa1rkWGTX4PHHk4d75eq0XJUIQ/xFssJjTz9QE2RCz1DPLGOjXCHx3
         qSJAfUnoDRu917jkZEkMSgJBZ1XAnS7VH0uyJNvjRp+9Lv4kZ4ZR27qRiLNQzjclSfl6
         BOo1yD0KOSclZFYEeolMNzW6x4mnNJGz00g1lrOzkqGrg4cM+oEdFjQ4yPlELw1ZhB3t
         F0ZhGoGQyWgUXjhZLR7D87nbuPEEyx5mm1EUQpcbC2CVKAN8AKMQZiwFA/NE43wAomdy
         HKIw==
X-Gm-Message-State: APjAAAXt+qQt8QkQFCbWL+YZVoGgo2ER6zYyt5xVJlAmuv1WVDyuDaVN
	PxXLfn+lWSdV726o6/pB0UrPg84Oa+g7+Nu0uErGHFMZJSU+0ildRH7zDyXRL+4CFX0v8bgaj0R
	CTwtZTh0Z+T4I8bbykbJ5UzOEHe1vo2gx+U23TGH0hl5/2lj9GDg+AXxQcErSUZUm7w==
X-Received: by 2002:a19:8c57:: with SMTP id i23mr42846668lfj.192.1564133772125;
        Fri, 26 Jul 2019 02:36:12 -0700 (PDT)
X-Received: by 2002:a19:8c57:: with SMTP id i23mr42846644lfj.192.1564133771256;
        Fri, 26 Jul 2019 02:36:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564133771; cv=none;
        d=google.com; s=arc-20160816;
        b=SirtMbvbBHea+q9N9mijyCbkCdfNJTUvAKtoTEzjumz+m95UpWozfDJuNYSsZusYbs
         PORbo90/0yuVpnaXONgcKicG0aliv7HVqXsCz2llIBpLGgSPCw26b46pWD38M3znE7Oq
         FL8b3K1ahGEaWdDiAZ6310pzE/0HcvRk/amYXnN4x4/6GhMBh/crI9o5psR3A46sGond
         AVpYunZVo49bvyt4h93ypjJMWzULEbcLqRDHxtL0G9XLqd7PkMgaTZSWEjrbyb2mp9s1
         24q7q/KKixzfIk6xSHyhTLHO0cd3xAbYZJr6tZpEmwmW0Frqh3o03JWE4vYpi1qaWp5L
         fvVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=cCNyX4EgHWf9DOLoNQ+h4Aw5GdNoi9VaZ75yal80M50=;
        b=efaQZmJcYay7Ip3DNFA3HlfMa7zt/hhXj9eud6BUfLLh3gLw/YJaxL/mbFm++TmSK/
         3WrHdh9Mau0NXZ0KDSlhUZX4VqGKGlxZgoRKq7KAeD5GHfJOlSz0C4EDATj5q5QgqlSY
         pYGG46G8Lf/4pgq9L6xQnsoHe7HEFR4+Fv6E562Z1wm2LyyFzVL/1xwnYPjnkRV7LOjG
         sv7gnpDC7lby9UdboFJMGMo5SsoPAdqkNlQjdFZyq8ZzjO4gwKDDXGe3LB3HeyfEkTW6
         dowzT9EXcemnmy29705435gn4ZgBGbudgUb1gBSpW3apgj7Z/EgTOypEUfo4mUaj7sTe
         H7Uw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@rasmusvillemoes.dk header.s=google header.b=X3hvdlGJ;
       spf=pass (google.com: domain of linux@rasmusvillemoes.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux@rasmusvillemoes.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y12sor13854380lfe.67.2019.07.26.02.36.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 02:36:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux@rasmusvillemoes.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@rasmusvillemoes.dk header.s=google header.b=X3hvdlGJ;
       spf=pass (google.com: domain of linux@rasmusvillemoes.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux@rasmusvillemoes.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=rasmusvillemoes.dk; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=cCNyX4EgHWf9DOLoNQ+h4Aw5GdNoi9VaZ75yal80M50=;
        b=X3hvdlGJC6xNYRLjQ1Sa8tEr/Ahcigk5o+UV3hCYNk5lCfwGNu/wPuAVlnJqXAxvxd
         hH6WHLD6i1nB+N2wO+xjpt0UI0XEzzBtl4tgSpXcNC9ex4T5oIN3qx/SzgJW7r5sg8Vr
         iT14ncdUJ8a7eb/cGraQgFwKdukyK6FYPRMLg=
X-Google-Smtp-Source: APXvYqwCo6Oe2SRXCiD3OqFxvFL5a4Y4zF/v0KyJ4Qkc7UkchhOvJ0pEiUiEr8ZRykwx46SVLNEesA==
X-Received: by 2002:a05:6512:48f:: with SMTP id v15mr791427lfq.37.1564133770570;
        Fri, 26 Jul 2019 02:36:10 -0700 (PDT)
Received: from [172.16.11.28] ([81.216.59.226])
        by smtp.gmail.com with ESMTPSA id h129sm8193919lfd.74.2019.07.26.02.36.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 02:36:10 -0700 (PDT)
Subject: Re: [PATCH 02/10] mm/page_alloc: use unsigned int for "order" in
 __rmqueue_fallback()
To: Pengfei Li <lpf.vector@gmail.com>, akpm@linux-foundation.org
Cc: mgorman@techsingularity.net, mhocko@suse.com, vbabka@suse.cz, cai@lca.pw,
 aryabinin@virtuozzo.com, osalvador@suse.de, rostedt@goodmis.org,
 mingo@redhat.com, pavel.tatashin@microsoft.com, rppt@linux.ibm.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190725184253.21160-1-lpf.vector@gmail.com>
 <20190725184253.21160-3-lpf.vector@gmail.com>
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <ac59714d-74d6-820c-37ea-5bf62cfc33a8@rasmusvillemoes.dk>
Date: Fri, 26 Jul 2019 11:36:08 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190725184253.21160-3-lpf.vector@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25/07/2019 20.42, Pengfei Li wrote:
> Because "order" will never be negative in __rmqueue_fallback(),
> so just make "order" unsigned int.
> And modify trace_mm_page_alloc_extfrag() accordingly.
> 

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 75c18f4fd66a..1432cbcd87cd 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2631,8 +2631,8 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
>   * condition simpler.
>   */
>  static __always_inline bool
> -__rmqueue_fallback(struct zone *zone, int order, int start_migratetype,
> -						unsigned int alloc_flags)
> +__rmqueue_fallback(struct zone *zone, unsigned int order,
> +		int start_migratetype, unsigned int alloc_flags)
>  {

Please read the last paragraph of the comment above this function, run
git blame to figure out when that was introduced, and then read the full
commit description. Here be dragons. At the very least, this patch is
wrong in that it makes that comment inaccurate.

Rasmus

