Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06CB0C606B0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 09:55:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C62782080C
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 09:55:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C62782080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 308148E0042; Tue,  9 Jul 2019 05:55:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B8598E0032; Tue,  9 Jul 2019 05:55:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 180228E0042; Tue,  9 Jul 2019 05:55:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C091A8E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 05:55:22 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w25so8692505edu.11
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 02:55:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UF2r6dihKr1kwqBBvKOig52pI5bPRMFr3RykymM0QwE=;
        b=jH+zDpm2xJJgt2eZxa+fOoIRfkfLeLfOg8kvjfeAGnG5G9TKOe8zk0wualOZ7jkEP3
         ETvc1W5rZaoUnCN+NnSN/oyG0rOm2wu3bJqSmHamEdMZa6tpCnTJ+J1LgsRb0dD2Ko45
         Sgmd7i0sTqTx66+yNdd2TilbKg7lfRHRWbpGPNNM2qOUl0VPj3gvfJwe38VYGt5kV6NL
         TLZ6LFXCP0N5eP/wEHSD88FZw9MAoUEjSXf663cOeapZ9VDQZ1ILwqRlTTLvl6AreVyn
         Kn6SlMyalU+QBEC9tgjS42nCo6kyk6MAzYfSei9GoT82p4ocoOUel6KTNeKA66JMMcqb
         WZ6w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWhj//ghcAEwkxkMgF2LDk7RctbSL9WMMs+23+x5JK44tYGlC3u
	tGQ558uCAIKL9Y9cz9OWkozT+ZBFzBCgw37Io70IVEmPT4Yvotx11iPDr99TUU3PTNZDyvAln4D
	yauJHo4SX08zgTb4GH9mWbNN8KFMRMUstDCxrg4+7hupQ5Q2pPI7IA58loMDDd+A=
X-Received: by 2002:a17:906:bcd6:: with SMTP id lw22mr20696252ejb.68.1562666122222;
        Tue, 09 Jul 2019 02:55:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw64ieSVRl4tJcmr98mZItl1SLVa8pzGrNLOcLa+ZAbH+kdISVljNLSZL2D+j0cJ0S9P1kJ
X-Received: by 2002:a17:906:bcd6:: with SMTP id lw22mr20696216ejb.68.1562666121444;
        Tue, 09 Jul 2019 02:55:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562666121; cv=none;
        d=google.com; s=arc-20160816;
        b=e5/6Sv1m2OQIR77YC6Ah6CvTIa9LWDeVHTz6cWjQfVKgI8rW6dKMP/bmNpbog3Bnkm
         8/7XXZzWVmgDwY+pw/tS2IOz58uE+KvuduLvfKrGZAn/ViFXc1U1LiXZ+pqIvppzovg/
         eDNgajq68qdNOInlbN8u1+t1Ksysq3SlgJcJvOrvZpMC4igyG+QC6NrW/XRpTKD1NmNI
         +XSf9ih1SwalAMNshg+4AgqClRf9L9p31EH2LhUvgNH8Bpbxfh8wJA1i1dbQfcjQc3vO
         7a3rnjQOmll2QKg2tylQ51vszozNADoZbMQEBRbsYTqv75Fdu9yOxGsf7G0Dl6qAB8HR
         hDrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UF2r6dihKr1kwqBBvKOig52pI5bPRMFr3RykymM0QwE=;
        b=h+UpI3t1/TZMYG1RtiWH+INgk98Jo8jggSV9QXHEAKURHWnJbId4AsA3F5/9Ul8gz3
         DqZdFnuQ/3UbmqsI++iSCvBjSIijYnNv61cbm1I16f7u5fZpIPch88Mrxh2cLfZu6o2R
         2PCVSjt/qVmv7fR5qymoAk9COUIPEgLHTLNrgfnEz8lu9MgxXsGFr/fCRj5pSN++rbWa
         9ecAsErH+FQjsPxpYympDATYZiEQZE4qS1ibn8gIyzT4cH16wftFjM7mCK3Hx5fr2boF
         m+jsCHmNBDoc2ZvCxC3qCKC14tUcP0Dm0eBasuGx0B5gRNYvwp3vdAmxkwSHjflkJNYW
         v+xQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f25si15485722ede.206.2019.07.09.02.55.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 02:55:21 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7524CAD3E;
	Tue,  9 Jul 2019 09:55:20 +0000 (UTC)
Date: Tue, 9 Jul 2019 11:55:19 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	oleksandr@redhat.com, hdanton@sina.com, lizeb@google.com,
	Dave Hansen <dave.hansen@intel.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v3 4/5] mm: introduce MADV_PAGEOUT
Message-ID: <20190709095518.GF26380@dhcp22.suse.cz>
References: <20190627115405.255259-1-minchan@kernel.org>
 <20190627115405.255259-5-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190627115405.255259-5-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 27-06-19 20:54:04, Minchan Kim wrote:
> When a process expects no accesses to a certain memory range
> for a long time, it could hint kernel that the pages can be
> reclaimed instantly but data should be preserved for future use.
> This could reduce workingset eviction so it ends up increasing
> performance.
> 
> This patch introduces the new MADV_PAGEOUT hint to madvise(2)
> syscall. MADV_PAGEOUT can be used by a process to mark a memory
> range as not expected to be used for a long time so that kernel
> reclaims *any LRU* pages instantly. The hint can help kernel in
> deciding which pages to evict proactively.
> 
> - man-page material
> 
> MADV_PAGEOUT (since Linux x.x)
> 
> Do not expect access in the near future so pages in the specified
> regions could be reclaimed instantly regardless of memory pressure.
> Thus, access in the range after successful operation could cause
> major page fault but never lose the up-to-date contents unlike
> MADV_DONTNEED.

> It works for only private anonymous mappings and
> non-anonymous mappings that belong to files that the calling process
> could successfully open for writing; otherwise, it could be used for
> sidechannel attack.

I would rephrase this way:
"
Pages belonging to a shared mapping are only processed if a write access
is allowed for the calling process.
"

I wouldn't really mention side channel attacks for a man page. You can
mention can_do_mincore check and the side channel prevention in the
changelog that is not aimed for the man page.

> MADV_PAGEOUT cannot be applied to locked pages, Huge TLB pages, or
> VM_PFNMAP pages.
> 
> * v2
>  * add comment about SWAP_CLUSTER_MAX - mhocko
>  * add permission check to prevent sidechannel attack - mhocko
>  * add man page stuff - dave
> 
> * v1
>  * change pte to old and rely on the other's reference - hannes
>  * remove page_mapcount to check shared page - mhocko
> 
> * RFC v2
>  * make reclaim_pages simple via factoring out isolate logic - hannes
> 
> * RFCv1
>  * rename from MADV_COLD to MADV_PAGEOUT - hannes
>  * bail out if process is being killed - Hillf
>  * fix reclaim_pages bugs - Hillf
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---


I am still not convinced about the SWAP_CLUSTER_MAX batching and the
udnerlying OOM argument. Is one pmd worth of pages really an OOM risk?
Sure you can have many invocations in parallel and that would add on
but the same might happen with SWAP_CLUSTER_MAX. So I would just remove
the batching for now and think of it only if we really see this being a
problem for real. Unless you feel really strong about this, of course.

Anyway the patch looks ok to me otherwise.

Acked-by: Michal Hocko <mhocko@suse.co>
-- 
Michal Hocko
SUSE Labs

