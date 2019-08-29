Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A18CCC3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 12:05:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6FF9B2166E
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 12:05:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FF9B2166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E61C26B0010; Thu, 29 Aug 2019 08:05:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E13406B0266; Thu, 29 Aug 2019 08:05:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D28F86B0269; Thu, 29 Aug 2019 08:05:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0104.hostedemail.com [216.40.44.104])
	by kanga.kvack.org (Postfix) with ESMTP id B37A56B0010
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 08:05:41 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 5649B180AD7C1
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 12:05:41 +0000 (UTC)
X-FDA: 75875336082.14.geese54_319f24457b947
X-HE-Tag: geese54_319f24457b947
X-Filterd-Recvd-Size: 3338
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 12:05:40 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E5131EC556;
	Thu, 29 Aug 2019 12:05:39 +0000 (UTC)
Received: from mail (ovpn-123-136.rdu2.redhat.com [10.10.123.136])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B00555F7E3;
	Thu, 29 Aug 2019 12:05:10 +0000 (UTC)
Date: Thu, 29 Aug 2019 08:05:09 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Kefeng Wang <wangkefeng.wang@huawei.com>, linux-mm <linux-mm@kvack.org>,
	Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Jann Horn <jannh@google.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] kernel BUG at fs/userfaultfd.c:385 after 04f5866e41fb
Message-ID: <20190829120509.GA14112@redhat.com>
References: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
 <20190827163334.GB6291@redhat.com>
 <20190827171410.GB4823@redhat.com>
 <20190828142544.GB3721@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190828142544.GB3721@redhat.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 29 Aug 2019 12:05:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 04:25:45PM +0200, Oleg Nesterov wrote:
> I seem to understand... Somehow I thought that __mcopy_atomic() should
> verify that dst_vma->vm_userfaultfd_ctx.ctx is the same ctx which was
> used in userfaultfd_ioctl() but it doesn't, it only checks
> dst_vma->vm_userfaultfd_ctx.ctx != NULL.
> 
> But why?
> 
> (I am just curious, let me repeat I know nothing about userfaultfd).

The ioctl fd only needs to hold an indirect reference to any ctx of
that mm. In other words the only thing the uffd ctx represents in the
UFFDIO_COPY is the destination mm, not the vma.

All the rest is done from the userland parameters of the ioctl
syscall. It's true you could have two uffd registered in the same mm
and you could call the UFFDIO_COPY ioctl on anyone of the two and it
wouldn't make any difference as long as they both are registered in
the same mm.

The uffd ctx in __mcopy_atomic is checked to be not null to be sure
the VM_MAYWRITE check run during uffd registration of the vma, before
we allow to fill any hole into the vma but it's otherwise a refcounting
neutral check.

The uffd ctx refcount in handle_userfault, that may also trigger in
copy-user invoked by the uffd ioctl -> __mcopy_atomic, works like for
any other page fault: by checking vm_userfaultfd_ctx.ctx is not null
while holding the mmap_sem with no association to the uffd ctx
refcount hold by the ioctl (again only needed to obtain the uffd
ctx->mm which is the dst_mm of the UFFDIO_COPY).

There would be nothing wrong to make it more strict, but it's not
strictly needed.

Thanks,
Andrea

