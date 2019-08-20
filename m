Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C335AC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 16:05:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90C3722DA9
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 16:05:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90C3722DA9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 607026B000E; Tue, 20 Aug 2019 12:05:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B7C36B0010; Tue, 20 Aug 2019 12:05:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CD4D6B0266; Tue, 20 Aug 2019 12:05:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0112.hostedemail.com [216.40.44.112])
	by kanga.kvack.org (Postfix) with ESMTP id 2525D6B000E
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 12:05:34 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id C673C8248AB6
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 16:05:33 +0000 (UTC)
X-FDA: 75843281346.02.coal18_1366ffc30a34a
X-HE-Tag: coal18_1366ffc30a34a
X-Filterd-Recvd-Size: 2471
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 16:05:33 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 197CB300BE7F;
	Tue, 20 Aug 2019 16:05:32 +0000 (UTC)
Received: from mail (ovpn-120-35.rdu2.redhat.com [10.10.120.35])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 406035D9D5;
	Tue, 20 Aug 2019 16:05:27 +0000 (UTC)
Date: Tue, 20 Aug 2019 12:05:25 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Kefeng Wang <wangkefeng.wang@huawei.com>, linux-mm <linux-mm@kvack.org>,
	Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Jann Horn <jannh@google.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] userfaultfd_release: always remove uffd flags and clear
 vm_userfaultfd_ctx
Message-ID: <20190820160525.GN31518@redhat.com>
References: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
 <20190820160237.GB4983@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190820160237.GB4983@redhat.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Tue, 20 Aug 2019 16:05:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 06:02:38PM +0200, Oleg Nesterov wrote:
> userfaultfd_release() should clear vm_flags/vm_userfaultfd_ctx even
> if mm->core_state != NULL.
> 
> Otherwise a page fault can see userfaultfd_missing() == T and use an
> already freed userfaultfd_ctx.
> 
> Reported-by: Kefeng Wang <wangkefeng.wang@huawei.com>
> Fixes: 04f5866e41fb ("coredump: fix race condition between mmget_not_zero()/get_task_mm() and core dumping")
> Cc: stable@vger.kernel.org
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> ---
>  fs/userfaultfd.c | 25 +++++++++++++------------
>  1 file changed, 13 insertions(+), 12 deletions(-)

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Thanks,
Andrea

