Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14944C10F05
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 14:20:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6167206C0
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 14:20:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="WHbzFAaC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6167206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61A866B026C; Fri, 29 Mar 2019 10:20:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A4216B026D; Fri, 29 Mar 2019 10:20:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 444B06B026E; Fri, 29 Mar 2019 10:20:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7836B026C
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 10:20:40 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id 4so1709357ybh.19
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 07:20:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=EdPl8wx9CT7eKW049LQPVwPDMTDYASSuYhqDUDUeQzw=;
        b=c9HjDZy/qZ8LMtS6clyqvWciB43+DbqyBDbnegt9B1ciPobLCDLnjr7rEtU8J6/ELp
         0FJ8bAnLKQW3Pi5pa/BjqccGTLekGpBl3CCU/XC9BJGsduD26KUWvPbuJIq4QszCe0vQ
         EmBgNj9LxFV4suz+ZNnhwoicIGcU8SsDIsPU44HstCBD4YbgBKOR+eeikwG73s9BrLgD
         ZFRrc43nzM8opTWT24QzkcudfpR2o4yjnKDhVeyScBkpZ5uK1C+7JHwWuCxm6veDI+2I
         yzzc+Dx1fcSjvtAShHBZw7HqSb8QxtW6uys7HjtSwcfnXYvd3gPLkgQBrfCYNwBuoPoF
         aDYw==
X-Gm-Message-State: APjAAAXk7FC2VcmuTt93HLVZTJaMvmkd554jHDOolwwqFCp22mT64Ij8
	NZhOCzIZgndsCLH3rc+MCChbrQsh0zI8DoKuD7dsQuMTOTQwcc/Tfu7j3V8ZD9PpDlERECEjTfD
	+2h/ivlGtJ1GrKX2yxTnuAMZtBv2qeIeroB8EFztp0tufjdNstcCrXAM2QnaTAEPaAQ==
X-Received: by 2002:a5b:587:: with SMTP id l7mr40440728ybp.44.1553869239731;
        Fri, 29 Mar 2019 07:20:39 -0700 (PDT)
X-Received: by 2002:a5b:587:: with SMTP id l7mr40440673ybp.44.1553869239019;
        Fri, 29 Mar 2019 07:20:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553869239; cv=none;
        d=google.com; s=arc-20160816;
        b=jDdEnkbIxyalX0RGfd3oJIDytOwamCBRVvHkA8JGG7YBoUYRizA7R/urJBQ/o1zkfJ
         6vruU4TIPYhQiWrJPrdRSw8IhpLpznNZE2hnsHVmSahPLrZ8+hZEQeln0RsQQFD1Xbt2
         lH+d070j64klJBC3yz7etWw+0dbO1pLyKeP++5KeReKlvLH8BL7j+cIqGdxRSICSHcp+
         PNngO8JsM1VVpz3kQt73NsmY1ljbjA1/Ze4WAjyznIdJXdjzGr0iXHTE5osf4+zgjNWI
         f1XwUvPoWQ6GiaXB4sihbvkRUbXDFdmtRSV9WjdogLGkmE95cxmFOO8y0sLlaYqJvjUS
         vTUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=EdPl8wx9CT7eKW049LQPVwPDMTDYASSuYhqDUDUeQzw=;
        b=WZZhfZTNVuYcpVDbfeLAhM6ku588Ruc7NE3x3zeQK4DGLNd3U/eFmcM0uZukHPnPRB
         af8rBQznTxsvTh4ovBmDNs78IiCssohdrbYrYqvl/dxWz3CTe0lxpTZ9xoaVm4GikYd/
         fQMSuvrtxb5ZH/j3Tl0OlvnI4J1//m7dBxljWWmTg1VPFhUk7ghqbzz4MFRvlsNepJEp
         9D6Mk/CRYOPbGezkQVNZbWQCkvbyTiim0MauadR/2Ggsk5iJpvUBxKe6vILMraCRcPId
         CHKo68yPE/Abd+h0LrHpAbo34FCEBS3Nl3rFuD4XZ4m4iTgnxZgxHRrAboFjQ4so0amr
         xWrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=WHbzFAaC;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q126sor1234814ybq.117.2019.03.29.07.20.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Mar 2019 07:20:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=WHbzFAaC;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=EdPl8wx9CT7eKW049LQPVwPDMTDYASSuYhqDUDUeQzw=;
        b=WHbzFAaCZ1Rp2mTxkykmaArTeY2OaUeosmIrcGXV6ktIDfrWsXSIgYtiWu1un+hAbq
         R4fjzyXoQYPoBkdpWu8lE5RFf/92pzrIyLJAs1KhZpiS8FXEYL73m+ZiH2Wh9j4TK6L8
         abyoN8VPyblI/VtDjAnujRSq46h8XrDiB+HgtCVJXHgFMPEXsnIgZ5waKIYUioG+S2+7
         UjEK1+iW2ihbPWGBu0fPbPR4P9aj6GuIHj7WKeAVee1sAuoYZe/+KpdLS1/Ueybal7ND
         4zOSk+UB/lR7hJC1MJLlzwGi9K3tHoDOTkGc6HytXXOWYeoRoVzKe+CK88Tl/AD/CBET
         AFyA==
X-Google-Smtp-Source: APXvYqxr/aJg2GTWvfMraC5VoXtkFI3s/QclcSjNZmIybpu9Sgmnn/PE4/h4exoDcU0bbQePdrrmDg==
X-Received: by 2002:a25:1482:: with SMTP id 124mr41366879ybu.421.1553869236276;
        Fri, 29 Mar 2019 07:20:36 -0700 (PDT)
Received: from localhost ([2620:10d:c091:180::20d1])
        by smtp.gmail.com with ESMTPSA id p75sm643875ywg.36.2019.03.29.07.20.34
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 07:20:35 -0700 (PDT)
Date: Fri, 29 Mar 2019 10:20:33 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Matthew Wilcox <willy@infradead.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Ben Gardon <bgardon@google.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Linux MM <linux-mm@kvack.org>, kvm@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH] mm, kvm: account kvm_vcpu_mmap to kmemcg
Message-ID: <20190329142033.GB2474@cmpxchg.org>
References: <20190329012836.47013-1-shakeelb@google.com>
 <20190329023552.GV10344@bombadil.infradead.org>
 <CALvZod5GiC1+HB3_Mm969Qbgj7s6-unbd141uP5pnMbsufS+mg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod5GiC1+HB3_Mm969Qbgj7s6-unbd141uP5pnMbsufS+mg@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 08:59:45PM -0700, Shakeel Butt wrote:
> On Thu, Mar 28, 2019 at 7:36 PM Matthew Wilcox <willy@infradead.org> wrote:
> > I don't understand why we need a PageKmemcg anyway.  We already
> > have an entire pointer in struct page; can we not just check whether
> > page->mem_cgroup is NULL or not?
> 
> PageKmemcg is for kmem while page->mem_cgroup is used for anon, file
> and kmem memory. So, page->mem_cgroup can not be used for NULL check
> unless we unify them. Not sure how complicated would that be.

A page flag warrants research into this.

The only reason we have PageKmemcg() is because of the way we do
memory type accounting at uncharge time:

	if (!PageKmemcg(page)) {
		unsigned int nr_pages = 1;

		if (PageTransHuge(page)) {
			nr_pages <<= compound_order(page);
			ug->nr_huge += nr_pages;
		}
		if (PageAnon(page))
			ug->nr_anon += nr_pages;
		else {
			ug->nr_file += nr_pages;
			if (PageSwapBacked(page))
				ug->nr_shmem += nr_pages;
		}
		ug->pgpgout++;
	} else {
		ug->nr_kmem += 1 << compound_order(page);
		__ClearPageKmemcg(page);
	}

	[...]

	if (!mem_cgroup_is_root(ug->memcg)) {
		page_counter_uncharge(&ug->memcg->memory, nr_pages);
		if (do_memsw_account())
			page_counter_uncharge(&ug->memcg->memsw, nr_pages);
		if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && ug->nr_kmem)
			page_counter_uncharge(&ug->memcg->kmem, ug->nr_kmem);
		memcg_oom_recover(ug->memcg);
	}

	local_irq_save(flags);
	__mod_memcg_state(ug->memcg, MEMCG_RSS, -ug->nr_anon);
	__mod_memcg_state(ug->memcg, MEMCG_CACHE, -ug->nr_file);
	__mod_memcg_state(ug->memcg, MEMCG_RSS_HUGE, -ug->nr_huge);
	__mod_memcg_state(ug->memcg, NR_SHMEM, -ug->nr_shmem);
	__count_memcg_events(ug->memcg, PGPGOUT, ug->pgpgout);

But nothing says we have to have all these duplicate private counters,
or update them this late in the page's lifetime. The generic vmstat
counters in comparison are updated when 1) we know the page is going
away but 2) we still know the page type. We can do the same here.

We can either

a) Push up the MEMCG_RSS, MEMCG_CACHE etc. accounting sites to before
   the pages are uncharged, when the page type is still known, but
   page->mem_cgroup is exclusive, i.e. when they are deleted from page
   cache or when their last pte is going away. This would be very
   close to where the VM updates NR_ANON_MAPPED, NR_FILE_PAGES etc.

or

b) Tweak the existing NR_ANON_MAPPED, NR_FILE_PAGES, NR_ANON_THPS
   accounting sites to use the lruvec_page_state infra and get rid of
   the duplicate MEMCG_RSS, MEMCG_CACHE counters completely.

   These sites would need slight adjustments, as they are sometimes
   before commit_charge() set up page->mem_cgroup, but it doesn't look
   too complicated to fix that ordering.

The latter would be a great cleanup, and frankly one that is long
overdue. There is no good reason for all this duplication. We'd not
only get rid of the private counters and the duplicate accounting
sites, it would drastically simplify charging and uncharging, and it
would even obviate the need for a separate kmem (un)charge path.

[ The cgroup1 memcg->kmem thing is the odd-one-out, but I think this
  is complete legacy at this point and nobody is actively setting
  limits on that counter anyway. We can break out an explicit v1-only
  mem_cgroup_charge_legacy_kmem(), put it into the currently accounted
  callsites for compatibility, and not add any new ones. ]

