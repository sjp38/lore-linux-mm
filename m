Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7984C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 06:33:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BC13218DA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 06:33:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BC13218DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vx.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E99A96B0003; Fri, 26 Jul 2019 02:33:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E23FA6B0005; Fri, 26 Jul 2019 02:33:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC3826B0006; Fri, 26 Jul 2019 02:33:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id AC7C96B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 02:33:31 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id p12so57594844iog.19
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 23:33:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=v/UwByuQo3Qe6V7/RXYBu0q1K5X+buHE4XjdGYVx19k=;
        b=MX+2NZUSBLS14Tbp50hUhr/RoPXEsRduC3lIp89VEUh1W5+wJdFNMY1NEWi99BmvHD
         /FatJae9H8tOLWphzr2FXATl8Fza1gXslG9nEAbBhR+DWzNv1Qg1X7RuuwPk6JVnw3Tn
         8Xth07o4kEMQnjLo5Raio/jOVmWS8VWSASUr0HLHuK6EbzXCUYaBAbgPdl+9Pk+Jx0i0
         nYFhzKlKiZwohYJF6XB4UcW+q7K+XGHOcVF+Q24RO9wXjK4Gj4Bg9OyJd0WuZS8kvAQe
         PEakhP4obdjHQxPCXW7q8xCLfJQ8mycYAVqMpyxi2b+UIBKri3DVZQSNgsSj2QEO4bfU
         fjNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=t-fukasawa@vx.jp.nec.com
X-Gm-Message-State: APjAAAUB3BzO2Ec4hMPmf3F6hZID7yjE5Rf5UBBPlERYBiuonpdMdNLx
	Ca50u6VJSVklwJ+skD6d3OggXKo5uyhTfkDZ1EXCocHOIYz1uWYH44slKYUO8yTHkYgQqJEZT62
	AErRYAC2RB/za/tmbEXi5BDBc+yj4FQtKGdeVMTo7rIUuaNteDg9v0mnKrGHru/lZQQ==
X-Received: by 2002:a02:b883:: with SMTP id p3mr22812301jam.79.1564122811439;
        Thu, 25 Jul 2019 23:33:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDjYIv/P0ZTYOjnPGfzlj+5j4IyVvEjdqlQUw/APtd0l4QS/5SkgIq4xhoXGsif1/wsd3G
X-Received: by 2002:a02:b883:: with SMTP id p3mr22812235jam.79.1564122810650;
        Thu, 25 Jul 2019 23:33:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564122810; cv=none;
        d=google.com; s=arc-20160816;
        b=03VgOlfBNEFF68i8EYBkSbogZUg80J1ZNPasgDEzqqD/qUkFQEK6UnYF+JhGgm0w50
         KS8ky9R7k1Lbqhf36EVxoKEwbLMQY1Ax6m7TfLvwAH8tc6BAUEy3XTz+ISc7B6BE9eKB
         x/RPx653Gw5GGgOxdWH0rQyeOSCXMQRS+Jz2EELqQeTfAzyXClf4HBtrbKTXW9zgMARu
         8CXnWjZBpyxBzlTsibnuQeXTAyNPE7anz3Z8ohilcQTQ6V43AlTpto7xzmelpkT14/EF
         HHk7iLD5h9qWexSo5HnqevifVkUhXhlHgczub5Tzjn2gO9NecI8gvtFZud1XclCUDw3A
         hZ9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=v/UwByuQo3Qe6V7/RXYBu0q1K5X+buHE4XjdGYVx19k=;
        b=g7eqZGR3eb9VqQr8/P8AWcq/LWGZ8QsfTULWduCBSXzVo/N85hOEWM6/lOc6520yeM
         SEfBa6KEYzfs2DAWZ3YmExU8qHDPLgVrYmN4N1gchM6TIfMwU9b1pF2lGzMlWCQox4Wc
         aB/kj0Qe3Z57CbvU8TmtJfTPhqHGcWtkUfK/gfOloiKRdgf0Sr/tIZRhz3U+w3ADor37
         ilB6pg71BEiiGbRMkX+O0VC+3R9E8wRt2HPm6dtErxbPV42i2XmmcnsO7T9yu1j9exby
         xwDKVr8BG95Ut1j225C7Px14Cek9cPYKX8mwOXwTYaFIwcLZvLDqTL+L9ilYIn6hQ7E3
         M5sA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=t-fukasawa@vx.jp.nec.com
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id e8si77290188jaj.110.2019.07.25.23.33.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 23:33:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.161 as permitted sender) client-ip=114.179.232.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=t-fukasawa@vx.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x6Q6XF0g009534
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Fri, 26 Jul 2019 15:33:15 +0900
Received: from mailsv02.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x6Q6XFnI026172;
	Fri, 26 Jul 2019 15:33:15 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x6Q6TpBq025337;
	Fri, 26 Jul 2019 15:33:15 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.152] [10.38.151.152]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-7142931; Fri, 26 Jul 2019 15:25:51 +0900
Received: from BPXM20GP.gisp.nec.co.jp ([10.38.151.212]) by
 BPXC24GP.gisp.nec.co.jp ([10.38.151.152]) with mapi id 14.03.0439.000; Fri,
 26 Jul 2019 15:25:50 +0900
From: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>
To: Michal Hocko <mhocko@kernel.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
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
Thread-Index: AQHVQpEKFGt+j6P+NkKoSe72QQuzoKbac7OAgAFmX4A=
Date: Fri, 26 Jul 2019 06:25:49 +0000
Message-ID: <40b3078e-fb8b-87ef-5c4e-6321956cc940@vx.jp.nec.com>
References: <20190725023100.31141-1-t-fukasawa@vx.jp.nec.com>
 <20190725023100.31141-3-t-fukasawa@vx.jp.nec.com>
 <20190725090341.GC13855@dhcp22.suse.cz>
In-Reply-To: <20190725090341.GC13855@dhcp22.suse.cz>
Accept-Language: ja-JP, en-US
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.135]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <565C14CFB150684B823E03D090635792@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/07/25 18:03, Michal Hocko wrote:
> On Thu 25-07-19 02:31:18, Toshiki Fukasawa wrote:
>> A kernel panic was observed during reading /proc/kpageflags for
>> first few pfns allocated by pmem namespace:
>>
>> BUG: unable to handle page fault for address: fffffffffffffffe
>> [  114.495280] #PF: supervisor read access in kernel mode
>> [  114.495738] #PF: error_code(0x0000) - not-present page
>> [  114.496203] PGD 17120e067 P4D 17120e067 PUD 171210067 PMD 0
>> [  114.496713] Oops: 0000 [#1] SMP PTI
>> [  114.497037] CPU: 9 PID: 1202 Comm: page-types Not tainted 5.3.0-rc1 #=
1
>> [  114.497621] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BI=
OS rel-1.11.0-0-g63451fca13-prebuilt.qemu-project.org 04/01/2014
>> [  114.498706] RIP: 0010:stable_page_flags+0x27/0x3f0
>> [  114.499142] Code: 82 66 90 66 66 66 66 90 48 85 ff 0f 84 d1 03 00 00 =
41 54 55 48 89 fd 53 48 8b 57 08 48 8b 1f 48 8d 42 ff 83 e2 01 48 0f 44 c7 =
<48> 8b 00 f6 c4 02 0f 84 57 03 00 00 45 31 e4 48 8b 55 08 48 89 ef
>> [  114.500788] RSP: 0018:ffffa5e601a0fe60 EFLAGS: 00010202
>> [  114.501373] RAX: fffffffffffffffe RBX: ffffffffffffffff RCX: 00000000=
00000000
>> [  114.502009] RDX: 0000000000000001 RSI: 00007ffca13a7310 RDI: ffffd074=
89000000
>> [  114.502637] RBP: ffffd07489000000 R08: 0000000000000001 R09: 00000000=
00000000
>> [  114.503270] R10: 0000000000000000 R11: 0000000000000000 R12: 00000000=
00240000
>> [  114.503896] R13: 0000000000080000 R14: 00007ffca13a7310 R15: ffffa5e6=
01a0ff08
>> [  114.504530] FS:  00007f0266c7f540(0000) GS:ffff962dbbac0000(0000) knl=
GS:0000000000000000
>> [  114.505245] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [  114.505754] CR2: fffffffffffffffe CR3: 000000023a204000 CR4: 00000000=
000006e0
>> [  114.506401] Call Trace:
>> [  114.506660]  kpageflags_read+0xb1/0x130
>> [  114.507051]  proc_reg_read+0x39/0x60
>> [  114.507387]  vfs_read+0x8a/0x140
>> [  114.507686]  ksys_pread64+0x61/0xa0
>> [  114.508021]  do_syscall_64+0x5f/0x1a0
>> [  114.508372]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
>> [  114.508844] RIP: 0033:0x7f0266ba426b
>>
>> The reason for the panic is that stable_page_flags() which parses
>> the page flags uses uninitialized struct pages reserved by the
>> ZONE_DEVICE driver.
>=20
> Why pmem hasn't initialized struct pages?=20

We proposed to initialize in previous approach but that wasn't merged.
(See https://marc.info/?l=3Dlinux-mm&m=3D152964792500739&w=3D2)

> Isn't that a bug that should be addressed rather than paper over it like =
this?

I'm not sure. What do you think, Dan?

Best regards,
Toshiki Fukasawa=

