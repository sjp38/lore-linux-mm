Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3524C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 11:37:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C833229ED
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 11:37:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C833229ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A7F46B0003; Wed, 24 Jul 2019 07:37:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 757E46B0005; Wed, 24 Jul 2019 07:37:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66DC98E0002; Wed, 24 Jul 2019 07:37:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 47FFD6B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:37:16 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id q26so41260409qtr.3
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 04:37:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JOWC4bhCJmfhcc7hKdBktwT8LxfwZnzkmPUQoHL0BtI=;
        b=bSyRukv15+xXb5pSSXI5j8DLHUSuJTBoxKOW7B9NApXligapZRaSVWqlMSAR7uvf0I
         gwhw1Ge1fGDU/0kLV0AiJn7gF/lW9fnsjQQOZyvvSxe2YzvpD7UrkSDL6C1TwMKmH3ri
         /J5IevgkaLCpA1dUXtQyQpz/i4SA0Km700oNuwRu+l2PCVxE3aBhevBwjNk9MJH8MYf5
         5mSu2Ign22MwLjVPtY/FW2tsj8bzIHgIM3PW2cgB6uWlSGFsCqisXl9HQKoMIP+uqt3J
         3yi6nJEE8kXPGxHtAVE8i47Xc6f9bTPWsBM78IIp9CrpYcf+i4kvq+oGFF7cTdu3xrBi
         ZXkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVUC3RTp8wmjGSpFzT7X/sOXqz14MRzCT5zetGqjIX+VfxViwcZ
	idlqvqXmFQeAwYLcJRiD6VpIVmxJAAinOATaHSP0pZq9Q4IHZ/bTxFbY3eH6zA8jZqRE4sZBK0K
	KOOAUVrIEu5oCtjUaDKsW+Xud1Ji1tl1eaedxgvq6krFrFYpTr7+RO5xo7HX/FWEtNw==
X-Received: by 2002:a05:620a:685:: with SMTP id f5mr51261434qkh.238.1563968236056;
        Wed, 24 Jul 2019 04:37:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNcfWa24MllXSHPV3e7BBtQj02Rl6g91Ky+Vw1Dw/rgdkMaBBKu/Uz8+j2VW7tquUXgNOs
X-Received: by 2002:a05:620a:685:: with SMTP id f5mr51261401qkh.238.1563968235483;
        Wed, 24 Jul 2019 04:37:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563968235; cv=none;
        d=google.com; s=arc-20160816;
        b=a8bgT05MCdrcyZlb9UZjs470qAVlWkZaGl+u7ndKJMvLMXhe+rsl1ek81Vo/dCX9ei
         TYwc+/oCaILtoY4d3tvQQfjycJF6whR+U4lAxPTtzQJ/G9myz5Cd6o2qHSAZ7pip+rOW
         K3vOmTJLTe2xQA4RUzhG4k9NdwxvIkFrVd9QvPWaJLbxzC7Crclyz9iFrFaa92n50jGa
         xW/nPB0KY/MooXOGSQMlCiimeke+BxvEn0ak4oEE1R2tvddZaZgVrBg4uNWSI6lMkj7R
         4/gI5YV6sFfhKiZWZBDwz+7hCY+YgvdFc9zitfms8a4bezAyjuhV1jkIRN11KRi1AURx
         pHGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JOWC4bhCJmfhcc7hKdBktwT8LxfwZnzkmPUQoHL0BtI=;
        b=oZ0+5bU94pjbo1H69CZxUbuUwWE5u/fFzqSdJj1L5qNeIFwIbxL6qRKOm3iUoEeExM
         49Njtp3x3wPUZEGyKe46kkQtqy3swnn6JnzeXOaaot0L+H+Kp24BTAP9fFPHM0SEfdsP
         2vSnwSndpR0dzbITUQp11OQLITaqTjwnw37IbPURNWjQGaSGqn7q2Y8uYzr5Ve41beo1
         CWu1h2/az431qZ33hoCe3xTtbYa6KxZ34aDL4m0WNDp1mXN96mi4MG9R51InRNL/QWCW
         eX8Jgx/IoCrg7SE9Qj+wLpYeTCvO+LRt6Sco4QRCJmAQbozmdFC8E1MWx2zNmqDkhEkk
         NSSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z7si10093001qtz.1.2019.07.24.04.37.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 04:37:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 748FC30BD1B1;
	Wed, 24 Jul 2019 11:37:14 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 53FB760BCE;
	Wed, 24 Jul 2019 11:37:12 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Wed, 24 Jul 2019 13:37:14 +0200 (CEST)
Date: Wed, 24 Jul 2019 13:37:11 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, peterz@infradead.org,
	rostedt@goodmis.org, kernel-team@fb.com,
	william.kucharski@oracle.com
Subject: Re: [PATCH v8 2/4] uprobe: use original page when all uprobes are
 removed
Message-ID: <20190724113711.GE21599@redhat.com>
References: <20190724083600.832091-1-songliubraving@fb.com>
 <20190724083600.832091-3-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724083600.832091-3-songliubraving@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 24 Jul 2019 11:37:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/24, Song Liu wrote:
>
>  	lock_page(old_page);
> @@ -177,15 +180,24 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
>  	mmu_notifier_invalidate_range_start(&range);
>  	err = -EAGAIN;
>  	if (!page_vma_mapped_walk(&pvmw)) {
> -		mem_cgroup_cancel_charge(new_page, memcg, false);
> +		if (!orig)
> +			mem_cgroup_cancel_charge(new_page, memcg, false);
>  		goto unlock;
>  	}
>  	VM_BUG_ON_PAGE(addr != pvmw.address, old_page);
>  
>  	get_page(new_page);
> -	page_add_new_anon_rmap(new_page, vma, addr, false);
> -	mem_cgroup_commit_charge(new_page, memcg, false, false);
> -	lru_cache_add_active_or_unevictable(new_page, vma);
> +	if (orig) {
> +		lock_page(new_page);  /* for page_add_file_rmap() */
> +		page_add_file_rmap(new_page, false);


Shouldn't we re-check new_page->mapping after lock_page() ? Or we can't
race with truncate?


and I am worried this code can try to lock the same page twice...
Say, the probed application does MADV_DONTNEED and then writes "int3"
into vma->vm_file at the same address to fool verify_opcode().

Oleg.

