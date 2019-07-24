Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FD81C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 22:03:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AB9E22ADA
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 22:03:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AB9E22ADA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66E716B026E; Wed, 24 Jul 2019 18:03:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61DE06B026F; Wed, 24 Jul 2019 18:03:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50D538E0002; Wed, 24 Jul 2019 18:03:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1B1146B026E
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 18:03:58 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id h5so29211599pgq.23
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:03:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=Vt84thAsLWJyAd5XrtQr8ILHkY6FV6XP1tRY7DSDNVE=;
        b=ocEavjkFzgd/VkM2+4JbXIKnTmXFGVe47i1t5xG5rwRVTWURUCZzR2QFL8k3TowCWm
         mYZhv0DseyVM6x6qVJX78luy3NJuPAo1EZGOiREABaN00Mg6/B9sBvxMnb5FZXx6F6JF
         /ujQmQZKV+zL1G6fdEobQ/GieYAAjUCk7t8zmASMN7bLVRKDqbxRXfEMKs5Ldq1XVYS0
         8RHhVy9NS5VFm6w17SNCk43CZ3BCXwuQJsjKfoXvtve7MohTZgQV4cuE3BOJxGqH9svx
         qS8vXQhtODc/VgrAo3+Xoiv1dbN3RKjccz858+boqB7DflY+yeJVlvxzabqAzlKrGbAW
         KA7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV1hU7DW3HrP6d9OrgWGW7uTlD6nGgGu+Jlxdl/jbUrmmLni2nz
	QyDYj9F2oC7klorJs/GF/jf7iTXo0+vkdyfRROLBYDQcVWaPAVCyxVu9zMFrbiOTbqWddm6CRjs
	60RJ+KaeMaxqJNEzQ8XM2qd7/XbuDjCzxxTNUkd3TXxVFGSBsuWo6haCGAJgQRlLCjA==
X-Received: by 2002:a17:902:f089:: with SMTP id go9mr87580129plb.81.1564005837704;
        Wed, 24 Jul 2019 15:03:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcfAU5WwHBXamwBdD6fWsoovp87C+K0rnz1H+mI9E5qBxwzRGNI/g2O8jlUehxpQOLuBFM
X-Received: by 2002:a17:902:f089:: with SMTP id go9mr87580079plb.81.1564005837014;
        Wed, 24 Jul 2019 15:03:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564005837; cv=none;
        d=google.com; s=arc-20160816;
        b=PSCmsTYaZHfPQX9L0j7MhmH+tC+Xj4JeLtVvjCX/15Er1d/4wvhNxlKH8Ob13CYv8D
         EEnxp4ZX/EsvTEX9j54OpuC+U9ntsr1YSb5HyDLRV7S2LWavDixVdTu8/1sBkuM3DHJa
         lxt5M3LplRVtG+jNkgybYEUA/BMWG75YK2LJ7Mr55JJqeUSX0GLaaRn0oRfpfg3uJRWr
         0gc7y9CcRC933QaQSip4tu5RG7DSNS7539Lsp0EHh0K1miivl4tZ0z26XXPwzCgwZt12
         ud9NMYMxiAjLqiljCxztCPIjNGW4/GozBddh6ZSWMojudWmLJ0hpnboLiEBlV510GCPN
         90zA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=Vt84thAsLWJyAd5XrtQr8ILHkY6FV6XP1tRY7DSDNVE=;
        b=Xol4bvpS3QW8PxIPxjyXHR+ZXb9bST6cCCEI+HNAjAL8aPSnGzPiu4izF5aO+ln5aa
         K07nunhViEqGnkO0T/6/qwqMqYXiasBTqt2W5qdgn4xSktSnvH+P5AVVAKfTV3ERKJq7
         q/wlgcGJdj9vBBmYSKkotbI3eMmTxLV9iMJ2Z8cCGvuPA90VlxxkT4gLKouefdVdGNb2
         p+cwJKFuIBabjb6howCRDUgFmneG/8dTeq9ZL0WVCEpzxKGLAeznUqBjUvEhrcZihKgm
         Zm2nQBDnkjs66FciGDhjJSJ9HR+fYgU3TRedeXpDgfyOEvR643EJX3Y0b8bqq2GVgCQK
         GyHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id e14si9033732pgg.442.2019.07.24.15.03.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 15:03:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jul 2019 15:03:56 -0700
X-IronPort-AV: E=Sophos;i="5.64,304,1559545200"; 
   d="scan'208";a="175019406"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga006-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jul 2019 15:03:56 -0700
Message-ID: <ada4e7d932ebd436d00c46e8de699212e72fd989.camel@linux.intel.com>
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>
Cc: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, 
	dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	akpm@linux-foundation.org, yang.zhang.wz@gmail.com, pagupta@redhat.com, 
	riel@surriel.com, konrad.wilk@oracle.com, lcapitulino@redhat.com, 
	wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com, 
	dan.j.williams@intel.com
Date: Wed, 24 Jul 2019 15:03:56 -0700
In-Reply-To: <20190724173403-mutt-send-email-mst@kernel.org>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
	 <20190724171050.7888.62199.stgit@localhost.localdomain>
	 <20190724173403-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-07-24 at 17:38 -0400, Michael S. Tsirkin wrote:
> On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > Add support for what I am referring to as "bubble hinting". Basically the
> > idea is to function very similar to how the balloon works in that we
> > basically end up madvising the page as not being used. However we don't
> > really need to bother with any deflate type logic since the page will be
> > faulted back into the guest when it is read or written to.
> > 
> > This is meant to be a simplification of the existing balloon interface
> > to use for providing hints to what memory needs to be freed. I am assuming
> > this is safe to do as the deflate logic does not actually appear to do very
> > much other than tracking what subpages have been released and which ones
> > haven't.
> > 
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
> BTW I wonder about migration here.  When we migrate we lose all hints
> right?  Well destination could be smarter, detect that page is full of
> 0s and just map a zero page. Then we don't need a hint as such - but I
> don't think it's done like that ATM.

I was wondering about that a bit myself. If you migrate with a balloon
active what currently happens with the pages in the balloon? Do you
actually migrate them, or do you ignore them and just assume a zero page?
I'm just reusing the ram_block_discard_range logic that was being used for
the balloon inflation so I would assume the behavior would be the same.

> I also wonder about interaction with deflate.  ATM deflate will add
> pages to the free list, then balloon will come right back and report
> them as free.

I don't know how likely it is that somebody who is getting the free page
reporting is likely to want to also use the balloon to take up memory.
However hinting on a page that came out of deflate might make sense when
you consider that the balloon operates on 4K pages and the hints are on 2M
pages. You are likely going to lose track of it all anyway as you have to
work to merge the 4K pages up to the higher order page.

