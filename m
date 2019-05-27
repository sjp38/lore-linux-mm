Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A029C07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 07:53:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DEBD2070D
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 07:53:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=rasmusvillemoes.dk header.i=@rasmusvillemoes.dk header.b="RQVILT43"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DEBD2070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rasmusvillemoes.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0298F6B026D; Mon, 27 May 2019 03:53:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECE5A6B026E; Mon, 27 May 2019 03:53:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6FAD6B026F; Mon, 27 May 2019 03:53:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5DA6B026D
	for <linux-mm@kvack.org>; Mon, 27 May 2019 03:53:38 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id n14so3041724ljj.19
        for <linux-mm@kvack.org>; Mon, 27 May 2019 00:53:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=u/jG7PRHQvQ/gJu4mWkgic1YFhICzQ7oYnhDTYgh/+A=;
        b=NlG/5Hb3QBpNKobrnDxA6vsRFUFNi/RGeK+wuXFoZ91QXKq0+WDYoMyh4itdhuhqUx
         ZGC2x9QFbKvFz+ZoNXGaSXbp3j1v7VgRTKyUbkiR7rJxKVHXjvUBnQew4fLrIQRtyvTD
         nizG5kb7PBFHlMgfZ7kLIM6T93T0Oc9JtZiGP1IHgFtgmXjgCRJfzxXJOXzES2Xe9iIQ
         +jcgYw7QkP8VWMLUQs2MRB0Fm6dW4tYVY4d2UUgpSaS91pxk2UXvJxFptUc4+eRb6mgJ
         KhtPKzqUb2FaA5NOT8HtOoX3T2sk7om9xVH2HypAjeL+sL08Siw5h8kvyRqq+rICvl7l
         DJ2g==
X-Gm-Message-State: APjAAAUvYMgjH7fn8EF1pTzTi9jCtjVtQg5xH/DdQjHZtEbRMEeJQxza
	RBUGbTvezLxmi3j3x+l36061DTwQBWNoklxB9yOk0UbQIJ0zhD2J2zm9Y/rps4qDA03h6cdeU/H
	ts1Auf/pcBrcHG2DNqcKLsMPT3M54rmgweJYPUtndVgPjwyv0GoH8ITSOrHz29O/i2Q==
X-Received: by 2002:ac2:5382:: with SMTP id g2mr5413431lfh.92.1558943617748;
        Mon, 27 May 2019 00:53:37 -0700 (PDT)
X-Received: by 2002:ac2:5382:: with SMTP id g2mr5413399lfh.92.1558943616983;
        Mon, 27 May 2019 00:53:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558943616; cv=none;
        d=google.com; s=arc-20160816;
        b=gt6QDfhXBUE1JlfzHq/ZlJ80hRFkWxdd6kI05lt1ExRc8QPeFHDEU1KNzYDZoClaV9
         mUYOuvZaYD34NROvrFune5v5+Knv4qOyCZrZDkflpwgxZso7RrMc4DgPqyy4b//YH4yt
         pB/YisxhxGXhzgosOs1+m/yLAAm4Rt6CZulbUv5QQxq8FoqsgZzMF8zz2t5YI8Ngm8Yd
         UI747/FJonSrZ5IFvTQIAqg+WIkEdI5MkbzasYbtukUGujpmeNeJAjDoRftPLOupLAqk
         eoL7lig4jF6/yekGMKXEeIT+FGOya6fWa6G8eO1k0eUnSCy88CtMsF1Au86cJAoeROKf
         J1kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=u/jG7PRHQvQ/gJu4mWkgic1YFhICzQ7oYnhDTYgh/+A=;
        b=d4/ojfbDGBZDwf+isXFPwoLNWY9xTBznCNgeQ8MOacE2f5Jtv8N0+5Q5ecvBEiT4dY
         nuPmfKgzi0r2sVof9w9V7Xqa6Bs9/J0h21cuoelxVeyy6io3pf/70BbghoKDa2LMt+BB
         AxZWlgz0rD2lFTQrTVov36rjr9taRWe2ycmrrUHSt5XCUtMYhmXhODX8cig6mk8GTSAW
         AkQw32uiWhaqv1wOt1Zj+dTwTnNCUymJx8nVKacvWFMJYtMlkp7banyFV8ySTTkUkXOE
         hc08kbF9PkBFLxPtn7lW3OihCf6iZEK3BKTdwR+R3EjOmWHeTeRkmw+qp8PvOsf13i57
         DRPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@rasmusvillemoes.dk header.s=google header.b=RQVILT43;
       spf=pass (google.com: domain of linux@rasmusvillemoes.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux@rasmusvillemoes.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r6sor4783165ljg.27.2019.05.27.00.53.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 00:53:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux@rasmusvillemoes.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@rasmusvillemoes.dk header.s=google header.b=RQVILT43;
       spf=pass (google.com: domain of linux@rasmusvillemoes.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux@rasmusvillemoes.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=rasmusvillemoes.dk; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=u/jG7PRHQvQ/gJu4mWkgic1YFhICzQ7oYnhDTYgh/+A=;
        b=RQVILT43qONfsxpQOQEQsUoX7Zku4pvkoHN7Vng5hM09sRKV87QSs0JRpHBdlpprBe
         UkGMd+fEQJlvhhZ6OtbZHb9Ar1EAWn9mxSrnIoAqRkqlQtLAj/tgjjBdWtEyxv+6xdR3
         s9kC4Hm3+NrcuGFU450aVm6xCpDsoUvA9zv0w=
X-Google-Smtp-Source: APXvYqw+Ija1yj1WbZ5QX3cIC+EjlZ9jBXxlLm1pyF3XxZqbylvz/66EsA4BJLkcl+dOysbZnAJljQ==
X-Received: by 2002:a2e:80d5:: with SMTP id r21mr7934450ljg.43.1558943616590;
        Mon, 27 May 2019 00:53:36 -0700 (PDT)
Received: from [172.16.11.26] ([81.216.59.226])
        by smtp.gmail.com with ESMTPSA id p5sm2124466ljg.55.2019.05.27.00.53.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 00:53:35 -0700 (PDT)
Subject: Re: lib/test_overflow.c causes WARNING and tainted kernel
To: Randy Dunlap <rdunlap@infradead.org>, Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
 Dan Carpenter <dan.carpenter@oracle.com>,
 Matthew Wilcox <willy@infradead.org>, Linux MM <linux-mm@kvack.org>,
 Andrew Morton <akpm@linux-foundation.org>
References: <9fa84db9-084b-cf7f-6c13-06131efb0cfa@infradead.org>
 <CAGXu5j+yRt_yf2CwvaZDUiEUMwTRRiWab6aeStxqodx9i+BR4g@mail.gmail.com>
 <e2646ac0-c194-4397-c021-a64fa2935388@infradead.org>
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <97c4b023-06fe-2ec3-86c4-bfdb5505bf6d@rasmusvillemoes.dk>
Date: Mon, 27 May 2019 09:53:33 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <e2646ac0-c194-4397-c021-a64fa2935388@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25/05/2019 17.33, Randy Dunlap wrote:
> On 3/13/19 7:53 PM, Kees Cook wrote:
>> Hi!
>>
>> On Wed, Mar 13, 2019 at 2:29 PM Randy Dunlap <rdunlap@infradead.org> wrote:
>>>
>>> This is v5.0-11053-gebc551f2b8f9, MAR-12 around 4:00pm PT.
>>>
>>> In the first test_kmalloc() in test_overflow_allocation():
>>>
>>> [54375.073895] test_overflow: ok: (s64)(0 << 63) == 0
>>> [54375.074228] WARNING: CPU: 2 PID: 5462 at ../mm/page_alloc.c:4584 __alloc_pages_nodemask+0x33f/0x540
>>> [...]
>>> [54375.079236] ---[ end trace 754acb68d8d1a1cb ]---
>>> [54375.079313] test_overflow: kmalloc detected saturation
>>
>> Yup! This is expected and operating as intended: it is exercising the
>> allocator's detection of insane allocation sizes. :)
>>
>> If we want to make it less noisy, perhaps we could add a global flag
>> the allocators could check before doing their WARNs?
>>
>> -Kees
> 
> I didn't like that global flag idea.  I also don't like the kernel becoming
> tainted by this test.

Me neither. Can't we pass __GFP_NOWARN from the testcases, perhaps with
a module parameter to opt-in to not pass that flag? That way one can
make the overflow module built-in (and thus run at boot) without
automatically tainting the kernel.

The vmalloc cases do not take gfp_t, would they still cause a warning?

BTW, I noticed that the 'wrap to 8K' depends on 64 bit and
pagesize==4096; for 32 bit the result is 20K, while if the pagesize is
64K one gets 128K and 512K for 32/64 bit size_t, respectively. Don't
know if that's a problem, but it's easy enough to make it independent of
pagesize (just make it 9*4096 explicitly), and if we use 5 instead of 9
it also becomes independent of sizeof(size_t) (wrapping to 16K).

Rasmus

