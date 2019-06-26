Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2868CC48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 19:48:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE8262085A
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 19:48:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="rUBcLKYA";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="aQE/L3Te"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE8262085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 553176B0005; Wed, 26 Jun 2019 15:48:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50C068E0003; Wed, 26 Jun 2019 15:48:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37CBE8E0002; Wed, 26 Jun 2019 15:48:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 157686B0005
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 15:48:07 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id q79so6860260ywg.13
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 12:48:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=TAsQ5pLU1WoayGWYitaI3duMZeo+ItUXK2h0Ul4mqig=;
        b=t2CJzI4KzoxuI5Pci4BorsN8Kyr6vM+11BjYT0IwBeDmIIR084LOcacWqiWtVVVi59
         awhFOLvqNn1cK3LwWaiiBe1tJJaRK23DMzyWIhXdIwTRvYyEjW6XD33uU4AhcdEkVM8M
         khI1zo4IS3LrVEi8laXfNN8BLrPA4c6/eNxaOJnqKm1EYGwUR0zy5nCOLfczP6miPUAu
         BNJOillQz6NPGjJol3IWyQ5BdY6n00n8hOUXcmYeALaJP0YZYs1XNXc4enlg65T3YGXl
         +Fs/aFbbyba8zaYTo3fIZvkH6d2xxf9hSseD3qgKNmwvfFh88j1bepj3maEZC4sriiuo
         ViAg==
X-Gm-Message-State: APjAAAWETmIbq7f6591e90XXOUlnj/8nBMEdfLxS3pYMjDDyYEKW8lfh
	tbYgduQDRcIqs1ALP5iEucTQuAQIzP6cGsnMZiz1xv7oHjgH4k6yEto+gDlCOhgXt9SPPhcK+n/
	g9D4YAMqWcQIzcnIOgsCsAHcSuahUm/3EJFo261YeaM9KylGFJPnTzSDb5ZMQJZAplg==
X-Received: by 2002:a05:6902:4f1:: with SMTP id w17mr50935ybs.277.1561578486779;
        Wed, 26 Jun 2019 12:48:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPArQUyW9O6NF+Qkg73IbRtE3SveIbS0retHbcxpK7w/H7D5VvdObTh9JAwuLJkYGw3iZa
X-Received: by 2002:a05:6902:4f1:: with SMTP id w17mr50906ybs.277.1561578485952;
        Wed, 26 Jun 2019 12:48:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561578485; cv=none;
        d=google.com; s=arc-20160816;
        b=RWrSSU8WnB++Tdj+frJcbJt3JO43nBZAD7QPRrae45f9YgwckcfAPnRxjJz7/S9XYX
         XSa6i+SC+pJRsBU4AMEuPdcZhEm5PvNDB7TohBVBbZzhBsZsd0LZ4180uhQ0UnjCbCsf
         E1YPzZB0F7Q5JZ4q7zI7PmV1PFxcx7hU3WZkMLj7OQSjKs+6gm3Sa92UotADAola/ut7
         xWi8rYsIvEyVdZC/LGQ38ZQWt9M/KT7vhPpVswFLmYBEeQEP5x9qMrUY6VNAg9oraSwP
         R3kKA2bAJPGUcLUMvSdTdvXtTwJgsEFtjEiXXV+lnkgWqF+aeWndMbmPcGQM/cZ7KZJH
         Y75Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=TAsQ5pLU1WoayGWYitaI3duMZeo+ItUXK2h0Ul4mqig=;
        b=t/cTcChWT97R7qBQOpmyyUDQPmWM+NoUmRzPRlt+sYcZ5rypoKrWESLGzKIec7JpZv
         PSiJTVg/3KPGMeGzedjZbQ9U1XHytPMu4MlcUywL2OafqQDUULMXgfJN3XTEwe9V6gSb
         15oGWW9h3hz7kcA6KlxazHFQt2ZtkigMd4gCHtjIyhtQr3dOczQmEbkqM869E7xNMjhr
         9hoSKKQ+dZBUk3STxr5M70EhPIJXGmg8NALYPkvfQBu8bjbF4grkbJZ+TunCqCY9pXCo
         NQsSGyrRryymrTrC99ANj6gmsNqAgexXzZHu2Eep/RsDi/R+kEMWj7KWEnZi7xNe8LrR
         zWHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=rUBcLKYA;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="aQE/L3Te";
       spf=pass (google.com: domain of prvs=10801e5284=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10801e5284=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id q1si4393231ybk.44.2019.06.26.12.48.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 12:48:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10801e5284=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=rUBcLKYA;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="aQE/L3Te";
       spf=pass (google.com: domain of prvs=10801e5284=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10801e5284=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5QJlbbV001910;
	Wed, 26 Jun 2019 12:47:51 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=TAsQ5pLU1WoayGWYitaI3duMZeo+ItUXK2h0Ul4mqig=;
 b=rUBcLKYAEb48Mgy5xAd3UbkT3rOl2wJSjRjXi8RlqljxheFqUibFWuZs4v1+r4P4M0vR
 pTtSr7KVz7p7R9bBT6K/HOHdizufGAvcS9I3qeTChdi2Atob+3kOWhY3xpF6f/t/DVPn
 Ob8L/uMJ6I8aHIT4/B3gP1hMnX9nV21y0ds= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2tc32rjpds-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 26 Jun 2019 12:47:51 -0700
Received: from prn-hub06.TheFacebook.com (2620:10d:c081:35::130) by
 prn-hub02.TheFacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 26 Jun 2019 12:47:50 -0700
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.30) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 26 Jun 2019 12:47:50 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=TAsQ5pLU1WoayGWYitaI3duMZeo+ItUXK2h0Ul4mqig=;
 b=aQE/L3TeWYoXZCHcbc9Et+80OIdWE+IJtzY6f4A/yO2Qk9NIIAhD5fG/A0Yjp1NPEjEgg0/LndC453FY6CwyEE7g5+BzTPpQBapInDk/HwdSf8672l6eC6NElseRRCgooYhYlbiSW6srxlnIYJMvnKCKkWdweQHUuJSxra/60C0=
Received: from BN8PR15MB2626.namprd15.prod.outlook.com (20.179.137.220) by
 BN8PR15MB2898.namprd15.prod.outlook.com (20.178.219.33) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Wed, 26 Jun 2019 19:47:49 +0000
Received: from BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::e594:155f:a43:92ad]) by BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::e594:155f:a43:92ad%6]) with mapi id 15.20.2008.018; Wed, 26 Jun 2019
 19:47:48 +0000
From: Roman Gushchin <guro@fb.com>
To: Shakeel Butt <shakeelb@google.com>
CC: Johannes Weiner <hannes@cmpxchg.org>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>,
        Michal Hocko <mhocko@kernel.org>,
        Andrew Morton
	<akpm@linux-foundation.org>,
        David Rientjes <rientjes@google.com>,
        "KOSAKI
 Motohiro" <kosaki.motohiro@jp.fujitsu.com>,
        Tetsuo Handa
	<penguin-kernel@i-love.sakura.ne.jp>,
        Paul Jackson <pj@sgi.com>, Nick Piggin
	<npiggin@suse.de>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com"
	<syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com>
Subject: Re: [PATCH v3 3/3] oom: decouple mems_allowed from
 oom_unkillable_task
Thread-Topic: [PATCH v3 3/3] oom: decouple mems_allowed from
 oom_unkillable_task
Thread-Index: AQHVKtOgPwd2cEqAckWsZxUJJC3GJKauWmKA
Date: Wed, 26 Jun 2019 19:47:48 +0000
Message-ID: <20190626194743.GA24698@tower.DHCP.thefacebook.com>
References: <20190624212631.87212-1-shakeelb@google.com>
 <20190624212631.87212-3-shakeelb@google.com>
In-Reply-To: <20190624212631.87212-3-shakeelb@google.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR13CA0029.namprd13.prod.outlook.com
 (2603:10b6:300:95::15) To BN8PR15MB2626.namprd15.prod.outlook.com
 (2603:10b6:408:c7::28)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:5c5c]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 94862ecf-5556-4018-c707-08d6fa6f2aa4
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BN8PR15MB2898;
x-ms-traffictypediagnostic: BN8PR15MB2898:
x-microsoft-antispam-prvs: <BN8PR15MB2898FCDCD1EC8F0C3CB6B277BEE20@BN8PR15MB2898.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:4502;
x-forefront-prvs: 00808B16F3
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(346002)(39860400002)(376002)(136003)(396003)(199004)(189003)(54534003)(86362001)(6512007)(71200400001)(8676002)(305945005)(66476007)(9686003)(33656002)(14444005)(386003)(2906002)(4326008)(73956011)(256004)(66946007)(66556008)(7736002)(102836004)(1076003)(71190400001)(6506007)(66446008)(81156014)(186003)(45080400002)(7416002)(52116002)(14454004)(6916009)(46003)(81166006)(64756008)(478600001)(316002)(8936002)(99286004)(5660300002)(53936002)(6116002)(486006)(68736007)(476003)(11346002)(76176011)(25786009)(6246003)(54906003)(6486002)(446003)(6436002)(229853002);DIR:OUT;SFP:1102;SCL:1;SRVR:BN8PR15MB2898;H:BN8PR15MB2626.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 1WZxrbhKVrHHI36V/vvx2K6pHFfqb8eiC4lklzC4CZsC3swJhafc3irBKVu9t+dR62QoaeB5LAUq4wUZQzbDXcjHhv59KTPnJZ7uaHvL9kOo/P1maqEaPAGcgeo45CIL1Q2ELMcTbDGnVrorH6SkFxFfYypZqjqr9aCukWZFVtlvQ+7TDnWQ4EobKL5oM9SsqiYbLd+niqaFCMo+RvwylsiPyo1tkcuROGOAmpT33uvMOwf8HooB7PkTkpByyQgBM897m9vHBn5Aa42R6vR1a43feUhSGlDcDuqcYipufsZyjZJRTO5CzSXA5oZpb7NRV0arhrHbR46uUQIXgAToE7jKGXJRyl6AZdOIWG3fWuH2VS/Gqu1aNBXMD8JwHJbtLJG0Pla7myIbqyERQKzu992r9rByBDYDp+Y1NZQ9Sf0=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <29591127A6DC72408490EC2A23B29772@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 94862ecf-5556-4018-c707-08d6fa6f2aa4
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Jun 2019 19:47:48.8706
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN8PR15MB2898
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-26_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906260230
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 02:26:31PM -0700, Shakeel Butt wrote:
> The commit ef08e3b4981a ("[PATCH] cpusets: confine oom_killer to
> mem_exclusive cpuset") introduces a heuristic where a potential
> oom-killer victim is skipped if the intersection of the potential victim
> and the current (the process triggered the oom) is empty based on the
> reason that killing such victim most probably will not help the current
> allocating process. However the commit 7887a3da753e ("[PATCH] oom:
> cpuset hint") changed the heuristic to just decrease the oom_badness
> scores of such potential victim based on the reason that the cpuset of
> such processes might have changed and previously they might have
> allocated memory on mems where the current allocating process can
> allocate from.
>=20
> Unintentionally commit 7887a3da753e ("[PATCH] oom: cpuset hint")
> introduced a side effect as the oom_badness is also exposed to the
> user space through /proc/[pid]/oom_score, so, readers with different
> cpusets can read different oom_score of th same process.
>=20
> Later the commit 6cf86ac6f36b ("oom: filter tasks not sharing the same
> cpuset") fixed the side effect introduced by 7887a3da753e by moving the
> cpuset intersection back to only oom-killer context and out of
> oom_badness. However the combination of the commit ab290adbaf8f ("oom:
> make oom_unkillable_task() helper function") and commit 26ebc984913b
> ("oom: /proc/<pid>/oom_score treat kernel thread honestly")
> unintentionally brought back the cpuset intersection check into the
> oom_badness calculation function.
>=20
> Other than doing cpuset/mempolicy intersection from oom_badness, the
> memcg oom context is also doing cpuset/mempolicy intersection which is
> quite wrong and is caught by syzcaller with the following report:
>=20
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] PREEMPT SMP KASAN
> CPU: 0 PID: 28426 Comm: syz-executor.5 Not tainted 5.2.0-rc3-next-2019060=
7
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:__read_once_size include/linux/compiler.h:194 [inline]
> RIP: 0010:has_intersects_mems_allowed mm/oom_kill.c:84 [inline]
> RIP: 0010:oom_unkillable_task mm/oom_kill.c:168 [inline]
> RIP: 0010:oom_unkillable_task+0x180/0x400 mm/oom_kill.c:155
> Code: c1 ea 03 80 3c 02 00 0f 85 80 02 00 00 4c 8b a3 10 07 00 00 48 b8 0=
0
> 00 00 00 00 fc ff df 4d 8d 74 24 10 4c 89 f2 48 c1 ea 03 <80> 3c 02 00 0f
> 85 67 02 00 00 49 8b 44 24 10 4c 8d a0 68 fa ff ff
> RSP: 0018:ffff888000127490 EFLAGS: 00010a03
> RAX: dffffc0000000000 RBX: ffff8880a4cd5438 RCX: ffffffff818dae9c
> RDX: 100000000c3cc602 RSI: ffffffff818dac8d RDI: 0000000000000001
> RBP: ffff8880001274d0 R08: ffff888000086180 R09: ffffed1015d26be0
> R10: ffffed1015d26bdf R11: ffff8880ae935efb R12: 8000000061e63007
> R13: 0000000000000000 R14: 8000000061e63017 R15: 1ffff11000024ea6
> FS:  00005555561f5940(0000) GS:ffff8880ae800000(0000) knlGS:0000000000000=
000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000607304 CR3: 000000009237e000 CR4: 00000000001426f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
> Call Trace:
>   oom_evaluate_task+0x49/0x520 mm/oom_kill.c:321
>   mem_cgroup_scan_tasks+0xcc/0x180 mm/memcontrol.c:1169
>   select_bad_process mm/oom_kill.c:374 [inline]
>   out_of_memory mm/oom_kill.c:1088 [inline]
>   out_of_memory+0x6b2/0x1280 mm/oom_kill.c:1035
>   mem_cgroup_out_of_memory+0x1ca/0x230 mm/memcontrol.c:1573
>   mem_cgroup_oom mm/memcontrol.c:1905 [inline]
>   try_charge+0xfbe/0x1480 mm/memcontrol.c:2468
>   mem_cgroup_try_charge+0x24d/0x5e0 mm/memcontrol.c:6073
>   mem_cgroup_try_charge_delay+0x1f/0xa0 mm/memcontrol.c:6088
>   do_huge_pmd_wp_page_fallback+0x24f/0x1680 mm/huge_memory.c:1201
>   do_huge_pmd_wp_page+0x7fc/0x2160 mm/huge_memory.c:1359
>   wp_huge_pmd mm/memory.c:3793 [inline]
>   __handle_mm_fault+0x164c/0x3eb0 mm/memory.c:4006
>   handle_mm_fault+0x3b7/0xa90 mm/memory.c:4053
>   do_user_addr_fault arch/x86/mm/fault.c:1455 [inline]
>   __do_page_fault+0x5ef/0xda0 arch/x86/mm/fault.c:1521
>   do_page_fault+0x71/0x57d arch/x86/mm/fault.c:1552
>   page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1156
> RIP: 0033:0x400590
> Code: 06 e9 49 01 00 00 48 8b 44 24 10 48 0b 44 24 28 75 1f 48 8b 14 24 4=
8
> 8b 7c 24 20 be 04 00 00 00 e8 f5 56 00 00 48 8b 74 24 08 <89> 06 e9 1e 01
> 00 00 48 8b 44 24 08 48 8b 14 24 be 04 00 00 00 8b
> RSP: 002b:00007fff7bc49780 EFLAGS: 00010206
> RAX: 0000000000000001 RBX: 0000000000760000 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: 000000002000cffc RDI: 0000000000000001
> RBP: fffffffffffffffe R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000075 R11: 0000000000000246 R12: 0000000000760008
> R13: 00000000004c55f2 R14: 0000000000000000 R15: 00007fff7bc499b0
> Modules linked in:
> ---[ end trace a65689219582ffff ]---
> RIP: 0010:__read_once_size include/linux/compiler.h:194 [inline]
> RIP: 0010:has_intersects_mems_allowed mm/oom_kill.c:84 [inline]
> RIP: 0010:oom_unkillable_task mm/oom_kill.c:168 [inline]
> RIP: 0010:oom_unkillable_task+0x180/0x400 mm/oom_kill.c:155
> Code: c1 ea 03 80 3c 02 00 0f 85 80 02 00 00 4c 8b a3 10 07 00 00 48 b8 0=
0
> 00 00 00 00 fc ff df 4d 8d 74 24 10 4c 89 f2 48 c1 ea 03 <80> 3c 02 00 0f
> 85 67 02 00 00 49 8b 44 24 10 4c 8d a0 68 fa ff ff
> RSP: 0018:ffff888000127490 EFLAGS: 00010a03
> RAX: dffffc0000000000 RBX: ffff8880a4cd5438 RCX: ffffffff818dae9c
> RDX: 100000000c3cc602 RSI: ffffffff818dac8d RDI: 0000000000000001
> RBP: ffff8880001274d0 R08: ffff888000086180 R09: ffffed1015d26be0
> R10: ffffed1015d26bdf R11: ffff8880ae935efb R12: 8000000061e63007
> R13: 0000000000000000 R14: 8000000061e63017 R15: 1ffff11000024ea6
> FS:  00005555561f5940(0000) GS:ffff8880ae800000(0000) knlGS:0000000000000=
000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000001b2f823000 CR3: 000000009237e000 CR4: 00000000001426f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
>=20
> The fix is to decouple the cpuset/mempolicy intersection check from
> oom_unkillable_task() and make sure cpuset/mempolicy intersection check
> is only done in the global oom context.
>=20
> Reported-by: syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
> Changelog since v2:
> - Further divided the patch into two patches.
> - More cleaned version.
>=20
> Changelog since v1:
> - Divide the patch into two patches.

Acked-by: Roman Gushchin <guro@fb.com>
for the series.

Thanks, Shakeel!

