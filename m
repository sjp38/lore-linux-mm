Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9565BC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:05:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43A63205F4
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:05:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="CoHvU737"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43A63205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E102E6B0006; Tue, 13 Aug 2019 11:05:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC1066B0007; Tue, 13 Aug 2019 11:05:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C888F6B0008; Tue, 13 Aug 2019 11:05:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0130.hostedemail.com [216.40.44.130])
	by kanga.kvack.org (Postfix) with ESMTP id A55C66B0006
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:05:42 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 5E6578248AA2
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:05:42 +0000 (UTC)
X-FDA: 75817728924.13.sea63_6be85034f2f16
X-HE-Tag: sea63_6be85034f2f16
X-Filterd-Recvd-Size: 6821
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:05:41 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id e16so13960944edv.6
        for <linux-mm@kvack.org>; Tue, 13 Aug 2019 08:05:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=YBSl0CajXoJyFM4Tub0QYu+W5pFIdDgKxAj7ER66uso=;
        b=CoHvU737VmfI3oyKN9MCpGf41kCR7rP/pY9yfa23wZpIf0qFmlKeUvc5sSqdX5B4WR
         GzWCwDjS9Yua8l4RxBlV7wJMf45Yh1LGwk6LBE0I2YpAPeUKTrEr8erv6VvUcJFdj+J9
         AjmmzsfmiTSjvY4Gi91rG3IEc0RHtxXgsiyEITtEoH9C3NCjAKzWoeDOpWLzBCPJ3I/q
         sYP86EKwkl5LHY2z7PJ6LejarajSyhSWLOCxt3cbTMblW8Z6NGSUFx2qXFi+T7pHTHWa
         K0Lu0IunLkAZpkYPM4J2kS9STY2Q2RfUnhxAgKndQLFkYHfSgec0+IdcyZE7Oh9HxYkS
         abiw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=YBSl0CajXoJyFM4Tub0QYu+W5pFIdDgKxAj7ER66uso=;
        b=rikXjJH5LV5NyM+I/eXiobD3HW21G9gClyKvzLzueldP5UqNtb9XXoXbQhm3oYfqKQ
         qoryW04CfV8JS3hJtdJ2OWYLoCPEr9AK0Jl75pjPBAu27o0X/xzhNWyWeGMluzqFhev1
         1A507pahhtNICVT8NHfJJMxzy2oqMUSnlJjdZ4YdBiQWZGrg7TXSJE2Dk9sQM/Lm+jjc
         bEqyeA9k28JIIaJmnmMn5BUaVmXq576Qs1YA7G3tl8lxQtJobDBd4zrWBjQYv1AKUkoj
         qGG87FEWfSPwNG2SaPiy4hUSDpmp28+xIYrREaXsAhHw1e38Aihs4Ia9eIV/MOh/V6xN
         DfUg==
X-Gm-Message-State: APjAAAV4h91W1oqRckWle+3OwCGtmpuTSvNNEKaONyPd9AcLPuUKi3CC
	IJn+H1rUMOgsUDqZ1kpi4o1Z9w==
X-Google-Smtp-Source: APXvYqwO45W8ArYTmQ7sk2TTXpXhzScDUzYYDs7QsdxWgDQpeMS0VNgTre2qyBnj9dzT2yH0zd4cuw==
X-Received: by 2002:aa7:d1c7:: with SMTP id g7mr3540552edp.227.1565708740258;
        Tue, 13 Aug 2019 08:05:40 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id w13sm17886231eji.22.2019.08.13.08.05.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Aug 2019 08:05:39 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 812BE100854; Tue, 13 Aug 2019 18:05:39 +0300 (+03)
Date: Tue, 13 Aug 2019 18:05:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Oleg Nesterov <oleg@redhat.com>
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
Message-ID: <20190813150539.ciai477wk2cratvc@box>
References: <20190808163303.GB7934@redhat.com>
 <770B3C29-CE8F-4228-8992-3C6E2B5487B6@fb.com>
 <20190809152404.GA21489@redhat.com>
 <3B09235E-5CF7-4982-B8E6-114C52196BE5@fb.com>
 <4D8B8397-5107-456B-91FC-4911F255AE11@fb.com>
 <20190812121144.f46abvpg6lvxwwzs@box>
 <20190812132257.GB31560@redhat.com>
 <20190812144045.tkvipsyit3nccvuk@box>
 <20190813133034.GA6971@redhat.com>
 <20190813140552.GB6971@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190813140552.GB6971@redhat.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 04:05:53PM +0200, Oleg Nesterov wrote:
> On 08/13, Oleg Nesterov wrote:
> >
> > On 08/12, Kirill A. Shutemov wrote:
> > >
> > > On Mon, Aug 12, 2019 at 03:22:58PM +0200, Oleg Nesterov wrote:
> > > > On 08/12, Kirill A. Shutemov wrote:
> > > > >
> > > > > On Fri, Aug 09, 2019 at 06:01:18PM +0000, Song Liu wrote:
> > > > > > +		if (pte_none(*pte) || !pte_present(*pte))
> > > > > > +			continue;
> > > > >
> > > > > You don't need to check both. Present is never none.
> > > >
> > > > Agreed.
> > > >
> > > > Kirill, while you are here, shouldn't retract_page_tables() check
> > > > vma->anon_vma (and probably do mm_find_pmd) under vm_mm->mmap_sem?
> > > >
> > > > Can't it race with, say, do_cow_fault?
> > >
> > > vma->anon_vma can race, but it doesn't matter. False-negative is fine.
> > > It's attempt to avoid taking mmap_sem where it can be not productive.
> >
> > I guess I misunderstood the purpose of this check or your answer...
> >
> > Let me reword my question. Why can retract_page_tables() safely do
> > pmdp_collapse_flush(vma) without additional checks similar to what
> > collapse_pte_mapped_thp() does?
> >
> > I thought that retract_page_tables() checks vma->anon_vma to ensure that
> > this vma doesn't have a cow'ed PageAnon() page. And I still can't understand
> > why can't it race with __handle_mm_fault() paths.

vma->anon_vma check is a cheap way to exclude MAP_PRIVATE mappings that
got written from userspace. My thinking was that these VMAs are not worth
investing down_write(mmap_sem) as PMD-mapping is likely to be split later.
(It's totally made up reasoning, I don't have numbers to back it up).

vma->anon_vma can be set up after the check but before taking mmap_sem.
But page lock would prevent establishing any new ptes of the page, so we
are safe.

An alternative would be drop the check, but check that page table is clear
before calling pmdp_collapse_flush() under ptl. It has higher chance to
recover THP for the VMA, but has higher cost too.

I don't know which way is better, so I've chosen which is easier to
implement.

> >
> > Suppose that shmem_file was mmaped with PROT_READ|WRITE, MAP_PRIVATE.
> > To simplify, suppose that a non-THP page was already faulted in,
> > pte_present() == T.
> >
> > Userspace writes to this page.
> >
> > Why __handle_mm_fault()->handle_pte_fault()->do_wp_page()->wp_page_copy()
> > can not cow this page and update pte after the vma->anon_vma chech and
> > before down_write_trylock(mmap_sem) ?
> 
> OK, probably this is impossible, collapse_shmem() does unmap_mapping_pages(),
> so handle_pte_fault() will call shmem_fault() which iiuc should block in
> find_lock_entry() because new_page is locked, and thus down_write_trylock()
> can't succeed.

You've got it right.

> Nevermind, I am sure I missed something. Perhaps you can update the comments
> to make this more clear.

Let me see first that my explanation makes sense :P

-- 
 Kirill A. Shutemov

