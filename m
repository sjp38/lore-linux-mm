Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E1A3C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:56:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44B86218AD
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:56:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44B86218AD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D04C18E014D; Mon, 11 Feb 2019 14:56:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB3348E0125; Mon, 11 Feb 2019 14:56:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA1D58E014D; Mon, 11 Feb 2019 14:56:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA478E0125
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:56:44 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id k1so184313qta.2
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:56:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=dxIH/eelx8NvcTuXb7rX+FMWAP5tUyEeW4raaT3XX7s=;
        b=mGeIfjhgB9aPPbbnG3LnMh76lf3HPSjqZPt+VJitIJOCjRAIaP9tg+5LthiZJmXk4B
         4RHL6+ocWw0cwYXF2bt8ccrcsQGh3nQ7X2wav+9el3vwqeou5J2ZIbwsjxO2D7a5npNg
         LZDsGve76xuebThFlS2bm9ZnwJ/Hv4S0VM6trYepOXlKS5vhLpricnI8BCDcVd0jEJND
         64nENoEuFKleKEa+28i38Ka6ZZFHE+NiwQh49qKq6w1dqfm67roxAo61l2fcZfjc+pmw
         1CjDN4EpPDDgVTBlw66P+6a7YPtKb4GWBNTMHv1O/5q3lEkg5OCEnBerwKo+ixfGtrjb
         cNQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAua8WzQugr6x16tlu9L7KJ2ivlGUopwbuHIdFtQJBCcEemq/AAo6
	rEFm6QANfXj/pRxdY2Z4JFf+h/nkdbpq50wOOzW3HMl+R4aN7PeGfnOxfqyuq1Q574qfSc8/W3T
	URHxBh6L0A0evd3FWcGuf4KJyfP5zdVy+39Y0cYYJCVNAJEWSVf/L36RJCO6z8+VaEQ==
X-Received: by 2002:ac8:3fd4:: with SMTP id v20mr8823917qtk.188.1549915004282;
        Mon, 11 Feb 2019 11:56:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZQBFEYUdNjhOM7n4yrm8F4QTGaj0mLDtXqu82EpsuberxEzUb1jQ7eg+3wrj/xUa9b3VR2
X-Received: by 2002:ac8:3fd4:: with SMTP id v20mr8823874qtk.188.1549915003467;
        Mon, 11 Feb 2019 11:56:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549915003; cv=none;
        d=google.com; s=arc-20160816;
        b=vdkNsrZs6RcgzAwhaEFTP75w5+lNMm+Khxdqew4MBngHBm0NCs4pb5JRaEI1jmXjFM
         hVSrdkYB1gFr+/VKVv3e+ndWf8NSpxGfV/mm+P5cD2We75512PXuAfJL73g0b1fIFymj
         x0B9eaNkbFNq+Y4c/ehXH8YQMM2SEDUj85EQ1o7W4i4f32AlxwIGhmoRn8AeQfsREb5K
         XaBZXRgiNliJEPMnTOk2GEncw6KqyFlM/kbDFERC0yeiwRJ3YAHAp2op/pvAz63fyy5X
         IDSFhp6pyijXMygvZeSzFfGH7MWCvs/MHZrg5l3qrCMmty0RoKBSxm0TsrXFfWHKadet
         yz3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=dxIH/eelx8NvcTuXb7rX+FMWAP5tUyEeW4raaT3XX7s=;
        b=uJT/nr+85LaK6Mg7mzl5eXMaD9qF29GBmR8P4Jqxx0uEOAK1kIv2HklWVhtZJ9xsQr
         gcW8VDqZuQnmogJXuT14Cc9kJfSMT1Z6fAkV0HGpSEXIFoOEDo7MUPA3frgBhM7l4jyG
         qm2mMFkiFxdeu14Kl9f2Szj+DTRVsJFSisS/ktxYaQTQyOlRBzeK7IEFcPXc6+WVpWaL
         665bTQF4BB0TUO6+3XWRVHDPabkyjrovgLTZrY/iTq0CvQCSkuhBbVk4QoJtMEHUwNE7
         T6ePoNfDRMH1uOyRI3BHWrPaVEslwOjz6ivS5S9dUa5KgMCQxj5aOcfFAuKOiMColgoZ
         zKUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l23si7018970qkg.227.2019.02.11.11.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 11:56:43 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BBDB980F81;
	Mon, 11 Feb 2019 19:56:41 +0000 (UTC)
Received: from redhat.com (ovpn-120-40.rdu2.redhat.com [10.10.120.40])
	by smtp.corp.redhat.com (Postfix) with SMTP id 04D2C6091C;
	Mon, 11 Feb 2019 19:56:39 +0000 (UTC)
Date: Mon, 11 Feb 2019 14:56:39 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com,
	x86@kernel.org, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
	pbonzini@redhat.com, tglx@linutronix.de, akpm@linux-foundation.org
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory hints
Message-ID: <20190211145531-mutt-send-email-mst@kernel.org>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181552.12095.46287.stgit@localhost.localdomain>
 <20190209194437-mutt-send-email-mst@kernel.org>
 <0d12ccec-d05f-80b8-9498-710d521c81d2@intel.com>
 <20190211124925-mutt-send-email-mst@kernel.org>
 <d0610465-1655-1fd0-4847-7a6ba233df85@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d0610465-1655-1fd0-4847-7a6ba233df85@intel.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Mon, 11 Feb 2019 19:56:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 10:19:17AM -0800, Dave Hansen wrote:
> On 2/11/19 9:58 AM, Michael S. Tsirkin wrote:
> >>> Really it seems we want a virtio ring so we can pass a batch of these.
> >>> E.g. 256 entries, 2M each - that's more like it.
> >> That only makes sense for a system that's doing high-frequency,
> >> discontiguous frees of 2M pages.  Right now, a 2M free/realloc cycle
> >> (THP or hugetlb) is *not* super-high frequency just because of the
> >> latency for zeroing the page.
> > Heh but with a ton of free memory, and a thread zeroing some of
> > it out in the background, will this still be the case?
> > It could be that we'll be able to find clean pages
> > at all times.
> 
> In a systems where we have some asynchrounous zeroing of memory where
> freed, non-zeroed memory is sequestered out of the allocator, yeah, that
> could make sense.
> 
> But, that's not what we have today.

Right. I wonder whether it's smart to build this assumption
into a host/guest interface though.

> >> A virtio ring seems like an overblown solution to a non-existent problem.
> > It would be nice to see some traces to help us decide one way or the other.
> 
> Yeah, agreed.  Sounds like we need some more testing to see if these
> approaches hit bottlenecks anywhere.

