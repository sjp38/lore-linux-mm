Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56E35C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 15:34:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1B9A23BE3
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 15:34:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1B9A23BE3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BBE06B0007; Mon,  3 Jun 2019 11:34:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76CC06B0008; Mon,  3 Jun 2019 11:34:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65B706B000A; Mon,  3 Jun 2019 11:34:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 300DE6B0007
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 11:34:02 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x5so13883906pfi.5
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 08:34:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=mvEsgoA6xIus5b1M9d0xWLWiBIN3y35s+GZ9aYhY56E=;
        b=FVUB8Ju/YJNPEqkJ/x/MClhUWtC4d6+j2XD6z42t46+036FIHjMYzRiduBcFCVnohK
         BIXoqyDWT3XCcq7zhuabNLCzZE47JFe6vOBc3DAOqqD8FtzOcO5vCCqBuBy6ufOG1thk
         QW7/hzm3P91iMeRfQmVj0FxtG4Q3eaAM+kTm/4qe/Npdfx0VTxjMLf4/QH9+e7QEWUUw
         RgO+xFiyyaVUSDbNGuYQf2POjZRzKvtj2OAiB/5KQtFiIveeiw8T0Mj2tRDSVBT9pVv3
         bAxfBG+EK6fQhhw/V2wxZPMZNfXtrNO5Ce51XmtVkJ7tB8hOuCH7sxqm7ShqxJzo1yJO
         OiHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW6CgpK/Mn4oS/jyjnPGLmxrs9HIL9ZjQs9Oee5aND3mzbZVmCZ
	WP0VrLbG19tg/HOhbeUZzpAjSxAaqiHEQVaA0hzUqMZPDJt5lcisilUnOU0jlVoJln6eAshGVrv
	CsTDnFyQxBfRE/1R0y0Rdgatvm7m/q72kAu3ghAOuaNoHEBrVGr6Ope1EmL/rQ1SjBg==
X-Received: by 2002:a17:90a:e17:: with SMTP id v23mr30136956pje.139.1559576041805;
        Mon, 03 Jun 2019 08:34:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0DevVoJhRzaMGdrZiAyNiwkGX071QGo5rZyWwfivmLVlEget/gOwTDkM8u/EaJ7pLNb9A
X-Received: by 2002:a17:90a:e17:: with SMTP id v23mr30136841pje.139.1559576040826;
        Mon, 03 Jun 2019 08:34:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559576040; cv=none;
        d=google.com; s=arc-20160816;
        b=p9gmJAv6cAKuF65ydPp1r8wKxVF8hVAPVX91t0EmZr655OsJIi3P9ZnsKwG7Nsq7FT
         Xm0z1rPqsV1B23ZEHoXtjZOX095LJ19O7hYsqGk9UCqafefDzBrzwWJnqs2mW6h5LWND
         kF/LfwNS3DbD9gG90WQNIhg40hqWAZ1ZieT6fBWYerDwBWYTu+se34sVTiO3d1tbTtYf
         2eymLIgScY0oeW3s7EjbOqpiGXKBxGfEf8wLDxEp2G9xmdc6MmKDQzF+gMqa43ywTQkG
         Ff+lxvYhezHB7jYaVzLZUBTE/4cC33sGbJQ7Dp5LSYNG5HJ46PexS97c5lFdQwXC5A9l
         Ou6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=mvEsgoA6xIus5b1M9d0xWLWiBIN3y35s+GZ9aYhY56E=;
        b=t30q3S1A0DXNsRWd8WysfnFx+9LqN6Wp5NZIZiEH3yVPZs3lHdjwdF59BhWr/zWN+0
         rhg15GC78Z+ZNWmiPcgPcBMBuoIxJtZm/07JYzQwnIrmcgVitV3r4wtI7grP7oBWYCT4
         03zLHCMVoCA5JEG/bfSoOWtc+NAsRnoYyvZ37f2wAcnEfb3zY8k5qTXU1PVuhXMp4tyn
         orm3jGAUPBh41KxUV/4ChtoTXpa6hOHujgiptS9wLNv3JhJLjCMzYh9T3tn53U9GaIcl
         fZldPllEcacMC4WZ7OwJDnjLA3kEkWKmrbK7KHbrKujEJuNKwRh4h2iudpxSFEBsmTfn
         JqIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id t28si18683366pfe.145.2019.06.03.08.34.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 08:34:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 03 Jun 2019 08:34:00 -0700
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga001-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 03 Jun 2019 08:33:59 -0700
Message-ID: <f510f69ec5744e80fc612ae06a35b49d56cf2c80.camel@linux.intel.com>
Subject: Re: [RFC PATCH 00/11] mm / virtio: Provide support for paravirtual
 waste page treatment
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: David Hildenbrand <david@redhat.com>, Alexander Duyck
	 <alexander.duyck@gmail.com>, nitesh@redhat.com, kvm@vger.kernel.org, 
	mst@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com, 
	konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com, 
	aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com
Date: Mon, 03 Jun 2019 08:33:59 -0700
In-Reply-To: <09c42bc7-ddc7-6b34-44d8-ffb5e63c7c6f@redhat.com>
References: <20190530215223.13974.22445.stgit@localhost.localdomain>
	 <09c42bc7-ddc7-6b34-44d8-ffb5e63c7c6f@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-06-03 at 11:31 +0200, David Hildenbrand wrote:
> On 30.05.19 23:53, Alexander Duyck wrote:
> > This series provides an asynchronous means of hinting to a hypervisor
> > that a guest page is no longer in use and can have the data associated
> > with it dropped. To do this I have implemented functionality that allows
> > for what I am referring to as "waste page treatment".
> > 
> > I have based many of the terms and functionality off of waste water
> > treatment, the idea for the similarity occured to me after I had reached
> > the point of referring to the hints as "bubbles", as the hints used the
> > same approach as the balloon functionality but would disappear if they
> > were touched, as a result I started to think of the virtio device as an
> > aerator. The general idea with all of this is that the guest should be
> > treating the unused pages so that when they end up heading "downstream"
> > to either another guest, or back at the host they will not need to be
> > written to swap.
> > 
> > So for a bit of background for the treatment process, it is based on a
> > sequencing batch reactor (SBR)[1]. The treatment process itself has five
> > stages. The first stage is the fill, with this we take the raw pages and
> > add them to the reactor. The second stage is react, in this stage we hand
> > the pages off to the Virtio Balloon driver to have hints attached to them
> > and for those hints to be sent to the hypervisor. The third stage is
> > settle, in this stage we are waiting for the hypervisor to process the
> > pages, and we should receive an interrupt when it is completed. The fourth
> > stage is to decant, or drain the reactor of pages. Finally we have the
> > idle stage which we will go into if the reference count for the reactor
> > gets down to 0 after a drain, or if a fill operation fails to obtain any
> > pages and the reference count has hit 0. Otherwise we return to the first
> > state and start the cycle over again.
> 
> While I like this analogy, I don't like the terminology mixed into
> linux-mm core.
> 
> mm/aeration.c? Bubble? Treated? whut?
> 
> Can you come up with a terminology once can understand without a PHD in
> biology? (if that is even the right field of study, I have no idea)

I had started with the bubble, as I had mentioned before. From there I got
to aerator because of the fact that we were filling the memory with holes.
I figure the first two work pretty well, but I am not really attached to
any of the other terms. As far as the rest of the terminology most of it
is actually chemistry if I am not mistaken. I could probably just swap out
"Treated" with "Aerated" and it would work just as well. I would also need
to get away from the more complex terms such as "decant", but for the most
part that is just a matter of finding the synonyms such as "drain".

> ALSO: isn't the analogy partially wrong? Nobody would be using "waste
> water" just because they are low on "clean water". At least not in my
> city (I hope so ;) ). But maybe I am not getting the whole concept
> because we are dealing with pages we want to hint to the hypervisor and
> not with actual "waste".

Actually the analogy isn't for a low condition. The analogy would be for a
condition where we have an excess of waste water and don't want to contain
it. As such we want to treat it and return it to the water cycle.

As far as the "waste" in the analogy I was thinking more of the page data.
When a page has been used we normally mark it as "Dirty", so I thought it
would be an apt analogy since those dirty pages would have to be written
to long term storage if we didn't do something to invalidate the page
data.

> > This patch set is still far more intrusive then I would really like for
> > what it has to do. Currently I am splitting the nr_free_pages into two
> > values and having to add a pointer and an index to track where we area in
> > the treatment process for a given free_area. I'm also not sure I have
> > covered all possible corner cases where pages can get into the free_area
> > or move from one migratetype to another.
> 
> Yes, it is quite intrusive. Maybe we can minimize the impact/error
> proneness.

My hope by submitting this as an RFC was to get input on what directions I
might need to head in before I went to far down this current path.

> > Also I am still leaving a number of things hard-coded such as limiting the
> > lowest order processed to PAGEBLOCK_ORDER, and have left it up to the
> > guest to determine what size of reactor it wants to allocate to process
> > the hints.
> > 
> > Another consideration I am still debating is if I really want to process
> > the aerator_cycle() function in interrupt context or if I should have it
> > running in a thread somewhere else.
> 
> Did you get to test/benchmark the difference?

I haven't yet.

