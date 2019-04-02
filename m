Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABC90C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 15:25:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70DE520830
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 15:25:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70DE520830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1FCBC6B000C; Tue,  2 Apr 2019 11:25:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1AC056B0010; Tue,  2 Apr 2019 11:25:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 083A86B0266; Tue,  2 Apr 2019 11:25:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id D79A96B000C
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 11:25:16 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id t22so13736345qtc.13
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 08:25:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=Mx9J4jw2GPScgHPcaXdWstBCWvWOeEoG4tjKtIlkD4g=;
        b=Zu9I7kAKl3DhxNojiY9VqmoXsY0YV51gALofwj+n47cPVB96rhFzUHXWMzZfUjU+qW
         hPR6ZTqZkAa5BzJLwwkiuPdpW55InwCIcJHPgBzzeFDgWCoXHHYbZuO6S3+W6dx5SdGE
         3BtzUpx+yn25dJcErg6FMYD4aYXYTkC+vEPUklT3hoh0Xa8Ib0kSVWdJdwJbzTZdjcTT
         R/AAHYrYCvuUcDuTFScYTwhll6VBQTm3Rq4ZH6+jCJcp8bMxbgXb0vKdxRR/TrFMLjqE
         kaoM/MAKrphKepLoB/9F0NnmYHSRmGNfA0aWAYhsg2RvJ5vGjxqa3vrWKSNzN6qGmOhk
         su8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW60K08AUOadsuqmfWckSRiPJGrO6W0HZgFPxgaCS9+o0YFbldi
	IkEdu3PVhx9OpTjhZRJLH4g+332PpdyikfiLzOy2vkuMypN3v2Xjvj2Izbj0JmB+O9P+uPHzuxx
	7l3NJJTIY5Juy7uDtpCVbCIQD7dovlY5oTcQGaYKoR5ZSMAIc1RSCm/+b5nGaDMwWmw==
X-Received: by 2002:aed:3aa6:: with SMTP id o35mr45368754qte.162.1554218716176;
        Tue, 02 Apr 2019 08:25:16 -0700 (PDT)
X-Received: by 2002:aed:3aa6:: with SMTP id o35mr45368704qte.162.1554218715667;
        Tue, 02 Apr 2019 08:25:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554218715; cv=none;
        d=google.com; s=arc-20160816;
        b=TMSbnz01MkW+0urDEQBLvYK6Dv4Ukf5eF11hvpIrdOVrPFI4yrM+rCKDGS8HqMHRlo
         lfWnaj+XbpEjnsIXWZY1n2Ht96yWFB4o2qtQEhV39IUHSTUcN3pSssBo5YogVll6DMBf
         484sdx7w/DNXWEdlPGEDwVqdYSDUNYIdYAAHpVQVD0dcSssB0u2acMLUcqw5QdkHprtR
         1UlQPCyIlK/I2L5fEqrlD6xBFXfHecpJZGq5N39KcrdpMNWKTiSEwWHXTAfKg876AcSN
         HNh3YkZkD144oD35L+QfPb+xmexxnSqaLuwdxmFiJWMHASz84vKX3R9ZMWMm28kvMXA0
         w8PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=Mx9J4jw2GPScgHPcaXdWstBCWvWOeEoG4tjKtIlkD4g=;
        b=clw1LbACoGVutCsnRhCqFOc2+J7lFdyEYUuty/GycEkf/u+cqAw5IXOSaxYfCqFPzo
         fOCkuym66fcCB3NXlQEjbS3Uk0kXtaxlzxHzWt88KrrIa8Condt555NHiWnvnSDifiz0
         bU+ogeLMm3rL4UC9XjpeR1qP1Yiku1FsEQ+OP22esGxdj3xbKlC0zDbOc+iXT75I1/+q
         E8o5jNc8e9HIPrZHnOoG/VY1z28pv/yQIH5UuTr7XWbyOYsUxyBcS0/65Gy9CKxX1ej1
         BKjdArqYYKxCJnW5MfixSxXrrpGoqK1iA5WdROad/zQOZOwXrukzcLpkMNbzwCoNikRp
         qLbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f9sor14082103qvr.51.2019.04.02.08.25.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 08:25:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwU2x/6XRs2Azjaky+XbQ7todIFJAnFK2yBCuWt+46dnJIjuwQoRZKqLUKdiA2YPkTMxWJ6bg==
X-Received: by 2002:a0c:d07b:: with SMTP id d56mr58838282qvh.89.1554218715324;
        Tue, 02 Apr 2019 08:25:15 -0700 (PDT)
Received: from redhat.com ([66.187.232.66])
        by smtp.gmail.com with ESMTPSA id a8sm7988404qtc.19.2019.04.02.08.25.12
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Apr 2019 08:25:13 -0700 (PDT)
Date: Tue, 2 Apr 2019 11:25:10 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: David Hildenbrand <david@redhat.com>,
	Nitesh Narayan Lal <nitesh@redhat.com>,
	kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
	lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
	Yang Zhang <yang.zhang.wz@gmail.com>,
	Rik van Riel <riel@surriel.com>, dodgen@google.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: On guest free page hinting and OOM
Message-ID: <20190402112115-mutt-send-email-mst@kernel.org>
References: <f0ee075d-3e99-efd5-8c82-98d53b9f204f@redhat.com>
 <20190329125034-mutt-send-email-mst@kernel.org>
 <fb23fd70-4f1b-26a8-5ecc-4c14014ef29d@redhat.com>
 <20190401073007-mutt-send-email-mst@kernel.org>
 <29e11829-c9ac-a21b-b2f1-ed833e4ca449@redhat.com>
 <dc14a711-a306-d00b-c4ce-c308598ee386@redhat.com>
 <20190401104608-mutt-send-email-mst@kernel.org>
 <CAKgT0UcJuD-t+MqeS9geiGE1zsUiYUgZzeRrOJOJbOzn2C-KOw@mail.gmail.com>
 <6a612adf-e9c3-6aff-3285-2e2d02c8b80d@redhat.com>
 <CAKgT0Ue_By3Z0=5ZEvscmYAF2P40Bdyo-AXhH8sZv5VxUGGLvA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0Ue_By3Z0=5ZEvscmYAF2P40Bdyo-AXhH8sZv5VxUGGLvA@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 02, 2019 at 08:04:00AM -0700, Alexander Duyck wrote:
> Basically what we would be doing is providing a means for
> incrementally transitioning the buddy memory into the idle/offline
> state to reduce guest memory overhead. It would require one function
> that would walk the free page lists and pluck out pages that don't
> have the "Offline" page type set,

I think we will need an interface that gets
an offline page and returns the next online free page.

If we restart the list walk each time we can't guarantee progress.

> a one-line change to the logic for
> allocating a page as we would need to clear that extra bit of state,
> and optionally some bits for how to handle the merge of two "Offline"
> pages in the buddy allocator (required for lower order support). It
> solves most of the guest side issues with the free page hinting in
> that trying to do it via the arch_free_page path is problematic at
> best since it was designed for a synchronous setup, not an
> asynchronous one.


-- 
MST

