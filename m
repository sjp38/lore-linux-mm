Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A8B3C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 16:24:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D0B220679
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 16:24:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D0B220679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5726B6B0005; Tue, 13 Aug 2019 12:24:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 524436B0006; Tue, 13 Aug 2019 12:24:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 411096B0007; Tue, 13 Aug 2019 12:24:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0068.hostedemail.com [216.40.44.68])
	by kanga.kvack.org (Postfix) with ESMTP id 1AFD66B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 12:24:57 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id C2E7E55F8C
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 16:24:56 +0000 (UTC)
X-FDA: 75817928592.26.net62_482d72fe9924a
X-HE-Tag: net62_482d72fe9924a
X-Filterd-Recvd-Size: 4279
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 16:24:55 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 839B1CF61C;
	Tue, 13 Aug 2019 16:24:54 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 73BB1271A5;
	Tue, 13 Aug 2019 16:24:52 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Tue, 13 Aug 2019 18:24:54 +0200 (CEST)
Date: Tue, 13 Aug 2019 18:24:51 +0200
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
Message-ID: <20190813162451.GD6971@redhat.com>
References: <770B3C29-CE8F-4228-8992-3C6E2B5487B6@fb.com>
 <20190809152404.GA21489@redhat.com>
 <3B09235E-5CF7-4982-B8E6-114C52196BE5@fb.com>
 <4D8B8397-5107-456B-91FC-4911F255AE11@fb.com>
 <20190812121144.f46abvpg6lvxwwzs@box>
 <20190812132257.GB31560@redhat.com>
 <20190812144045.tkvipsyit3nccvuk@box>
 <20190813133034.GA6971@redhat.com>
 <20190813140552.GB6971@redhat.com>
 <20190813150539.ciai477wk2cratvc@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190813150539.ciai477wk2cratvc@box>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 13 Aug 2019 16:24:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/13, Kirill A. Shutemov wrote:
>
> On Tue, Aug 13, 2019 at 04:05:53PM +0200, Oleg Nesterov wrote:
> > >
> > > I thought that retract_page_tables() checks vma->anon_vma to ensure that
> > > this vma doesn't have a cow'ed PageAnon() page. And I still can't understand
> > > why can't it race with __handle_mm_fault() paths.
>
> vma->anon_vma check is a cheap way to exclude MAP_PRIVATE mappings that
> got written from userspace.

Yes, and this is how I understood it from the very beginning, but then
I was confused.

> vma->anon_vma can be set up after the check but before taking mmap_sem.
> But page lock would prevent establishing any new ptes of the page, so we
> are safe.

And this is what was not clear to me until I noticed unmap_mapping_pages()
in collapse_shmem().

Plus I was confused by the comment above down_write_trylock(mmap_sem).
To me it looks as if we _could_ do down_write(), but we do not want to
disturb the system.

But iiuc we simply can't do down_write(), exactly because handle_mm_fault()
can wait for page lock with mmap_sem held.

> > > Suppose that shmem_file was mmaped with PROT_READ|WRITE, MAP_PRIVATE.
> > > To simplify, suppose that a non-THP page was already faulted in,
> > > pte_present() == T.
> > >
> > > Userspace writes to this page.
> > >
> > > Why __handle_mm_fault()->handle_pte_fault()->do_wp_page()->wp_page_copy()
> > > can not cow this page and update pte after the vma->anon_vma chech and
> > > before down_write_trylock(mmap_sem) ?
> >
> > OK, probably this is impossible, collapse_shmem() does unmap_mapping_pages(),
> > so handle_pte_fault() will call shmem_fault() which iiuc should block in
> > find_lock_entry() because new_page is locked, and thus down_write_trylock()
> > can't succeed.
>
> You've got it right.

Great, thanks.

> > Nevermind, I am sure I missed something. Perhaps you can update the comments
> > to make this more clear.
>
> Let me see first that my explanation makes sense :P

It does ;)

Oleg.


