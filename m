Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52171C76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 06:52:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B89B21841
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 06:52:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B89B21841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B10036B0005; Thu, 18 Jul 2019 02:52:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9AA58E0003; Thu, 18 Jul 2019 02:52:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 939C98E0001; Thu, 18 Jul 2019 02:52:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 707DC6B0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 02:52:07 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id v4so22297581qkj.10
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 23:52:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=WXSVZThXaa7MCiYb3qO6Oi3nuRTx8b9y1mEpGmlC3AU=;
        b=LoDxWbuVWm0V+gExTfoc2S6GdPbsDtHRYHsIUD67UQ3kSke3iA2oL4J0WPukN8wbje
         1D9pNEpksXMFs6hLDIlUkbG60RQnKrBS8htkCep/RfyXyXU5uJpA999OmhUmSO+csjei
         2cwL6gdKib0GgxH9GeHe7ATKuB9dMf/xU8kvjb0hKGtn/6aNcQLNfG9vkN1zMeBTovNw
         LZLCwZjivhFlJj7S4Jh6XBeu87N8Bet5OyPFxBx3QpAI4YPxhr9v9XK9Vi4P2dEQFl4R
         Had23nD5zS9td323LuimIySf4+EQDQ7Qq8/ao+Rj5VBTBfC+8X+fJ00MsyQ3qLJORd2l
         0gow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVSJC50kAmDSOeiY7W/0kY5t6nTgGko0jM5yrrWT0qvciKz4Rsw
	1c6oQlSrSoI9FWXF80OSxW/GdxgWUcuPll0PoUjLJiJBt8gPK8H9HkDmokM7Svqs8qBfwruPVZI
	6JDhhvXCEsMcRC8h8u0q2ZrdEyeP/Z41KG3ZyuFsroJwWZ897WGO+8vMOdMtounB9hw==
X-Received: by 2002:ad4:5311:: with SMTP id y17mr31497711qvr.1.1563432727193;
        Wed, 17 Jul 2019 23:52:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzj3x26H4WLXxjkgjmqQiwGpP3g1qMUBncFyTiLXuIBu3Eakofg0I38Kwws2OSrYOYU78y9
X-Received: by 2002:ad4:5311:: with SMTP id y17mr31497689qvr.1.1563432726560;
        Wed, 17 Jul 2019 23:52:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563432726; cv=none;
        d=google.com; s=arc-20160816;
        b=MLyuij/Vk689qsv3vrONmUp2vGRC4eNzUeeslrpG/ZesJjg2N6viwe10aDUgumZjF4
         1Cw23wSQreG/oMry/Tg5EaaJtVAC4XEbdqCSTU8zGPMGsle54hSMW7bruVMpSEqJlcT4
         ozexuAP0cRIZzQrFwytw9VaYh34pdAG38U2eX2xU3GpCckryxx88RqmpjGjdYCMuVCZm
         AZxTm5aSYQVmxJxcM4CVIHqDQJMgIkJCT0YnF60RVXNoFzwWRd42xtDHj/dK6ybmmHAA
         zvWDhVt/DKxHg6fpEaDgOUcHE8UAtzoEKZyhziaXyacmhF5ltOb+YNZOHnViIylVN5Xc
         L6rA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=WXSVZThXaa7MCiYb3qO6Oi3nuRTx8b9y1mEpGmlC3AU=;
        b=iiXNh0J5n4HPy/+rEIY1ZTC0iVeQkbywzAta9SeBXgqd/5GSCds+00LvG5FRElBPox
         aKNeurrVJqFSLwV91D9EkoU9vCY1vqU7eLiAO1udQl2OV6AAxs001qkbllnekxWcJqDD
         xDNs3HkQd1cFn1X4kcJyCpx8lGGPvJApXxo39Mbrt7TRO1H+23nIVTBvHk0dD+BIC8R5
         i98SWTMiPhzMtSkfvfFlnyebehHqWCzMFdREd//cMGIb0Js+2a4ovr3JzUkGQwnK2YNN
         IhRFujyUN8WCgc6BwA2PmAEQOoMULEMz+miXKe/zY+OZZpRL+mom2UmDAF5Fq/mTkeDT
         8iUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 16si17580156qtz.340.2019.07.17.23.52.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 23:52:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A54388E24F;
	Thu, 18 Jul 2019 06:52:05 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id E894160D7C;
	Thu, 18 Jul 2019 06:51:52 +0000 (UTC)
Date: Thu, 18 Jul 2019 02:51:51 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	xdeguillard@vmware.com, namit@vmware.com, akpm@linux-foundation.org,
	pagupta@redhat.com, riel@surriel.com, dave.hansen@intel.com,
	david@redhat.com, konrad.wilk@oracle.com, yang.zhang.wz@gmail.com,
	nitesh@redhat.com, lcapitulino@redhat.com, aarcange@redhat.com,
	pbonzini@redhat.com, alexander.h.duyck@linux.intel.com,
	dan.j.williams@intel.com
Subject: Re: [PATCH v1] mm/balloon_compaction: avoid duplicate page removal
Message-ID: <20190718024822-mutt-send-email-mst@kernel.org>
References: <1563416610-11045-1-git-send-email-wei.w.wang@intel.com>
 <20190718001605-mutt-send-email-mst@kernel.org>
 <5D301232.7080808@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5D301232.7080808@intel.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 18 Jul 2019 06:52:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 02:31:14PM +0800, Wei Wang wrote:
> On 07/18/2019 12:31 PM, Michael S. Tsirkin wrote:
> > On Thu, Jul 18, 2019 at 10:23:30AM +0800, Wei Wang wrote:
> > > Fixes: 418a3ab1e778 (mm/balloon_compaction: List interfaces)
> > > 
> > > A #GP is reported in the guest when requesting balloon inflation via
> > > virtio-balloon. The reason is that the virtio-balloon driver has
> > > removed the page from its internal page list (via balloon_page_pop),
> > > but balloon_page_enqueue_one also calls "list_del"  to do the removal.
> > I would add here "this is necessary when it's used from
> > balloon_page_enqueue_list but not when it's called
> > from balloon_page_enqueue".
> > 
> > > So remove the list_del in balloon_page_enqueue_one, and have the callers
> > > do the page removal from their own page lists.
> > > 
> > > Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> > Patch is good but comments need some work.
> > 
> > > ---
> > >   mm/balloon_compaction.c | 3 ++-
> > >   1 file changed, 2 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
> > > index 83a7b61..1a5ddc4 100644
> > > --- a/mm/balloon_compaction.c
> > > +++ b/mm/balloon_compaction.c
> > > @@ -11,6 +11,7 @@
> > >   #include <linux/export.h>
> > >   #include <linux/balloon_compaction.h>
> > > +/* Callers ensure that @page has been removed from its original list. */
> > This comment does not make sense. E.g. balloon_page_enqueue
> > does nothing to ensure this. And drivers are not supposed
> > to care how the page lists are managed. Pls drop.
> > 
> > Instead please add the following to balloon_page_enqueue:
> > 
> > 
> > 	Note: drivers must not call balloon_page_list_enqueue on
> 
> Probably, you meant balloon_page_enqueue here.

yes

> The description for balloon_page_enqueue also seems incorrect:
> "allocates a new page and inserts it into the balloon page list."
> This function doesn't do any allocation itself.
> Plan to reword it: inserts a new page into the balloon page list."

And maybe
" Page must have been allocated with balloon_page_alloc.".


Also
 * Driver must call it to properly enqueue a balloon pages before definitively

should be
 * Driver must call it to properly enqueue balloon pages before definitively


> 
> Best,
> Wei

