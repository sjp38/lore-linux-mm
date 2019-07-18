Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BFC6C76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 13:47:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9B9220873
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 13:47:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9B9220873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1EA8A6B0005; Thu, 18 Jul 2019 09:47:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19AB36B0006; Thu, 18 Jul 2019 09:47:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03CF76B0007; Thu, 18 Jul 2019 09:47:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BF8C36B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 09:47:45 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h3so16693099pgc.19
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 06:47:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=TDLZ5+uKDbL91Wp3Ii9vh/EIQugL21Xd64csPUMUvJA=;
        b=GMubhhQrA2m/S/Ie3XMmNV03F+xEPnaMV0V422z9q5tu7DjRhOr6N6SfpA9bABjOPz
         1+CXFoYmkaB3DdQ+lwrCoevTU28eop+uMh06ArvGC8n+Dug2Tqh0OepfJebSsTRbLr4j
         dBLqNBJ8pCFmjz5z+p8Y6KQvgseX5+p3v0b0I/hF+QIlwOC4INDkNPYWdafAuLW1FSfm
         t+SqywG2wRyOVbW+PM6spil3IjbQEpGL3zFJFFCMvxc0hTFWjS+MlSYYYDsBQT+Ujhov
         srWfHLUMqQcDboamQRHi/TWI1LrU1xBNyfQgsefYEz68u9nDjqP2h0i3RkZSS6Xu8feA
         /Msw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVnm4rMSpm2U3vvj+i7rRV3bwWl5t4HJANmivvzB9G2jypVRpWx
	6LbEKu7GGnf2iFDHvwqXClW+63L8U+ONlmDO3vVLSRKpfgbOtp+6yHYHi+mwvUA6zerO56gC9p4
	AgCa2Ymb8ZPtYHZh2zGwWbypIAvQUg3u2N2ld1wH/5KA8eXvdkTwywVLeNBEw5p/QNg==
X-Received: by 2002:a17:90a:338b:: with SMTP id n11mr50514883pjb.21.1563457665294;
        Thu, 18 Jul 2019 06:47:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1fv+8HjqRN3/YC77UZTHp7LwucCvyxLnTukQwUjzmUe9mqDag6ABqmcerYlfzvVrycqFw
X-Received: by 2002:a17:90a:338b:: with SMTP id n11mr50514801pjb.21.1563457664115;
        Thu, 18 Jul 2019 06:47:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563457664; cv=none;
        d=google.com; s=arc-20160816;
        b=SVXCQutqAShkwZsRtnb6RGkJktAxJyYvvE4D8+f6TSjNQpTMah+48Q2xryiN4VBVgJ
         2YSNsVNokbgyr5dReSF/FmrVU3F79yKOm/Qeg+oRU9kbOAOrXu3sIm/TBlRVHlZ7vSxR
         cE9oGjVdXcrJto9ZoVi9dD9PLo4jCg1mhY5HiwXJn/DAltky1W9vcuN7xI2t61X8Yb9T
         dFt+/JxS+5ynRUan65JF1FJTWHGceJifkcQ+5X+9KgoXLg0hfX8ba4CJPurZJLJeYnop
         BRXJGTDgRlSBjW7bqmvsvzDVaKv6aX0y9JuAd4EFNOsqKv/4vyiUb2+EMvwhbwW4Zkyu
         ajMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=TDLZ5+uKDbL91Wp3Ii9vh/EIQugL21Xd64csPUMUvJA=;
        b=NOLJjt10sB159EP849RW+wgjoKVHhBHSQo73STCAqsEzbhS2Obi4aQczpRPeQkG41h
         HicqoeAlbvAHjLGfn4MkoCddwk/YjIFRD8/mQN8NhW1TNBBr/O8jREZ2TKcbFndshZ7l
         OeFult5o8Y9q0BpdVOKBKkXf5OmOsBP2OfX1LmCTHXBcMU31EL3gpIdn9SsCAqzjz9aj
         iPEMuJ/qhyKBgpwDJfnW4ROT88cOCpGG237G90V65rGRcOyABAjWexrVJduV465or9EK
         9pAeKkauTXWlZgMMGUpeXa+nOa33Ss9daniWDmIAJ+IUWNWfQHZ/teTjQMpDdSD7aQea
         MMwA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id v27si1708446pgn.14.2019.07.18.06.47.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 06:47:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of wei.w.wang@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=wei.w.wang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jul 2019 06:47:43 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,278,1559545200"; 
   d="scan'208";a="169860182"
Received: from fmsmsx105.amr.corp.intel.com ([10.18.124.203])
  by fmsmga007.fm.intel.com with ESMTP; 18 Jul 2019 06:47:43 -0700
Received: from fmsmsx155.amr.corp.intel.com (10.18.116.71) by
 FMSMSX105.amr.corp.intel.com (10.18.124.203) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Thu, 18 Jul 2019 06:47:42 -0700
Received: from shsmsx104.ccr.corp.intel.com (10.239.4.70) by
 FMSMSX155.amr.corp.intel.com (10.18.116.71) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Thu, 18 Jul 2019 06:47:42 -0700
Received: from shsmsx102.ccr.corp.intel.com ([169.254.2.3]) by
 SHSMSX104.ccr.corp.intel.com ([169.254.5.110]) with mapi id 14.03.0439.000;
 Thu, 18 Jul 2019 21:47:41 +0800
From: "Wang, Wei W" <wei.w.wang@intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
CC: Jason Wang <jasowang@redhat.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>
Subject: RE: [PATCH v3 2/2] balloon: fix up comments
Thread-Topic: [PATCH v3 2/2] balloon: fix up comments
Thread-Index: AQHVPWPB7Kn6mp4V4ECCoWD/TZ2+lqbQWhSw
Date: Thu, 18 Jul 2019 13:47:40 +0000
Message-ID: <286AC319A985734F985F78AFA26841F73E1705ED@shsmsx102.ccr.corp.intel.com>
References: <20190718122324.10552-1-mst@redhat.com>
 <20190718122324.10552-2-mst@redhat.com>
In-Reply-To: <20190718122324.10552-2-mst@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiNmYzMTA4NzItODMyNi00OTQ1LWExYmQtYTg0ZjVkNWNjMWNlIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiSUc3MUVZK0YrRkpHb2Eyam5BN2lKWloyZ3cySDlMd1pRV211TW5KTjAxZXFRcEdRaFNEMitYZmw2c0NBK2VhbiJ9
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
dlp-reaction: no-action
x-originating-ip: [10.239.127.40]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday, July 18, 2019 8:24 PM, Michael S. Tsirkin wrote:
>  /*
>   * balloon_page_alloc - allocates a new page for insertion into the ball=
oon
> - *			  page list.
> + *			page list.
>   *
> - * Driver must call it to properly allocate a new enlisted balloon page.
> - * Driver must call balloon_page_enqueue before definitively removing it
> from
> - * the guest system.  This function returns the page address for the rec=
ently
> - * allocated page or NULL in the case we fail to allocate a new page thi=
s turn.
> + * Driver must call this function to properly allocate a new enlisted ba=
lloon
> page.

Probably better to say "allocate a new balloon page to enlist" ?
"enlisted page" implies that the allocated page has been added to the list,=
 which might
be misleading.


> + * Driver must call balloon_page_enqueue before definitively removing
> + the page
> + * from the guest system.
> + *
> + * Returns: struct page address for the allocated page or NULL in case i=
t fails
> + * 			to allocate a new page.
>   */

Returns: pointer to the page struct of the allocated page, or NULL if alloc=
ation fails.



>  struct page *balloon_page_alloc(void)
>  {
> @@ -130,19 +133,15 @@ EXPORT_SYMBOL_GPL(balloon_page_alloc);
>  /*
>   * balloon_page_enqueue - inserts a new page into the balloon page list.
>   *
> - * @b_dev_info: balloon device descriptor where we will insert a new pag=
e
> to
> + * @b_dev_info: balloon device descriptor where we will insert a new
> + page
>   * @page: new page to enqueue - allocated using balloon_page_alloc.
>   *
> - * Driver must call it to properly enqueue a new allocated balloon page
> - * before definitively removing it from the guest system.
> + * Drivers must call this function to properly enqueue a new allocated
> + balloon
> + * page before definitively removing the page from the guest system.
>   *
> - * Drivers must not call balloon_page_enqueue on pages that have been
> - * pushed to a list with balloon_page_push before removing them with
> - * balloon_page_pop. To all pages on a list, use balloon_page_list_enque=
ue
> - * instead.
> - *
> - * This function returns the page address for the recently enqueued page=
 or
> - * NULL in the case we fail to allocate a new page this turn.
> + * Drivers must not call balloon_page_enqueue on pages that have been
> + pushed to
> + * a list with balloon_page_push before removing them with
> + balloon_page_pop. To
> + * enqueue all pages on a list, use balloon_page_list_enqueue instead.

"To enqueue a list of pages" ?


>   */
>  void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
>  			  struct page *page)
> @@ -157,14 +156,24 @@ EXPORT_SYMBOL_GPL(balloon_page_enqueue);
>=20
>  /*
>   * balloon_page_dequeue - removes a page from balloon's page list and
> returns
> - *			  the its address to allow the driver release the page.
> + *			  its address to allow the driver to release the page.
>   * @b_dev_info: balloon device decriptor where we will grab a page from.
>   *
> - * Driver must call it to properly de-allocate a previous enlisted ballo=
on
> page
> - * before definetively releasing it back to the guest system.
> - * This function returns the page address for the recently dequeued page=
 or
> - * NULL in the case we find balloon's page list temporarily empty due to
> - * compaction isolated pages.
> + * Driver must call this to properly dequeue a previously enqueued page
=20
"call this function"?
=20

> + * before definitively releasing it back to the guest system.
> + *
> + * Caller must perform its own accounting to ensure that this
> + * function is called only if some pages are actually enqueued.


"only when" ?

> + *
> + * Note that this function may fail to dequeue some pages even if there

"even when" ?

> + are
> + * some enqueued pages - since the page list can be temporarily empty
> + due to
> + * the compaction of isolated pages.
> + *
> + * TODO: remove the caller accounting requirements, and allow caller to
> + wait
> + * until all pages can be dequeued.
> + *
> + * Returns: struct page address for the dequeued page, or NULL if it fai=
ls to
> + * 			dequeue any pages.

Returns: pointer to the page struct of the dequeued page, or NULL if no pag=
e gets dequeued.


>   */
>  struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
> { @@ -177,9 +186,9 @@ struct page *balloon_page_dequeue(struct
> balloon_dev_info *b_dev_info)
>  	if (n_pages !=3D 1) {
>  		/*
>  		 * If we are unable to dequeue a balloon page because the
> page
> -		 * list is empty and there is no isolated pages, then
> something
> +		 * list is empty and there are no isolated pages, then
> something
>  		 * went out of track and some balloon pages are lost.
> -		 * BUG() here, otherwise the balloon driver may get stuck
> into
> +		 * BUG() here, otherwise the balloon driver may get stuck in
>  		 * an infinite loop while attempting to release all its pages.
>  		 */
>  		spin_lock_irqsave(&b_dev_info->pages_lock, flags); @@ -
> 230,8 +239,8 @@ int balloon_page_migrate(struct address_space *mapping,
>=20
>  	/*
>  	 * We can not easily support the no copy case here so ignore it as it
=20
"cannot"

> -	 * is unlikely to be use with ballon pages. See include/linux/hmm.h
> for
> -	 * user of the MIGRATE_SYNC_NO_COPY mode.
> +	 * is unlikely to be used with ballon pages. See include/linux/hmm.h


"ballon" -> "balloon"


> for
> +	 * a user of the MIGRATE_SYNC_NO_COPY mode.

"for the usage of" ?


Other parts look good to me.
Reviewed-by: Wei Wang <wei.w.wang@intel.com>

Best,
Wei

