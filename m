Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61FABC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:13:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 227DA208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:13:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 227DA208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7D1E6B0006; Fri,  7 Jun 2019 15:13:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2DE76B000A; Fri,  7 Jun 2019 15:13:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACE906B000C; Fri,  7 Jun 2019 15:13:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7579E6B0006
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 15:13:56 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z10so2024981pgf.15
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 12:13:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=CtpnRA6Qzz0WbpuB8gLNio4h0HrmWyKurRoUjYFKT2E=;
        b=E3bG/DoqEKLhSX3OtXJiNwXuWlysttbCKoKI4DzRLn4kDQfiFyDf60ThTNh79URL9a
         bDfGaF/HTYmtfMa9AXi+Xi+Ul2rni7fhsJ/XAcy8mgE4phMjsoLJXZFPAADnhbEIQEqh
         3XMVkWqC8WjTtlc4q1olWUOjCwVqO2TQgOf84L1M+OJctM12O2E3NT46l34UwxU+Yp8b
         0FJX6kMORFEOO4ZMCsKrWKVTUhiSsa8qzc+fl8ngVCoOOTddXcZuQ24tCuIChYLM7eLR
         tLUv/q8feMRJSyjo/uUHpGJ1v1BQHlRG6cjpEJ/dhWcALnmd2htlUQxX1KY2cYbSazvw
         7VNw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAViJkIEnoEKTiQBF14x1k4XFCR/nI8OtIIUnpwCRJT8CoXMu4p2
	NdLKT2yLZipdp4MckHWFDS2FM8ABJN40VoklkjDyhWV5okybpk/krEfyDy8gu4rxHj7WYm4RM1d
	Mn4euZUHMtwsPXCd4hEQGE6Vvi+7ClpWaCjEl2J5PB4mOXFj1L5ToL9E8ZQPEQ8C8tw==
X-Received: by 2002:a63:231c:: with SMTP id j28mr4410834pgj.430.1559934836072;
        Fri, 07 Jun 2019 12:13:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsZE4c8wjHAy8gr0eWaYDzv0EO9O1uNVgX0H4yK04LMnJ5A/Y+inXCqwcpl9UcIBD6Xx7D
X-Received: by 2002:a63:231c:: with SMTP id j28mr4410791pgj.430.1559934835316;
        Fri, 07 Jun 2019 12:13:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559934835; cv=none;
        d=google.com; s=arc-20160816;
        b=y3ofZs2i+NVa5fHAxdbUENux1GFulnlZAE4EWlkTAgnsLIMCRFhWUqP1St4gxgGNl7
         Zs2vngaWCLSkB1+gLFC1iR/gm6S0HFXhjvuER8f1UftHw9JGGGuU7Y/Ay/AfFJBu2ITq
         2TKDsmqZ+cCHYmc6RxtgLhWpIpjArKj8XTXNBolJxTapXcS0Dn3E9ydQ4vlLdqO1Rbjr
         yZH5DczhW9H7C6EFERap2PQE9xyC2zX8X40PeMFgXjJuAzqkCFxyrWz0OWY1tB6BiRDF
         pik4BFGEll0MJoKPawEd0qspQpGkJgNljNr3EL4/GttweRuaZHlXRF0yXd9HfAO75XmN
         MjqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=CtpnRA6Qzz0WbpuB8gLNio4h0HrmWyKurRoUjYFKT2E=;
        b=kc6gW3b1dq39ck/+zWJ1vrLxr8AO7LrmwPm67ZWloVZaIqk6dh2ZITvdJv4xejVeDV
         BK/X4mbk0cFdQj4uXhyFnKF/dHstV9WE6z6tTueS4lpJ3BALC5tpU2jppifgViTGfWOi
         aBJGrSwa+R1BgkYTiZW/eCmAyTbAsRNT8qOb6U1idAfTJJlwzalanEf6QTDGsj8FZ5Xh
         RWwS00kEB3uzBWf714WEMZq68hcQy+0+Zg3xAzXG8Xc9MG3BFE5ou7+V8FtOco/fvrX9
         VbkLQjvwOWa0jEhXH5VY1yFBRCdiQXqiI5xqCOAG2EhlIR3OslV/A34oiQlHwq+2+LOT
         Jlcg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id q2si2739793pgh.177.2019.06.07.12.13.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 12:13:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 12:13:54 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga006.fm.intel.com with ESMTP; 07 Jun 2019 12:13:52 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 0BAED526; Fri,  7 Jun 2019 22:13:49 +0300 (EEST)
Date: Fri, 7 Jun 2019 22:13:49 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Oleg Nesterov <oleg@redhat.com>,
	Jann Horn <jannh@google.com>, Hugh Dickins <hughd@google.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Peter Xu <peterx@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
	Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 1/1] coredump: fix race condition between
 collapse_huge_page() and core dumping
Message-ID: <20190607191349.wvhhnnsd63vrz7xo@black.fi.intel.com>
References:<20190607161558.32104-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To:<20190607161558.32104-1-aarcange@redhat.com>
User-Agent: NeoMutt/20170714-126-deb55f (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 04:15:58PM +0000, Andrea Arcangeli wrote:
> When fixing the race conditions between the coredump and the mmap_sem
> holders outside the context of the process, we focused on
> mmget_not_zero()/get_task_mm() callers in commit
> 04f5866e41fb70690e28397487d8bd8eea7d712a, but those aren't the only
> cases where the mmap_sem can be taken outside of the context of the
> process as Michal Hocko noticed while backporting that commit to
> older -stable kernels.
> 
> If mmgrab() is called in the context of the process, but then the
> mm_count reference is transferred outside the context of the process,
> that can also be a problem if the mmap_sem has to be taken for writing
> through that mm_count reference.
> 
> khugepaged registration calls mmgrab() in the context of the process,
> but the mmap_sem for writing is taken later in the context of the
> khugepaged kernel thread.
> 
> collapse_huge_page() after taking the mmap_sem for writing doesn't
> modify any vma, so it's not obvious that it could cause a problem to
> the coredump, but it happens to modify the pmd in a way that breaks an
> invariant that pmd_trans_huge_lock() relies upon. collapse_huge_page()
> needs the mmap_sem for writing just to block concurrent page faults
> that call pmd_trans_huge_lock().
> 
> Specifically the invariant that "!pmd_trans_huge()" cannot become
> a "pmd_trans_huge()" doesn't hold while collapse_huge_page() runs.
> 
> The coredump will call __get_user_pages() without mmap_sem for
> reading, which eventually can invoke a lockless page fault which will
> need a functional pmd_trans_huge_lock().
> 
> So collapse_huge_page() needs to use mmget_still_valid() to check it's
> not running concurrently with the coredump... as long as the coredump
> can invoke page faults without holding the mmap_sem for reading.
> 
> This has "Fixes: khugepaged" to facilitate backporting, but in my view
> it's more a bug in the coredump code that will eventually have to be
> rewritten to stop invoking page faults without the mmap_sem for
> reading. So the long term plan is still to drop all
> mmget_still_valid().
> 
> Cc: <stable@vger.kernel.org>
> Fixes: ba76149f47d8 ("thp: khugepaged")
> Reported-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

