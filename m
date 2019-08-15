Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51EBDC31E40
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 10:16:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21BE421744
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 10:16:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21BE421744
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A987E6B026F; Thu, 15 Aug 2019 06:16:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A22CB6B0270; Thu, 15 Aug 2019 06:16:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C2906B0271; Thu, 15 Aug 2019 06:16:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0117.hostedemail.com [216.40.44.117])
	by kanga.kvack.org (Postfix) with ESMTP id 632EA6B026F
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 06:16:42 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 159B021FA
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 10:16:42 +0000 (UTC)
X-FDA: 75824258244.30.dogs38_1d455e471c11e
X-HE-Tag: dogs38_1d455e471c11e
X-Filterd-Recvd-Size: 2695
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 10:16:41 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8A73130832E1;
	Thu, 15 Aug 2019 10:16:39 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id D50D12C8C6;
	Thu, 15 Aug 2019 10:16:36 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Thu, 15 Aug 2019 12:16:39 +0200 (CEST)
Date: Thu, 15 Aug 2019 12:16:36 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <matthew.wilcox@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	"srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v12 5/6] khugepaged: enable collapse pmd for pte-mapped
 THP
Message-ID: <20190815101635.GD32051@redhat.com>
References: <20190808163303.GB7934@redhat.com>
 <770B3C29-CE8F-4228-8992-3C6E2B5487B6@fb.com>
 <20190809152404.GA21489@redhat.com>
 <3B09235E-5CF7-4982-B8E6-114C52196BE5@fb.com>
 <4D8B8397-5107-456B-91FC-4911F255AE11@fb.com>
 <20190812121144.f46abvpg6lvxwwzs@box>
 <20190812132257.GB31560@redhat.com>
 <20190812144045.tkvipsyit3nccvuk@box>
 <2D11C742-BB7E-4296-9E97-5114FA58474B@fb.com>
 <857DA509-D891-4F4C-A55C-EE58BC2CC452@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <857DA509-D891-4F4C-A55C-EE58BC2CC452@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Thu, 15 Aug 2019 10:16:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Song,

sorry, I forgot to reply to this email,

On 08/13, Song Liu wrote:
>
> Do you have further comments for the version below? If not, could you
> please reply with your Acked-by or Reviewed-by?

I see nothing wrong in the last series, no objections from me.

I don't think I can't ack the changes in this area, but feel free to
add my Reviewed-by.

Oleg.


