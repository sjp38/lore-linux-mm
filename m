Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71873C76192
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 15:04:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 436B320693
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 15:04:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 436B320693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDE998E0007; Tue, 16 Jul 2019 11:04:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C90DD8E0006; Tue, 16 Jul 2019 11:04:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7DD18E0007; Tue, 16 Jul 2019 11:04:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 93F1F8E0006
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 11:04:53 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id x17so17138200qkf.14
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 08:04:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=/wDYTkkza3J7bnZk9wcn1Fsd5fKIxIlkHQ7jUUx0bO8=;
        b=bewdJrSDVfk3k3ctRwKFtN0ooxfludVQ4BlxK2wbboHr0wKIvXdRuxT0Zo+b88Td6p
         HuP7anIKPTOSvfNRa1ZCFgvti1EW1lXzpZpXh9nGNckUOTc6jVjcg8UwvMbwCIU+OMYE
         Hk1oajcAKaFLVw6Wgjn33HPDtKDYBQf3zPA3AobEZCMLfFJmGX8wIkYjVQA45tceLv/0
         KTxvfJwAimqBeNi0gvYvV+Ghz21seUt+FbzDICONNiOlp6AwAfOd0p+CS9fO5dLOPAjT
         RtTegxLsKw1XPXHfAnLmXv7hFR6drk2SYKEL2b/S2c1WV5wNzZddwa/K6wJc8KfRIOtD
         UTHw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUKfoV8VmjlSkMZ9vvJRSI7BqTznofwpjD5Pi6dHSns74zF5r93
	IWCLFa1b3Z6DRwdDI9tdaHmLuDGjvgQQv/Txiwq4aB56n/HZtMC+L9ZQh0jPKjJtM7wmTDkYO0X
	8uYuYbdK6IKFkcRqX7gUPhArRIYOhL+S2n+emumyVbbLRVByCKibm5xeb9jTWUDgY+g==
X-Received: by 2002:a05:620a:1456:: with SMTP id i22mr21523190qkl.170.1563289493386;
        Tue, 16 Jul 2019 08:04:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1r05yB5xZSolLEbDyVC4QcLKB9QQ2x7g41JTCnpFoMpPv1AGbyEiT3T3pIUptYYBPR3dr
X-Received: by 2002:a05:620a:1456:: with SMTP id i22mr21523069qkl.170.1563289492092;
        Tue, 16 Jul 2019 08:04:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563289492; cv=none;
        d=google.com; s=arc-20160816;
        b=WDBvg3XsUSZv2MYwfvjtggLYP1VBJKA9yA3HsKte17oQn2vhg1qZdIR2SCs/Mgoi8/
         WSY6d8SELfKKsJsiIaSw9HaXoN0AqM60ar2aJJVPfYqXNqkZ9zcjpLJk5EiU9xj0eCNj
         Ew+kZU+6OZKfbVZ3TA+2oKFgzZXt9E35X4pmPNoeKHA9sl3IxpRPuHiynBJQEXqOy1Tf
         52CVElKUxtK2vHC1uFVUBOTef+kV0/vspwGNfOmb4isc5k8tTg5mKDh6nbWaksl7wS1a
         x7s5g09l70W5tes1IZHv1NrT2POYTguqK2RTjk8L1zBe0z7F3upkjIVPFXWn5qz/CmSO
         nQsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=/wDYTkkza3J7bnZk9wcn1Fsd5fKIxIlkHQ7jUUx0bO8=;
        b=V5tT4uAo1eO6xQGp31Wat1QIQywFj++fu/q3ie1kkDQBzxHzj1w9qwOl6I9rR9sNs8
         L9hr+o2c3BUW/sGN2ROeXugh1nzjv46S9tIY7vs6kW26G0y3ASvU2fsAUnwEy/ApMn7R
         bP63m2n3K+DLhVCgBSMWcr0dRfNScIleM3u61Nwb2N83VOPTAywT6RjxLqXPu4AlJo6c
         95sPKLD/P38mAKJSVSvSSDEAd7Wy2BErRMr82UD564y/pj6G2Kh88uC3U9QEWFx88C0H
         YoitdarmT2bUnUZ1dtng7TV/9K/mlIW7e3HhV2JvhYvX/tOHuDeQmWBem0MDC+oLIYBD
         /6pQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i9si14411684qvl.126.2019.07.16.08.04.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 08:04:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4AC22C1EB1E4;
	Tue, 16 Jul 2019 15:04:51 +0000 (UTC)
Received: from redhat.com (ovpn-122-108.rdu2.redhat.com [10.10.122.108])
	by smtp.corp.redhat.com (Postfix) with SMTP id 82A916013C;
	Tue, 16 Jul 2019 15:04:30 +0000 (UTC)
Date: Tue, 16 Jul 2019 11:04:27 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>, nitesh@redhat.com,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, akpm@linux-foundation.org,
	yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
	konrad.wilk@oracle.com, lcapitulino@redhat.com,
	wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
	dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Subject: Re: [PATCH v1 6/6] virtio-balloon: Add support for aerating memory
 via hinting
Message-ID: <20190716110357-mutt-send-email-mst@kernel.org>
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
 <20190619223338.1231.52537.stgit@localhost.localdomain>
 <20190716055017-mutt-send-email-mst@kernel.org>
 <cad839c0-bbe6-b065-ac32-f32c117cf07e@intel.com>
 <3f8b2a76-b2ce-fb73-13d4-22a33fc1eb17@redhat.com>
 <e565859c-d41a-e3b8-fd50-4537b50b95fb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e565859c-d41a-e3b8-fd50-4537b50b95fb@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 16 Jul 2019 15:04:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 04:17:13PM +0200, David Hildenbrand wrote:
> On 16.07.19 16:12, David Hildenbrand wrote:
> > On 16.07.19 16:00, Dave Hansen wrote:
> >> On 7/16/19 2:55 AM, Michael S. Tsirkin wrote:
> >>> The approach here is very close to what on-demand hinting that is
> >>> already upstream does.
> >>
> >> Are you referring to the s390 (and powerpc) stuff that is hidden behind
> >> arch_free_page()?
> >>
> > 
> > I assume Michael meant "free page reporting".
> > 
> 
> (https://lwn.net/Articles/759413/)


Yes - VIRTIO_BALLOON_F_FREE_PAGE_HINT.

> -- 
> 
> Thanks,
> 
> David / dhildenb

