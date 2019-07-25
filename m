Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0E40C76191
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 08:14:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8614922BED
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 08:14:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8614922BED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 282C68E004F; Thu, 25 Jul 2019 04:14:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 232F48E0031; Thu, 25 Jul 2019 04:14:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 121CC8E004F; Thu, 25 Jul 2019 04:14:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E512E8E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 04:14:18 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id k31so43908271qte.13
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 01:14:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=g1B0j/DFbwZg53pT5uPps1IkIrXjJzGgjJ/VWYzhU2w=;
        b=VgkA1/xmV0Zm6p308Mol4gSBUw3/gt/rdsLIYAbccZ0Fk5gP4YFfNQUlq/VGXyRIlI
         S4qgZ/qIO5xKVQXWctEhzURh5MTuO6ZXaEUS9fmI/bv27+Rg6GjzZWU0mE93uBoK0/FX
         IMVrfjulV5j2kscu1wmEUgvUd5xOdJBB75F1LUHrxD7gg/sbFkGksgmGfl370HV4uZtp
         vOl6nNr1zcHojbz0e0ud7QEM4UoRnn5bMD/Q2PqfMOMau19KX/rhgRchEgNEpoZziuUG
         oQh4CioQ4wpGfrWemW5AHExNE8GRJ/MTmSseAVxq91+RYWyWvYyiL5U+8Lmd2KWkJe09
         BL4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUBQBDFWheREoXiMmL3bJM9y6i7SxWFjojzh1csD0mXXTNcEG51
	tMhgVclD2gzYxM7IJmIQpk10Hi7f0guwvTQFUzASZL0ENC+rmbehKillPgB6ZYMm2R3neDlkuG8
	hURB77mbHgiUtYc0nt0TMZc/uoQKCIUBNi0Rql8NS6OPQrDXO/JBLHVqt/Q8iybsFwA==
X-Received: by 2002:ac8:252e:: with SMTP id 43mr60851930qtm.61.1564042458688;
        Thu, 25 Jul 2019 01:14:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyaXyFWmnd/ZJKLt9/OfWKv/jn0NV/cFs/NvxIcsSH6XxGfX0N9trBPzUveI5x/z+vLBks
X-Received: by 2002:ac8:252e:: with SMTP id 43mr60851903qtm.61.1564042458142;
        Thu, 25 Jul 2019 01:14:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564042458; cv=none;
        d=google.com; s=arc-20160816;
        b=OzbT7IwfAEKBn9pwyzHYTliBFQ0vdI1rMFw0Etig0jy84jppsuhD9/S0FhEx7/dGy4
         W0BR+Ok3D/LbTpyo64po93LPm2vc2k6kkZYDsbJd518w+MZ/33nJzX+lLd6esIrToJkR
         YQE9pqQxWvmyioM4tNhPMQqyJiERAuG2/XqpDeojyOa781cSwVR9TQg0l0AeA1cLqQSR
         qpg4OV/nvtJkC9FkV89zPhEN09BU03llKAcfHTsC3a6nr3wQkRkha3YVxH2w62jBZ+ZB
         NF3Ot4AZXhSR+6OsOsnFMSh3p05/OCHQaGmTffBPlYKB14Pnls6mQMcMvNmHn0q7lAuF
         Z15Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=g1B0j/DFbwZg53pT5uPps1IkIrXjJzGgjJ/VWYzhU2w=;
        b=lHdGz71TUzGRsPmzbgSgeT3qZvTXVEfeWvP1BcfAXGI6wRR+zbziQ39X8duzVo/iU7
         QhGtcZB/evnTQOkvyOKAZSsJJ6N+NzqVJwHP1pM/cdxHeBeZzrsu4pmd9SAfDqWxRH+E
         fGEdBTUHCcm5GmOPp+GkkMalNSQfZInCTg0pp9zDdTkereOGP/3xz8rbYMhQc/HyKjVf
         deSNaUHJsQEJBCTaiAgYYzsbf4P5ffrBZadnw0JXq+ykvE85L+VpLzfXjmR9w/jCh9pa
         n0axUANc0ij2l50z00UF9bca265a7p1a/FpTrK5n+k7TRxd11Ttay2NLnBURhccdrir5
         YiRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s7si24705757qkc.12.2019.07.25.01.14.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 01:14:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 64CA485546;
	Thu, 25 Jul 2019 08:14:17 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 5028B600C4;
	Thu, 25 Jul 2019 08:14:15 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Thu, 25 Jul 2019 10:14:17 +0200 (CEST)
Date: Thu, 25 Jul 2019 10:14:14 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"rostedt@goodmis.org" <rostedt@goodmis.org>,
	Kernel Team <Kernel-team@fb.com>,
	"william.kucharski@oracle.com" <william.kucharski@oracle.com>
Subject: Re: [PATCH v8 2/4] uprobe: use original page when all uprobes are
 removed
Message-ID: <20190725081414.GB4707@redhat.com>
References: <20190724083600.832091-1-songliubraving@fb.com>
 <20190724083600.832091-3-songliubraving@fb.com>
 <20190724113711.GE21599@redhat.com>
 <BCE000B2-3F72-4148-A75C-738274917282@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BCE000B2-3F72-4148-A75C-738274917282@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 25 Jul 2019 08:14:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/24, Song Liu wrote:
>
>
> > On Jul 24, 2019, at 4:37 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> >
> > On 07/24, Song Liu wrote:
> >>
> >> 	lock_page(old_page);
> >> @@ -177,15 +180,24 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
> >> 	mmu_notifier_invalidate_range_start(&range);
> >> 	err = -EAGAIN;
> >> 	if (!page_vma_mapped_walk(&pvmw)) {
> >> -		mem_cgroup_cancel_charge(new_page, memcg, false);
> >> +		if (!orig)
> >> +			mem_cgroup_cancel_charge(new_page, memcg, false);
> >> 		goto unlock;
> >> 	}
> >> 	VM_BUG_ON_PAGE(addr != pvmw.address, old_page);
> >>
> >> 	get_page(new_page);
> >> -	page_add_new_anon_rmap(new_page, vma, addr, false);
> >> -	mem_cgroup_commit_charge(new_page, memcg, false, false);
> >> -	lru_cache_add_active_or_unevictable(new_page, vma);
> >> +	if (orig) {
> >> +		lock_page(new_page);  /* for page_add_file_rmap() */
> >> +		page_add_file_rmap(new_page, false);
> >
> >
> > Shouldn't we re-check new_page->mapping after lock_page() ? Or we can't
> > race with truncate?
>
> We can't race with truncate, because the file is open as binary and
> protected with DENYWRITE (ETXTBSY).

No. Yes, deny_write_access() protects mm->exe_file, but not the dynamic
libraries or other files which can be mmaped.

> > and I am worried this code can try to lock the same page twice...
> > Say, the probed application does MADV_DONTNEED and then writes "int3"
> > into vma->vm_file at the same address to fool verify_opcode().
> >
>
> Do you mean the case where old_page == new_page?

Yes,

> I think this won't
> happen, because in uprobe_write_opcode() we only do orig_page for
> !is_register case.

See above.

!is_register doesn't necessarily mean the original page was previously cow'ed.
And even if it was cow'ed, MADV_DONTNEED can restore the original mapping.

Oleg.

