Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01D91C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:52:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE6BE2084F
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:52:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE6BE2084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39E256B0008; Wed, 15 May 2019 04:52:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34F4A6B000A; Wed, 15 May 2019 04:52:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23F206B000C; Wed, 15 May 2019 04:52:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id BFBB06B0008
	for <linux-mm@kvack.org>; Wed, 15 May 2019 04:52:01 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id h4so503712wrp.21
        for <linux-mm@kvack.org>; Wed, 15 May 2019 01:52:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=F6DFe62CqcWW1zROhCHNbimDkV4rEZq8vvGMAT2Is98=;
        b=Q1GRC+Y1vD+oHHgpHFbyCJgT73xHcddxpOO3owwJK3xDUIPMZJhPLM3dEYcKWJxyUD
         A3HeCltOGwldnZKpaGmwDbVbehJEd00YckYl+cJdOWQ4SX8XmPDy5Tpd35+YkwFD8gpA
         CG6r0uSIKY9l1pUL3fiF0BUqsGQ0P6gXnhJDIua09wBRP7XQKO3krVcbJqLVNl4FzHHW
         zdDP5QIwHbB7kLXYJCSu1P9emwufIont4LHQCtidGvTKuOUqljKmLDyOmy+LktZPCGRV
         41asH9J+D5PvDkHw2AB3wmc3iKy01YmrAcNsPIHw/qHQz52zMU400ahjMmYy9Zx579EA
         8Lbg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWAPBaEWEOM3Pc2S7ImI93f/08Y3gMhDdMXXFgpCQViWfwcCKwC
	cVqXWKGLSxEd53iNZyBWr9VUQ3zihKZQUOSDQjBUV/V20+HPlY2VZyg6tSAD//z+fe1592qQf+J
	exLy+j7i4ZVNswHsVMr8BDRwUUH3TlXKE5kQb7uujwYmRxDuOiU/5ctP5CUKs+6txqA==
X-Received: by 2002:a1c:7f10:: with SMTP id a16mr21545554wmd.30.1557910321345;
        Wed, 15 May 2019 01:52:01 -0700 (PDT)
X-Received: by 2002:a1c:7f10:: with SMTP id a16mr21545524wmd.30.1557910320591;
        Wed, 15 May 2019 01:52:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557910320; cv=none;
        d=google.com; s=arc-20160816;
        b=LAr5Fl2kbyDA8ixKzxHyYs3PfR71IVjfc8DcliBKBGja7FRdIHXsH+t0RhYCjxpBSM
         vMwlL3HVd7V8y3Dynw6XV5/B3SRCicQmjOTmAkkqkce0SrjVXMnYoemArV3ZudPbSrco
         ms90ATIib4rjgsnxWQfQwG6HYWyqEgSbCCpEVeDQGHlU5cNYskp3MJ3YV6PUqmp4r8Bd
         NLjueLL4tkAXBMiJQmILlxq1HAUN11XBPm4NadxzF5aj5fRGqXNMpZ1Y0EsYXv3h8Esy
         8aFoOA7nRGvHMtXAAG+SHbvZOOQzMSJnEaycy2V0GB6+CyWQ6QDilfzCFRJh1gPYMVL5
         OTDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=F6DFe62CqcWW1zROhCHNbimDkV4rEZq8vvGMAT2Is98=;
        b=0fiOsb0EtFhSgd1dzF5T0T/+8yXBsqCCRVMYV8Bt0zddtmcNxpua1VBNCZ12xjTunu
         SR67A9wDuJRX30bWpGjhxZp6ihXBiT8gTxz1rgJk/v6q3zUMxMsjG6Pqfg743c1gll6n
         8php3qvFzpfEOOEmpguv8dqJ1zKAkMl0S412IGM3nL+jgFapLE3Oj1cpbjF0pWWMsBAD
         YVGJkQ4IYyeQPy40FSGQ/UmFCIC9n9zjNifIpbDgQwSkkmTljZxFM4UK3aPfvAYQCLrh
         +ekGzCCXdvlcPbHJM1h4pwxBNYieSq83+b4R2QLZ31Rj33xIgzgynqNP1DyPGHtywnwV
         t0tQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q8sor1069111wru.29.2019.05.15.01.52.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 01:52:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwLCZxxNevBY2k96AGejabdkmuyTgj3ImDiVQ15+XN1UfSnqKNGvxTjlaeeXG7DlIrNyVO6Ew==
X-Received: by 2002:adf:ba10:: with SMTP id o16mr15326042wrg.89.1557910320163;
        Wed, 15 May 2019 01:52:00 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id o16sm1915596wro.63.2019.05.15.01.51.59
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 15 May 2019 01:51:59 -0700 (PDT)
Date: Wed, 15 May 2019 10:51:58 +0200
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH RFC v2 0/4] mm/ksm: add option to automerge VMAs
Message-ID: <20190515085158.hyuamrxkxhjhx6go@butterfly.localdomain>
References: <20190514131654.25463-1-oleksandr@redhat.com>
 <20190514144105.GF4683@dhcp22.suse.cz>
 <20190514145122.GG4683@dhcp22.suse.cz>
 <20190515062523.5ndf7obzfgugilfs@butterfly.localdomain>
 <20190515065311.GB16651@dhcp22.suse.cz>
 <20190515073723.wbr522cpyjfelfav@butterfly.localdomain>
 <20190515083321.GC16651@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190515083321.GC16651@dhcp22.suse.cz>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 10:33:21AM +0200, Michal Hocko wrote:
> > For my current setup with 2 Firefox instances I get 100 to 200 MiB saved
> > for the second instance depending on the amount of tabs.
> 
> What does prevent Firefox (an opensource project) to be updated to use
> the explicit merging?

This was rather an example of a big project. Other big projects may be
closed source, of course.

And yes, with regard to FF specifically I think nothing prevents it from
being modified appropriately.

> > Answering your question regarding using existing interfaces, since
> > there's only one, madvise(2), this requires modifying all the
> > applications one wants to de-duplicate. In case of containers with
> > arbitrary content or in case of binary-only apps this is pretty hard if
> > not impossible to do properly.
> 
> OK, this makes more sense. Please note that there are other people who
> would like to see certain madvise operations to be done on a remote
> process - e.g. to allow external memory management (Android would like
> to control memory aging so something like MADV_DONTNEED without loosing
> content and more probably) and potentially other madvise operations.
> Or maybe we need a completely new interface other than madvise.

I didn't know about those intentions. Could you please point me to a
relevant discussion so that I can check the details?

> In general, having a more generic API that would cover more usecases is
> definitely much more preferable than one ad-hoc API that handles a very
> specific usecase. So please try to think about a more generic

Yup, I see now. Since you are aware of ongoing intentions, please do Cc
those people then and/or let me know about previous discussions please.
That way thinking of how a new API should be implemented (be it a sysfs
file or something else) should be easier and more visible.

Thanks.

-- 
  Best regards,
    Oleksandr Natalenko (post-factum)
    Senior Software Maintenance Engineer

