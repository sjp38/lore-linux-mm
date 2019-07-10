Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DE6EC73C7C
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 10:48:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA8AF2064A
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 10:48:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DD7J5KVi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA8AF2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55E8F8E006E; Wed, 10 Jul 2019 06:48:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 510CE8E0032; Wed, 10 Jul 2019 06:48:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FEE78E006E; Wed, 10 Jul 2019 06:48:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 08FCE8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 06:48:20 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 191so1116628pfy.20
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 03:48:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=SVbHqdqp8YOEjHzGDlrAyL6DJKyDMTvzdc6bOUeWR1I=;
        b=e5AHI9egLyvuDYGSltaJfMffWgfPRgFG8jiVlumlmydMsC8VuNFs42mh9rqkdRkGeq
         EH94nKvuhnciWzgY1TInU+1jPMvvIAuPsnWvSHBxv946AC5DPNS3OJ8s6IYbKgl8axUl
         ltlXf6bcj+g1V5MRqd6QycO6dxY9+clnpIk8Axrtj6kFPXMp2bMDGIU/KEdQJWYv9lIw
         Zs2D+6Gxlwu93Kwa+PXYKhfvceI06XTBrw1GLwgUx2CsO+uX216OO/CjUGS9XJwGyh0o
         NKI296yxrILVWXQxkOpcQec3GNYICrm6bDjAdHLnJPt6mDsOsFasDqPB/b3Jxgk/TXV0
         Yipw==
X-Gm-Message-State: APjAAAV5Jo8ZeWhyr/JfsqJwt8kS5PELyB0RdjXKpsIgFAhxfQ+/K9Jd
	n8kb9JIZ4sx8XfEf8NsTFELg6N9LsWQqgjuUmiaEM4Ypkb7mbQPPG5JEtoE/zCCcZfJiH0vRS1z
	EzvnwJsj4iKWD5WMO2TkMJ83CclFI8mLY5D3FqkvG8l2jSTW8NDsxMylZDSOCI3w=
X-Received: by 2002:a17:90a:8d09:: with SMTP id c9mr6256270pjo.131.1562755699531;
        Wed, 10 Jul 2019 03:48:19 -0700 (PDT)
X-Received: by 2002:a17:90a:8d09:: with SMTP id c9mr6256205pjo.131.1562755698729;
        Wed, 10 Jul 2019 03:48:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562755698; cv=none;
        d=google.com; s=arc-20160816;
        b=DUBImhMe3jmxQsWP7ddJQkh4Bjb2iiRtalfCTPWgM5LgGr8BPGXvnG+Cs3yMTpxxC0
         og+Ln3DSnsZVo9/QcMIszuxQxoDogo9CzCjg0+a+YdEwTBSVjt4Dn3sBoxtCAbqqTwH7
         vvJYQm/k80v1kQv/Qw75/FYHHXyNm02UkeVwiXcgDQJF3HCuaUeghtiYJ5w3gRoOVH+8
         68aPaXMs/dt/ymEc131nXqf4OD1ANpa7ifd3wCL/l5S/HeVhbY9t93ETdivaArM1gqtV
         cnS5SeTu0FjDa7Ye2PzpscxQN8QkvhUdaxz7Kd+q6zX9AIA3LI9bkPij8i2d3KZvyJit
         u2gA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=SVbHqdqp8YOEjHzGDlrAyL6DJKyDMTvzdc6bOUeWR1I=;
        b=A+OU/3f1ehx5rcIJ4KO5KA2uHpumG1/rKGyqnDFjS5EBilDyyGaApozOgCCJ8i+8jD
         q5/MkfcVo4+Oim90BM1WxLs4A2PN9DfqQ1g7T9Gw7vpS/CFn3f8hK7rP6ZmWRAJarpgI
         sYuNsWIMBsRR7gwIT92nz86w0ZD6PuTZjwHmTCISWBSBKboxfSwL/+5Vh7hTSXle/yfD
         M6JzjnBNtKs7wO9RXpGrXeIdPL1xvMgmBgCe+CDpaQ2L2TmngnvozDkjV+90rSFsAbhh
         s2utQo4BFKfoJYMdOcO3j89etxaIfPgJNL4+nbdBh2ztZ5++MM52N1sLjwjy9JtQPI8a
         TvFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DD7J5KVi;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1sor2127878plt.64.2019.07.10.03.48.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 03:48:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DD7J5KVi;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=SVbHqdqp8YOEjHzGDlrAyL6DJKyDMTvzdc6bOUeWR1I=;
        b=DD7J5KViJCMsZS754qIX6Y4jUrX0fWg/3IHZql0k5fRn26Pk0TShCitXRx7OTTseDY
         6v3lMMHATfhEJ3tiNCmpVNgPQ9kaPGY7EJsmhtkxPsqM64T02mvWG4PsHdCOQYJbz9ux
         eawlllSZ9RTrEvcD586DFY7lQs3yNlPtKpDmNyqNYspV05+EF1r2SnXxWA5KYG4s8oHd
         MUiWMcdjZYD3DoBxH2u4MxdefIL/a2JpZmK6Q3i57t/yGIXAIfs/0/MhnxTtvzV8ZGuA
         ndWAIgY4RLJO9XTIrPapP37/aV5PqRocILYKPeBhv2l5fEbxLR7CuF/KjYxb4Vy9+aAT
         nmPg==
X-Google-Smtp-Source: APXvYqyUjXTFy7JIc4o6O8Fp/ORN4uEPxjM/KP3u/BWYZDGiSMFzR6sgSRyiktvoDcFkwIiWFQwugg==
X-Received: by 2002:a17:902:da4:: with SMTP id 33mr35095869plv.209.1562755698240;
        Wed, 10 Jul 2019 03:48:18 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id p1sm2002534pff.74.2019.07.10.03.48.12
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 10 Jul 2019 03:48:16 -0700 (PDT)
Date: Wed, 10 Jul 2019 19:48:09 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
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
Message-ID: <20190710104809.GA186559@google.com>
References: <20190627115405.255259-1-minchan@kernel.org>
 <20190627115405.255259-5-minchan@kernel.org>
 <20190709095518.GF26380@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190709095518.GF26380@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 09, 2019 at 11:55:19AM +0200, Michal Hocko wrote:
> On Thu 27-06-19 20:54:04, Minchan Kim wrote:
> > When a process expects no accesses to a certain memory range
> > for a long time, it could hint kernel that the pages can be
> > reclaimed instantly but data should be preserved for future use.
> > This could reduce workingset eviction so it ends up increasing
> > performance.
> > 
> > This patch introduces the new MADV_PAGEOUT hint to madvise(2)
> > syscall. MADV_PAGEOUT can be used by a process to mark a memory
> > range as not expected to be used for a long time so that kernel
> > reclaims *any LRU* pages instantly. The hint can help kernel in
> > deciding which pages to evict proactively.
> > 
> > - man-page material
> > 
> > MADV_PAGEOUT (since Linux x.x)
> > 
> > Do not expect access in the near future so pages in the specified
> > regions could be reclaimed instantly regardless of memory pressure.
> > Thus, access in the range after successful operation could cause
> > major page fault but never lose the up-to-date contents unlike
> > MADV_DONTNEED.
> 
> > It works for only private anonymous mappings and
> > non-anonymous mappings that belong to files that the calling process
> > could successfully open for writing; otherwise, it could be used for
> > sidechannel attack.
> 
> I would rephrase this way:
> "
> Pages belonging to a shared mapping are only processed if a write access
> is allowed for the calling process.
> "
> 
> I wouldn't really mention side channel attacks for a man page. You can
> mention can_do_mincore check and the side channel prevention in the
> changelog that is not aimed for the man page.

Agree. I will rephrase with one you suggested.
Thanks for the suggestion.

> 
> > MADV_PAGEOUT cannot be applied to locked pages, Huge TLB pages, or
> > VM_PFNMAP pages.
> > 
> > * v2
> >  * add comment about SWAP_CLUSTER_MAX - mhocko
> >  * add permission check to prevent sidechannel attack - mhocko
> >  * add man page stuff - dave
> > 
> > * v1
> >  * change pte to old and rely on the other's reference - hannes
> >  * remove page_mapcount to check shared page - mhocko
> > 
> > * RFC v2
> >  * make reclaim_pages simple via factoring out isolate logic - hannes
> > 
> > * RFCv1
> >  * rename from MADV_COLD to MADV_PAGEOUT - hannes
> >  * bail out if process is being killed - Hillf
> >  * fix reclaim_pages bugs - Hillf
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> 
> 
> I am still not convinced about the SWAP_CLUSTER_MAX batching and the
> udnerlying OOM argument. Is one pmd worth of pages really an OOM risk?
> Sure you can have many invocations in parallel and that would add on
> but the same might happen with SWAP_CLUSTER_MAX. So I would just remove
> the batching for now and think of it only if we really see this being a
> problem for real. Unless you feel really strong about this, of course.

I don't have the number to support SWAP_CLUSTER_MAX batching for hinting
operations. However, I wanted to be consistent with other LRU batching
logic so that it could affect altogether if someone try to increase
SWAP_CLUSTER_MAX which is more efficienty for batching operation, later.
(AFAIK, someone tried it a few years ago but rollback soon, I couldn't
rebemeber what was the reason at that time, anyway).

> 
> Anyway the patch looks ok to me otherwise.
> 
> Acked-by: Michal Hocko <mhocko@suse.co>

Thanks!

