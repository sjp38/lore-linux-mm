Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A493DC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 21:06:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68C69214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 21:06:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68C69214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0799D8E0003; Tue, 12 Mar 2019 17:06:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 002D18E0002; Tue, 12 Mar 2019 17:06:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0EBA8E0003; Tue, 12 Mar 2019 17:06:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C2868E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 17:06:26 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m17so4016202pgk.3
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 14:06:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+I2/0B4Z/KCN6pu7J8qhdH8xmn0Wr+p+LqWqRt1KPoA=;
        b=FX7OtbZj2tXNCTIlvMPLR39yRZgaG3L0gVR6qodBuYOH1t+7tOUcSnsXco1Z8LuMXr
         aTO6Urjig5AoN0boiXqk6+VT7Ufn3CDnwcLbvBDU5kpET/ArRaQfdCE3huTjzLaZuJaL
         +dLi08LoFrArNFvMv9q2z9orbX2qvyzV11A/ljqwMPlXWwtWGo/TY268K5/qdSH3BG1h
         Pasuq9VcT1eVD8tTOKU7U7fwzYhOPmeMktCnd6kHnxJf197h5FVWEREN741w6eHuv7vj
         tZKBuBjwvIvgLHftV1wBobhkNs5AD3kCmfjfpBrG1mPobcDg87kc3Dk4z6TPfvErfUlI
         jM+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAXh1tiz2LjrMzrl+pL2gGKK0FC5tlwGEa4gG7nExmK4zMLblvjB
	8jro3GVirCrfqr94uHk1yXEA3k0nB51eOios02sND4x1Y9WAqtN5NvQS0AnRxryoEVWSk2zIFyP
	a9rNOMRbfpS9pLR3NuFJDHYmkUKLmqGaL/tndypVE7DgyB6zKNp4rmm15ljAS/9vtZA==
X-Received: by 2002:a17:902:e60e:: with SMTP id cm14mr41880911plb.192.1552424786248;
        Tue, 12 Mar 2019 14:06:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOKjcPerHGwsEicuAG7T32sULfN4b47OM9Opq2+jUJcogQ+fQefVps3cGc6ee3YmlDKlmN
X-Received: by 2002:a17:902:e60e:: with SMTP id cm14mr41880786plb.192.1552424784814;
        Tue, 12 Mar 2019 14:06:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552424784; cv=none;
        d=google.com; s=arc-20160816;
        b=UJAHVr1Fzun7DGOHxtppBSxBGWM3x/yME2RJwWp447Txer247ywj/WHB6UegJBXywC
         mJVXF37HEKy9d32SRhVAoF9hfikXqoHDYVyQSfIhsRcf7YObXa2Iduur1q25wZ7Uqvb9
         wvdJQHGA2fUpHwtLwI4ZZD+es4L4glZhtK9Ak94drB/NPnTuf6fSwXzHhHUJipO7XNYA
         5p4iteEhOtt6kOu4p1omyXcVKpcNgpHuLI/1ywntkzwztPcJYNIRoRqWITELfZdjGEod
         MB/YWTcyzxAcjfHHXXCHQsxTkaGoBUYnosvtBtpjH1M/5CzAjnYO3kMlSX3VBDE984Eb
         W04w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=+I2/0B4Z/KCN6pu7J8qhdH8xmn0Wr+p+LqWqRt1KPoA=;
        b=zLVwLvxfvW/zvKB5NIIhGhaJX+HGYEUutX1vDmVx5+EW62ZZcsltIigmGbXLWd9ML+
         R6Yy/jQd/j0+UsZAEc+R2oqZ+HRfy4O/TWUH68Kfq8a1/It5cl6L3YKNrI9fyT9ZMer7
         7BgvFRt7qK6Crb9q2BI/Guob5nK0uJ/9IwOwWZHnold5KiCXbCwjbyhO2rONeVeoTfR/
         ePvUgFQrm6Wke5pWraXQFa3z7eojXNiK4vZD9OJ6Q4dt/f82dlGjxOzcwgQw6l5bBtiM
         hH2bPmODKYAQNPs6tpqsWSIdV4c/Sb0ZKI/BV0Vd5g3DY6VNbkSOZW2uBmPp9XyS+LL0
         sg5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e9si8138051pgv.349.2019.03.12.14.06.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 14:06:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 47FECE3C;
	Tue, 12 Mar 2019 21:06:24 +0000 (UTC)
Date: Tue, 12 Mar 2019 14:06:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH] filemap: don't unlock null page in FGP_FOR_MMAP case
Message-Id: <20190312140623.54e337e01eb9fbfe11258330@linux-foundation.org>
In-Reply-To: <20190312201742.22935-1-josef@toxicpanda.com>
References: <20190312201742.22935-1-josef@toxicpanda.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Mar 2019 16:17:42 -0400 Josef Bacik <josef@toxicpanda.com> wrote:

> We noticed a panic happening in production with the filemap fault pages
> because we were unlocking a NULL page.  If add_to_page_cache() fails
> then we'll have a NULL page, so fix this check to only unlock if we
> have a valid page.
> 
> Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> ---
>  mm/filemap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index cace3eb8069f..2815cb79a246 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1663,7 +1663,7 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
>  		 * add_to_page_cache_lru locks the page, and for mmap we expect
>  		 * an unlocked page.
>  		 */
> -		if (fgp_flags & FGP_FOR_MMAP)
> +		if (page && (fgp_flags & FGP_FOR_MMAP))
>  			unlock_page(page);
>  	}
>  

Fixes "filemap: kill page_cache_read usage in filemap_fault".

This patch series:

filemap-kill-page_cache_read-usage-in-filemap_fault.patch
filemap-kill-page_cache_read-usage-in-filemap_fault-fix.patch
filemap-kill-page_cache_read-usage-in-filemap_fault-fix-2.patch
filemap-pass-vm_fault-to-the-mmap-ra-helpers.patch
filemap-drop-the-mmap_sem-for-all-blocking-operations.patch
filemap-drop-the-mmap_sem-for-all-blocking-operations-v6.patch
filemap-drop-the-mmap_sem-for-all-blocking-operations-fix.patch
filemap-drop-the-mmap_sem-for-all-blocking-operations-checkpatch-fixes.patch

has been stuck since December.  I have a note here that syzbot reported
a use-after-free.  What's the situation with that?

I also have a cryptic note that
filemap-drop-the-mmap_sem-for-all-blocking-operations-v6.patch is
"still fishy".  I'm not sure what I meant by the latter - the (small
amount of) review seems to be OK.  Do you recall what issues there
might have been and the status of those?

