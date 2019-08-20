Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D87DC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 16:09:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0C0E205C9
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 16:09:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0C0E205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95F936B026E; Tue, 20 Aug 2019 12:09:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 910296B026F; Tue, 20 Aug 2019 12:09:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 826806B0270; Tue, 20 Aug 2019 12:09:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0131.hostedemail.com [216.40.44.131])
	by kanga.kvack.org (Postfix) with ESMTP id 63A036B026E
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 12:09:44 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 141A7180AD806
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 16:09:44 +0000 (UTC)
X-FDA: 75843291888.12.plot52_37d99d3a1fd3a
X-HE-Tag: plot52_37d99d3a1fd3a
X-Filterd-Recvd-Size: 2938
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 16:09:43 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A64F5693E7;
	Tue, 20 Aug 2019 16:09:42 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (ovpn-204-99.brq.redhat.com [10.40.204.99])
	by smtp.corp.redhat.com (Postfix) with SMTP id E3CFA3DA5;
	Tue, 20 Aug 2019 16:09:37 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Tue, 20 Aug 2019 18:09:42 +0200 (CEST)
Date: Tue, 20 Aug 2019 18:09:36 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
	Kefeng Wang <wangkefeng.wang@huawei.com>,
	Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>,
	Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Jann Horn <jannh@google.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] kernel BUG at fs/userfaultfd.c:385 after 04f5866e41fb
Message-ID: <20190820160936.GC4983@redhat.com>
References: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
 <20190814135351.GY17933@dhcp22.suse.cz>
 <7e0e4254-17f4-5f07-e9af-097c4162041a@huawei.com>
 <20190814151049.GD11595@redhat.com>
 <20190814154101.GF11595@redhat.com>
 <20190819160517.GG31518@redhat.com>
 <73d7b5b1-a88c-5fca-ba16-be214c2524a4@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <73d7b5b1-a88c-5fca-ba16-be214c2524a4@I-love.SAKURA.ne.jp>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 20 Aug 2019 16:09:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/20, Tetsuo Handa wrote:
>
> On 2019/08/20 1:05, Andrea Arcangeli wrote:
> > It's a bit strange that the file that
> > was opened by the ioctl() syscall gets released and its
> > file->private_data destroyed before the ioctl syscall has a chance to
> > return to userland.
>
> My guess is that the fd was opened by userfaultfd() syscall, and the fd was
> closed by close() syscall. Nothing wrong. But when a page fault happened,

The problem is that this page fault is triggered by ioctl() and this file
was already closed and the final fput() was already called, note that
userfaultfd_release() is f_op->release.

> Then, not resetting pointer to the data structure before
> releasing the memory (due to "goto skip_mm;") is the bug.

Yes, this is wrong in any case and this is that the patch tries to fix.

Oleg.


