Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 220D3C742A8
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 08:27:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC5B621019
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 08:27:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC5B621019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 484328E0128; Fri, 12 Jul 2019 04:27:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 435368E00DB; Fri, 12 Jul 2019 04:27:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34C138E0128; Fri, 12 Jul 2019 04:27:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DD0818E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 04:27:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l26so7166956eda.2
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 01:27:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jIocLEX3k1ojubRfum2a6qGFB3hHKtugO8wPHqWDXY8=;
        b=Yt1Dn2NSkVcuYdo0iiEd91S5Zuj2Rp+xt2EoNqOsPqES5XzjvTNqoZaMPnWFuEF8lp
         hDzeedRmqTYFjddA7ZPQqRSWMtnkKmB+s9gX7pMAKoppBuYVBjkucNXzl1N1IMHfGA2B
         1jPsJncSIdgUCudQw96uXEgYu15DcFy7LY05OuS4OHFZXEIYlBZCHac5Hkb6zSbT/gKh
         VdkxdC3AjRh28gfTW1A4Z59UIu/s6b/Aa3JNPM0fp3oFoTMUNRFN7UO7Zq1kHNldyILW
         lnh5eWLhKxUeGZHH1OeqqzcCTCaI+/ST2Zafd9zpN6cJRq4jPYJ/5f7M7Nh7hjiv4rCv
         p2XQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAWX3K0C1Utj2+XjMs7rJb9tyMUkMkSMl/y36DGVaYC4o2DHMd/g
	QZ2aywsgNKdFLdOmcD0lIipHF6zkgn4PdkOUMWX6OSwgzwWr06G5qWrFeArdx1EyFcF7+brSKP6
	t+v5fheqursvKtnLwzvCQTc83pzxGolMRqyd8QHl0+smbMkJlQmV99yhSsVppi+SzxQ==
X-Received: by 2002:a17:906:19d3:: with SMTP id h19mr7086054ejd.300.1562920034450;
        Fri, 12 Jul 2019 01:27:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6o+Nk5nSm4NyNMC8R3VFfHc0r+M6oaycrHfSX0ba6NtBI3blENsNtxf4rdcgWuDgpdeaM
X-Received: by 2002:a17:906:19d3:: with SMTP id h19mr7086019ejd.300.1562920033556;
        Fri, 12 Jul 2019 01:27:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562920033; cv=none;
        d=google.com; s=arc-20160816;
        b=h3PI3aOVfwH8bd509VJyh7od6WuVjKMqhzWQNxep5gUSkEn6yIEycBOnwHIyS/fm/K
         1acNkVWwXwZLO28BZfC/PjVyQUYaFY1fTsfmbMDU2PCKF/bumE54p1oP4qekwrcSDlA1
         Ulro57XzvUtqBJFyJcfEeFYIXv+xsVt8V+mcexQI7JM9lV7yDE8asqQzx/VppGtlkb0v
         QEpGUiHeLPoeRFJgIdr8bqwSBmZeu8sHCosHm8NI5oIH1mehjSg6gE3oFguhHaoJu+MV
         kI14tQn2EG4qwGy3HeF/ETzRdHj3m27PF2wzbHvUqxRQIBp3AuOJkZ/UNLqFNgzwK3x5
         WJ+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jIocLEX3k1ojubRfum2a6qGFB3hHKtugO8wPHqWDXY8=;
        b=oL3BXBxBK5Jon7+bH4R2+XX10xEvdlIAQQ92mDEr+s+r5bk58iS8wt/4rrU7SfpIle
         lpG3pwM14dao1/4zFT+TkneLPeHcdhLds/N73k5PGfzYFN37vVuR9AiRaNMrYw2bsZpK
         69sjUhZlRDTSjatYkhhITRYpkgYn0Fy1Oolb8Uu5+v3UI/flXA758Jy2yfS8D1TO8jPi
         jG0nuPpS4p9YXSVM2ENqWiJJUGbqwKSDYGisv3UOT/4mL2pa1OkUxYvy7AA8+viPO7sG
         wbrOcftg8zMX4IH9KMggX7M9HvcCRuUA89/iljpQLQafepo2Le8q5vS2Crnudhg5sEyt
         ZArQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z14si4398479ejq.189.2019.07.12.01.27.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 01:27:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DAC5BAC4C;
	Fri, 12 Jul 2019 08:27:12 +0000 (UTC)
Date: Fri, 12 Jul 2019 09:27:10 +0100
From: Mel Gorman <mgorman@suse.de>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: huang ying <huang.ying.caritas@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>, jhladky@redhat.com,
	lvenanci@redhat.com, Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH -mm] autonuma: Fix scan period updating
Message-ID: <20190712082710.GH13484@suse.de>
References: <20190624025604.30896-1-ying.huang@intel.com>
 <20190624140950.GF2947@suse.de>
 <CAC=cRTNYUxGUcSUvXa-g9hia49TgrjkzE-b06JbBtwSn2zWYsw@mail.gmail.com>
 <20190703091747.GA13484@suse.de>
 <87ef3663nd.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <87ef3663nd.fsf@yhuang-dev.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 04, 2019 at 08:32:06AM +0800, Huang, Ying wrote:
> Mel Gorman <mgorman@suse.de> writes:
> 
> > On Tue, Jun 25, 2019 at 09:23:22PM +0800, huang ying wrote:
> >> On Mon, Jun 24, 2019 at 10:25 PM Mel Gorman <mgorman@suse.de> wrote:
> >> >
> >> > On Mon, Jun 24, 2019 at 10:56:04AM +0800, Huang Ying wrote:
> >> > > The autonuma scan period should be increased (scanning is slowed down)
> >> > > if the majority of the page accesses are shared with other processes.
> >> > > But in current code, the scan period will be decreased (scanning is
> >> > > speeded up) in that situation.
> >> > >
> >> > > This patch fixes the code.  And this has been tested via tracing the
> >> > > scan period changing and /proc/vmstat numa_pte_updates counter when
> >> > > running a multi-threaded memory accessing program (most memory
> >> > > areas are accessed by multiple threads).
> >> > >
> >> >
> >> > The patch somewhat flips the logic on whether shared or private is
> >> > considered and it's not immediately obvious why that was required. That
> >> > aside, other than the impact on numa_pte_updates, what actual
> >> > performance difference was measured and on on what workloads?
> >> 
> >> The original scanning period updating logic doesn't match the original
> >> patch description and comments.  I think the original patch
> >> description and comments make more sense.  So I fix the code logic to
> >> make it match the original patch description and comments.
> >> 
> >> If my understanding to the original code logic and the original patch
> >> description and comments were correct, do you think the original patch
> >> description and comments are wrong so we need to fix the comments
> >> instead?  Or you think we should prove whether the original patch
> >> description and comments are correct?
> >> 
> >
> > I'm about to get knocked offline so cannot answer properly. The code may
> > indeed be wrong and I have observed higher than expected NUMA scanning
> > behaviour than expected although not enough to cause problems. A comment
> > fix is fine but if you're changing the scanning behaviour, it should be
> > backed up with data justifying that the change both reduces the observed
> > scanning and that it has no adverse performance implications.
> 
> Got it!  Thanks for comments!  As for performance testing, do you have
> some candidate workloads?
> 

Ordinarily I would hope that the patch was motivated by observed
behaviour so you have a metric for goodness. However, for NUMA balancing
I would typically run basic workloads first -- dbench, tbench, netperf,
hackbench and pipetest. The objective would be to measure the degree
automatic NUMA balancing is interfering with a basic workload to see if
they patch reduces the number of minor faults incurred even though there
is no NUMA balancing to be worried about. This measures the general
overhead of a patch. If your reasoning is correct, you'd expect lower
overhead.

For balancing itself, I usually look at Andrea's original autonuma
benchmark, NAS Parallel Benchmark (D class usually although C class for
much older or smaller machines) and spec JBB 2005 and 2015. Of the JBB
benchmarks, 2005 is usually more reasonable for evaluating NUMA balancing
than 2015 is (which can be unstable for a variety of reasons). In this
case, I would be looking at whether the overhead is reduced, whether the
ratio of local hits is the same or improved and the primary metric of
each (time to completion for Andrea's and NAS, throughput for JBB).

Even if there is no change to locality and the primary metric but there
is less scanning and overhead overall, it would still be an improvement.

If you have trouble doing such an evaluation, I'll queue tests if they
are based on a patch that addresses the specific point of concern (scan
period not updated) as it's still not obvious why flipping the logic of
whether shared or private is considered was necessary.

-- 
Mel Gorman
SUSE Labs

