Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDD69C76191
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 12:26:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71A21217F4
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 12:26:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71A21217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED13D6B0003; Thu, 18 Jul 2019 08:26:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E816E6B0007; Thu, 18 Jul 2019 08:26:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D96408E0001; Thu, 18 Jul 2019 08:26:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B5BCE6B0003
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 08:26:33 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id e39so24102838qte.8
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 05:26:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=L7sUTXkpil8lGGW6uIRJo6nFXE6R0Nebf1DOcmrGXRM=;
        b=XqRvBLWrQFN/s8vluLHHZSVqSXgqUPeUtCGFlYNVYtzVW8AUdhLmuKVaHk7Cb0Hkrf
         KlexhPGDCFkGTSeiKqQPUU8UJeaxaJ5v6vUgotry5N2LRThkgITPUAPMcmldBeUU8Biq
         KCcxhYuLsg98YJmq1nUI7GYZvDuTNCuSoA+x8Gf2Sr7HzJfdKQL2YTTEN5gGCs7IFogl
         vllKBKRHPdDVRrkJTm86FR+N1QWMoumdSWSXKNWeM6mIQRyTqd7p/D/dpTXs59FtxRTP
         PbhMJ3vVC4SFdX8mcuTjOj1a4SpQars9swanetapFxPKm/OU+dDsZZgbwhhTNGUom0+r
         AV5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVJNjudO+AyM78rU24t6HUtV885Zd6BZfe9J6RNUDWmsJ3l+wR2
	EgaUYhr/NnB+hjZyBet1YPoMzfh69sR5xqoqoP9i8+sgsYJhln9diysOwUhvcUlbjSOY/OJCuWy
	hphHBPQoAQCEj8AFjRymNamzZvbEo0NhCiTj2tQTn8R12bi3tRSJLBnGNP1tZyNrn1w==
X-Received: by 2002:ac8:7349:: with SMTP id q9mr31834579qtp.151.1563452793472;
        Thu, 18 Jul 2019 05:26:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwE383ZzoTnQxUQKUbEYWCoPlyke0LlGwRqQ++4ZpaGnaY27uAKxu94bDvHxWwDc0iTT3Tx
X-Received: by 2002:ac8:7349:: with SMTP id q9mr31834544qtp.151.1563452792945;
        Thu, 18 Jul 2019 05:26:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563452792; cv=none;
        d=google.com; s=arc-20160816;
        b=BWCijICzpKOLiYUaBLOtzd+g/ec69nrGzlA16gMeCilT8UWJVuiQezRpUMed+ztUPz
         m3tjeCjKkEnfUFtULFKPLWRYNAZJNRJ42ip90JWWSZ/w3jGgRaZTydyChcxcwiEaABA+
         KeIJoEWtCTQAnys7LHVDZLYvHNnMzynBWc0UhynsWqTmSB+sQXtWxe0ES5Zt91m7joc6
         m+6RbPTVISKVGUQaAFXj2WzzOBo/79ddyvczIElZe5/bH5DUBvEsfYjqhYcZGBv3UYsU
         G6pQY7HaXVWPFJvt4RCSSOKLkw5QnU8Qi2KYbj7AekNMIOnV/RvYju2W7aM+QT0aDuof
         dMTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=L7sUTXkpil8lGGW6uIRJo6nFXE6R0Nebf1DOcmrGXRM=;
        b=eQIz8UZvTsF8UoGYy9CAy2pzL+IwH5+qgtl60uPicAlshAco/kQbG6ZE/c3+jyx6ZE
         LEK9gedyKh2dykkednt/ebrLK90LhJspXXFkFHIps7/aErh4327CnrpBmFhQkgBfQY30
         dowDGpEA/2V4ziR+Lj2RndolaMhTzzDuxLaqQ0Hv1fOvSc6uScumS+oeNh620NfmlbjF
         BIjU4WvmfjIDNO1iK56oL2amjIKxWF2bzDR26Xnr1wY4SoI+3oTnH0Z8hmkpcEToL9eP
         8jfUIG8AKNmT80TGt4B+2PlYdHRGm7flzBRfvziqfXxMK0qg8e0RpWufThnlyKmAl+jv
         sqEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q124si16312484qkf.251.2019.07.18.05.26.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 05:26:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0D1E58553B;
	Thu, 18 Jul 2019 12:26:32 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id 5B13360A35;
	Thu, 18 Jul 2019 12:26:18 +0000 (UTC)
Date: Thu, 18 Jul 2019 08:26:11 -0400
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
Message-ID: <20190718082535-mutt-send-email-mst@kernel.org>
References: <1563442040-13510-1-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1563442040-13510-1-git-send-email-wei.w.wang@intel.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 18 Jul 2019 12:26:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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


ok I posted v3 with typo fixes. 1/2 is this patch with comment changes. Pls take a look.

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

