Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA182C32750
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 13:23:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7E16206C2
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 13:23:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7E16206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59E466B0008; Mon, 12 Aug 2019 09:23:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5750B6B000A; Mon, 12 Aug 2019 09:23:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48A046B000C; Mon, 12 Aug 2019 09:23:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0016.hostedemail.com [216.40.44.16])
	by kanga.kvack.org (Postfix) with ESMTP id 1B3716B0008
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 09:23:03 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id BD5588248AA3
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 13:23:02 +0000 (UTC)
X-FDA: 75813841404.02.elbow16_1a8f0c35f2a0d
X-HE-Tag: elbow16_1a8f0c35f2a0d
X-Filterd-Recvd-Size: 2628
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 13:23:02 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8217AC0022F1;
	Mon, 12 Aug 2019 13:23:01 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 9317B1018A2E;
	Mon, 12 Aug 2019 13:22:59 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Mon, 12 Aug 2019 15:23:00 +0200 (CEST)
Date: Mon, 12 Aug 2019 15:22:58 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Song Liu <songliubraving@fb.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <matthew.wilcox@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	"srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v12 5/6] khugepaged: enable collapse pmd for pte-mapped
 THP
Message-ID: <20190812132257.GB31560@redhat.com>
References: <20190807233729.3899352-1-songliubraving@fb.com>
 <20190807233729.3899352-6-songliubraving@fb.com>
 <20190808163303.GB7934@redhat.com>
 <770B3C29-CE8F-4228-8992-3C6E2B5487B6@fb.com>
 <20190809152404.GA21489@redhat.com>
 <3B09235E-5CF7-4982-B8E6-114C52196BE5@fb.com>
 <4D8B8397-5107-456B-91FC-4911F255AE11@fb.com>
 <20190812121144.f46abvpg6lvxwwzs@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190812121144.f46abvpg6lvxwwzs@box>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Mon, 12 Aug 2019 13:23:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/12, Kirill A. Shutemov wrote:
>
> On Fri, Aug 09, 2019 at 06:01:18PM +0000, Song Liu wrote:
> > +		if (pte_none(*pte) || !pte_present(*pte))
> > +			continue;
>
> You don't need to check both. Present is never none.

Agreed.

Kirill, while you are here, shouldn't retract_page_tables() check
vma->anon_vma (and probably do mm_find_pmd) under vm_mm->mmap_sem?

Can't it race with, say, do_cow_fault?

Oleg.


