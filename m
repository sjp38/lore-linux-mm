Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E0D5C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 21:16:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E94921530
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 21:16:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="qkN/qi8K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E94921530
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EB2A6B0003; Fri, 21 Jun 2019 17:16:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89B2B8E0002; Fri, 21 Jun 2019 17:16:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 789878E0001; Fri, 21 Jun 2019 17:16:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 42ECC6B0003
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:16:46 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x9so5092973pfm.16
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 14:16:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=ee7dIZ6uP6QXNcDhtf383EXh+QJWWk7ZjpJlf1hao0g=;
        b=enGUjPT0RIf9iD0ys9qTpjHwbUoNyqrKBkob2lNjsJcNOj1mt/h9sVgKkFY+aScv22
         nT21NQ/WHrWOJG/BOWUgQ+Rq9tTpaFavWkbhFpPlNPKBjbwPNg1mGkp46QqyI74dC7uS
         ooYGyqIo7kZvgcgFL4BNTEk0FNUOQV41lmXOlcyEf0PdwUJZTmMGQCPkjL4lX/DtH2FN
         u5kpDEN3JRs4NEN509HEDZ1E9C3X66+puDfaLyMYJRgFivn6c8ljDPU0eGHbpdL+vjYR
         zevd7RZ1dUc9rPOuLS7q8g7/yV6tlZFivZcTL0bGzZd8M19+dHjeup1h2tHcDCAVDgZN
         v4+g==
X-Gm-Message-State: APjAAAWoWyJaC/O7MxqDD1404zXsDj7NTl7d9nsQ6SgwHB2jn9Ua+xKI
	VMV0+ZGnywrgt1IJzBGITKZGlUp4d47feu7Zm8CebS82M1fX5AKb/RbNES+fspY3p8v1lsLT9Pu
	jPQ9HChYuxtUnPS+/oLjCPhSfG2YoZApNHEeZ8PZxBqGeS+O/RKkXPbIChMRVjR5giA==
X-Received: by 2002:a65:5c8c:: with SMTP id a12mr10800992pgt.255.1561151805813;
        Fri, 21 Jun 2019 14:16:45 -0700 (PDT)
X-Received: by 2002:a65:5c8c:: with SMTP id a12mr10800912pgt.255.1561151804428;
        Fri, 21 Jun 2019 14:16:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561151804; cv=none;
        d=google.com; s=arc-20160816;
        b=HGx/x+8ImBgA1GwZ/z0Cu1uljOGujj094ItQJRoiXhNVW1ExlS19/901IT26GKlT09
         8+Sye2F+IPAQERMiwlJZZ0wInBc4YaRfPC/Y7/Y+nIHKy5PpxUgISE4kvq3ccLjYoaPp
         2twM8J88RSVb1vqBxMYeZsHKUi0Z188GEVT1XMT9mRyZ+RFvHGX3oBK+EVbYtay5UYew
         gNb7u+8n82OWUkoIjJMS9VliyZr5LnZyS8KwolvTL5Y0LOE3+uP/bAnesAmBqXwvATts
         LWnwV4S9SSF5wqhAoiKTk4cpLr3AJIths10ptJlpJ6ifjUWdpN7rkehoD9ZTLLW+vFNT
         KBBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=ee7dIZ6uP6QXNcDhtf383EXh+QJWWk7ZjpJlf1hao0g=;
        b=as0cFZhYtWN9BdM2jNBoCmOLlVGQE7EPYDOOfMiF1SdiRi71qdPquOm8GzM09+OnWB
         v8Clp3NcSnXlgujsMC6I30VH6G+W2Y1qDV+Odt4bxVGDttFeNolDp2D62BaXWHDxCdM9
         UpMVktzz+qVOuMMaFtao/b5unmcJhNnA+gdtBBbRwMbRY63xBKh/ABUQcZckvN53qYTk
         eK27UT1CzqwoIoOvPtT/B9k28oOR5hT2NKGRtMDSQPlPveiHSez3lPCIcJPeXhjBq0aH
         10Y4sjv4cdtM2OAPz5M6at58zJwArYk5Rk9pvnlQEZz0S4q4H7RYcJ11ntWAW4xPnRvV
         U5cQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="qkN/qi8K";
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l7sor2558858pgm.25.2019.06.21.14.16.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 14:16:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="qkN/qi8K";
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=ee7dIZ6uP6QXNcDhtf383EXh+QJWWk7ZjpJlf1hao0g=;
        b=qkN/qi8Kbd8EBvRSeNglafT8WHdsT6KSGK8BbqDwGMfz8caRBQQJWkq7B/DdSQKES3
         vrMUhIY+/V39FxHSDpMgxmgiAbGANCFFyenU+/X3g5PJRqQ/1LYFMfxwEjJ+X+hhr0s9
         OI11/dhh5KjSFQWy+fxuVJv/rxRXBgDS/O3y3B0QzbPR4CD5rM5BjFxUdJlAYCIPX2uz
         cwBj9+6GZ4hAkzdUQqeW3kX1OAgEmwXQZQaZu7xWbPQokIRnaz9ImxOIOAs4MA84phqS
         hnL+9EBdZ55OrbqRLSJahRb3g/mKJsfX6wNPr4lYLuzlmF0Izj0mJyGzP8AxjbWq23tU
         YqQA==
X-Google-Smtp-Source: APXvYqzImg3CJgpFdQNkZkifeLhRrlBNhd3lJLtmXTamXKF6i/FQMziQdLYRjCbUgP1OER/BKZtqhA==
X-Received: by 2002:a63:ed06:: with SMTP id d6mr20481370pgi.267.1561151803708;
        Fri, 21 Jun 2019 14:16:43 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id w14sm3691529pfn.47.2019.06.21.14.16.42
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 21 Jun 2019 14:16:42 -0700 (PDT)
Date: Fri, 21 Jun 2019 14:16:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Andrea Arcangeli <aarcange@redhat.com>
cc: Michal Hocko <mhocko@kernel.org>, 
    Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, 
    Vlastimil Babka <vbabka@suse.cz>, Zi Yan <zi.yan@cs.rutgers.edu>, 
    Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, 
    "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] Revert "mm, thp: restore node-local hugepage
 allocations"
In-Reply-To: <alpine.DEB.2.21.1906061451001.121338@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.21.1906211415050.77141@chino.kir.corp.google.com>
References: <20190503223146.2312-1-aarcange@redhat.com> <20190503223146.2312-3-aarcange@redhat.com> <alpine.DEB.2.21.1905151304190.203145@chino.kir.corp.google.com> <20190520153621.GL18914@techsingularity.net> <alpine.DEB.2.21.1905201018480.96074@chino.kir.corp.google.com>
 <20190523175737.2fb5b997df85b5d117092b5b@linux-foundation.org> <alpine.DEB.2.21.1905281907060.86034@chino.kir.corp.google.com> <20190531092236.GM6896@dhcp22.suse.cz> <alpine.DEB.2.21.1905311430120.92278@chino.kir.corp.google.com> <20190605093257.GC15685@dhcp22.suse.cz>
 <alpine.DEB.2.21.1906061451001.121338@chino.kir.corp.google.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 6 Jun 2019, David Rientjes wrote:

> The idea that I had was snipped from this, however, and it would be nice 
> to get some feedback on it: I've suggested that direct reclaim for the 
> purposes of hugepage allocation on the local node is never worthwhile 
> unless and until memory compaction can both capture that page to use (not 
> rely on the freeing scanner to find it) and that migration of a number of 
> pages would eventually result in the ability to free a pageblock.
> 
> I'm hoping that we can all agree to that because otherwise it leads us 
> down a bad road if reclaim is doing pointless work (freeing scanner can't 
> find it or it gets allocated again before it can find it) or compaction 
> can't make progress as a result of it (even though we can migrate, it 
> still won't free a pageblock).
> 
> In the interim, I think we should suppress direct reclaim entirely for 
> thp allocations, regardless of enabled=always or MADV_HUGEPAGE because it 
> cannot be proven that the reclaim work is beneficial and I believe it 
> results in the swap storms that are being reported.
> 
> Any disagreements so far?
> 
> Furthermore, if we can agree to that, memory compaction when allocating a 
> transparent hugepage fails for different reasons, one of which is because 
> we fail watermark checks because we lack migration targets.  This is 
> normally what leads to direct reclaim.  Compaction is *supposed* to return 
> COMPACT_SKIPPED for this but that's overloaded as well: it happens when we 
> fail extfrag_threshold checks and wheng gfp flags doesn't allow it.  The 
> former matters for thp.
> 
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
>  - if watermarks fail, a follow up allocation of the pte will likely also
>    fail, so thp retries the allocation with a cleared  __GFP_THISNODE.
> 
> This doesn't sound very invasive and I'll code it up if it will be tested.
> 

Following up on this since there has been no activity in a week, I am 
happy to prototype this.  Andrea, would you be able to test a patch once 
it is ready for you to try?

