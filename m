Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98542C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:57:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 668C22189F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:57:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 668C22189F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDBDA6B0003; Wed, 24 Jul 2019 04:57:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8D876B0005; Wed, 24 Jul 2019 04:57:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7AF78E0002; Wed, 24 Jul 2019 04:57:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 97A906B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 04:57:40 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x7so40849734qtp.15
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:57:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vPV1fefQaDRzlxDQ7MFrg1N7GDGhKhDrBP+wKS5+/08=;
        b=RFL89htLtRoy6964FDSkWEosXVE+D1RRvFUxSRx2crcNSCRyNUOTVM0wAWgVAfmd1/
         k+ZEPmdf2OAgZcrch5Kw5iysEMz/ycp2AKVYcTg+nufkrto7FIjFDsLxyVkczrjB6CX6
         eT98UgHyLtmR1uiGnRY2ARX8ZI/Kwa17Z6W6tMDCopbrjVtZUMBhVgykdgNtdsaOWrrP
         RM1LSzg7Cn1yPSU4mFVtkNEL/8r0ttxmEdLNV/WThWdy2DUO5J5BMxt769rGkbYcwAIl
         VAFFrDe6PtEqpb+6zp8Fs6PmRZdPLDz2eLYOH0MFs+oEmcZhwOW2S/0MFrIYpyDCDvMi
         SE/g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWpwwD2JnVwEsqb2J6FupSzIzYC/oA+8F9mL/p9LrXDSRVAH4ui
	19/pUTnTvDdrXIDk/Dqns0rsohW5RtUO0jxJVRoCgcUD3o75IlO77U/QFVebe+Dteg2DzHoF7yF
	nUiCi/S6G0l1ut/ODWdmuqQ8WaIzfFDHSJUsXWjf0w1DvL4l5IqHD0Cs0ppjOvP1+dA==
X-Received: by 2002:ac8:6950:: with SMTP id n16mr3182203qtr.185.1563958660399;
        Wed, 24 Jul 2019 01:57:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwM1NziSd7nSaW2qAjzrikMe6vgrfnkcSf9agjl3ArKGXF3ynKqMBZgtk26UPJs+TJaUEBP
X-Received: by 2002:ac8:6950:: with SMTP id n16mr3182175qtr.185.1563958659862;
        Wed, 24 Jul 2019 01:57:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563958659; cv=none;
        d=google.com; s=arc-20160816;
        b=o3a5/lrJ6EtFFi3l/j0HsDjj6MSQbURbpQSefGxOprqG4I7WJCQ8gE/V4F9i4MmnLu
         lxM1bmCWIJ0Y42ZiR65yD5sWUbxDC3lLSkWnnc0CWvdwXIuKZPR0jryH0poS77M3FxqY
         TXfkmtd29mjgEkKr0WNPsqrpNa6MRkncQVIZbIPxVHi/0MKEITlPndmu8fCQBZhpd2kH
         nqS16hivVBCMIgixDP/qWWt32le1Pgcv4Dbv2NKgDSMCLc3dswU3MxMPxFDIWex+nqen
         VJaNPb3eyYflXbZMHGoQXnoOerkXf409XryiagOqTYsUH/FIjcr8llcuu+JLsm/LLB1m
         A4FA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vPV1fefQaDRzlxDQ7MFrg1N7GDGhKhDrBP+wKS5+/08=;
        b=WikTITreYF6YkdjV6aBazEcs0W7jG0pm8A8LzpQJ0j/sDo4a+5kZFgY2JpHXJxTaHP
         +AAeH23YN9EfH5zy21Nblw1o+ZTOF1AwrcKfsw0ot1E7gQv0AWay+yc3jWbjiSFJ7lV+
         bpeVo2cZL1fLYPF3K8GNx+54wJxlsmhgLpuf6OkFZOxywVL823rgJvf7BkNJ6T39hyLg
         mGlT2lWtJoqwAXnlHxBnWN0f2MhXmabuKrYMFjuZsJ+UYGnyoZBSobXkhPeHYf1eZAki
         E/jMk56Ohr9syp/gf2MJlAaKeUs6c8O2nd2rwr3plPnn5H1oGO6iuhbWnoG//pw/thud
         1Prw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s16si20754969qte.92.2019.07.24.01.57.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 01:57:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0E1D830C1E3F;
	Wed, 24 Jul 2019 08:57:39 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 44A8D60BFC;
	Wed, 24 Jul 2019 08:57:37 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Wed, 24 Jul 2019 10:57:38 +0200 (CEST)
Date: Wed, 24 Jul 2019 10:57:36 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	Matthew Wilcox <matthew.wilcox@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Kernel Team <Kernel-team@fb.com>,
	William Kucharski <william.kucharski@oracle.com>
Subject: Re: [PATCH v7 2/4] uprobe: use original page when all uprobes are
 removed
Message-ID: <20190724085736.GA21599@redhat.com>
References: <20190625235325.2096441-1-songliubraving@fb.com>
 <20190625235325.2096441-3-songliubraving@fb.com>
 <20190715152513.GD1222@redhat.com>
 <EA58E3BD-7EB1-4433-8F7F-1E3894F8D563@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <EA58E3BD-7EB1-4433-8F7F-1E3894F8D563@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Wed, 24 Jul 2019 08:57:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/24, Song Liu wrote:
>
>
> > On Jul 15, 2019, at 8:25 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> >
> >> +	if (!is_register) {
> >> +		struct page *orig_page;
> >> +		pgoff_t index;
> >> +
> >> +		index = vaddr_to_offset(vma, vaddr & PAGE_MASK) >> PAGE_SHIFT;
> >> +		orig_page = find_get_page(vma->vm_file->f_inode->i_mapping,
> >> +					  index);
> >> +
> >> +		if (orig_page) {
> >> +			if (pages_identical(new_page, orig_page)) {
> >
> > Shouldn't we at least check PageUptodate?
>
> For page cache, we only do ClearPageUptodate() on read failures,

Hmm. I don't think so.

> so
> this should be really rare case. But I guess we can check anyway.

Can? I think we should or this code is simply wrong...

> > and I am a bit surprised there is no simple way to unmap the old page
> > in this case...
>
> The easiest way I have found requires flush_cache_page() plus a few
> mmu_notifier calls around it.

But we need to do this anyway? At least with your patch replace_page() still
does this after page_add_file_rmap().

> I think current solution is better than
> that,

perhaps, I won't argue,

> as it saves a page fault.

I don't think it matters in this case.

Oleg.

