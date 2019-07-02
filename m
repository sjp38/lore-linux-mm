Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F8B2C5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 23:27:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF39D219BE
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 23:27:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tKlI879d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF39D219BE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=roeck-us.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5EB026B0003; Tue,  2 Jul 2019 19:27:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 59B078E0003; Tue,  2 Jul 2019 19:27:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48A978E0001; Tue,  2 Jul 2019 19:27:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6E96B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 19:27:15 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id e7so239885plt.13
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 16:27:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:subject:to:cc:references
         :from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=sIW4c2nsoK1zg9iPJ9PWWFYICxxuZVhWWS0PGONCcT8=;
        b=JAtDxV8jb09Gm83Foa0IeAeLut0ldRSJzvLkszhTrE2sRDVetsfPvdjt1JZ2dRBjJe
         8vLMCHNATr/EhZ1QoAk+zMF9zw+ZJaxRJrNi/JZzccISK+8imo7uNIOq+++3iKxFYuWp
         i8jytLoNxMfMLmo4Drm5BCfK96udgicZ5ZZaZxIBNhJ8OzCiZxss2q3l3QxWuoYCx6zy
         eQpbbdpSgLPjxGSYAJSvrvRarpOSrr8OliElafgxTxAhmzykLWpRhV86ht93ZZB30HMy
         lfi+aiR3632Muexj1nUp8kTkfL2TJaj/vqCVgVNUik7/SlkVtwOjy2mDcJ79Z2MhDZRb
         SWEQ==
X-Gm-Message-State: APjAAAUFzdDZR97bM9so+wxngy/EpDyQscWRiBrMUbSTOwecV6M+T2gn
	q/UBybVAUmZdGsgtgAhy5b0/qv8562RZSuOgtV2k46FAZY7V8PHH9TCa61lpNT6bsVXXy/0e5EK
	B4TBP6JYQxiIVNJPkOg39lyW6ez5y6/VEXz8RvDUNGDlVPC06gPE52VofveYL5Qc=
X-Received: by 2002:a17:902:2aab:: with SMTP id j40mr36523746plb.76.1562110034725;
        Tue, 02 Jul 2019 16:27:14 -0700 (PDT)
X-Received: by 2002:a17:902:2aab:: with SMTP id j40mr36523695plb.76.1562110033924;
        Tue, 02 Jul 2019 16:27:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562110033; cv=none;
        d=google.com; s=arc-20160816;
        b=sZqWjHAW/6xBKisN7MZcRA23dKgIkNZjw/ZxEZEfobDwsKCxWQP5Ti+/fkVGgELt7j
         6Uq+qBotWSrOVVLKSEVxDdCvRjc06rO+aWm3z2uE60oDjN6SSVUEYUJRZ8hZ/RHGtWco
         zOArOal4lXgVyazIeDN+IsuJGDPvQ4s6Qdd9E6OsxHm09br3xBJmrEET925wbZk5JOY0
         dtoogHdwxC/9wP2udGxMpyEvqbfVhk+Eclh1oLcfLuNb44oMGIjBvszoHu/kae7loi68
         A7hiHQne5C7wL3WF1ueHz1wLlaFUZ1j48PRa8HgEY3OF9Qt/WdQlmW9A4A6TKjsuD6TR
         n4ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject:sender
         :dkim-signature;
        bh=sIW4c2nsoK1zg9iPJ9PWWFYICxxuZVhWWS0PGONCcT8=;
        b=HuGqII2etFyAzFI5SUHDTHb9bFi2z++BE7qOclPxfKYGI9U1dEGdHljnYN3FZFinLm
         RGjb1xyJtFctP/4OE8pWfpYEGJfA3jOBarQwpwDKHPC+oqoe+D2Jce5Jz8GLtmtABMl/
         NhWiahoxm8FpBIoFMzIPsAV2KaRHvbjhqJDWTXAGFkFuZ+R/l6elN6mWkBtqkug5IbTC
         VfaGECp5ca+kOnts3tWWI37guIqFI8uii96D0XbxwVthG1pxnInJH1DsNyzQfqAxN5XB
         0FsixYcw8Uj5hAnIGZZmrMwvMdC5sTJzXHe7AblegJ4CUNKckTkVHuMu/TmnrCmF+ow2
         KIYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tKlI879d;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 101sor648127plf.70.2019.07.02.16.27.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 16:27:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tKlI879d;
       spf=pass (google.com: domain of groeck7@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck7@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=sIW4c2nsoK1zg9iPJ9PWWFYICxxuZVhWWS0PGONCcT8=;
        b=tKlI879d6GOCn5/viRbA8CB+2LHjMm+LHx8vu35g2JtHmWRh1MS1K2Oq0gOO4uanyd
         c15xofeqIVhd7SStkRQtGGQG8ogXRpToC2cmZoqBYxGBLvl9kjjYZ0xuo8mFYG1VEsLy
         ikmPD7gHqGybsUQltdIn7Jjmkd2wmRlohhi8jmnbU3YIPRnW77+JMRLFQ8emQ6GOC9vD
         mkgfNh+CChWY9/02UtCZY5Z4d/iptGSMjM4I4uAS4y3vUxK4UYVODhXk0yUlEZGc668+
         VgBtNszBl2lr0RVPKRfw91a/mbIqdV4lCzbBpKDNJSCzW2vG9+iNlMhl4b9cvPnPb3/T
         F3hg==
X-Google-Smtp-Source: APXvYqyoBXu4AyqKJhdPuz9LblEnnUpotkfLl9gMkZHnkxwo6EMqYJPvNrNLG2nCtlyB3nXPt7OwmA==
X-Received: by 2002:a17:902:467:: with SMTP id 94mr37806898ple.131.1562110033549;
        Tue, 02 Jul 2019 16:27:13 -0700 (PDT)
Received: from server.roeck-us.net ([2600:1700:e321:62f0:329c:23ff:fee3:9d7c])
        by smtp.gmail.com with ESMTPSA id v22sm186381pgk.69.2019.07.02.16.27.11
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 16:27:12 -0700 (PDT)
Subject: Re: [PATCH -next] mm: Mark undo_dev_pagemap as __maybe_unused
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Stephen Rothwell <sfr@canb.auug.org.au>,
 Robin Murphy <robin.murphy@arm.com>, linux-kernel@vger.kernel.org,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
References: <1562072523-22311-1-git-send-email-linux@roeck-us.net>
 <20190702135418.ce51c988e88ca0d9546a2a11@linux-foundation.org>
From: Guenter Roeck <linux@roeck-us.net>
Message-ID: <fa5137e4-478a-94b6-f0ae-28d48f53825e@roeck-us.net>
Date: Tue, 2 Jul 2019 16:27:10 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <20190702135418.ce51c988e88ca0d9546a2a11@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/2/19 1:54 PM, Andrew Morton wrote:
> On Tue,  2 Jul 2019 06:02:03 -0700 Guenter Roeck <linux@roeck-us.net> wrote:
> 
>> Several mips builds generate the following build warning.
>>
>> mm/gup.c:1788:13: warning: 'undo_dev_pagemap' defined but not used
>>
>> The function is declared unconditionally but only called from behind
>> various ifdefs. Mark it __maybe_unused.
>>
>> ...
>>
>> --- a/mm/gup.c
>> +++ b/mm/gup.c
>> @@ -1785,7 +1785,8 @@ static inline pte_t gup_get_pte(pte_t *ptep)
>>   }
>>   #endif /* CONFIG_GUP_GET_PTE_LOW_HIGH */
>>   
>> -static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
>> +static void __maybe_unused undo_dev_pagemap(int *nr, int nr_start,
>> +					    struct page **pages)
>>   {
>>   	while ((*nr) - nr_start) {
>>   		struct page *page = pages[--(*nr)];
> 
> It's not our preferred way of doing it but yes, it would be a bit of a
> mess and a bit of a maintenance burden to get the ifdefs correct.
> 
That is why I did it here. I understand that some maintainers don't like it,
and I noticed that it wasn't used elsewhere in the file, but it seemed to be
to most straightforward solution.

> And really, __maybe_unused isn't a bad way at all - it ensures that the
> function always gets build-tested and the compiler will remove it so we
> don't have to play the chase-the-ifdefs game.
> 
Yes, it does have its advantages. I like it myself, but usually I would not
impose my opinion on others. In this case, anything else would have been
quite awkward and be prone to never-ending adjustments.

Thanks,
Guenter

