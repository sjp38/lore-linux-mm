Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60B1AC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 16:38:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E3AC2147A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 16:38:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E3AC2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8A236B0003; Fri, 26 Jul 2019 12:38:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3B788E0005; Fri, 26 Jul 2019 12:38:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 929668E0002; Fri, 26 Jul 2019 12:38:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 591F26B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 12:38:10 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h27so33504164pfq.17
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 09:38:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=Mt0OfoqR00Muu9JYwElLbZSfbHbB+FrDjJVuktnQLrs=;
        b=gtHqITDoKjkYWNpj+3qcXvM5iBzy8UDopy8msRazIxqb9diJ2H7Nn5GVzHmIq/MbVb
         sZ3tjSR30tnEZ2Ryv7AFzw5iiCuLtcefngE4ZHxGKDTKK3UzrpP2FDI0yNZwwnUCga6J
         0iEOqSqovexdRXUSW8OyrufsmGOc4WM2Latr3MDxO/AzGdFVyWg/SqxV6RAhxPUjPzXo
         Q2xVsMS42edzxn7uCyAblocMCFEKIi8YejRGBR21sr3uTzW2dUgYS/KrRzQYfTHaR05A
         T+fEUplVtz1p12c6kMVDb0pa7ajF0+q0IkxFHdwP/32GjXNWjcvY0zPiRV3t+tuf3ywJ
         jSEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV3Mxmxjn7Ad865HK3b7BApOKh1T2J9bYCzvuGuJjs6xpYCtXRh
	Ep1g5xkh8IHANdjcSwmWFGdhe5ax64TWmuLUtujrsI4x3eQZWfFXwwGuOC/bX6joF4qSVNOt4fN
	N1AuIEIMe0kgCaJGQuUWi6hZV+KnM7MlauUMeCfMYAbPQUeVRYRL70Px4XOVv+NvYtA==
X-Received: by 2002:aa7:8651:: with SMTP id a17mr22961152pfo.138.1564159089944;
        Fri, 26 Jul 2019 09:38:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEbJUe4f8eIpSVOiaydA3MK9ZnJPNVKsLJmqkS1WMhdybEuXmcCTDZzcJOsC+QJXXcjoFC
X-Received: by 2002:aa7:8651:: with SMTP id a17mr22961097pfo.138.1564159089142;
        Fri, 26 Jul 2019 09:38:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564159089; cv=none;
        d=google.com; s=arc-20160816;
        b=rAfURR1UOdfUVoSn9J0BN1eguJQ/H1WuaD8I1Z6YR4S+oay0huO+dYcKJtF+cQKXI+
         YtAGJT0WPCQ15jmkq6SiXCEH02mgwjiXuQ49161HN9rUp9sNonjElqZzvOXvBI9/qr0d
         c1MGTAhf7Mh8yN/Md3mBEycNr8am7VVMVqTcIYjFTag7084xMGXxBdcFSKlId0/86bk7
         AQtp+LwkbRAYt/IToLbeclxnOfJ/YI7YXxgJ/SWMKb8AlZz16Jv0YdNar+CSgY2jPFuD
         n32Ii/lKLeqd4Qn9Cwmnti27PDer1sNSNiMCDYKdICjZBDfCijW+DH7z3+7k/maVJY44
         LdHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=Mt0OfoqR00Muu9JYwElLbZSfbHbB+FrDjJVuktnQLrs=;
        b=xagqltf/lL2tay1F7g2O2qaSqvePKZx4yujqQvueVjkUWiAlMl3cla/IKb1mCyhkuC
         wn5FW632nzg+3vbV9WloyMzgkZriQdJWtcCmdbV6ivfwsSqBrSCSp6DLJ4GfGbC0A8KF
         2Ia/QmjMegz8pZye0uQRDcl4Cs58wxZ2WXPkTVMesXPouob1leiPI7qMwNUfD4CpnCFQ
         O0gz0sSMV8ouAhxLjm5Ta1Qd6I6uXzzzHtgwXUEnGQF9YC7YfhcRPspS6vru2EJohq02
         llVwmIp7tUvsOWoldlWf1ubp213a4VySdadg3PbzoF2fxJUYqD6U1kZWDJng9TZSUdJb
         zP9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id f1si20991833plf.410.2019.07.26.09.38.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 09:38:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Jul 2019 09:38:08 -0700
X-IronPort-AV: E=Sophos;i="5.64,311,1559545200"; 
   d="scan'208";a="175655606"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga006-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Jul 2019 09:38:08 -0700
Message-ID: <c59c6c9a5bb77d517336e3fc3b17eebd0f294276.camel@linux.intel.com>
Subject: Re: [PATCH v2 4/5] mm: Introduce Hinted pages
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>, kvm@vger.kernel.org, david@redhat.com, 
	mst@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com, 
	konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com, 
	aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com
Date: Fri, 26 Jul 2019 09:38:08 -0700
In-Reply-To: <49a49a38-b1f4-d5c0-f5f1-a6bed57a03d2@redhat.com>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
	 <20190724170259.6685.18028.stgit@localhost.localdomain>
	 <49a49a38-b1f4-d5c0-f5f1-a6bed57a03d2@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-07-26 at 08:24 -0400, Nitesh Narayan Lal wrote:
> On 7/24/19 1:03 PM, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > 

<snip>

> > +/*
> > + * The page hinting cycle consists of 4 stages, fill, react, drain, and idle.
> > + * We will cycle through the first 3 stages until we fail to obtain any
> > + * pages, in that case we will switch to idle.
> > + */
> > +static void page_hinting_cycle(struct zone *zone,
> > +			       struct page_hinting_dev_info *phdev)
> > +{
> > +	/*
> > +	 * Guarantee boundaries and stats are populated before we
> > +	 * start placing hinted pages in the zone.
> > +	 */
> > +	if (page_hinting_populate_metadata(zone))
> > +		return;
> > +
> > +	spin_lock(&zone->lock);
> > +
> > +	/* set bit indicating boundaries are present */
> > +	set_bit(ZONE_PAGE_HINTING_ACTIVE, &zone->flags);
> > +
> > +	do {
> > +		/* Pull pages out of allocator into a scaterlist */
> > +		unsigned int num_hints = page_hinting_fill(zone, phdev);
> > +
> > +		/* no pages were acquired, give up */
> > +		if (!num_hints)
> > +			break;
> > +
> > +		spin_unlock(&zone->lock);
> 
> Is there any recommendation in general about how/where we should lock and unlock
> zones in the code? For instance, over here you have a zone lock outside the loop
> and you are unlocking it inside the loop and then re-acquiring it.
> My guess is we should be fine as long as:
> 1. We are not holding the lock for a very long time.
> 2. We are making sure that if we have a zone lock we are releasing it before
> returning from the function.

So as a general rule the first two you mention work. Basically what you
want to do is work with some sort of bounded limit when you are holding
the lock so you know it will be released in a timely fashion.

The reason for dropping the lock inside of the loop s because we will end
up sleeping while we wait for the virtio-balloon device to process the
pages. So it makes sense to release the lock, process the pages, and then
reacquire the lock so that we can return the pages and grab another 16
pages.

