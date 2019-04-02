Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 119F4C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 17:53:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5D232084B
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 17:53:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5D232084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 734B76B0274; Tue,  2 Apr 2019 13:53:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E5A26B0275; Tue,  2 Apr 2019 13:53:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5ADA76B0276; Tue,  2 Apr 2019 13:53:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 392906B0274
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 13:53:17 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id b1so14104382qtk.11
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 10:53:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=OLJXHlhYI15g5py0OlU6OBcth4eT+AVlpGiVwqABwyM=;
        b=jui3XAHgoRrkWS7iZ7wXT5UFDgSAaMYqZmEJHMH4mmIZ6e1DdmkxwfmvP4+1wIyVGW
         sMnXoLOmPmfqQ0dlq82Xaxg3cSAsHYPxTHO6V30BZzfZFg+evLCZoVyjfZbEp9qJUmjg
         RjnqbMG0KCWMWHosIgaYLGQd6hU2NmOaee7BNm643ATx0Aotn1Vku98JCqEr5k0I9pAU
         HKagl0aylOV3Lle8gGwxUvhNwnmb9dLJv/36cy9gLaQHKVXlRMt7BSHtuxs8py/oCNJP
         +FGwVkOpFrrqItykvghfZMkHQ/R/EHM8cn/j5XPev0it5p0uDVT4IhKDQduoRwTTkK6G
         t9Kg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWKg/n85bmA6iFfnSbBU8z03SqF4sbBWB2vEmc9ElHdQK3EIbkK
	cdBhscCCaAjoWhyMCLLwDCOxCjXHEopumUHb5BtsXyLr4VBeaxlodwO5Q/bNgDy04lfH/e3Pslz
	I8dmTpEd4Y9C6PJBNdL7iqUWVjbJAJe0UNaOOX8azL6Pn5G5iQROD1vjvWY251IJnsw==
X-Received: by 2002:ac8:2ca3:: with SMTP id 32mr2750338qtw.60.1554227597014;
        Tue, 02 Apr 2019 10:53:17 -0700 (PDT)
X-Received: by 2002:ac8:2ca3:: with SMTP id 32mr2750295qtw.60.1554227596514;
        Tue, 02 Apr 2019 10:53:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554227596; cv=none;
        d=google.com; s=arc-20160816;
        b=f1KNKSmAJgNUEtJvClCl9W8sM3Brgml2SSBWVCnRtmYWiVV1emRoUV4SXmAmG3RMhB
         Kotu8F3RfZCIYRJq+6mvyYq+zgNOafPKqjeTDeacxZ5lLfw9unde6SjN8jsLNE/gmoMq
         CO/yFise3GPiz0rl3haKXKPwLLW8KjXiyCPQFxv0fUkdMYucQSAbJWUGttfAtNjWvCBO
         M3/JXA60cfhIK40XS17HT0BKt2/d46N+LWQi6zg3uBeOg3kiwIBn2jR+/olwmB0K7QKI
         YmsLIc7TnCvFSeAu29OPP9EeZZLM+UYBvVvOQehnKYEZCwiBQ2Ml4Og8wGovmaKE5uYI
         HCdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=OLJXHlhYI15g5py0OlU6OBcth4eT+AVlpGiVwqABwyM=;
        b=fFNJYtPfwkmNJV0GC29zELs7nR4zDBEDOIpxBYXVKHLXFy4jK19I6brROpkVQazdvP
         8edL9Rzbsr8CDlefVveGMcFmqu4B1531Xx9AQkZ9xkC7gFn8uBHRZqxlukb8ugHHV17C
         a9ld0/4e5bw0CsfDbUiRdgjY01LmxbhAuF3qBM1yIyg8U1526gRcT+TDBPhgKQEGOySF
         gHitm5GiYqobI0tEmyP0zzIY7uU5IgY6nh5OsgQ0JcGUA1NP4vINfUvH16g2baadMGNq
         9Xn4oj1454UL64roy5dHEGYR3bOt/KvT0G6zJLWUfi/ILoG4sfMZRkfK1a+GfzAzSnj4
         KWDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k39sor10436889qvf.59.2019.04.02.10.53.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 10:53:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwBiZji2CbrWAPhiXLkuH2SxquqiO4kBtgNqdomsId+YeuaIw+i15Rp6ZVpaVK2OIU9Uu9l2g==
X-Received: by 2002:a0c:b2d6:: with SMTP id d22mr58846546qvf.39.1554227596333;
        Tue, 02 Apr 2019 10:53:16 -0700 (PDT)
Received: from redhat.com ([66.187.232.66])
        by smtp.gmail.com with ESMTPSA id y197sm7267625qkb.23.2019.04.02.10.53.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Apr 2019 10:53:15 -0700 (PDT)
Date: Tue, 2 Apr 2019 13:53:12 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: David Hildenbrand <david@redhat.com>,
	Nitesh Narayan Lal <nitesh@redhat.com>,
	kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
	lcapitulino@redhat.com, pagupta@redhat.com,
	Yang Zhang <yang.zhang.wz@gmail.com>,
	Rik van Riel <riel@surriel.com>, dodgen@google.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Dave Hansen <dave.hansen@intel.com>
Subject: Re: On guest free page hinting and OOM
Message-ID: <20190402134722-mutt-send-email-mst@kernel.org>
References: <dc14a711-a306-d00b-c4ce-c308598ee386@redhat.com>
 <20190401104608-mutt-send-email-mst@kernel.org>
 <CAKgT0UcJuD-t+MqeS9geiGE1zsUiYUgZzeRrOJOJbOzn2C-KOw@mail.gmail.com>
 <6a612adf-e9c3-6aff-3285-2e2d02c8b80d@redhat.com>
 <CAKgT0Ue_By3Z0=5ZEvscmYAF2P40Bdyo-AXhH8sZv5VxUGGLvA@mail.gmail.com>
 <20190402112115-mutt-send-email-mst@kernel.org>
 <3dd76ce6-c138-b019-3a43-0bb0b793690a@redhat.com>
 <CAKgT0Uc78NYnva4T+G5uas_iSnE_YHGz+S5rkBckCvhNPV96gw@mail.gmail.com>
 <6b0a3610-0e7b-08dc-8b5f-707062f87bea@redhat.com>
 <CAKgT0UdHA66z1j=3H06AfgtiF4ThFdXwQ6i8p1MszdL2bRHeZQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0UdHA66z1j=3H06AfgtiF4ThFdXwQ6i8p1MszdL2bRHeZQ@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 02, 2019 at 10:45:43AM -0700, Alexander Duyck wrote:
> We went through this back in the day with
> networking. Adding more buffers is not the solution. The solution is
> to have a way to gracefully recover and keep our hinting latency and
> buffer bloat to a minimum.

That's an interesting approach, I think that things that end up working
well are NAPI (asychronous notifications), limited batching, XDP (big
aligned buffers) and BQL (accounting). Is that your perspective too?

-- 
MST

