Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04033C433FF
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 09:54:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5B9D21855
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 09:54:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5B9D21855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1A756B026B; Thu, 15 Aug 2019 05:54:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCBA16B026C; Thu, 15 Aug 2019 05:54:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE1CF6B026D; Thu, 15 Aug 2019 05:54:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0118.hostedemail.com [216.40.44.118])
	by kanga.kvack.org (Postfix) with ESMTP id 9E33B6B026B
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 05:54:17 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 3208D181AC9AE
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 09:54:17 +0000 (UTC)
X-FDA: 75824201754.20.stop66_7cad86d26cc3e
X-HE-Tag: stop66_7cad86d26cc3e
X-Filterd-Recvd-Size: 4324
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 09:54:16 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8939E796E0;
	Thu, 15 Aug 2019 09:54:15 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 146F45D9DC;
	Thu, 15 Aug 2019 09:54:10 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Thu, 15 Aug 2019 11:54:15 +0200 (CEST)
Date: Thu, 15 Aug 2019 11:54:10 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Kefeng Wang <wangkefeng.wang@huawei.com>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Jann Horn <jannh@google.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] kernel BUG at fs/userfaultfd.c:385 after 04f5866e41fb
Message-ID: <20190815095409.GC32051@redhat.com>
References: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
 <20190814135351.GY17933@dhcp22.suse.cz>
 <7e0e4254-17f4-5f07-e9af-097c4162041a@huawei.com>
 <20190814151049.GD11595@redhat.com>
 <20190814154101.GF11595@redhat.com>
 <0cfded81-6668-905f-f2be-490bf7c750fb@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0cfded81-6668-905f-f2be-490bf7c750fb@huawei.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 15 Aug 2019 09:54:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/15, Kefeng Wang wrote:
>
> On 2019/8/14 23:41, Oleg Nesterov wrote:
> >
> > Heh, I didn't notice you too mentioned userfaultfd_release() in your email.
> > can you try the patch below?
>
> Your patch below fixes the issue, could you send a formal patch ASAP and also it
> should be queued into stable, I have test lts4.4, it works too, thanks.

Thanks.

Yes, I _think_ we need something like this patch anyway, but it needs more
discussion. And it is not clear if it really fixes this issue or it hides
another bug.


> I built kernel with wrong gcc version, and the KASAN is not enabled, When KASAN enabled,
> there is an UAF,
>
> [   67.393442] ==================================================================
> [   67.395531] BUG: KASAN: use-after-free in handle_userfault+0x12f/0xc70
> [   67.397001] Read of size 8 at addr ffff8883c622c160 by task syz-executor.9/5225

OK, thanks this probably confirms that .ctx points to nowhere because it
was freed by userfaultfd_release() without clearing vm_flags/userfaultfd_ctx.

But,

> [   67.430243] RIP: 0010:copy_user_handle_tail+0x2/0x10
> [   67.431586] Code: c3 0f 1f 80 00 00 00 00 66 66 90 83 fa 40 0f 82 70 ff ff ff 89 d1 f3 a4 31 c0 66 66 90 c3 66 2e 0f 1f 84 00 00 00 00 00 89 d1 <f3> a4 89 c8 66 66 90 c3 66 0f 1f 44 00 00 66 66 90 83 fa 08 0f 82
> [   67.436978] RSP: 0018:ffff8883c4e8f908 EFLAGS: 00010246
> [   67.438743] RAX: 0000000000000001 RBX: 0000000020ffd000 RCX: 0000000000001000
> [   67.441101] RDX: 0000000000001000 RSI: 0000000020ffd000 RDI: ffff8883c0aa4000
> [   67.442865] RBP: 0000000000001000 R08: ffffed1078154a00 R09: 0000000000000000
> [   67.444534] R10: 0000000000000200 R11: ffffed10781549ff R12: ffff8883c0aa4000
> [   67.446216] R13: ffff8883c6096000 R14: ffff88837721f838 R15: ffff8883c6096000
> [   67.448388]  _copy_from_user+0xa1/0xd0
> [   67.449655]  mcopy_atomic+0xb3d/0x1380
> [   67.450991]  ? lock_downgrade+0x3a0/0x3a0
> [   67.452337]  ? mm_alloc_pmd+0x130/0x130
> [   67.453618]  ? __might_fault+0x7d/0xe0
> [   67.454980]  userfaultfd_ioctl+0x14a2/0x1c30

This must not be called after __fput(). So I think there is something else,
may by just an unbalanced userfaultfd_ctx_put(). I dunno, I know nothing
about usefaultfd.

It would be nice to understand what this reproducer does...

Oleg.


