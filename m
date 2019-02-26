Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4734C10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:06:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABDE4213A2
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:06:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABDE4213A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 483F48E0003; Tue, 26 Feb 2019 01:06:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 433C58E0002; Tue, 26 Feb 2019 01:06:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 322748E0003; Tue, 26 Feb 2019 01:06:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2898E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:06:45 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id d49so11444437qtd.15
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 22:06:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Xmw8Qb+EIreCEt76B4u1+5aPg48uJFZCiCPoEreFv8s=;
        b=A4PsAu2MsSvJN2hx+uLGMsTizYr+YlDPb9EnCiNe4nGmtMBqdpn4VH/mKzC/N0SmPk
         +EpiXA2QbZJZIOKQnsRBq9V1AAfidclkxCXngNO4A5tXrpacii+DlEKsQ9xm7dXhas1m
         6eBn3rSlEcfAdD1mLYmUeO8dMR6lkWJShQhf36HhToSxNCMFzr+qHM9UIZrcx3ELTHSw
         aJHGp4ij6bXvOei/omg8Fzf4IEpmI5VS1N99nqsI6pjYsKVTeVXzY3cGaqkJu1WXopTi
         L29KvcE/lJmcsrJiFRSg5yrk/cYUv4/XK0qTEqxQXt8gNun5Y9BvrRRgrSfvPATcR7vA
         XGbw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYIuveC8e7oXKzjjkzUSO3umK739CyVWAokGtKTtzTGdo3sVVIR
	ds8CsmKXDuX3nDlAgCd+75wUNNZbJI4YodJVfWmBXaQTFroRDnBMYqJSXNxQAofMaR2waul+fNh
	HyvnzoS24EUsqhZwb7ro8YoDd+nOMLg903kEChuDH4p4KvipUbs3XJnRIWPFycyKjOg==
X-Received: by 2002:a37:a105:: with SMTP id k5mr15657659qke.32.1551161204712;
        Mon, 25 Feb 2019 22:06:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ6ESetwq6A5k9m//LZVFUnk3nCVdFyWnlBDecuHbeyeETFI74Q9UcDamTf+6fCD6NC/Ygn
X-Received: by 2002:a37:a105:: with SMTP id k5mr15657620qke.32.1551161203719;
        Mon, 25 Feb 2019 22:06:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551161203; cv=none;
        d=google.com; s=arc-20160816;
        b=PKfaS6YffgzpGu+2rK15FDf4ZEaq+Xix5uOB6i6fFAR+aVEGudBIk2ivleoOUmW/O/
         JBO0wuJa3BH4oI1yyByTvZ+NupH2DWoNP2eEkTtqegDfd+zsBm5SNS8h3ClOB1FLK2v1
         n45hBgDvuGLyW4bhEdA7gNOdk6F+YBQN0gRuCdSR8IQn9Yr+DDghY76zwhV3vevxp6P/
         poUGwr7Q7m8hmaK08Clw1XxP8YLSGwUCcTZvPiyG5kA4kLyNDG6vGLDvEx+BZOErgZB3
         PGdfGnR6/yxiy6ImbqhZACOCPQV7qQYVATINPV+mrIYV+GvK5Glzsu9KLptYR8bThadT
         n05g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Xmw8Qb+EIreCEt76B4u1+5aPg48uJFZCiCPoEreFv8s=;
        b=zy82d4F2DtKDh/yuPL17RlLPzkP4u4GO41WIkYKfplyHO8rx1ibw3Qbc7m/6Prd9F7
         UeFLx2qt6sikQ8YbOazUVsO0tnJ/y8Oflj/e1qPGOkYxeb8B+f2E49ejYgJoN2FgY9UZ
         EPWJLrjX3PtnwhPzZMdaU2sU4bzgFwnYFr9WDOh48lvBn67LcI6ARoc9rmgsW83r7iMX
         3+t7FgldorhT4R801xpZS4YWQ8cgylwIecOM6eRb4LM0OzQpr3xQSo3ojZhc8B0qzcVt
         7Wr/xkf+JMwfSXof6pK25XrDQR/G/7iQU84eeZ8oEbnR95GPtDNzwFWdyRBNlFlTd971
         pGxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n6si1908722qtk.21.2019.02.25.22.06.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 22:06:43 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 71E6A3082163;
	Tue, 26 Feb 2019 06:06:42 +0000 (UTC)
Received: from xz-x1 (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 462E460BE7;
	Tue, 26 Feb 2019 06:06:30 +0000 (UTC)
Date: Tue, 26 Feb 2019 14:06:27 +0800
From: Peter Xu <peterx@redhat.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH v2 20/26] userfaultfd: wp: support write protection for
 userfault vma range
Message-ID: <20190226060627.GG13653@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-21-peterx@redhat.com>
 <20190225205233.GC10454@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190225205233.GC10454@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Tue, 26 Feb 2019 06:06:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 10:52:34PM +0200, Mike Rapoport wrote:
> On Tue, Feb 12, 2019 at 10:56:26AM +0800, Peter Xu wrote:
> > From: Shaohua Li <shli@fb.com>
> > 
> > Add API to enable/disable writeprotect a vma range. Unlike mprotect,
> > this doesn't split/merge vmas.
> > 
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Kirill A. Shutemov <kirill@shutemov.name>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Shaohua Li <shli@fb.com>
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > [peterx:
> >  - use the helper to find VMA;
> >  - return -ENOENT if not found to match mcopy case;
> >  - use the new MM_CP_UFFD_WP* flags for change_protection
> >  - check against mmap_changing for failures]
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> > ---
> >  include/linux/userfaultfd_k.h |  3 ++
> >  mm/userfaultfd.c              | 54 +++++++++++++++++++++++++++++++++++
> >  2 files changed, 57 insertions(+)
> > 
> > diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
> > index 765ce884cec0..8f6e6ed544fb 100644
> > --- a/include/linux/userfaultfd_k.h
> > +++ b/include/linux/userfaultfd_k.h
> > @@ -39,6 +39,9 @@ extern ssize_t mfill_zeropage(struct mm_struct *dst_mm,
> >  			      unsigned long dst_start,
> >  			      unsigned long len,
> >  			      bool *mmap_changing);
> > +extern int mwriteprotect_range(struct mm_struct *dst_mm,
> > +			       unsigned long start, unsigned long len,
> > +			       bool enable_wp, bool *mmap_changing);
> > 
> >  /* mm helpers */
> >  static inline bool is_mergeable_vm_userfaultfd_ctx(struct vm_area_struct *vma,
> > diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> > index fefa81c301b7..529d180bb4d7 100644
> > --- a/mm/userfaultfd.c
> > +++ b/mm/userfaultfd.c
> > @@ -639,3 +639,57 @@ ssize_t mfill_zeropage(struct mm_struct *dst_mm, unsigned long start,
> >  {
> >  	return __mcopy_atomic(dst_mm, start, 0, len, true, mmap_changing, 0);
> >  }
> > +
> > +int mwriteprotect_range(struct mm_struct *dst_mm, unsigned long start,
> > +			unsigned long len, bool enable_wp, bool *mmap_changing)
> > +{
> > +	struct vm_area_struct *dst_vma;
> > +	pgprot_t newprot;
> > +	int err;
> > +
> > +	/*
> > +	 * Sanitize the command parameters:
> > +	 */
> > +	BUG_ON(start & ~PAGE_MASK);
> > +	BUG_ON(len & ~PAGE_MASK);
> > +
> > +	/* Does the address range wrap, or is the span zero-sized? */
> > +	BUG_ON(start + len <= start);
> 
> I'd replace these BUG_ON()s with
> 
> 	if (WARN_ON())
> 		 return -EINVAL;

I believe BUG_ON() is used because these parameters should have been
checked in userfaultfd_writeprotect() already by the common
validate_range() even before calling mwriteprotect_range().  So I'm
fine with the WARN_ON() approach but I'd slightly prefer to simply
keep the patch as is to keep Jerome's r-b if you won't disagree. :)

Thanks,

-- 
Peter Xu

