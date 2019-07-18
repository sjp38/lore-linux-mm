Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CC46C76196
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 13:54:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D37B6217F4
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 13:54:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D37B6217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EDE46B0007; Thu, 18 Jul 2019 09:54:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69ECC6B0008; Thu, 18 Jul 2019 09:54:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58E028E0001; Thu, 18 Jul 2019 09:54:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 388C36B0007
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 09:54:53 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id y19so24437370qtm.0
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 06:54:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=xX5YPpqp0yL5Xb3nP1kSnufYHXYkTrLtJvIseYd9Mfg=;
        b=NQEcU8DriZP8rG2iVOAnvWYq2cNJpvEArw9VUbaLq6gDEzv/tcwCBjb6YVPNzVVg11
         el+rIbRQa2fp6Js+1DJ61icxh168b2UZPMFcYjAH9lc2S7sLN9wa2dtF1LDdS1gWhMHR
         01Kr7gR5cd/N+0pb/4Ynl5SDaOpsm/Rgp52LatfQe07ZurFp3aTB6T5SuPn5S2m2LM+f
         7RGFSyNsQxI5ebgUoTmNmxekgUnTBi4UAK6YdFbD0bN2YqvXy0SMmaksRpVYZlX/M+jC
         HVejE4ne+Kv4Tf+4bqwPukCHt65f+DLfy/7D/5DMBjeYZHmFLzxNXDPGR8Y26phuQq7A
         QF2g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX+lX5Kb2heGW3hWn7sBptG5Qj7yR4KA5cotnTKjgfGZP2cE4QA
	ycw9Qp2DBe2PI6Z159eoBUyXVNHpWj975RtCb8mQCB79eHC3sKrT/hKVBv9cAOp7GrduYNC5CD8
	mUIoYRaLocOPnGl6py1pvH7s+z53gc0fz9p+6ND3hriMYMN+dm2MoTHAFWizFhoimYQ==
X-Received: by 2002:a0c:ea4b:: with SMTP id u11mr2383464qvp.143.1563458092948;
        Thu, 18 Jul 2019 06:54:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2tSbrpyc5ZdQVoYIxTWRadzDxBQs6y05D8Q/du4pD0EGFGK4LsCxk/aFHEJSjCDj3YKeP
X-Received: by 2002:a0c:ea4b:: with SMTP id u11mr2383410qvp.143.1563458092102;
        Thu, 18 Jul 2019 06:54:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563458092; cv=none;
        d=google.com; s=arc-20160816;
        b=EnAH9d7/BiJGOWBl1Te00idPGeeDI1LHpY3O+HbXxfhQWTLvbdncHRWlcCarY8obR1
         AEm7YUoX2Vaj1cq3KoER3VXmKYTC9U2pbT0VrhUOzEBjtGl+PwKSVAwzCSPgUrPT4HlJ
         errhhv/RA+kuhiDSxDTm/Do5uc1M3Opd8BlsRwTL9wN6baddvMkRMmxzzwd/aMiOIXm6
         uEj1EB57OrlEOsSg9KILPYz5ZQ2glSXzg9Vg49TSaITWwdRxaNFibQ7sjbhTIpGWSrfT
         fGjxccTEuiZP4RyZXzo4DTCK18VPG0wg3zuNhkcc5XYh3Gx6N3JIbcWp/e0KUOELW2tT
         cVDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=xX5YPpqp0yL5Xb3nP1kSnufYHXYkTrLtJvIseYd9Mfg=;
        b=uMAc1cAMaIrj2y7vhEiieHJHxBtDEuaTy/v8IrG4X2dnw8k5e1WXXor+gNIBrvBDhM
         9yZnlD57d0faOTa1Bp0FCmImU2BxnuhrAT3KQ0b3nP3yW6WJr5iFTv/nSWZ1j3273xKg
         7gNWu1AiJNbbOzRgmaubnT46rhZ2+p3DOO0+DepSXD17U3jHfjXzcxsI5x7Pfy6AoCzX
         ct6iZif7UKqWb1/kZvx3p9oyoJlb/b7mx7Xa/aVH9PsqjhgVUdWRKQYZlscMvwFkABNx
         vbvWoddXnR12x1ObZCvO6a/RvpleOkzHHhoXmdCI+GEw4yBCeN7kbnwK/6gPjhhtR043
         h9HQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z7si18476216qtz.1.2019.07.18.06.54.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 06:54:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id ECA3430C62AC;
	Thu, 18 Jul 2019 13:54:50 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id 220381001B18;
	Thu, 18 Jul 2019 13:54:48 +0000 (UTC)
Date: Thu, 18 Jul 2019 09:54:48 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: "Wang, Wei W" <wei.w.wang@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jason Wang <jasowang@redhat.com>,
	"virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [PATCH v3 2/2] balloon: fix up comments
Message-ID: <20190718094840-mutt-send-email-mst@kernel.org>
References: <20190718122324.10552-1-mst@redhat.com>
 <20190718122324.10552-2-mst@redhat.com>
 <286AC319A985734F985F78AFA26841F73E1705ED@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <286AC319A985734F985F78AFA26841F73E1705ED@shsmsx102.ccr.corp.intel.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 18 Jul 2019 13:54:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 01:47:40PM +0000, Wang, Wei W wrote:
> On Thursday, July 18, 2019 8:24 PM, Michael S. Tsirkin wrote:
> >  /*
> >   * balloon_page_alloc - allocates a new page for insertion into the balloon
> > - *			  page list.
> > + *			page list.
> >   *
> > - * Driver must call it to properly allocate a new enlisted balloon page.
> > - * Driver must call balloon_page_enqueue before definitively removing it
> > from
> > - * the guest system.  This function returns the page address for the recently
> > - * allocated page or NULL in the case we fail to allocate a new page this turn.
> > + * Driver must call this function to properly allocate a new enlisted balloon
> > page.
> 
> Probably better to say "allocate a new balloon page to enlist" ?
> "enlisted page" implies that the allocated page has been added to the list, which might
> be misleading.


right should be just a new balloon page.
> 
> > + * Driver must call balloon_page_enqueue before definitively removing
> > + the page
> > + * from the guest system.
> > + *
> > + * Returns: struct page address for the allocated page or NULL in case it fails
> > + * 			to allocate a new page.
> >   */
> 
> Returns: pointer to the page struct of the allocated page, or NULL if allocation fails.


ok

> 
> 
> >  struct page *balloon_page_alloc(void)
> >  {
> > @@ -130,19 +133,15 @@ EXPORT_SYMBOL_GPL(balloon_page_alloc);
> >  /*
> >   * balloon_page_enqueue - inserts a new page into the balloon page list.
> >   *
> > - * @b_dev_info: balloon device descriptor where we will insert a new page
> > to
> > + * @b_dev_info: balloon device descriptor where we will insert a new
> > + page
> >   * @page: new page to enqueue - allocated using balloon_page_alloc.
> >   *
> > - * Driver must call it to properly enqueue a new allocated balloon page
> > - * before definitively removing it from the guest system.
> > + * Drivers must call this function to properly enqueue a new allocated
> > + balloon
> > + * page before definitively removing the page from the guest system.
> >   *
> > - * Drivers must not call balloon_page_enqueue on pages that have been
> > - * pushed to a list with balloon_page_push before removing them with
> > - * balloon_page_pop. To all pages on a list, use balloon_page_list_enqueue
> > - * instead.
> > - *
> > - * This function returns the page address for the recently enqueued page or
> > - * NULL in the case we fail to allocate a new page this turn.
> > + * Drivers must not call balloon_page_enqueue on pages that have been
> > + pushed to
> > + * a list with balloon_page_push before removing them with
> > + balloon_page_pop. To
> > + * enqueue all pages on a list, use balloon_page_list_enqueue instead.
> 
> "To enqueue a list of pages" ?

ok

> 
> >   */
> >  void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
> >  			  struct page *page)
> > @@ -157,14 +156,24 @@ EXPORT_SYMBOL_GPL(balloon_page_enqueue);
> > 
> >  /*
> >   * balloon_page_dequeue - removes a page from balloon's page list and
> > returns
> > - *			  the its address to allow the driver release the page.
> > + *			  its address to allow the driver to release the page.
> >   * @b_dev_info: balloon device decriptor where we will grab a page from.
> >   *
> > - * Driver must call it to properly de-allocate a previous enlisted balloon
> > page
> > - * before definetively releasing it back to the guest system.
> > - * This function returns the page address for the recently dequeued page or
> > - * NULL in the case we find balloon's page list temporarily empty due to
> > - * compaction isolated pages.
> > + * Driver must call this to properly dequeue a previously enqueued page
>  
> "call this function"?

ok

> 
> > + * before definitively releasing it back to the guest system.
> > + *
> > + * Caller must perform its own accounting to ensure that this
> > + * function is called only if some pages are actually enqueued.
> 
> 
> "only when" ?

I think when would be confusing here since this function
is called significantly after pages are first enqueued.

> > + *
> > + * Note that this function may fail to dequeue some pages even if there
> 
> "even when" ?

same

> > + are
> > + * some enqueued pages - since the page list can be temporarily empty
> > + due to
> > + * the compaction of isolated pages.
> > + *
> > + * TODO: remove the caller accounting requirements, and allow caller to
> > + wait
> > + * until all pages can be dequeued.
> > + *
> > + * Returns: struct page address for the dequeued page, or NULL if it fails to
> > + * 			dequeue any pages.
> 
> Returns: pointer to the page struct of the dequeued page, or NULL if no page gets dequeued.
> 

was dequeued.

> >   */
> >  struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
> > { @@ -177,9 +186,9 @@ struct page *balloon_page_dequeue(struct
> > balloon_dev_info *b_dev_info)
> >  	if (n_pages != 1) {
> >  		/*
> >  		 * If we are unable to dequeue a balloon page because the
> > page
> > -		 * list is empty and there is no isolated pages, then
> > something
> > +		 * list is empty and there are no isolated pages, then
> > something
> >  		 * went out of track and some balloon pages are lost.
> > -		 * BUG() here, otherwise the balloon driver may get stuck
> > into
> > +		 * BUG() here, otherwise the balloon driver may get stuck in
> >  		 * an infinite loop while attempting to release all its pages.
> >  		 */
> >  		spin_lock_irqsave(&b_dev_info->pages_lock, flags); @@ -
> > 230,8 +239,8 @@ int balloon_page_migrate(struct address_space *mapping,
> > 
> >  	/*
> >  	 * We can not easily support the no copy case here so ignore it as it
>  
> "cannot"
> 
> > -	 * is unlikely to be use with ballon pages. See include/linux/hmm.h
> > for
> > -	 * user of the MIGRATE_SYNC_NO_COPY mode.
> > +	 * is unlikely to be used with ballon pages. See include/linux/hmm.h
> 
> 
> "ballon" -> "balloon"

ok

> 
> > for
> > +	 * a user of the MIGRATE_SYNC_NO_COPY mode.
> 
> "for the usage of" ?

Not really I think, it's an example user but does not document usage.

> 
> Other parts look good to me.
> Reviewed-by: Wei Wang <wei.w.wang@intel.com>
> 
> Best,
> Wei

