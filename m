Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B7B0C76196
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 11:37:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BAC92085A
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 11:37:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BAC92085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC23D6B000A; Thu, 18 Jul 2019 07:37:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B71536B000C; Thu, 18 Jul 2019 07:37:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A86A98E0001; Thu, 18 Jul 2019 07:37:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 871B46B000A
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 07:37:27 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x17so22938641qkf.14
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 04:37:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=5ERH6j84Wl27x+RpL6A8MMNg1+Akr7ti8rloGvx/QNs=;
        b=MBxtjaqYhGo/WGPsImz5d1x48yZUvweTGpJzi0NaesLTTL4DWbubpVIjHEFaxyAYr5
         BTRrNNBxoKfzI9LxzUe4mISSWlb4JGESYLbF6hR6L6mwLYUpd8WEQPEM+AJ7WB2hMXBu
         SnwZQ5bdwGQ5K/Iz9Hski16eF8dlyhlPHkrpmXJrfIxgr2PoaLE08RoSNx6q0DYVWn7r
         BDEnOnsMUjBxQAdhGkW/Ab/++ihZvjJtG+TUwQ47Fd0MDe36RuAko0bskaS4qaPhigJd
         4Z0ebzMhZZ2Smj766eQwa1Izm4c57C9b8HGSwdzNmSTYCQ9ISWpIS6N35GI5pZGt4FqV
         BHyg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXMCYcnToEwkZi0j0jEvBv1jUsBM5OTh+Ndp+f0FhiuNiQDQi3K
	XZWltwzGD3o6YiOmRqhjEqP+cYfoseBeaQk0QYZvtQll0dmF/xw+v7uuoBLucVfpGPCtofQ2aGn
	8FI+MrAqdMtggGBjiXUp3gaYaGR+pJRVF7cfJ2+OewYqWSByanEu9U3jlsrkjhSDAdA==
X-Received: by 2002:a05:620a:247:: with SMTP id q7mr32018968qkn.265.1563449847301;
        Thu, 18 Jul 2019 04:37:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQtJYDJ/5tdTQdreewQAXquXfDFs1rL0pg5pw/Vdp5dt83gsToOhP/2apLDUdtVQrNxv8u
X-Received: by 2002:a05:620a:247:: with SMTP id q7mr32018893qkn.265.1563449846265;
        Thu, 18 Jul 2019 04:37:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563449846; cv=none;
        d=google.com; s=arc-20160816;
        b=vhyEJYuP6nTwNEMWEazza04k+ZoZRzF4WPEFy27ZEeBcru/xmFdEggm4kMauH42973
         kNkuibLolvtmSVcGlw06gruzc7Sd51tlVbVKcfOgW6Gl5QPkCWN1gsj5eFj6InyEZ71e
         dQPj/3FFXOAoLje3NAlAAi+4lYwYiJZOqPPfJDhPXsNLLeW8NMOwg4sa7al35jJMm/yc
         qLv7CLFLWZEJ4s2VnQD+w2tpp1RWqzUe7xqiMwC1OuZVrkM6vMtRkSes8AiH3Ex0Nh+i
         untaCRL3Z5Zqs3YTNREIQUOd5p25n77ND5KKu06Q+FEBMcn/0l7twn5xIvtpfr/J5/cK
         Sg0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=5ERH6j84Wl27x+RpL6A8MMNg1+Akr7ti8rloGvx/QNs=;
        b=IrIb/2+w1RL+bK/iz1Rw0ZYLEReQbpoYo3zOutjzhgNmQtVEs6p3b4AffqqOUzTeeN
         v+2bhTrmtIx0RzlNEQp5UOnBkG56dsN8TtCUj+9eaq5YmtCSyXPrqOKijGkupDW6nyao
         R5iBKrjUg2DuOjQ+/i7btMHfQNwBcDTNnz5SXfe6/zHPruQGzE9Gj8NuyUXH+Vzhso2q
         Pb3CvBPekaE1mt224AQcBUM6tyIiOakcqvkhoFu2jp+JckCWDAMsA+svMg3XW1emi1kC
         Rp/59qcoi14PUu9h+sfJxSTwfcw20gbYH2A6DIgpH4+UxnkoeCluHXOkgWRqxhJdXMhy
         SeJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p3si18777973qtf.41.2019.07.18.04.37.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 04:37:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0DE5059465;
	Thu, 18 Jul 2019 11:37:25 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id A992460C98;
	Thu, 18 Jul 2019 11:37:10 +0000 (UTC)
Date: Thu, 18 Jul 2019 07:37:06 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	xdeguillard@vmware.com, namit@vmware.com, akpm@linux-foundation.org,
	pagupta@redhat.com, riel@surriel.com, dave.hansen@intel.com,
	david@redhat.com, konrad.wilk@oracle.com, yang.zhang.wz@gmail.com,
	nitesh@redhat.com, lcapitulino@redhat.com, aarcange@redhat.com,
	pbonzini@redhat.com, alexander.h.duyck@linux.intel.com,
	dan.j.williams@intel.com
Subject: Re: [PATCH v2] mm/balloon_compaction: avoid duplicate page removal
Message-ID: <20190718073645-mutt-send-email-mst@kernel.org>
References: <1563442040-13510-1-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1563442040-13510-1-git-send-email-wei.w.wang@intel.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 18 Jul 2019 11:37:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

OK almost. Bunch of typos but I fixed them. Thanks!

On Thu, Jul 18, 2019 at 05:27:20PM +0800, Wei Wang wrote:
> Fixes: 418a3ab1e778 (mm/balloon_compaction: List interfaces)
> 
> A #GP is reported in the guest when requesting balloon inflation via
> virtio-balloon. The reason is that the virtio-balloon driver has
> removed the page from its internal page list (via balloon_page_pop),
> but balloon_page_enqueue_one also calls "list_del"  to do the removal.
> This is necessary when it's used from balloon_page_enqueue_list, but
> not from balloon_page_enqueue_one.
> 
> So remove the list_del balloon_page_enqueue_one, and update some
> comments as a reminder.
> 
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> ---
> ChangeLong:
> v1->v2: updated some comments
> 
>  mm/balloon_compaction.c | 14 ++++++++++----
>  1 file changed, 10 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
> index 83a7b61..8639bfc 100644
> --- a/mm/balloon_compaction.c
> +++ b/mm/balloon_compaction.c
> @@ -21,7 +21,6 @@ static void balloon_page_enqueue_one(struct balloon_dev_info *b_dev_info,
>  	 * memory corruption is possible and we should stop execution.
>  	 */
>  	BUG_ON(!trylock_page(page));
> -	list_del(&page->lru);
>  	balloon_page_insert(b_dev_info, page);
>  	unlock_page(page);
>  	__count_vm_event(BALLOON_INFLATE);
> @@ -33,7 +32,7 @@ static void balloon_page_enqueue_one(struct balloon_dev_info *b_dev_info,
>   * @b_dev_info: balloon device descriptor where we will insert a new page to
>   * @pages: pages to enqueue - allocated using balloon_page_alloc.
>   *
> - * Driver must call it to properly enqueue a balloon pages before definitively
> + * Driver must call it to properly enqueue balloon pages before definitively
>   * removing it from the guest system.
>   *
>   * Return: number of pages that were enqueued.
> @@ -47,6 +46,7 @@ size_t balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
>  
>  	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
>  	list_for_each_entry_safe(page, tmp, pages, lru) {
> +		list_del(&page->lru);
>  		balloon_page_enqueue_one(b_dev_info, page);
>  		n_pages++;
>  	}
> @@ -128,13 +128,19 @@ struct page *balloon_page_alloc(void)
>  EXPORT_SYMBOL_GPL(balloon_page_alloc);
>  
>  /*
> - * balloon_page_enqueue - allocates a new page and inserts it into the balloon
> - *			  page list.
> + * balloon_page_enqueue - inserts a new page into the balloon page list.
> + *
>   * @b_dev_info: balloon device descriptor where we will insert a new page to
>   * @page: new page to enqueue - allocated using balloon_page_alloc.
>   *
>   * Driver must call it to properly enqueue a new allocated balloon page
>   * before definitively removing it from the guest system.
> + *
> + * Drivers must not call balloon_page_enqueue on pages that have been
> + * pushed to a list with balloon_page_push before removing them with
> + * balloon_page_pop. To all pages on a list, use balloon_page_list_enqueue
> + * instead.
> + *
>   * This function returns the page address for the recently enqueued page or
>   * NULL in the case we fail to allocate a new page this turn.
>   */
> -- 
> 2.7.4

