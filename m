Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 279AEC04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:33:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF60B20881
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:33:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF60B20881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7770C6B0003; Tue, 14 May 2019 09:33:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 727236B0006; Tue, 14 May 2019 09:33:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 617396B0007; Tue, 14 May 2019 09:33:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 18F2F6B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 09:33:22 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id 206so738346wmb.0
        for <linux-mm@kvack.org>; Tue, 14 May 2019 06:33:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=d9EoIX4OtN63tuf6PqPnEv+P68EjjjVZjk7X2yNFHPw=;
        b=HsR9rC/fFqNKlh9fKnjerZb/UGF6plBDc+wRXBNc5NPPd38Q0nNi7EJRV9T2vh7+j+
         ZYG5GYGYkV1GphMcnUZiw5ZIrZwVzuHEeVeZsA8eUhSRCd+EseXaye5v0mBkdCRrM9hX
         2bpfYCt/BCrX2AQZQTz+PekykiDMEhAkchKksDVeXcyneLpE5P0gDl+YFYthd1sEooWQ
         CiC3f/jNCNAKZVhNbRoyGiXtQ4kjZP1nl/WFNARZo1tzbNHtAuiJAu5RSGmOuR8DGJB2
         FG+fKpK98n7yqw0pQYx1KNEXN0OxLTUjNFxLdDCRFKHgjYL94LLYQcRl5O3kn8T2lKFY
         8m3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVwagqsNfEOyF5QqpRWYV4OnfFmjKATVT+LihjZdK5Y6u81N1Wq
	3ejUZ9NlmqiNVRC/ptsFN0SV3UWI5gYFmMgq8l4xCxW+UYwQtNF1ZV4amiVJpKfHyDJt/qWSYI3
	FP4wj4nB7eZSqNTFnDvI1la/9QLUtdGGd5oi3moBkl7IwuYZBP8s6/LiO7NcLCXsD4Q==
X-Received: by 2002:a5d:45c7:: with SMTP id b7mr9251130wrs.176.1557840801674;
        Tue, 14 May 2019 06:33:21 -0700 (PDT)
X-Received: by 2002:a5d:45c7:: with SMTP id b7mr9251093wrs.176.1557840800887;
        Tue, 14 May 2019 06:33:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557840800; cv=none;
        d=google.com; s=arc-20160816;
        b=zuguTdfKu4aAU3lPBtoI/8hv7Af37BPFJHtr8troNSrlZ9RIgurx9xMjX+PrFlCqXu
         +ZiULuUH4i1/xMLkEPw0pK84sFoMvA1gBq+SJGZtdvg7EwyrKlcYdjTS6ss/hCgxHqVE
         3k7dLrtvZGFiPBAJqZXcgrWLqm9fhx2DJbbRYEDUG53kwNmB994GFXRisFfJSpGXrK6G
         kF00U+cmrXKNpJ4f3UslDRD8rACEoomXjB3c2AxzGlOD12W4MVEZq5vy5+/BrzUErChU
         pVDmaFniBq3n8o/kPk2vPsULh96JBKaFaxQ8sAhG4wox4IedUslLDmTA5M6HkCkNOuwb
         eR+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=d9EoIX4OtN63tuf6PqPnEv+P68EjjjVZjk7X2yNFHPw=;
        b=yxr9msDgQy67nVCUYXXa+m6AEHkv9tuMCQAig/3OYUN3Iv8znKoiJVoTbr8zy8296o
         UIGi27bYMF5g9Ra2xHNZ7ku5hKBM3nKPyIZ98qRT2mVB0wgd2K33UpWl4XvssBUGGpSl
         dpEre7qD9I277Q9hSsQ7RKYnfl+ODncATiS3/yZyuP+0d/QBhbEMECTUK0BKX4kKM+b7
         ZCzIAqlhsEuY3DgcJuek4Y6jgT37bzGF7Yt+IQ1cTcGjF1BAG+8Dgz/JI2lR2dCeODG6
         EUFFxz7PNQ0ucGcCoxRZTvLA/4/AtX+QW5+M5Wu9L9OdBHMJnfxKaLveB/dDxNsXwjNZ
         Hekg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11sor1655326wmk.14.2019.05.14.06.33.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 06:33:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyH4xbvnALaIskNjJjytlyDm4bpDsvIv/E9RvAZ/9pcOfLCie6sMSJ6eRwPJvRv8tXja/Wuaw==
X-Received: by 2002:a1c:f312:: with SMTP id q18mr18961502wmq.96.1557840800371;
        Tue, 14 May 2019 06:33:20 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id a6sm13803254wrp.49.2019.05.14.06.33.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 06:33:19 -0700 (PDT)
Date: Tue, 14 May 2019 15:33:18 +0200
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>, linux-mm@kvack.org
Subject: Re: [PATCH RFC 0/4] mm/ksm: add option to automerge VMAs
Message-ID: <20190514133318.6ajp3jn22jqowt4p@butterfly.localdomain>
References: <20190510072125.18059-1-oleksandr@redhat.com>
 <36a71f93-5a32-b154-b01d-2a420bca2679@virtuozzo.com>
 <20190513113314.lddxv4kv5ajjldae@butterfly.localdomain>
 <a3870e32-3a27-e6df-fcb2-79080cdd167a@virtuozzo.com>
 <20190514063043.ojhsb6d3ohxx4wur@butterfly.localdomain>
 <8f146863-5963-81b2-ed20-6428d1da353c@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8f146863-5963-81b2-ed20-6428d1da353c@virtuozzo.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi.

On Tue, May 14, 2019 at 12:12:16PM +0300, Kirill Tkhai wrote:
> > Immediate question: what should be actually done on this? I see 2
> > options:
> > 
> > 1) mark all VMAs as mergeable + set some flag for mmap() to mark all
> > further allocations as mergeable as well;
> > 2) just mark all the VMAs as mergeable; userspace can call this
> > periodically to mark new VMAs.
> > 
> > My prediction is that 2) is less destructive, and the decision is
> > preserved predominantly to userspace, thus it would be a desired option.
> 
> Let's see, how we use KSM now. It's good for virtual machines: people
> install the same distribution in several VMs, and they have the same
> packages and the same files. When you read a file inside VM, its pages
> are file cache for the VM, but they are anonymous pages for host kernel.
> 
> Hypervisor marks VM memory as mergeable, and host KSM merges the same
> anonymous pages together. Many of file cache inside VM is constant
> content, so we have good KSM compression on such the file pages.
> The result we have is explainable and expected.

Yup, correct.

> But we don't know anything about pages, you have merged on your laptop.
> We can't make any assumptions before analysis of applications, which
> produce such the pages. Let's check what happens before we try to implement
> some specific design (if we really need something to implement).
> 
> The rest is just technical details. We may implement everything we need
> on top of this (even implement a polling of /proc/[pid]/maps and write
> a task and address of vma to force_madvise or similar file).

I'm not sure that reviewing all the applications falls under the scope
of this and/or similar submission. Personally I do not feel comfortable
reviewing Firefox code, for example.

But I do run 2 instances of FF, one for work stuff, one for personal stuff,
so merging its memory would be definitely beneficial for me. I believe I'm
not the only one doing this, and things are not limited to Firefox only, of
course.

Please consider checking a v2 submission I've just posted. It implements
your suggestion on "force_madvise" knob, and I find your feedback very
relevant and useful.

Thanks.

-- 
  Best regards,
    Oleksandr Natalenko (post-factum)
    Senior Software Maintenance Engineer

