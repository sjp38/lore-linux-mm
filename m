Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D674C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 05:31:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02CCC20665
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 05:31:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02CCC20665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vx.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 602656B0003; Mon,  5 Aug 2019 01:31:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B3E76B0005; Mon,  5 Aug 2019 01:31:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47B586B0006; Mon,  5 Aug 2019 01:31:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2746A6B0003
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 01:31:25 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id n8so90914431ioo.21
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 22:31:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=4rWXaCLpl6e63mZUGWGUjYUBBJeTLdZ95yGD61DHdCc=;
        b=DAXo/BZMpagSAgEWYTivAdcR7kQubiAsthR9FPdoLIW7/z1Lkm8EOsLf+9yCwgK7iR
         VNM/XWwsJqLv0LtgzOjmOChSwN3qcN/FNyt0OZcrKvTcX4sbUjyOISYP2AmxIqJy2yrG
         yDazVODbUha5EvSxUFKcWG4ysOB5auJFnVaRT+fvFff4ARtCKOYBclInDIzJKvBi+IIo
         aUhL/nd2GXr9xlT85Il38TcUeTQHCExRzEBn9ft3+1OPboq3T14dnM6D2Ksq2nh4ZkTn
         rDaNeCVswXARLHxD3ruggHfbu2JkG5+6y/LS8wxxdCP+7T0V6gdyQ8ozJWpf7A3k3kn3
         VgiQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=t-fukasawa@vx.jp.nec.com
X-Gm-Message-State: APjAAAXec0IKIPt3MWd7qhnYO6hz7jeJTEZCJ/4Yy8XZ01//3XVlmUAD
	5eRgigc3pPt70jomfUVzPJmQOmoUb40wQ0OwPl5BmemRWicnB4LEQJEYwcAMrwjd9E59IuNvXzD
	bDSSFLttdspp1t2k53Ez1DlWswljdv83uVGnZACQ5PCcoQWJFWxPYt314XJrtNwTseA==
X-Received: by 2002:a02:b883:: with SMTP id p3mr12150044jam.79.1564983084902;
        Sun, 04 Aug 2019 22:31:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0uu8RN4AI5Ffk9ESt2OBDGx7HwShHru75FYzBVmPDL8g5PUgEbtJwcQcsbXbdaVdsz9Di
X-Received: by 2002:a02:b883:: with SMTP id p3mr12149966jam.79.1564983083839;
        Sun, 04 Aug 2019 22:31:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564983083; cv=none;
        d=google.com; s=arc-20160816;
        b=UuZ5p8LbI0T8jWk7zQlUSyhs5HqFJKWgBfsOPtFPvvQdL9SkuB+VA/g3fMhHxYBLvV
         37RDFInIJ0VdcPy/AEyFOf6wb/lErICCwjHZeKzK+vElWxpfT+hTN0WjV0olhk0KPk0y
         9GOrYihqPCVY32r169DmckXYNs5SgW8vosziYP5C6VuxkN2hma2IcqclV1Tk0aNfDRG1
         KkSSbv5JAyThEiJ0Df7NJBnBM4IAHdFwlakxB5QGflm4L0JXU/tI3sSvVF/mIFOntJt2
         1rBOaywc/XSEoLuCbL98ou1FN8QYzIxlsnkzWl3d1lpnskoVh/c3Eo2A6kSTZRiE894r
         iceg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=4rWXaCLpl6e63mZUGWGUjYUBBJeTLdZ95yGD61DHdCc=;
        b=zyG+sVT4CDr/7CUAuTskMv8NS+yeDlGaZFWa6OcBF1/KncC452jeA3iezy2kfnPhee
         g1aNJ9UQNVuBmwKWjxDEoPD4o8tL6g/c2t7i+S2Had0J5D9Y/s7gMslhu2Bj63/5+iaV
         tucuCuuJmZ/Zk0lS9er6M3xJm1S8WQ1CM9ll6NeTM5VMN7JD47+oXOf52HXeT0IBUYm2
         E4p6BjNYgVj7ZwDuvB1xnWL+vyT5JcDET8gLdsF39pvIoCAta+J7iOzsUKG2BOw8zlXZ
         0+H1nXGpkV4u+kGadoyyeHzUoyuKq5LOtz14fYtkWhXQCTySmou+m1HPjghrXCNZXWZO
         LDWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=t-fukasawa@vx.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id h18si8570017ioj.95.2019.08.04.22.31.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Aug 2019 22:31:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=t-fukasawa@vx.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x755V8XK004238
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Mon, 5 Aug 2019 14:31:08 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x755V8sK019089;
	Mon, 5 Aug 2019 14:31:08 +0900
Received: from mail03.kamome.nec.co.jp (mail03.kamome.nec.co.jp [10.25.43.7])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x755M4TE002674;
	Mon, 5 Aug 2019 14:31:08 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.152] [10.38.151.152]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-7394443; Mon, 5 Aug 2019 14:12:41 +0900
Received: from BPXM20GP.gisp.nec.co.jp ([10.38.151.212]) by
 BPXC24GP.gisp.nec.co.jp ([10.38.151.152]) with mapi id 14.03.0439.000; Mon, 5
 Aug 2019 14:12:41 +0900
From: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>
To: Michal Hocko <mhocko@kernel.org>
CC: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "dan.j.williams@intel.com" <dan.j.williams@intel.com>,
        "adobriyan@gmail.com" <adobriyan@gmail.com>, "hch@lst.de" <hch@lst.de>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        Junichi Nomura <j-nomura@ce.jp.nec.com>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: Re: [PATCH 2/2] /proc/kpageflags: do not use uninitialized struct
 pages
Thread-Topic: [PATCH 2/2] /proc/kpageflags: do not use uninitialized struct
 pages
Thread-Index: AQHVQpEKFGt+j6P+NkKoSe72QQuzoKbac7OAgAFmX4CAAAsmgIAPl5OA
Date: Mon, 5 Aug 2019 05:12:40 +0000
Message-ID: <3a926ce5-75b9-ea94-d6e4-6888872e0dc4@vx.jp.nec.com>
References: <20190725023100.31141-1-t-fukasawa@vx.jp.nec.com>
 <20190725023100.31141-3-t-fukasawa@vx.jp.nec.com>
 <20190725090341.GC13855@dhcp22.suse.cz>
 <40b3078e-fb8b-87ef-5c4e-6321956cc940@vx.jp.nec.com>
 <20190726070615.GB6142@dhcp22.suse.cz>
In-Reply-To: <20190726070615.GB6142@dhcp22.suse.cz>
Accept-Language: ja-JP, en-US
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.178.21.43]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <092F480E631D4C46AA067F5ECBA30C88@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/07/26 16:06, Michal Hocko wrote:
> On Fri 26-07-19 06:25:49, Toshiki Fukasawa wrote:
>>
>>
>> On 2019/07/25 18:03, Michal Hocko wrote:
>>> On Thu 25-07-19 02:31:18, Toshiki Fukasawa wrote:
>>>> A kernel panic was observed during reading /proc/kpageflags for
>>>> first few pfns allocated by pmem namespace:
>>>>
>>>> BUG: unable to handle page fault for address: fffffffffffffffe
>>>> [  114.495280] #PF: supervisor read access in kernel mode
>>>> [  114.495738] #PF: error_code(0x0000) - not-present page
>>>> [  114.496203] PGD 17120e067 P4D 17120e067 PUD 171210067 PMD 0
>>>> [  114.496713] Oops: 0000 [#1] SMP PTI
>>>> [  114.497037] CPU: 9 PID: 1202 Comm: page-types Not tainted 5.3.0-rc1=
 #1
>>>> [  114.497621] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), =
BIOS rel-1.11.0-0-g63451fca13-prebuilt.qemu-project.org 04/01/2014
>>>> [  114.498706] RIP: 0010:stable_page_flags+0x27/0x3f0
>>>> [  114.499142] Code: 82 66 90 66 66 66 66 90 48 85 ff 0f 84 d1 03 00 0=
0 41 54 55 48 89 fd 53 48 8b 57 08 48 8b 1f 48 8d 42 ff 83 e2 01 48 0f 44 c=
7 <48> 8b 00 f6 c4 02 0f 84 57 03 00 00 45 31 e4 48 8b 55 08 48 89 ef
>>>> [  114.500788] RSP: 0018:ffffa5e601a0fe60 EFLAGS: 00010202
>>>> [  114.501373] RAX: fffffffffffffffe RBX: ffffffffffffffff RCX: 000000=
0000000000
>>>> [  114.502009] RDX: 0000000000000001 RSI: 00007ffca13a7310 RDI: ffffd0=
7489000000
>>>> [  114.502637] RBP: ffffd07489000000 R08: 0000000000000001 R09: 000000=
0000000000
>>>> [  114.503270] R10: 0000000000000000 R11: 0000000000000000 R12: 000000=
0000240000
>>>> [  114.503896] R13: 0000000000080000 R14: 00007ffca13a7310 R15: ffffa5=
e601a0ff08
>>>> [  114.504530] FS:  00007f0266c7f540(0000) GS:ffff962dbbac0000(0000) k=
nlGS:0000000000000000
>>>> [  114.505245] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>>> [  114.505754] CR2: fffffffffffffffe CR3: 000000023a204000 CR4: 000000=
00000006e0
>>>> [  114.506401] Call Trace:
>>>> [  114.506660]  kpageflags_read+0xb1/0x130
>>>> [  114.507051]  proc_reg_read+0x39/0x60
>>>> [  114.507387]  vfs_read+0x8a/0x140
>>>> [  114.507686]  ksys_pread64+0x61/0xa0
>>>> [  114.508021]  do_syscall_64+0x5f/0x1a0
>>>> [  114.508372]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
>>>> [  114.508844] RIP: 0033:0x7f0266ba426b
>>>>
>>>> The reason for the panic is that stable_page_flags() which parses
>>>> the page flags uses uninitialized struct pages reserved by the
>>>> ZONE_DEVICE driver.
>>>
>>> Why pmem hasn't initialized struct pages?
>>
>> We proposed to initialize in previous approach but that wasn't merged.
>> (See https://marc.info/?l=3Dlinux-mm&m=3D152964792500739&w=3D2)
>>
>>> Isn't that a bug that should be addressed rather than paper over it lik=
e this?
>>
>> I'm not sure. What do you think, Dan?
>=20
> Yeah, I am really curious about details. Why do we keep uninitialized
> struct pages at all? What is a random pfn walker supposed to do? What
> kind of metadata would be clobbered? In other words much more details
> please.
>=20
I also want to know. I do not think that initializing struct pages will
clobber any metadata.

Best regards,
Toshiki Fukasawa=

