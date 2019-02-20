Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 559D9C10F07
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 23:59:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DB722089F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 23:59:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DB722089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B201E8E004A; Wed, 20 Feb 2019 18:59:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACE4F8E0002; Wed, 20 Feb 2019 18:59:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E6CA8E004A; Wed, 20 Feb 2019 18:59:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 70B688E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 18:59:38 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id y31so24963005qty.9
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 15:59:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=5Hd1LzJJYxId5zws0/xjQKhFmTCN01qyQFrhgffQPJU=;
        b=q99oUXNeToQR+jTiIlCRSGkfgLdE5FS5sOGIuRa/OZciKK8Nxk7bLkKCU1vLDaGLrA
         Bxar77M7+IlW/hRC6HpH1MLTnxpvar7pzDhpo6AsO0SuBki0ZoJecdNjfI54z46qzBdw
         83tgFAxzxjkHrh8xZbEWpV7BB4nD5R/5zkEY68b3fnrkuEDJiCrBtUt2kSOuF6j1zBP0
         kceJ4EH8mpyN5U+VjVZBcbTleYN5XSpbtPPVK7ETT33BKL4wkoa8LrCTbqrqGNoVwAD3
         nCy1QCOUza3WhgxlCfXDJ8Egq6WAx/hg2wAGgVefOTRL4lI1GHBx2yyzpzdJFyvmEK9J
         S7kQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZiUN9DDeGFA7eWVibfPSEf0mbT/WssebtqfNdJ0FC8nTW30ngX
	BwEupmP9mQaH0vu5Ed4D0dUdIaj2WkpQh39bGu+nVbtIc4OtApzKQS1Osq3ugRJrE8fBzByGZ7j
	K92yO48eUoQrlWMpnb8uoojjih9qJCcTECvxfoRsKL6NZ1H1a8ez5im3Awt8Tlh9rTw==
X-Received: by 2002:a37:a381:: with SMTP id m123mr15282958qke.147.1550707178211;
        Wed, 20 Feb 2019 15:59:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYZIDqlDCZUba8/5s/tqPviAfN0SBHr2uIDH9YKkvaAx2zn2AVDlJZTTFizXAJYAXZ95zZK
X-Received: by 2002:a37:a381:: with SMTP id m123mr15282928qke.147.1550707177525;
        Wed, 20 Feb 2019 15:59:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550707177; cv=none;
        d=google.com; s=arc-20160816;
        b=yh/NQTfwqx3z2F58zJcIuoJ7Kqby8JR1JHqHw8j/LFUvN1juh0dtmEd3mQvjbyJCup
         LuEUJX9jKGAuZaE9X0X6Mc4+lPuqmODOKHsHmP8wP0/rrwvilsbPiT9Y3Z4pS4PNEpT5
         NvDkPoJzZHKplxn8aGZ2LUFdJ75t28nPW6SNy+QQg64iEy7p4f5vng3FegvKjZuleLM0
         2AxByfkag7M26R90kDev/NAy15Pm/zNQyjJeBX40AL7wYoCowJjMuxMf0HKNzEYmFsT2
         FlQdmFwgDNR/Yi//ljnzIEhvVxTzhbjZL6d5H2iO+H6QinFWH2/obqzt6DH44+uRme63
         yTsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=5Hd1LzJJYxId5zws0/xjQKhFmTCN01qyQFrhgffQPJU=;
        b=s1XkzJ931/ZLrgsvhL/lGB7Ox0I96E185VrSL1DE5yP8EoXjT8U+7iCVAnrrJu+cV8
         q7id+9BlUdrbXFZyEcOH98H2iff9TDpmHTt820QeQaed4XLi8JFlHeM1gen8O7dNx4q5
         Zr/JWWnYCUQRrVi7cqosjc3OacNf9KQ/efg2aTZhGKLj9S9raZPKTKsAOlLq7T5ToW1S
         rZxV/vHeHhe0gIZ2DHO3Tvk5BXBTq9h1M8Q4nqeN9HEprQjdBu5Qsld3QB5iUo0pGy19
         0lfmwHk8zjWmtTQzoIpgK7prabM7ZQNzqMG34PE37CosyqusEo4dEFkg7XLwC8gyDIzp
         eKJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n126si1079806qke.130.2019.02.20.15.59.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 15:59:37 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8A8523082E50;
	Wed, 20 Feb 2019 23:59:36 +0000 (UTC)
Received: from redhat.com (ovpn-120-249.rdu2.redhat.com [10.10.120.249])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A98405D9D2;
	Wed, 20 Feb 2019 23:59:35 +0000 (UTC)
Date: Wed, 20 Feb 2019 18:59:33 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Ralph Campbell <rcampbell@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/10] mm/hmm: use reference counting for HMM struct
Message-ID: <20190220235933.GD11325@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190129165428.3931-2-jglisse@redhat.com>
 <1373673d-721e-a7a2-166f-244c16f236a3@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1373673d-721e-a7a2-166f-244c16f236a3@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Wed, 20 Feb 2019 23:59:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 03:47:50PM -0800, John Hubbard wrote:
> On 1/29/19 8:54 AM, jglisse@redhat.com wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > Every time i read the code to check that the HMM structure does not
> > vanish before it should thanks to the many lock protecting its removal
> > i get a headache. Switch to reference counting instead it is much
> > easier to follow and harder to break. This also remove some code that
> > is no longer needed with refcounting.
> 
> Hi Jerome,
> 
> That is an excellent idea. Some review comments below:
> 
> [snip]
> 
> >   static int hmm_invalidate_range_start(struct mmu_notifier *mn,
> >   			const struct mmu_notifier_range *range)
> >   {
> >   	struct hmm_update update;
> > -	struct hmm *hmm = range->mm->hmm;
> > +	struct hmm *hmm = hmm_get(range->mm);
> > +	int ret;
> >   	VM_BUG_ON(!hmm);
> > +	/* Check if hmm_mm_destroy() was call. */
> > +	if (hmm->mm == NULL)
> > +		return 0;
> 
> Let's delete that NULL check. It can't provide true protection. If there
> is a way for that to race, we need to take another look at refcounting.

I will do a patch to delete the NULL check so that it is easier for
Andrew. No need to respin.

> Is there a need for mmgrab()/mmdrop(), to keep the mm around while HMM
> is using it?

It is already the case. The hmm struct holds a reference on the mm struct
and the mirror struct holds a reference on the hmm struct hence the mirror
struct holds a reference on the mm through the hmm struct.


[...]

> >   	/* FIXME support hugetlb fs */
> >   	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL) ||
> >   			vma_is_dax(vma)) {
> >   		hmm_pfns_special(range);
> > +		hmm_put(hmm);
> >   		return -EINVAL;
> >   	}
> > @@ -910,6 +958,7 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
> >   		 * operations such has atomic access would not work.
> >   		 */
> >   		hmm_pfns_clear(range, range->pfns, range->start, range->end);
> > +		hmm_put(hmm);
> >   		return -EPERM;
> >   	}
> > @@ -945,7 +994,16 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
> >   		hmm_pfns_clear(range, &range->pfns[i], hmm_vma_walk.last,
> >   			       range->end);
> >   		hmm_vma_range_done(range);
> > +		hmm_put(hmm);
> > +	} else {
> > +		/*
> > +		 * Transfer hmm reference to the range struct it will be drop
> > +		 * inside the hmm_vma_range_done() function (which _must_ be
> > +		 * call if this function return 0).
> > +		 */
> > +		range->hmm = hmm;
> 
> Is that thread-safe? Is there anything preventing two or more threads from
> changing range->hmm at the same time?

The range is provided by the driver and the driver should not change
the hmm field nor should it use the range struct in multiple threads.
If the driver do stupid things there is nothing i can do. Note that
this code is removed latter in the serie.

Cheers,
Jérôme

