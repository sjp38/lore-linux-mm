Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAAB3C32753
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 15:11:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 843382083B
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 15:11:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 843382083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36B236B000A; Wed, 14 Aug 2019 11:11:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31BD66B000C; Wed, 14 Aug 2019 11:11:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 209E66B000D; Wed, 14 Aug 2019 11:11:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0080.hostedemail.com [216.40.44.80])
	by kanga.kvack.org (Postfix) with ESMTP id 008C76B000A
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 11:11:00 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 9301A501F
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 15:11:00 +0000 (UTC)
X-FDA: 75821371080.03.pain40_42e4f3104b31d
X-HE-Tag: pain40_42e4f3104b31d
X-Filterd-Recvd-Size: 3918
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 15:10:59 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 70405C0094CA;
	Wed, 14 Aug 2019 15:10:58 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id A78398328F;
	Wed, 14 Aug 2019 15:10:51 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Wed, 14 Aug 2019 17:10:57 +0200 (CEST)
Date: Wed, 14 Aug 2019 17:10:50 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Kefeng Wang <wangkefeng.wang@huawei.com>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Jann Horn <jannh@google.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] kernel BUG at fs/userfaultfd.c:385 after 04f5866e41fb
Message-ID: <20190814151049.GD11595@redhat.com>
References: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
 <20190814135351.GY17933@dhcp22.suse.cz>
 <7e0e4254-17f4-5f07-e9af-097c4162041a@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7e0e4254-17f4-5f07-e9af-097c4162041a@huawei.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 14 Aug 2019 15:10:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/14, Kefeng Wang wrote:
>
> On 2019/8/14 21:53, Michal Hocko wrote:
> > On Tue 13-08-19 17:08:05, Kefeng Wang wrote:
> >>
> >> Syzkaller reproducer:
> >> # {Threaded:true Collide:true Repeat:false RepeatTimes:0 Procs:1 Sandbox:none Fault:false FaultCall:-1 FaultNth:0 EnableTun:true EnableNetDev:true EnableNetReset:false EnableCgroups:false EnableBinfmtMisc:true EnableCloseFds:true UseTmpDir:true HandleSegv:true Repro:false Trace:false}
> >> r0 = userfaultfd(0x80800)
> >> ioctl$UFFDIO_API(r0, 0xc018aa3f, &(0x7f0000000200))
> >> ioctl$UFFDIO_REGISTER(r0, 0xc020aa00, &(0x7f0000000080)={{&(0x7f0000ff2000/0xe000)=nil, 0xe000}, 0x1})
> >> ioctl$UFFDIO_COPY(r0, 0xc028aa03, 0x0)
> >> ioctl$UFFDIO_COPY(r0, 0xc028aa03, &(0x7f0000000000)={&(0x7f0000ffc000/0x3000)=nil, &(0x7f0000ffd000/0x2000)=nil, 0x3000})
> >> syz_execute_func(&(0x7f00000000c0)="4134de984013e80f059532058300000071f3c4e18dd1ce5a65460f18320ce0b9977d8f64360f6e54e3a50fe53ff30fb837c42195dc42eddb8f087ca2a4d2c4017b708fa878c3e600f3266440d9a200000000c4016c5bdd7d0867dfe07f00f20f2b5f0009404cc442c102282cf2f20f51e22ef2e1291010f2262ef045814cb39700000000f32e3ef0fe05922f79a4000030470f3b58c1312fe7460f50ce0502338d00858526660f346253f6010f0f801d000000470f0f2c0a90c7c7df84feefff3636260fe02c98c8b8fcfc81fc51720a40400e700064660f71e70d2e0f57dfe819d0253f3ecaf06ad647608c41ffc42249bccb430f9bc8b7a042420f8d0042171e0f95ca9f7f921000d9fac4a27d5a1fc4a37961309de9000000003171460fc4d303c466410fd6389dc4426c456300c4233d4c922d92abf90ac6c34df30f5ee50909430f3a15e7776f6e866b0fdfdfc482797841cf6ffc842d9b9a516dc2e52ef2ac2636f20f114832d46231bffd4834eaeac4237d09d0003766420f160182c4a37d047882007f108f2808a6e68fc401505d6a82635d1467440fc7ba0c000000d4c482359652745300")
> >> poll(&(0x7f00000000c0)=[{}], 0x1, 0x0)
> >
> > Is there any way to decypher the above?
>
> no, I also want to know the way :(

perhaps you can run it under strace?

I am wondering if "goto skip_mm" in userfaultfd_release() is correct...
shouldn't it clear VM_UFFD_* and reset vm_userfaultfd_ctx.ctx even if
!mmget_still_valid ?

Oleg.


