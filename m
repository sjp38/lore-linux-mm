Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CF27C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 16:34:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10C2A214DA
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 16:34:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10C2A214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D5916B0006; Tue, 27 Aug 2019 12:34:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69ED26B0008; Tue, 27 Aug 2019 12:34:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B4D36B000A; Tue, 27 Aug 2019 12:34:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0049.hostedemail.com [216.40.44.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3BA146B0006
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 12:34:06 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 7BD15879E
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 16:33:40 +0000 (UTC)
X-FDA: 75868753800.24.walk19_5a3c02971913d
X-HE-Tag: walk19_5a3c02971913d
X-Filterd-Recvd-Size: 4479
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 16:33:39 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CA12B8077F2;
	Tue, 27 Aug 2019 16:33:38 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.63])
	by smtp.corp.redhat.com (Postfix) with SMTP id CE25B5C1D6;
	Tue, 27 Aug 2019 16:33:36 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Tue, 27 Aug 2019 18:33:37 +0200 (CEST)
Date: Tue, 27 Aug 2019 18:33:35 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Kefeng Wang <wangkefeng.wang@huawei.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Jann Horn <jannh@google.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] kernel BUG at fs/userfaultfd.c:385 after 04f5866e41fb
Message-ID: <20190827163334.GB6291@redhat.com>
References: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.67]); Tue, 27 Aug 2019 16:33:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Kefeng,

On 08/13, Kefeng Wang wrote:
>
> Syzkaller reproducer:
> # {Threaded:true Collide:true Repeat:false RepeatTimes:0 Procs:1 Sandbox:none Fault:false FaultCall:-1 FaultNth:0 EnableTun:true EnableNetDev:true EnableNetReset:false EnableCgroups:false EnableBinfmtMisc:true EnableCloseFds:true UseTmpDir:true HandleSegv:true Repro:false Trace:false}
> r0 = userfaultfd(0x80800)
> ioctl$UFFDIO_API(r0, 0xc018aa3f, &(0x7f0000000200))
> ioctl$UFFDIO_REGISTER(r0, 0xc020aa00, &(0x7f0000000080)={{&(0x7f0000ff2000/0xe000)=nil, 0xe000}, 0x1})
> ioctl$UFFDIO_COPY(r0, 0xc028aa03, 0x0)
> ioctl$UFFDIO_COPY(r0, 0xc028aa03, &(0x7f0000000000)={&(0x7f0000ffc000/0x3000)=nil, &(0x7f0000ffd000/0x2000)=nil, 0x3000})
> syz_execute_func(&(0x7f00000000c0)="4134de984013e80f059532058300000071f3c4e18dd1ce5a65460f18320ce0b9977d8f64360f6e54e3a50fe53ff30fb837c42195dc42eddb8f087ca2a4d2c4017b708fa878c3e600f3266440d9a200000000c4016c5bdd7d0867dfe07f00f20f2b5f0009404cc442c102282cf2f20f51e22ef2e1291010f2262ef045814cb39700000000f32e3ef0fe05922f79a4000030470f3b58c1312fe7460f50ce0502338d00858526660f346253f6010f0f801d000000470f0f2c0a90c7c7df84feefff3636260fe02c98c8b8fcfc81fc51720a40400e700064660f71e70d2e0f57dfe819d0253f3ecaf06ad647608c41ffc42249bccb430f9bc8b7a042420f8d0042171e0f95ca9f7f921000d9fac4a27d5a1fc4a37961309de9000000003171460fc4d303c466410fd6389dc4426c456300c4233d4c922d92abf90ac6c34df30f5ee50909430f3a15e7776f6e866b0fdfdfc482797841cf6ffc842d9b9a516dc2e52ef2ac2636f20f114832d46231bffd4834eaeac4237d09d0003766420f160182c4a37d047882007f108f2808a6e68fc401505d6a82635d1467440fc7ba0c000000d4c482359652745300")
> poll(&(0x7f00000000c0)=[{}], 0x1, 0x0)
> 
> ./syz-execprog -executor=./syz-executor -repeat=0 -procs=16 -cover=0 repofile

I tried to reproduce using the C code provided by Tetsuo but it doesn't work
for me.

Could you run this test-case with the patch below? (on top of the fix you have
already tested).

Oleg.

--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -882,6 +882,8 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	unsigned long new_flags;
 	bool still_valid;
 
+	file->private_data = (void*)0x6666;
+
 	WRITE_ONCE(ctx->released, true);
 
 	if (!mmget_not_zero(mm))
@@ -1859,6 +1861,8 @@ static long userfaultfd_ioctl(struct file *file, unsigned cmd,
 	int ret = -EINVAL;
 	struct userfaultfd_ctx *ctx = file->private_data;
 
+	BUG_ON(ctx == (void*)0x6666);
+
 	if (cmd != UFFDIO_API && ctx->state == UFFD_STATE_WAIT_API)
 		return -EINVAL;
 
@@ -1882,6 +1886,8 @@ static long userfaultfd_ioctl(struct file *file, unsigned cmd,
 		ret = userfaultfd_zeropage(ctx, arg);
 		break;
 	}
+
+	BUG_ON(ctx != file->private_data);
 	return ret;
 }
 


