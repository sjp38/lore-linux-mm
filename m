Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 491DAC3A59B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 16:49:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E73E20820
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 16:49:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E73E20820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A67F26B0006; Fri, 30 Aug 2019 12:49:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3EDA6B0008; Fri, 30 Aug 2019 12:49:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97C176B000A; Fri, 30 Aug 2019 12:49:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0022.hostedemail.com [216.40.44.22])
	by kanga.kvack.org (Postfix) with ESMTP id 7629F6B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 12:49:29 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id BB5991E080
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 16:49:28 +0000 (UTC)
X-FDA: 75879680016.26.van36_6fc8a03a1c939
X-HE-Tag: van36_6fc8a03a1c939
X-Filterd-Recvd-Size: 2296
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 16:49:28 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 14FFF19CF26;
	Fri, 30 Aug 2019 16:49:27 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.63])
	by smtp.corp.redhat.com (Postfix) with SMTP id B4CCA600F8;
	Fri, 30 Aug 2019 16:49:22 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Fri, 30 Aug 2019 18:49:26 +0200 (CEST)
Date: Fri, 30 Aug 2019 18:49:22 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Kefeng Wang <wangkefeng.wang@huawei.com>, linux-mm <linux-mm@kvack.org>,
	Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Jann Horn <jannh@google.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] kernel BUG at fs/userfaultfd.c:385 after 04f5866e41fb
Message-ID: <20190830164921.GE2634@redhat.com>
References: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
 <20190827163334.GB6291@redhat.com>
 <20190827171410.GB4823@redhat.com>
 <20190828142544.GB3721@redhat.com>
 <20190829120509.GA14112@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190829120509.GA14112@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Fri, 30 Aug 2019 16:49:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/29, Andrea Arcangeli wrote:
>
> It's true you could have two uffd registered in the same mm
> and you could call the UFFDIO_COPY ioctl on anyone of the two and it
> wouldn't make any difference as long as they both are registered in
> the same mm.

...

> There would be nothing wrong to make it more strict, but it's not
> strictly needed.

Thanks Andrea, this answers my question.

Oleg.


