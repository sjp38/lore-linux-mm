Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89FCDC742B2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 10:53:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FBE921019
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 10:53:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FBE921019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E7988E0139; Fri, 12 Jul 2019 06:53:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BE7D8E00DB; Fri, 12 Jul 2019 06:53:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D4E78E0139; Fri, 12 Jul 2019 06:53:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3965E8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 06:53:49 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id o6so4995617plk.23
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 03:53:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=65iBrFc13JaFnS5Qc5ybRrNCPkdA57LYwjCq0CdYqdA=;
        b=PoxCa11Z1I2hLrheqrSKTO+UR2QYuz2TD9wyfrSqvIM+LQWyrjFW7tp9tnJAM/9y1J
         fCczP7bqO8YacDW8g8rBmC4jeLn2ZJ1C2fEhmeBEafMAWAjW4TbgxfbSd4BEW8DB/Bg8
         4NNI1MPgAnCGYLejsH6AEF0YGvG2MNj1kLsOikcSdrlF2e4RrwB6JNSRradoTuddtziQ
         wchAzp+zdbFgwp8twbHMPovEPlDIh4X+mSHACIdGq6ieW7YFvyPvoIp0EM1anhupj0hz
         RdRKU6AJXb4SlbDFFmSuxQNYWNRvp3NhLJBTHl0+pZ9AWehBGJVkYsZcyvko7QU2M+Bx
         k2NA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenjianhong2@huawei.com designates 45.249.212.187 as permitted sender) smtp.mailfrom=chenjianhong2@huawei.com
X-Gm-Message-State: APjAAAWwnostsUFYDbflY9nQS13KRN0Xgr+RyHZbKGRocjrchDSNJzHS
	sUvwbZEx7ThFiud8mjwEHcb1VDFSfNBV+oxgVdunQc6rU1YHb8kXBstKQkCSFBhlkBqLB1oFXQZ
	dL595st8a7GkRW3fNTUU96IiFLGqbDRF3v5Cfm8XKcbmbs9is8VdZ8md8qhK+okhhDQ==
X-Received: by 2002:a17:90a:290b:: with SMTP id g11mr10961021pjd.122.1562928828892;
        Fri, 12 Jul 2019 03:53:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzL9WxLsEYSC/uUF5i75wlk+AOo/ohKZN5DB1Fy3N2a22UX7xQYbkY4T8CMCRqdP/W3ljep
X-Received: by 2002:a17:90a:290b:: with SMTP id g11mr10960945pjd.122.1562928828126;
        Fri, 12 Jul 2019 03:53:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562928828; cv=none;
        d=google.com; s=arc-20160816;
        b=Q3xfWFNzD7kVfuVNox/H/6tSKeiUN2m3jg00HKn5fytb/YVBUm3Y3QA4zR9QlZu4eQ
         Iuo3Uuodv3zm3OoJmSCZKlCGp2W/ETtb0C7of9GQn5uD0s892zpEzO7k9VDJDusL5qzi
         X7Se2T127S5DvWT/wHa0Yp9kiOaSaOW5yWGjmwOLg/yd0RHhNSLzIkfYiNY/bPGe2Gek
         pdhyH2K8KFQ8XHzZVMpvxJnbqxWvRdLkIVmP++bIc/Y1REJvLitVsK5W8VJ/JSrPQboF
         yn7eVFED+NG1F0Z7v4UODXfZRpAvrOIGAiTHGYknjQvCj/6Hci9lSECDLbjg2TP6E6L0
         pr8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=65iBrFc13JaFnS5Qc5ybRrNCPkdA57LYwjCq0CdYqdA=;
        b=oZkocEDak316Cd701NqKQpe6juMojQl58jJH2/R8J2vQ4vSukeAC7B0RRKOj6QrClf
         CqhoWK7VkIzNZrQ7NeMiVKQO6/FEUp3Z3dWvoUHMozGe/4QsXUwaWfT94KAC0VKRsGAf
         +7eTTlAntdiOpgoeZB5BECfgR+Xc2txzElxaojjneryo9LvLpK9KVA9UYjsquwiEqhBo
         LM11bopw/UJczn5Dpsf2p8cDkAzF4cvROmqr5pHTFgnrP4/cGGuIZJp46vLQKuSFGoHs
         C4n5fiIH4vYJFRT0o+tO58nu3w097BkcTEsSzpXboZOqX60uYBewNa3IIx3+Umm+PyJF
         uTpg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenjianhong2@huawei.com designates 45.249.212.187 as permitted sender) smtp.mailfrom=chenjianhong2@huawei.com
Received: from huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id 65si7465780plf.368.2019.07.12.03.53.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 03:53:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenjianhong2@huawei.com designates 45.249.212.187 as permitted sender) client-ip=45.249.212.187;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenjianhong2@huawei.com designates 45.249.212.187 as permitted sender) smtp.mailfrom=chenjianhong2@huawei.com
Received: from DGGEMM406-HUB.china.huawei.com (unknown [172.30.72.57])
	by Forcepoint Email with ESMTP id BF800D2E2BFB2E395BE4;
	Fri, 12 Jul 2019 18:53:46 +0800 (CST)
Received: from dggeme757-chm.china.huawei.com (10.3.19.103) by
 DGGEMM406-HUB.china.huawei.com (10.3.20.214) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Fri, 12 Jul 2019 18:53:46 +0800
Received: from dggeme758-chm.china.huawei.com (10.3.19.104) by
 dggeme757-chm.china.huawei.com (10.3.19.103) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256) id
 15.1.1591.10; Fri, 12 Jul 2019 18:53:45 +0800
Received: from dggeme758-chm.china.huawei.com ([10.6.80.69]) by
 dggeme758-chm.china.huawei.com ([10.6.80.69]) with mapi id 15.01.1591.008;
 Fri, 12 Jul 2019 18:53:46 +0800
From: "chenjianhong (A)" <chenjianhong2@huawei.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: Michel Lespinasse <walken@google.com>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, "mhocko@suse.com" <mhocko@suse.com>,
	"Vlastimil Babka" <vbabka@suse.cz>, "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>, Yang Shi <yang.shi@linux.alibaba.com>,
	"jannh@google.com" <jannh@google.com>, "steve.capper@arm.com"
	<steve.capper@arm.com>, "tiny.windzz@gmail.com" <tiny.windzz@gmail.com>, LKML
	<linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>, "willy@infradead.org"
	<willy@infradead.org>, "wangle (H)" <wangle6@huawei.com>, "Chengang (L)"
	<cg.chen@huawei.com>
Subject: RE: [PATCH] mm/mmap: fix the adjusted length error
Thread-Topic: [PATCH] mm/mmap: fix the adjusted length error
Thread-Index: AQHVDHYdPcl0kS4eg0Wb8Sh+xIS/waZvfcqAgADBHlCAVcHrAIAAiW9w
Date: Fri, 12 Jul 2019 10:53:45 +0000
Message-ID: <71c4329e246344eeb38c8ac25c63c09d@huawei.com>
References: <1558073209-79549-1-git-send-email-chenjianhong2@huawei.com>
	<CANN689G6mGLSOkyj31ympGgnqxnJosPVc4EakW5gYGtA_45L7g@mail.gmail.com>
	<df001b6fbe2a4bdc86999c78933dab7f@huawei.com>
 <20190711182002.9bb943006da6b61ab66b95fd@linux-foundation.org>
In-Reply-To: <20190711182002.9bb943006da6b61ab66b95fd@linux-foundation.org>
Accept-Language: en-US
Content-Language: zh-CN
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.65.79.126]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thank you for your reply!=20
> How significant is this problem in real-world use cases?  How much troubl=
e is it causing?
   In my opinion, this problem is very rare in real-world use cases. In arm=
64
   or x86 environment, the virtual memory is enough. In arm32 environment,
   each process has only 3G or 4G or less, but we seldom use out all of the=
 virtual memory,
   it only happens in some special environment. They almost use out all the=
 virtual memory, and
   in some moment, they will change their working mode so they will release=
 and allocate
   memory again. This current length limitation will cause this problem. I =
explain it's the memory
   length limitation. But they can't accept the reason, it is unreasonable =
that we fail to allocate
   memory even though the memory gap is enough.

> Have you looked further into this?  Michel is concerned about the perform=
ance cost of the current solution.
   The current algorithm(change before) is wonderful, and it has been used =
for a long time, I don't
   think it is worthy to change the whole algorithm in order to fix this pr=
oblem. Therefore, I just
   adjust the gap_start and gap_end value in place of the length. My change=
 really affects the
   performance because I calculate the gap_start and gap_end value again an=
d again. Does it affect
   too much performance?  I have no complex environment, so I can't test it=
, but I don't think it will cause
   too much performance loss. First, I don't change the whole algorithm. Se=
cond, unmapped_area and
   unmapped_area_topdown function aren't used frequently. Maybe there are s=
ome big performance problems
   I'm not concerned about. But I think if that's not a problem, there shou=
ld be a limitation description.

-----Original Message-----
From: Andrew Morton [mailto:akpm@linux-foundation.org]=20
Sent: Friday, July 12, 2019 9:20 AM
To: chenjianhong (A) <chenjianhong2@huawei.com>
Cc: Michel Lespinasse <walken@google.com>; Greg Kroah-Hartman <gregkh@linux=
foundation.org>; mhocko@suse.com; Vlastimil Babka <vbabka@suse.cz>; Kirill =
A. Shutemov <kirill.shutemov@linux.intel.com>; Yang Shi <yang.shi@linux.ali=
baba.com>; jannh@google.com; steve.capper@arm.com; tiny.windzz@gmail.com; L=
KML <linux-kernel@vger.kernel.org>; linux-mm <linux-mm@kvack.org>; stable@v=
ger.kernel.org; willy@infradead.org
Subject: Re: [PATCH] mm/mmap: fix the adjusted length error

On Sat, 18 May 2019 07:05:07 +0000 "chenjianhong (A)" <chenjianhong2@huawei=
.com> wrote:

> I explain my test code and the problem in detail. This problem is=20
> found in 32-bit user process, because its virtual is limited, 3G or 4G.
>=20
> First, I explain the bug I found. Function unmapped_area and=20
> unmapped_area_topdowns adjust search length to account for worst case=20
> alignment overhead, the code is ' length =3D info->length + info->align_m=
ask; '.
> The variable info->length is the length we allocate and the variable
> info->align_mask accounts for the alignment, because the gap_start  or=20
> info->gap_end
> value also should be an alignment address, but we can't know the alignmen=
t offset.
> So in the current algorithm, it uses the max alignment offset, this=20
> value maybe zero or other(0x1ff000 for shmat function).
> Is it reasonable way? The required value is longer than what I allocate.
> What's more,  why for the first time I can allocate the memory=20
> successfully Via shmat, but after releasing the memory via shmdt and I=20
> want to attach again, it fails. This is not acceptable for many people.
>=20
> Second, I explain my test code. The code I have sent an email. The=20
> following is the step. I don't think it's something unusual or=20
> unreasonable, because the virtual memory space is enough, but the=20
> process can allocate from it. And we can't pass explicit addresses to=20
> function mmap or shmat, the address is getting from the left vma gap.
>  1, we allocat large virtual memory;
>  2, we allocate hugepage memory via shmat, and release one  of the=20
> hugepage memory block;  3, we allocate hugepage memory by shmat again,=20
> this will fail.

How significant is this problem in real-world use cases?  How much trouble =
is it causing?

> Third, I want to introduce my change in the current algorithm. I don't=20
> change the current algorithm. Also, I think there maybe a better way=20
> to fix this error. Nowadays, I can just adjust the gap_start value.

Have you looked further into this?  Michel is concerned about the performan=
ce cost of the current solution.

