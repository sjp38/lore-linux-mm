Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09DC4C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 18:59:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFBC72173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 18:59:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFBC72173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CA956B0007; Thu,  8 Aug 2019 14:59:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57C026B0008; Thu,  8 Aug 2019 14:59:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46A656B000A; Thu,  8 Aug 2019 14:59:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F01716B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 14:59:27 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i44so58818432eda.3
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 11:59:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jC9SZ4A1hXUew9ADzlJ2MF15Eh4DqbwXOb8aB2HOTkI=;
        b=RSyH3ZlJ1fK9v5Fq0GhWXojBF9OcHf8leQ4iDAuZB5qG9NoSCsW3K0lLjkYfC+SzKI
         hv5NPNLp/IomUrBkwvJ0UVK9bxE516TV6gesYNXV+K50YLjlOzU3LblOxBFvfEPAWdGf
         BHxxj1XScytGYnbOGt8cZm01pDHqSdefoi9XkLBTPyVKNom6xhdxWLyyBJYorOIE7lXY
         HrBVWBl3JpSWU1u8Pp6/7XnBvE2BQ0dKppbHtEt7WFRnBsYGJ51IP2gn/TBluKcfI8cX
         7g1SCXfl7O1feCJRjOLrWi2JGk4GySWhMpSdzvbU0tCFtjHJMVxT0JpYp75heUhEK64z
         YO0Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUS8m5hXRa23gHriQo5uC3B+XGrekeLBLl9fIiZBtNLRYEOluN5
	6CeTVy4vpN39rW98sDrKM11SijjYEps44B5MCVeRKUKTKNR/XYbwphuAHM2TtsWi7V5m4bD1ugR
	Kvk3uenGzcaVrD8pQfch+UTRq0W3jK69zn6toQuOPVIHaSWGOFS4bJpS3T70dLvY=
X-Received: by 2002:a50:972c:: with SMTP id c41mr17903081edb.153.1565290767541;
        Thu, 08 Aug 2019 11:59:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyb3XWS1Z8hNvAnLNB8XJNq2Fa37HqhXaCULk3kUGP+i+xoWvKCUL0IIt+s8w93/WlFDVff
X-Received: by 2002:a50:972c:: with SMTP id c41mr17903022edb.153.1565290766699;
        Thu, 08 Aug 2019 11:59:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565290766; cv=none;
        d=google.com; s=arc-20160816;
        b=bR1kR9Js8CIPm6jPvWhwOMA+51ThNfMSxoY2IYxwhFNv4kkcQ4cMaTkXe4b5TRPeGR
         q0bGWj8UnA1WsmXk0ivgj5KtynxSiBzXzf/+MruUjPwbLdLLnuixBnAmGKx7RzlYWWTJ
         /9lydIgJwLswwnUTcwjm6JyfStt27f/HSdLJrwKsCN3cCPupD4lo3tKVrewSpDqehCn5
         dyVS3zfkJDEJCEgAkYyW99JtbhDeMOq3cotnkef8X8MLEQlLq61sijpY8ryWPetQKIwu
         luvh8N9Pxffm689Djon9OvV6Z1TTSxIOwrNmEI7RkdHdZbKsw3+Qu1nzh86JIMSYm0sp
         yg9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jC9SZ4A1hXUew9ADzlJ2MF15Eh4DqbwXOb8aB2HOTkI=;
        b=Es1spIIwPxmFTuFehI5JN7+KvIuB4Sw1AcUFO+5j3ja4p750ywrKTJcpPwwViR8gfP
         aA/tbuGPm6zHpk3IjIgDt50DjUtLFYfxdPLsWHm5PsKIzFuQLQyep8813Fvlaat/odOT
         4S90lSwHYllpgn59ZuCB1TJDsM821oqkwmpX8ighqpHL8sthOD12XnwQQpCKcWw6GtpT
         di3Rg89wslksQvJsAnCU9pKSQSycRZcxInQoOT/kclOyKUUY+De0zmwB0rQr8CJ3B19s
         g30DiU+ON1eN46VLpCDe36GJQVVqiTfNDL/GFDCXdhYglyxCvxgoXfWwtm2yRYOdFvrY
         am8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g23si37149383edg.39.2019.08.08.11.59.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 11:59:26 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 325BEAFD4;
	Thu,  8 Aug 2019 18:59:26 +0000 (UTC)
Date: Thu, 8 Aug 2019 20:59:25 +0200
From: Michal Hocko <mhocko@kernel.org>
To: ndrw.xf@redhazel.co.uk
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	"Artem S. Tashkinov" <aros@gmx.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
Message-ID: <20190808185925.GH18351@dhcp22.suse.cz>
References: <20190806142728.GA12107@cmpxchg.org>
 <20190806143608.GE11812@dhcp22.suse.cz>
 <CAJuCfpFmOzj-gU1NwoQFmS_pbDKKd2XN=CS1vUV4gKhYCJOUtw@mail.gmail.com>
 <20190806220150.GA22516@cmpxchg.org>
 <20190807075927.GO11812@dhcp22.suse.cz>
 <20190807205138.GA24222@cmpxchg.org>
 <20190808114826.GC18351@dhcp22.suse.cz>
 <806F5696-A8D6-481D-A82F-49DEC1F2B035@redhazel.co.uk>
 <20190808163228.GE18351@dhcp22.suse.cz>
 <5FBB0A26-0CFE-4B88-A4F2-6A42E3377EDB@redhazel.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5FBB0A26-0CFE-4B88-A4F2-6A42E3377EDB@redhazel.co.uk>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 08-08-19 18:57:02, ndrw.xf@redhazel.co.uk wrote:
> 
> 
> On 8 August 2019 17:32:28 BST, Michal Hocko <mhocko@kernel.org> wrote:
> >
> >> Would it be possible to reserve a fixed (configurable) amount of RAM
> >for caches,
> >
> >I am afraid there is nothing like that available and I would even argue
> >it doesn't make much sense either. What would you consider to be a
> >cache? A kernel/userspace reclaimable memory? What about any other in
> >kernel memory users? How would you setup such a limit and make it
> >reasonably maintainable over different kernel releases when the memory
> >footprint changes over time?
> 
> Frankly, I don't know. The earlyoom userspace tool works well enough
> for me so I assumed this functionality could be implemented in
> kernel. Default thresholds would have to be tested but it is unlikely
> zero is the optimum value.

Well, I am afraid that implementing anything like that in the kernel
will lead to many regressions and bug reports. People tend to have very
different opinions on when it is suitable to kill a potentially
important part of a workload just because memory gets low.

> >Besides that how does that differ from the existing reclaim mechanism?
> >Once your cache hits the limit, there would have to be some sort of the
> >reclaim to happen and then we are back to square one when the reclaim
> >is
> >making progress but you are effectively treshing over the hot working
> >set (e.g. code pages)
> 
> By forcing OOM killer. Reclaiming memory when system becomes unresponsive is precisely what I want to avoid.
> 
> >> and trigger OOM killer earlier, before most UI code is evicted from
> >memory?
> >
> >How does the kernel knows that important memory is evicted?
> 
> I assume current memory management policy (LRU?) is sufficient to keep most frequently used pages in memory.

LRU aspect doesn't help much, really. If we are reclaiming the same set
of pages becuase they are needed for the workload to operate then we are
effectivelly treshing no matter what kind of replacement policy you are
going to use.


[...]
> >PSI is giving you a matric that tells you how much time you
> >spend on the memory reclaim. So you can start watching the system from
> >lower utilization already.
> 
> This is a fantastic news. Really. I didn't know this is how it
> works. Two potential issues, though:
> 1. PSI (if possible) should be normalised wrt the memory reclaiming
> cost (SSDs have lower cost than HDDs). If not automatically then
> perhaps via a user configurable option. That's somewhat similar to
> having configurable PSI thresholds.

The cost of the reclaim is inherently reflected in those numbers
already because it gives you the amount of time that is spent getting a
memory for you. If you are under a memory pressure then the memory
reclaim is a part of the allocation path.

> 2. It seems PSI measures the _rate_ pages are evicted from
> memory. While this may correlate with the _absolute_ amount of of
> memory left, it is not the same. Perhaps weighting PSI with absolute
> amount of memory used for caches would improve this metric.

Please refer to Documentation/accounting/psi.rst for more information
about how PSI works. 
-- 
Michal Hocko
SUSE Labs

