Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D03D4C46476
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 08:32:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CA542133D
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 08:32:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CA542133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1419F6B000C; Fri,  7 Jun 2019 04:32:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F1EA6B000E; Fri,  7 Jun 2019 04:32:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 007DD6B0266; Fri,  7 Jun 2019 04:32:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A6EA76B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 04:32:58 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l26so2081734eda.2
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 01:32:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Nxs9Ay0PD0dAfOtZ+9wjuHA399OHkkaNPhXYu1S+S1s=;
        b=LeZuiYpWgLD3a3mRNGjGI6oR/B3OM7OrVQeMlMg13e0+nf2ugAwCNCB23QYOamD7zg
         LxaL26ghGd+rG48MdTrPBPq50HSLbJWmH/suOU3FiAYPLRi9n+BL5VMRZ/Is3eOIhYa7
         qeyPSOXEudBo8w+eCCYc/qAkpaGzELKBR2oKLbRKGszV3l4UadMRZyZGHlxqxoDXf92m
         eL/UGL7Sb4SgfpnGlYpbVjgHfR3+Rcs1IoDaVLl1kpxHpLiaOAK8cQGbqoqGyx/Sx2hn
         lUF4hoJfXXTOIkVc6jolFNHFlE1T0uvyUPTSmiCSNK9Ffh51DUOBOOn0tdWfh9H4lRBS
         ZyQg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV449ryLef8rLFq6MugwqLNxVwx0AJd8xGRzhRavSpGhFlIrXsE
	cXaaOTtKUOm/cNn/pq9PWwBpZt3uCmep1dNF8U/hrw2Zy9VcFBctAH5fOfwOgxfHt/yGGWlw2/a
	ftVWVgzZOdE3W5rbNO/KKVwCdJNJadXtYDi9uLmvV4kPF8wbmjoFn4PjXYwvLmW0=
X-Received: by 2002:a17:906:2315:: with SMTP id l21mr38023634eja.54.1559896378226;
        Fri, 07 Jun 2019 01:32:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwK3jyUMuSFH2J4GwmTAEgm6D2QIGuproKzhyDrbzmnKjQ9Yj4XTrHbxrllPY8sY/ydjM6X
X-Received: by 2002:a17:906:2315:: with SMTP id l21mr38023567eja.54.1559896377052;
        Fri, 07 Jun 2019 01:32:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559896377; cv=none;
        d=google.com; s=arc-20160816;
        b=Ln6vIZCF41TPJxQ4g8EN+5YkX2mnvn99FLZuGp9y8/1OnVZZynnrU0woCRk2XR/RuF
         jDGQ7EhMBN0DVjsvaIr+J0al/mcL9Zgnv/Y8b2nTezDBPAoGp4xWKxphgGYNr7/90V7x
         uWtOSNS7yArXsIZ0KMZGKl2wmUfIFBI2lY1YXdQ6wfwMoVC2eIAUMCPK+f1RxipwyMoq
         CIbmz17pJ6nPaLTYZF0cHGu/zbXhYYniEAcMxvqInhIoWOQ7+Ti9SoTC/LyHIxB427Ry
         u757tSkFlaWOKuK8k7jfg2Jm+eWs0qGaw67PBmuHNDgTXm8Y4hO3oLWANNaDTITo4Uf1
         HVGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Nxs9Ay0PD0dAfOtZ+9wjuHA399OHkkaNPhXYu1S+S1s=;
        b=VVwYyB3ivhwcn7QY9qnVf3DzisRAYZ+54eudB8oECsZ1VQNPdLOs6xHbalVVjPA8YI
         Fa/oojSJA2a1BRpIOisJVF3NmcW2bO45xJ0hydfBY5R7uVGWsPaBTNi0IqWE3n+OKMbR
         z9PpzTmhxQG+gNH9hp/aSv41dNytaLP0GgzdTf9Dt11erUUapatQ0LIuQKO0hWtynmX7
         5sbcLi7+WZMS2JXuFb2FbT73eQC9kHHhT8vTuCeZxYq7m5u27k8rPZqV5uWAeHdiIH/C
         Zu/5iDGv0USUA0BtJZqqa1vs3X5gXIXqvFTCNtKKsYvB0/IDyhNoqG2PnGlHVOL1q7iw
         PfiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c44si848687ede.137.2019.06.07.01.32.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 01:32:57 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F3AAFAF22;
	Fri,  7 Jun 2019 08:32:55 +0000 (UTC)
Date: Fri, 7 Jun 2019 10:32:55 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Vlastimil Babka <vbabka@suse.cz>, Zi Yan <zi.yan@cs.rutgers.edu>,
	Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	"Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] Revert "mm, thp: restore node-local hugepage
 allocations"
Message-ID: <20190607083255.GA18435@dhcp22.suse.cz>
References: <20190503223146.2312-3-aarcange@redhat.com>
 <alpine.DEB.2.21.1905151304190.203145@chino.kir.corp.google.com>
 <20190520153621.GL18914@techsingularity.net>
 <alpine.DEB.2.21.1905201018480.96074@chino.kir.corp.google.com>
 <20190523175737.2fb5b997df85b5d117092b5b@linux-foundation.org>
 <alpine.DEB.2.21.1905281907060.86034@chino.kir.corp.google.com>
 <20190531092236.GM6896@dhcp22.suse.cz>
 <alpine.DEB.2.21.1905311430120.92278@chino.kir.corp.google.com>
 <20190605093257.GC15685@dhcp22.suse.cz>
 <alpine.DEB.2.21.1906061451001.121338@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1906061451001.121338@chino.kir.corp.google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 06-06-19 15:12:40, David Rientjes wrote:
> On Wed, 5 Jun 2019, Michal Hocko wrote:
> 
> > > That's fine, but we also must be mindful of users who have used 
> > > MADV_HUGEPAGE over the past four years based on its hard-coded behavior 
> > > that would now regress as a result.
> > 
> > Absolutely, I am all for helping those usecases. First of all we need to
> > understand what those usecases are though. So far we have only seen very
> > vague claims about artificial worst case examples when a remote access
> > dominates the overall cost but that doesn't seem to be the case in real
> > life in my experience (e.g. numa balancing will correct things or the
> > over aggressive node reclaim tends to cause problems elsewhere etc.).
> > 
> 
> The usecase is a remap of a binary's text segment to transparent hugepages 
> by doing mmap() -> madvise(MADV_HUGEPAGE) -> mremap() and when this 
> happens on a locally fragmented node.  This happens at startup when we 
> aren't concerned about allocation latency: we want to compact.  We are 
> concerned with access latency thereafter as long as the process is 
> running.

You have indicated this previously but no call for a stand alone
reproducer was successful. It is really hard to optimize for such a
specialized workload without anything to play with. Btw. this is exactly
a case where I would expect numa balancing to converge to the optimal
placement. And if numabalancing is not an option than an explicit
mempolicy (e.g. the one suggested here) would be a good fit.

[...]

I will defer the compaction related stuff to Vlastimil and Mel who are
much more familiar with the current code.

> So my proposed change would be:
>  - give the page allocator a consistent indicator that compaction failed
>    because we are low on memory (make COMPACT_SKIPPED really mean this),
>  - if we get this in the page allocator and we are allocating thp, fail,
>    reclaim is unlikely to help here and is much more likely to be
>    disruptive
>      - we could retry compaction if we haven't scanned all memory and
>        were contended,
>  - if the hugepage allocation fails, have thp check watermarks for order-0 
>    pages without any padding,
>  - if watermarks succeed, fail the thp allocation: we can't allocate
>    because of fragmentation and it's better to return node local memory,

Doesn't this lead to the same THP low success rate we have seen with one
of the previous patches though?

Let me remind you of the previous semantic I was proposing
http://lkml.kernel.org/r/20181206091405.GD1286@dhcp22.suse.cz and that
didn't get shot down. Linus had some follow up ideas on how exactly
the fallback order should look like and that is fine. We should just
measure differences between local node cheep base page vs. remote THP on
_real_ workloads. Any microbenchmark which just measures a latency is
inherently misleading.

And really, fundamental problem here is that MADV_HUGEPAGE has gained 
a NUMA semantic without a due scrutiny leading to a broken interface
with side effects that are simply making the interface unusable for a
large part of usecases that the madvise was originaly designed for.
Until we find an agreement on this point we will be looping in a dead
end discussion, I am afraid.

-- 
Michal Hocko
SUSE Labs

