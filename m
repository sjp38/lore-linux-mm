Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68415C3A59D
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 00:53:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BEAE2087E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 00:53:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BEAE2087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 035396B026E; Tue, 20 Aug 2019 20:53:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F28026B026F; Tue, 20 Aug 2019 20:53:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3E806B0270; Tue, 20 Aug 2019 20:53:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0214.hostedemail.com [216.40.44.214])
	by kanga.kvack.org (Postfix) with ESMTP id C439F6B026E
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 20:53:26 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 6487152C3
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:53:26 +0000 (UTC)
X-FDA: 75844611612.16.sofa89_752b0ca940144
X-HE-Tag: sofa89_752b0ca940144
X-Filterd-Recvd-Size: 2272
Received: from huawei.com (szxga07-in.huawei.com [45.249.212.35])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:53:25 +0000 (UTC)
Received: from DGGEMS401-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 90AFC6EB68EC1F723933;
	Wed, 21 Aug 2019 08:53:20 +0800 (CST)
Received: from [127.0.0.1] (10.133.217.137) by DGGEMS401-HUB.china.huawei.com
 (10.3.19.201) with Microsoft SMTP Server id 14.3.439.0; Wed, 21 Aug 2019
 08:53:18 +0800
Subject: Re: [PATCH] userfaultfd_release: always remove uffd flags and clear
 vm_userfaultfd_ctx
To: Oleg Nesterov <oleg@redhat.com>
CC: linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>, Jann Horn
	<jannh@google.com>, Jason Gunthorpe <jgg@mellanox.com>, Michal Hocko
	<mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa
	<penguin-kernel@I-love.SAKURA.ne.jp>, <linux-kernel@vger.kernel.org>
References: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
 <20190820160237.GB4983@redhat.com>
From: Kefeng Wang <wangkefeng.wang@huawei.com>
Message-ID: <d2bf0b99-2cdd-7868-e5ad-8c2cad4681c2@huawei.com>
Date: Wed, 21 Aug 2019 08:53:17 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190820160237.GB4983@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Originating-IP: [10.133.217.137]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/8/21 0:02, Oleg Nesterov wrote:
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

Tested on lts4.4 and 5.3-rc4, Thanks.



