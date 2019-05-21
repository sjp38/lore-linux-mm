Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF1EEC46470
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 18:07:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 246C92173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 18:07:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 246C92173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C8516B0003; Tue, 21 May 2019 14:07:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9793D6B0006; Tue, 21 May 2019 14:07:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 843226B0007; Tue, 21 May 2019 14:07:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D0406B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 14:07:31 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id g8so3293706lja.12
        for <linux-mm@kvack.org>; Tue, 21 May 2019 11:07:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=VW5Gqms6RUuTMruuwhVT0/XMTieYuN/y7XeRBAJOnCU=;
        b=CSF1HrmfULT+3veGzB+Bc+GavO61tOi5Jggis6dNyY8mChh9Avd16f+G1ylAEUg65R
         aOl0gyyUU5w8hT40LRWl3gM6m+G5FVLy/7DlsY4Li0YDfFy6fxpblueJtrokc+ae4apQ
         tMWLebl81Enl7wv6qFI0SOlOumBm/xzEYtwzP3R7Y8Fmj6PlH/PpSSUJJsKxSDeqBc6e
         yAEAMmHk5Jw9r+vie9jnCDEMy5Ij8F6JGsUmdZnSQ9L9IGwymytQGXbhkCEpChQOi8a1
         HA9vZc1KzB2MV3k/y8T7VXrOQvgJjRah/UtzxgTroKyxnDOXMPGznF5gzL0V1zHp9apa
         vO4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWli9RzsF7LCVSLd9jb1be4jUEvM5HKS+MMducs/XfRnXmcPiQc
	AnIYFOUh+GZqmYzpfBkNUwI8OKeBw7rrJqzrnSID481uh/EEVIKiTJ6lGZwaP0/UgBdcEnfKKFD
	aYkcwKV+Pjidod2K2Kx8mFdbG8qkK/NVFg61gW7R+dmjeNDep0o9BDjHNsCtBF13IaA==
X-Received: by 2002:ac2:53ad:: with SMTP id j13mr3423227lfh.14.1558462050376;
        Tue, 21 May 2019 11:07:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyLfz9QQTD7xIRctTyF5FBVdhayFkT4H4j/5+kCx9Fvkgs27e2obehQZy7Q1V6ItZ5UiM2
X-Received: by 2002:ac2:53ad:: with SMTP id j13mr3423174lfh.14.1558462049245;
        Tue, 21 May 2019 11:07:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558462049; cv=none;
        d=google.com; s=arc-20160816;
        b=LShegZVnb3mp7D8+LWEKzwYVj/oLuYriyZJZ0Icv3V8xO3WjzHN+PW9i3PwK2jr9NA
         NXnA9SsTb0joftWmRbJERsfj+YfoOrHA+xfdgOTmb+UO1KNoGOsJvJpIZg9LIIRwYtgU
         KchceXhEKZQXILI6wmMtEves/jWqeIhFB3bABnOyjuD5Zrhe4FzWN/1r6Y+rnRMYbEsO
         EWd2PvNSPYj3VcgAX1WZP9xHrGGxteuhWgqPUWQYVkpk4EKnYmPYtXBRAhLpSz/ihbAx
         F4X3WXRJDqx/uisOYOF0yoSTpzxTncU6zlzpreFY0SRBtJrJdO+WiSUvWsMZG0YaUHYY
         0Big==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=VW5Gqms6RUuTMruuwhVT0/XMTieYuN/y7XeRBAJOnCU=;
        b=sDoGmdl56qaRplID1uEZTkngCa/w+topyYVE6LszKLj8NbUKuAMCn2so1x/Qz9zmxH
         QNk3kxeOHslhrIbEA4wp2bWBPGBuHSH22+XkYnHhZLbNselksT1m+FSXNuCwkCCHdo5w
         gk7wJTZCpf4kQPDljMfFXZV7K2XfGr/aj88a4REfrLJ53CIqfTyPr4iz9O+lKwevkC10
         YU6uDbLUyVZIllVCi5Onj+4E1pmQaHQko/qSILQTB5m7qpDIfm282OzzuAGXmjuYT0Ju
         P5NBNKiEprA70xLuDOdZfH/kNmHaqMcqd6tybGKbj7YDVx8ZAtG3/CnZlTOK/gyzgHnj
         5nwA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id m4si17349524ljg.68.2019.05.21.11.07.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 11:07:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1hT9Ad-00083b-Gp; Tue, 21 May 2019 21:07:27 +0300
Subject: Re: [PATCH v2] mm/kasan: Print frame description for stack bugs
To: Marco Elver <elver@google.com>, Alexander Potapenko <glider@google.com>
Cc: Dmitriy Vyukov <dvyukov@google.com>,
 Andrey Konovalov <andreyknvl@google.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Linux Memory Management List <linux-mm@kvack.org>,
 kasan-dev <kasan-dev@googlegroups.com>
References: <20190520154751.84763-1-elver@google.com>
 <ebec4325-f91b-b392-55ed-95dbd36bbb8e@virtuozzo.com>
 <CAG_fn=W+_Ft=g06wtOBgKnpD4UswE_XMXd61jw5ekOH_zeUVOQ@mail.gmail.com>
 <CANpmjNN177XBadNfoSmizQF7uZV61PNPQSftT7hPdc3HmdzSjA@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <292035fd-64b7-1767-3e8a-3a6cb50298b5@virtuozzo.com>
Date: Tue, 21 May 2019 21:07:45 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CANpmjNN177XBadNfoSmizQF7uZV61PNPQSftT7hPdc3HmdzSjA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/21/19 7:07 PM, Marco Elver wrote:
> On Tue, 21 May 2019 at 17:53, Alexander Potapenko <glider@google.com> wrote:
>>
>> On Tue, May 21, 2019 at 5:43 PM Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>>>
>>> On 5/20/19 6:47 PM, Marco Elver wrote:
>>>
>>>> +static void print_decoded_frame_descr(const char *frame_descr)
>>>> +{
>>>> +     /*
>>>> +      * We need to parse the following string:
>>>> +      *    "n alloc_1 alloc_2 ... alloc_n"
>>>> +      * where alloc_i looks like
>>>> +      *    "offset size len name"
>>>> +      * or "offset size len name:line".
>>>> +      */
>>>> +
>>>> +     char token[64];
>>>> +     unsigned long num_objects;
>>>> +
>>>> +     if (!tokenize_frame_descr(&frame_descr, token, sizeof(token),
>>>> +                               &num_objects))
>>>> +             return;
>>>> +
>>>> +     pr_err("\n");
>>>> +     pr_err("this frame has %lu %s:\n", num_objects,
>>>> +            num_objects == 1 ? "object" : "objects");
>>>> +
>>>> +     while (num_objects--) {
>>>> +             unsigned long offset;
>>>> +             unsigned long size;
>>>> +
>>>> +             /* access offset */
>>>> +             if (!tokenize_frame_descr(&frame_descr, token, sizeof(token),
>>>> +                                       &offset))
>>>> +                     return;
>>>> +             /* access size */
>>>> +             if (!tokenize_frame_descr(&frame_descr, token, sizeof(token),
>>>> +                                       &size))
>>>> +                     return;
>>>> +             /* name length (unused) */
>>>> +             if (!tokenize_frame_descr(&frame_descr, NULL, 0, NULL))
>>>> +                     return;
>>>> +             /* object name */
>>>> +             if (!tokenize_frame_descr(&frame_descr, token, sizeof(token),
>>>> +                                       NULL))
>>>> +                     return;
>>>> +
>>>> +             /* Strip line number, if it exists. */
>>>
>>>    Why?
> 
> The filename is not included, and I don't think it adds much in terms
> of ability to debug; nor is the line number included with all
> descriptions. I think, the added complexity of separating the line
> number and parsing is not worthwhile here. Alternatively, I could not
> pay attention to the line number at all, and leave it as is -- in that
> case, some variable names will display as "foo:123".
> 

Either way is fine by me. But explain why in comment if you decide
to keep current code.  Something like
	 /* Strip line number cause it's not very helpful. */


>>>
>>>> +             strreplace(token, ':', '\0');
>>>> +
>>>
>>> ...
>>>
>>>> +
>>>> +     aligned_addr = round_down((unsigned long)addr, sizeof(long));
>>>> +     mem_ptr = round_down(aligned_addr, KASAN_SHADOW_SCALE_SIZE);
>>>> +     shadow_ptr = kasan_mem_to_shadow((void *)aligned_addr);
>>>> +     shadow_bottom = kasan_mem_to_shadow(end_of_stack(current));
>>>> +
>>>> +     while (shadow_ptr >= shadow_bottom && *shadow_ptr != KASAN_STACK_LEFT) {
>>>> +             shadow_ptr--;
>>>> +             mem_ptr -= KASAN_SHADOW_SCALE_SIZE;
>>>> +     }
>>>> +
>>>> +     while (shadow_ptr >= shadow_bottom && *shadow_ptr == KASAN_STACK_LEFT) {
>>>> +             shadow_ptr--;
>>>> +             mem_ptr -= KASAN_SHADOW_SCALE_SIZE;
>>>> +     }
>>>> +
>>>
>>> I suppose this won't work if stack grows up, which is fine because it grows up only on parisc arch.
>>> But "BUILD_BUG_ON(IS_ENABLED(CONFIG_STACK_GROUWSUP))" somewhere wouldn't hurt.
>> Note that KASAN was broken on parisc from day 1 because of other
>> assumptions on the stack growth direction hardcoded into KASAN
>> (e.g. __kasan_unpoison_stack() and __asan_allocas_unpoison()).

It's not broken, it doesn't exist.

>> So maybe this BUILD_BUG_ON can be added in a separate patch as it's
>> not specific to what Marco is doing here?
> 

I think it's fine to add it in this patch because BUILD_BUG_ON() is just a hint for developers
that this particular function depends on growing down stack. So it's more a property of the function
rather than KASAN in general.

Other functions you mentioned can be marked with BUILD_BUG_ON()s as well, but not in this patch indeed.

> Happy to send a follow-up patch, or add here. Let me know what you prefer.
> 

Send v3 please.

