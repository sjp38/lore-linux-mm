Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F770C32753
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 13:30:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F16632084D
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 13:30:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F16632084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88C0E6B0006; Tue, 13 Aug 2019 09:30:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83BCD6B0007; Tue, 13 Aug 2019 09:30:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72B7F6B0008; Tue, 13 Aug 2019 09:30:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0221.hostedemail.com [216.40.44.221])
	by kanga.kvack.org (Postfix) with ESMTP id 51E7D6B0006
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:30:39 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 1041855F96
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:30:39 +0000 (UTC)
X-FDA: 75817489398.04.snail37_5a03c0bb872a
X-HE-Tag: snail37_5a03c0bb872a
X-Filterd-Recvd-Size: 3841
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:30:38 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 341AC30EA182;
	Tue, 13 Aug 2019 13:30:37 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 3CC49608A5;
	Tue, 13 Aug 2019 13:30:35 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Tue, 13 Aug 2019 15:30:36 +0200 (CEST)
Date: Tue, 13 Aug 2019 15:30:34 +0200
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
Message-ID: <20190813133034.GA6971@redhat.com>
References: <20190807233729.3899352-1-songliubraving@fb.com>
 <20190807233729.3899352-6-songliubraving@fb.com>
 <20190808163303.GB7934@redhat.com>
 <770B3C29-CE8F-4228-8992-3C6E2B5487B6@fb.com>
 <20190809152404.GA21489@redhat.com>
 <3B09235E-5CF7-4982-B8E6-114C52196BE5@fb.com>
 <4D8B8397-5107-456B-91FC-4911F255AE11@fb.com>
 <20190812121144.f46abvpg6lvxwwzs@box>
 <20190812132257.GB31560@redhat.com>
 <20190812144045.tkvipsyit3nccvuk@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190812144045.tkvipsyit3nccvuk@box>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Tue, 13 Aug 2019 13:30:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/12, Kirill A. Shutemov wrote:
>
> On Mon, Aug 12, 2019 at 03:22:58PM +0200, Oleg Nesterov wrote:
> > On 08/12, Kirill A. Shutemov wrote:
> > >
> > > On Fri, Aug 09, 2019 at 06:01:18PM +0000, Song Liu wrote:
> > > > +		if (pte_none(*pte) || !pte_present(*pte))
> > > > +			continue;
> > >
> > > You don't need to check both. Present is never none.
> >
> > Agreed.
> >
> > Kirill, while you are here, shouldn't retract_page_tables() check
> > vma->anon_vma (and probably do mm_find_pmd) under vm_mm->mmap_sem?
> >
> > Can't it race with, say, do_cow_fault?
>
> vma->anon_vma can race, but it doesn't matter. False-negative is fine.
> It's attempt to avoid taking mmap_sem where it can be not productive.

I guess I misunderstood the purpose of this check or your answer...

Let me reword my question. Why can retract_page_tables() safely do
pmdp_collapse_flush(vma) without additional checks similar to what
collapse_pte_mapped_thp() does?

I thought that retract_page_tables() checks vma->anon_vma to ensure that
this vma doesn't have a cow'ed PageAnon() page. And I still can't understand
why can't it race with __handle_mm_fault() paths.

Suppose that shmem_file was mmaped with PROT_READ|WRITE, MAP_PRIVATE.
To simplify, suppose that a non-THP page was already faulted in,
pte_present() == T.

Userspace writes to this page.

Why __handle_mm_fault()->handle_pte_fault()->do_wp_page()->wp_page_copy()
can not cow this page and update pte after the vma->anon_vma chech and
before down_write_trylock(mmap_sem) ?

Oleg.


