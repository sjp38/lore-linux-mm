Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92156C3A5A6
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:25:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 620F022CED
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:25:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 620F022CED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F242F6B0003; Wed, 28 Aug 2019 10:25:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED4A66B000D; Wed, 28 Aug 2019 10:25:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E11ED6B000E; Wed, 28 Aug 2019 10:25:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0180.hostedemail.com [216.40.44.180])
	by kanga.kvack.org (Postfix) with ESMTP id C61076B0003
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 10:25:49 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 6E0F2181AC9B4
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:25:49 +0000 (UTC)
X-FDA: 75872060418.20.ray89_32cc4f4eea204
X-HE-Tag: ray89_32cc4f4eea204
X-Filterd-Recvd-Size: 2510
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:25:48 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E87612A09D2;
	Wed, 28 Aug 2019 14:25:47 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.63])
	by smtp.corp.redhat.com (Postfix) with SMTP id 21E851001925;
	Wed, 28 Aug 2019 14:25:45 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Wed, 28 Aug 2019 16:25:47 +0200 (CEST)
Date: Wed, 28 Aug 2019 16:25:45 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Kefeng Wang <wangkefeng.wang@huawei.com>, linux-mm <linux-mm@kvack.org>,
	Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Jann Horn <jannh@google.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] kernel BUG at fs/userfaultfd.c:385 after 04f5866e41fb
Message-ID: <20190828142544.GB3721@redhat.com>
References: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
 <20190827163334.GB6291@redhat.com>
 <20190827171410.GB4823@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190827171410.GB4823@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 28 Aug 2019 14:25:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/27, Andrea Arcangeli wrote:
>
> I finished the debugging of the ioctl refcounting last week, but I
> didn't yet post an update sorry.

Great! so we can finally forget this problem ;)

> It was important to verify the uffd ctx of the UFFDIO_COPY ioctl is
> different than the one registered on the vma where UFFDIO_COPY hits
> handle_userfault,

I seem to understand... Somehow I thought that __mcopy_atomic() should
verify that dst_vma->vm_userfaultfd_ctx.ctx is the same ctx which was
used in userfaultfd_ioctl() but it doesn't, it only checks
dst_vma->vm_userfaultfd_ctx.ctx != NULL.

But why?

(I am just curious, let me repeat I know nothing about userfaultfd).

Oleg.


