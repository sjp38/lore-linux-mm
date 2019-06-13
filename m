Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A557AC31E49
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:14:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76FC1217D6
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:14:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76FC1217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6D6F6B026B; Thu, 13 Jun 2019 11:14:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1E3D6B026C; Thu, 13 Jun 2019 11:14:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D34D18E0001; Thu, 13 Jun 2019 11:14:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C2F56B026B
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 11:14:23 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 59so12118883plb.14
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:14:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zQjn1s7WJFZu7VY7A+6586JA46f8i8oLBonp8NrIAYw=;
        b=RxSO1gQb6cVFrL9yUzBf31utmwhSFMO4PVFNs1r3l4Loqk6FfwjsjRh7JZRBOUupPU
         UMWTwUNvVzqCPrtyxQ03QEcraoa7ozqrmqSFoDoUAVI3HXJT3GolK0KrL1puE6Gz+v7P
         8bCzYL85FZlHXINXoQfllx94slHuivFNjdxVbR7M+gvcmizcUUO4Mv8CPgJdeybHUan+
         3ZikOe2oktWL+RrGwu/TfL6Bf0M25mMLXo0VBS3o7bYksg3o4RHbDVcmEHtU1W7gRsQh
         ooEBQNYsqc5+0jxgs70UoW/GbwrQ37bf40FBIqfamgXJxKVpRq9jJhBuWtSRQYvcDMrv
         6PvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUyY4IHsoO80hSQuDaxTbCpR6JNmdbZCTxXfVbgceevgYlnRrRZ
	ZTzXZMPDDPEdN3Oo7H1dAw/Meb47O3YE6zn33P7ZMlKneNl7MV3bWeE9stQOhCYy29ey7awh2ZZ
	WWfdCY7IWKA2KAgkd7P53f2CEusXfVN1bgvDz+ADNw8S6oFy33CN2njuGeoRUugLEJw==
X-Received: by 2002:a65:5344:: with SMTP id w4mr30910026pgr.8.1560438863169;
        Thu, 13 Jun 2019 08:14:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz33fct0RcgdBcM8DhNDclS0vBrg31+Um55BQjpjIGV6GoL0NwbHkv/5722DOqqfXqEOU0T
X-Received: by 2002:a65:5344:: with SMTP id w4mr30909977pgr.8.1560438862462;
        Thu, 13 Jun 2019 08:14:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560438862; cv=none;
        d=google.com; s=arc-20160816;
        b=rF+TAR+ByqFDRgaWOF+laqxeFBhTvPbp6FxdPKrip6HnvhQbqPQ0EngxHbdRuhsft3
         XbHd5beeWitYyXxlofceroBO8PARhOYgM5v0Z/4SGzjJcOsJBOjirBYoWsq5QpzPzX3O
         0Mv/zLQRbc/IfU1dlXg6d/2YHTwE8gT1IXFl3PkfjCMOoEqaDE9I/dNQNGQEKJ8oQhbe
         VxRGNGHEvPw/SQ/6Uy43tWkKkHuY1NS6/pVcghlzsIMY558dWaAR+GcaSMY4Wq/+JgXl
         uDgjA9nmsVdR9AvRnZt6nrK5y73SegX1DzDHj4xnuWq2p/seEX+EQXgoK2cogNs6aJ0K
         WjGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zQjn1s7WJFZu7VY7A+6586JA46f8i8oLBonp8NrIAYw=;
        b=FeZF6MuKQRJVXSe20hCIa0V+gfWdE2uqfpxfxCtH8iEtRWFvl7+jcv/3Okxr6KN4V3
         AFydONVHtKZDAH27LnDqDPNtA3r4ySA9ToY2o5Z7GGxGEDOmcdjfrKUpKguYW+gTk3+3
         Q3zsKG1JEPI1wIfEvCN8EnOXijucwkn88ohN2gyiXyCk4xu4b/HIg8CGd/nm0es34m8b
         z+Og4EFM83YSGRwN8UFxn+grWL0NDOpqttS1fZ3pcJJNodCJh7W3ttSNEZJ7+GBec/UL
         MHYgvf8R2njtj8WIcLx+vxO0Q1l0BYlObZ2Jio05MEdaoFsIEYL75k1mJtWb5OpROy94
         VwYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 59si3688051plp.90.2019.06.13.08.14.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 08:14:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Jun 2019 08:14:21 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga004.jf.intel.com with ESMTP; 13 Jun 2019 08:14:18 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id CC735159; Thu, 13 Jun 2019 18:14:17 +0300 (EEST)
Date: Thu, 13 Jun 2019 18:14:17 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Song Liu <songliubraving@fb.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>,
	LKML <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"namit@vmware.com" <namit@vmware.com>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"oleg@redhat.com" <oleg@redhat.com>,
	"rostedt@goodmis.org" <rostedt@goodmis.org>,
	"mhiramat@kernel.org" <mhiramat@kernel.org>,
	"matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
	Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH v3 3/5] mm, thp: introduce FOLL_SPLIT_PMD
Message-ID: <20190613151417.7cjxwudjssl5h2pf@black.fi.intel.com>
References:<20190612220320.2223898-1-songliubraving@fb.com>
 <20190612220320.2223898-4-songliubraving@fb.com>
 <20190613125718.tgplv5iqkbfhn6vh@box>
 <5A80A2B9-51C3-49C4-97B6-33889CC47F08@fb.com>
 <20190613141615.yvmckzi3fac4qjag@box>
 <32E15B93-24B9-4DBB-BDD4-DDD8537C7CE0@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To:<32E15B93-24B9-4DBB-BDD4-DDD8537C7CE0@fb.com>
User-Agent: NeoMutt/20170714-126-deb55f (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 03:03:01PM +0000, Song Liu wrote:
> 
> 
> > On Jun 13, 2019, at 7:16 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > 
> > On Thu, Jun 13, 2019 at 01:57:30PM +0000, Song Liu wrote:
> >>> And I'm not convinced that it belongs here at all. User requested PMD
> >>> split and it is done after split_huge_pmd(). The rest can be handled by
> >>> the caller as needed.
> >> 
> >> I put this part here because split_huge_pmd() for file-backed THP is
> >> not really done after split_huge_pmd(). And I would like it done before
> >> calling follow_page_pte() below. Maybe we can still do them here, just 
> >> for file-backed THPs?
> >> 
> >> If we would move it, shall we move to callers of follow_page_mask()? 
> >> In that case, we will probably end up with similar code in two places:
> >> __get_user_pages() and follow_page(). 
> >> 
> >> Did I get this right?
> > 
> > Would it be enough to replace pte_offset_map_lock() in follow_page_pte()
> > with pte_alloc_map_lock()?
> 
> This is similar to my previous version:
> 
> +		} else {  /* flags & FOLL_SPLIT_PMD */
> +			pte_t *pte;
> +			spin_unlock(ptl);
> +			split_huge_pmd(vma, pmd, address);
> +			pte = get_locked_pte(mm, address, &ptl);
> +			if (!pte)
> +				return no_page_table(vma, flags);
> +			spin_unlock(ptl);
> +			ret = 0;
> +		}
> 
> I think this is cleaner than use pte_alloc_map_lock() in follow_page_pte(). 
> What's your thought on these two versions (^^^ vs. pte_alloc_map_lock)?

It's additional lock-unlock cycle and few more lines of code...

> > This will leave bunch not populated PTE entries, but it is fine: they will
> > be populated on the next access to them.
> 
> We need to handle page fault during next access, right? Since we already
> allocated everything, we can just populate the PTE entries and saves a
> lot of page faults (assuming we will access them later). 

Not a lot due to faultaround and they may never happen, but you need to
tear down the mapping any way.

-- 
 Kirill A. Shutemov

