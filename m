Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3A24C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 16:15:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA7A922DD6
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 16:15:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA7A922DD6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53C6A6B0271; Tue, 20 Aug 2019 12:15:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EC946B0272; Tue, 20 Aug 2019 12:15:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 403466B0273; Tue, 20 Aug 2019 12:15:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0070.hostedemail.com [216.40.44.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1D66B0271
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 12:15:36 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id B9F8EAC0E
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 16:15:35 +0000 (UTC)
X-FDA: 75843306630.03.smash60_6b03e13b76b04
X-HE-Tag: smash60_6b03e13b76b04
X-Filterd-Recvd-Size: 2722
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 16:15:35 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 23832308339B;
	Tue, 20 Aug 2019 16:15:34 +0000 (UTC)
Received: from mail (ovpn-120-35.rdu2.redhat.com [10.10.120.35])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id EEDC91001281;
	Tue, 20 Aug 2019 16:15:25 +0000 (UTC)
Date: Tue, 20 Aug 2019 12:15:24 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Kefeng Wang <wangkefeng.wang@huawei.com>,
	Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>,
	Peter Xu <peterx@redhat.com>, Mike Rapoport <rppt@linux.ibm.com>,
	Jann Horn <jannh@google.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] kernel BUG at fs/userfaultfd.c:385 after 04f5866e41fb
Message-ID: <20190820161524.GP31518@redhat.com>
References: <d4583416-5e4a-95e7-a08a-32bf2c9a95fb@huawei.com>
 <20190814135351.GY17933@dhcp22.suse.cz>
 <7e0e4254-17f4-5f07-e9af-097c4162041a@huawei.com>
 <20190814151049.GD11595@redhat.com>
 <20190814154101.GF11595@redhat.com>
 <20190819160517.GG31518@redhat.com>
 <20190820155948.GA4983@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190820155948.GA4983@redhat.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Tue, 20 Aug 2019 16:15:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 05:59:49PM +0200, Oleg Nesterov wrote:
> On 08/19, Andrea Arcangeli wrote:
> >
> > The proposed fix looks correct, can you resend in a way that can be merged?
> 
> OK, I'll send the same patch to lkml, the only change is s/xxx/still_valid/.

Thanks! Actually I wasn't sure if I should send it myself to avoid
delaying it to next week, but I see you already sent it so problem
solved.

> > It's a bit strange that the file that
> > was opened by the ioctl() syscall gets released
> 
> and this look like another bug we need to investigate,

I did some more debugging in the meanwhile. The current theory is
there are multiple uffd in the same mm and the uffd ctx of the page
fault is not the same uffd ctx of the ioctl that triggers the copy
user.

I'll need to add some more bpftrace code to be sure.

Thanks,
Andrea

