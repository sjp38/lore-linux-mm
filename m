Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 490F1C3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 12:48:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AAB820989
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 12:48:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AAB820989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41C2E6B0008; Mon, 19 Aug 2019 08:48:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3CC6A6B000A; Mon, 19 Aug 2019 08:48:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E23F6B000C; Mon, 19 Aug 2019 08:48:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0027.hostedemail.com [216.40.44.27])
	by kanga.kvack.org (Postfix) with ESMTP id 0CE186B0008
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 08:48:42 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id A51B72DF0
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 12:48:41 +0000 (UTC)
X-FDA: 75839156442.13.birth19_8603f79581120
X-HE-Tag: birth19_8603f79581120
X-Filterd-Recvd-Size: 4553
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 12:48:40 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3B0E2C059758;
	Mon, 19 Aug 2019 12:48:39 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (ovpn-204-244.brq.redhat.com [10.40.204.244])
	by smtp.corp.redhat.com (Postfix) with SMTP id 993C358C9C;
	Mon, 19 Aug 2019 12:48:33 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Mon, 19 Aug 2019 14:48:38 +0200 (CEST)
Date: Mon, 19 Aug 2019 14:48:33 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Kefeng Wang <wangkefeng.wang@huawei.com>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Jann Horn <jannh@google.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] kernel BUG at fs/userfaultfd.c:385 after 04f5866e41fb
Message-ID: <20190819124832.GA15044@redhat.com>
References: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
 <20190814135351.GY17933@dhcp22.suse.cz>
 <7e0e4254-17f4-5f07-e9af-097c4162041a@huawei.com>
 <20190814151049.GD11595@redhat.com>
 <20190814154101.GF11595@redhat.com>
 <0cfded81-6668-905f-f2be-490bf7c750fb@huawei.com>
 <20190815095409.GC32051@redhat.com>
 <3b521a8c-586f-251e-f486-d71ff094b8e9@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3b521a8c-586f-251e-f486-d71ff094b8e9@huawei.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Mon, 19 Aug 2019 12:48:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Kefeng, et al, sorry I am travelling till the next monday, can't even
open my laptop too often.

On 08/16, Kefeng Wang wrote:
>
> The patch do fix the UAF and avoid panic, and it doesn't seem to cause new issue,
> even if there are some another issue, it can be fixed later :)

Yes... but if we want a hot fix without any understanding why does it
help in this particular case we can simply add mmget_still_valid() into
handle_userfault(), I am almost sure this should equally "fix" (hide) the
problem.

But to clarify, let me repeat that I still think the patch I sent makes
sense anyway; __handle_mm_fault() is possible even after do_coredump()
sets mm->core_state and after userfaultfd_unregister().

> >> [   67.430243] RIP: 0010:copy_user_handle_tail+0x2/0x10
> >> [   67.431586] Code: c3 0f 1f 80 00 00 00 00 66 66 90 83 fa 40 0f 82 70 ff ff ff 89 d1 f3 a4 31 c0 66 66 90 c3 66 2e 0f 1f 84 00 00 00 00 00 89 d1 <f3> a4 89 c8 66 66 90 c3 66 0f 1f 44 00 00 66 66 90 83 fa 08 0f 82
> >> [   67.436978] RSP: 0018:ffff8883c4e8f908 EFLAGS: 00010246
> >> [   67.438743] RAX: 0000000000000001 RBX: 0000000020ffd000 RCX: 0000000000001000
> >> [   67.441101] RDX: 0000000000001000 RSI: 0000000020ffd000 RDI: ffff8883c0aa4000
> >> [   67.442865] RBP: 0000000000001000 R08: ffffed1078154a00 R09: 0000000000000000
> >> [   67.444534] R10: 0000000000000200 R11: ffffed10781549ff R12: ffff8883c0aa4000
> >> [   67.446216] R13: ffff8883c6096000 R14: ffff88837721f838 R15: ffff8883c6096000
> >> [   67.448388]  _copy_from_user+0xa1/0xd0
> >> [   67.449655]  mcopy_atomic+0xb3d/0x1380
> >> [   67.450991]  ? lock_downgrade+0x3a0/0x3a0
> >> [   67.452337]  ? mm_alloc_pmd+0x130/0x130
> >> [   67.453618]  ? __might_fault+0x7d/0xe0
> >> [   67.454980]  userfaultfd_ioctl+0x14a2/0x1c30
> >
> > This must not be called after __fput(). So I think there is something else,
> > may by just an unbalanced userfaultfd_ctx_put(). I dunno, I know nothing
> > about usefaultfd.
>
> There are different processes, maybe some concurrency problems.

and this is what I think we need to understand...


> > It would be nice to understand what this reproducer does...
>
> I tried strace -f the reproducer, but can't find any useful info.

Could you send me the output of strace -f ? Not sure it will help and
again, I am not sure I will have a chance to read it this week.

Perhaps it is possible to translate this test-case to C somehow?

Oleg.


