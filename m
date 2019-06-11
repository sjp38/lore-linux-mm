Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F362FC43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:17:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3DD9206E0
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:17:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3DD9206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E88D6B0006; Tue, 11 Jun 2019 08:17:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BF256B0007; Tue, 11 Jun 2019 08:17:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D4B96B0008; Tue, 11 Jun 2019 08:17:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3EC366B0007
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 08:17:17 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id p19so2193660itm.3
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 05:17:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=pKauZ5NRH5UfCjW9vvwssv5JXZ33gqhTzKf8/XYL2Qg=;
        b=HlvZG7D6Rbq2Z3y90UzApUrwVXIhJRf3dNa0OhKXUwLtcfZ5QsFlILbSUjPMPs1mL4
         cjWTlxYS6iHZBo/rXV11RiU/SL9uGFVmOqPOelLwULF6vTY8zAxRWv3QF1XciwitsC7j
         L0itoFykz5oS6NNukv1nZfTlmxDEoI0nEH1OUhMmZcNSdRIpj4spCkHtNO4kOpEIOvvP
         KkBXeBec4AKQvm96VH+KOJapGy3U31avUtfpSogiFBfSSRRDDuvvzosISMCsejKXn+BO
         kloF8oDpYHAYnQ9sIab6WyKHG6LTO1+ytsTT2/qZ+j++Dx5dI+25RNVylfgWWC1qlDYf
         TkxA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of cg.chen@huawei.com designates 45.249.212.187 as permitted sender) smtp.mailfrom=cg.chen@huawei.com
X-Gm-Message-State: APjAAAVuw9RJyve6fwDU+iWiaQKTgfq0V9N+9mHTP6wNQqzQvO5xl9XF
	NL7q5rjb7wStohdcmOvYR43KvatOnLFGyvPiZW8W7Imi2bRRg/101Sp0Vj4vUJjY/UXzgAxjkdv
	i0/k0EYoiD+gdRU6XxmJd43Pt3xi9cCl5GYBbZ13NAWMdwQy5JysWhH3Us6pTWB5oqQ==
X-Received: by 2002:a02:3b55:: with SMTP id i21mr49472363jaf.128.1560255437044;
        Tue, 11 Jun 2019 05:17:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWclDxXv+CMsBcq/d44jCU1ikGyI9AdV2yZCOLYimidqS4C2OE3IaFxoHWN3vpuO6LATK4
X-Received: by 2002:a02:3b55:: with SMTP id i21mr49472232jaf.128.1560255435040;
        Tue, 11 Jun 2019 05:17:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560255435; cv=none;
        d=google.com; s=arc-20160816;
        b=MuNiYQWnXq5tuMX+thg41EMhCB/2SqF4TZAEqga/yDCqErvZsecPdMUMmHl1u87ytb
         oBW+/nzegQErUEvldnGf421l1IND2F+jJQS8D2cFoMsG0+0JlWGHARQqPSVCAiIxUsAQ
         SqvGc8kaocn0kG5d6MwGk96Dqgdh+MdpV2GofWraMLldiHBF932dzIClwBs6ezHTKRmF
         m0GMCgP7UW5RRur0OOmt2fV+0wRInVjnOLo7J7k7PgORhlTbQkZCQPh7zzzj9Qz5LVj3
         mYsYfxczIclbS/HvFhX2PAPs9c+SZD7pWxjmP6VcyMPaR9th+/XqaFTKzymGoN/v9YLP
         tHlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from;
        bh=pKauZ5NRH5UfCjW9vvwssv5JXZ33gqhTzKf8/XYL2Qg=;
        b=Yu7hwtJCnTUhka7aZXUkteFABTqI1jEs1n3vOSiXXvdGtnN5oaePmJg+khePbfYI42
         kbSRAjKKn/Y+BYK8RwPPcPhYW8rZ1B/GkKB05KG57z5BBeYjosb8G6L4ZP5Kuu9zrp26
         gM45nd6orfWKBDZOx8uqFCX0ymGGMhBZ+EdaMIqLHbKXb/OXz9lbaiC5ITu02EBQXE90
         3x07OIwQxCAQxYgvcARbxkr/IA7266la/WSZzw/jzN23Z/4VMqyFKprM88hqu15tGA5O
         7KI3fg5M8QFGQbNvgKfh7a2RHxdvhdP9ud5G1ROHaI6sZOnncj2CPobTEhsh1zfj/Ovm
         gyDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of cg.chen@huawei.com designates 45.249.212.187 as permitted sender) smtp.mailfrom=cg.chen@huawei.com
Received: from huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id s20si7652122iom.2.2019.06.11.05.17.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 05:17:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of cg.chen@huawei.com designates 45.249.212.187 as permitted sender) client-ip=45.249.212.187;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of cg.chen@huawei.com designates 45.249.212.187 as permitted sender) smtp.mailfrom=cg.chen@huawei.com
Received: from dggemi403-hub.china.huawei.com (unknown [172.30.72.56])
	by Forcepoint Email with ESMTP id 542341CB09A22907BC29;
	Tue, 11 Jun 2019 20:16:42 +0800 (CST)
Received: from DGGEMI529-MBS.china.huawei.com ([169.254.5.79]) by
 dggemi403-hub.china.huawei.com ([10.3.17.136]) with mapi id 14.03.0415.000;
 Tue, 11 Jun 2019 20:16:35 +0800
From: "Chengang (L)" <cg.chen@huawei.com>
To: Michal Hocko <mhocko@kernel.org>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz"
	<vbabka@suse.cz>, "osalvador@suse.de" <osalvador@suse.de>,
	"pavel.tatashin@microsoft.com" <pavel.tatashin@microsoft.com>,
	"mgorman@techsingularity.net" <mgorman@techsingularity.net>,
	"rppt@linux.ibm.com" <rppt@linux.ibm.com>, "richard.weiyang@gmail.com"
	<richard.weiyang@gmail.com>, "alexander.h.duyck@linux.intel.com"
	<alexander.h.duyck@linux.intel.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm: align up min_free_kbytes to multipy of 4
Thread-Topic: [PATCH] mm: align up min_free_kbytes to multipy of 4
Thread-Index: AdUgTpdGfX4K+yczTYe6f6nhJDDS/w==
Date: Tue, 11 Jun 2019 12:16:35 +0000
Message-ID: <D27E5778F399414A8B5D5F672064BAD8B3E5FB7B@dggemi529-mbs.china.huawei.com>
Accept-Language: en-US
Content-Language: zh-CN
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.74.216.69]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Michal


>On Sun 09-06-19 17:10:28, ChenGang wrote:
>> Usually the value of min_free_kbytes is multiply of 4, and in this=20
>> case ,the right shift is ok.
>> But if it's not, the right-shifting operation will lose the low 2=20
>> bits, and this cause kernel don't reserve enough memory.
>> So it's necessary to align the value of min_free_kbytes to multiply of 4=
.
>> For example, if min_free_kbytes is 64, then should keep 16 pages, but=20
>> if min_free_kbytes is 65 or 66, then should keep 17 pages.

>Could you describe the actual problem? Do we ever generate min_free_kbytes=
 that would lead to unexpected reserves or is this trying to compensate for=
 those values being configured from the userspace? If later why do we care =
at all?

>Have you seen this to be an actual problem or is this mostly motivated by =
the code reading?

I haven't seen an actual problem, and it's motivated by code reading.  User=
s can configure this value through interface /proc/sys/vm/min_free_kbytes, =
so I think a bit precious is better.

>> Signed-off-by: ChenGang <cg.chen@huawei.com>
>> ---
>>  mm/page_alloc.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>=20
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c index d66bc8a..1baeeba=20
>> 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -7611,7 +7611,8 @@ static void setup_per_zone_lowmem_reserve(void)
>> =20
>>  static void __setup_per_zone_wmarks(void)  {
>> -	unsigned long pages_min =3D min_free_kbytes >> (PAGE_SHIFT - 10);
>> +	unsigned long pages_min =3D
>> +		(PAGE_ALIGN(min_free_kbytes * 1024) / 1024) >> (PAGE_SHIFT - 10);
>>  	unsigned long lowmem_pages =3D 0;
>>  	struct zone *zone;
>>  	unsigned long flags;
>> --
>> 1.8.5.6
>>=20

>--=20
>Michal Hocko
>SUSE Labs

