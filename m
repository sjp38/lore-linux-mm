Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C477EC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:55:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D7F320C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 10:55:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="blv8rluI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D7F320C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71B026B0003; Tue,  6 Aug 2019 06:55:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CAB16B0008; Tue,  6 Aug 2019 06:55:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56C326B000A; Tue,  6 Aug 2019 06:55:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 204E46B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 06:55:17 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id z1so55589365pfb.7
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 03:55:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=oa5z6zUvCHcd7r910UMaS4iQDg5URkCU1Ylsu0mgnns=;
        b=pO4w0KhVnNROnit0Pmn+r5yNXqx29f5BmLU28Q/ZILHRYSKsAKDvkrqkXfBvLppch9
         +NbkUpOIrrtiItoINUWYYz/fUTgifjrKWTW/kBoqtseQVQs+mRnnqWDMlrf+f1BLUXwg
         pixCtjOkfHNf0U3BgauDBdB9ifldGYJ4thnjABDSvY8VUve6W0slWYBGxVRtbinajrk1
         050pQA6ENT5wqJ0fztm2JMa84be523ttpFCp/aXeP+G/Kkt0rovtP0GQ8/+ajduE7uhX
         bqhGU38ku6fOmjJNQfcFcKe8MTLdr/2Pka6OGC8JHZztfr+EjQGiA/En48stMecuHxsX
         l4bQ==
X-Gm-Message-State: APjAAAX+167ebPWHQaUr3qbOsSMVGhZHXVXkTkPlSwhoq6RhN3CRAS0T
	5pKomIXyCUSNpMQxd8zaxBhDGgkMbaZwVNbtJwZpbjW41E+HSmG9aQL9aPAk6R1a+pTIB1XUOo9
	YUWv1A1BWdLzPmfWzPK7cRJi95tH3Pc6htE22ghgi4j+oKQa6xWyNAm3/tOtX6WA=
X-Received: by 2002:a17:90a:b115:: with SMTP id z21mr2561811pjq.64.1565088916794;
        Tue, 06 Aug 2019 03:55:16 -0700 (PDT)
X-Received: by 2002:a17:90a:b115:: with SMTP id z21mr2561753pjq.64.1565088916080;
        Tue, 06 Aug 2019 03:55:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565088916; cv=none;
        d=google.com; s=arc-20160816;
        b=e0fj0dcpAWOLhxRQPCjURApozYALCr60r1n5YpHEKE/PB8PvjCLBpYSYfjL12Tm3bQ
         NDfCgIr4o2Y0MbvUmVm5LCiloJpQFzrdARCCgg8nmaH15kHdw3NshyN55nAjxETIqJ89
         RMyLi5lJhcSoVYIYxqi8QEln4RXTNKHdhsvDzL7O5EgI5cRNbOvbmpo/YJYGBrjuk/FU
         +72/mmnCkEU1c6vjTCUjJZGZywmG+237M846e3RUYPlorHZ0mCuLkUc3jyB8SrR7m6UD
         0kDnu6uk75NtpZJwGw8WK/N+J7hhsy1pc5o0mlRZ+3jLgpNP9KI/1a2hzDWSRN1IsWH5
         UrDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=oa5z6zUvCHcd7r910UMaS4iQDg5URkCU1Ylsu0mgnns=;
        b=y50pwQau0bKVQVIUyU+I6mQjGJhVQ8Rna79DIdS6PiqWIW6ByWQ+DQWpNsgAX5VBbd
         V1eyZqTYtlhhivvZlbrNr51oHXYAfxDeL1PpKFa17SdAGd0x9o6dV+xYJb95285QlMCB
         xvRuk4+gqOk+X+Au6skVsDDHVwQLC9Xebum17SFuiRqxZUmtqza7QYbmHs90GvCiJnC2
         ZiqN9T0Mw2r5y9JU1JctdBlJun6M8QmzaRhGVLP8JTt2vwVJDV+bUymCS9nDSBKlNrWw
         DllPn96dENZBkn/Nlhz0J1l7ojAmrG2EfXGQcjHUNjAt9XSVzrH4ZQsZqE+HpaPgGIuH
         rD4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=blv8rluI;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q1sor68019256pfb.34.2019.08.06.03.55.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 03:55:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=blv8rluI;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=oa5z6zUvCHcd7r910UMaS4iQDg5URkCU1Ylsu0mgnns=;
        b=blv8rluI18O6mziiEb2dE4tZgdd+rRx2neLdiacDFpSj6cKi/JVgKIEpfl3XbLdHZ3
         z2Z4xTX0KMsT6r+sQv4cwLvWDRXLPdJ7HxEFdqDAS69w2UjEgYqX1O54hmoPijaPpOlg
         4fPbhHpn0CBaDJeekIvtg6hyw+Fh7fyBune0pzfEetyOLl1L+SOwPdqGNQv6/CUArNrn
         Ahtddt682EsIVhH5tqFu7VRgj+wmbX61q9Xj6PqIbMeCkJ/7w+UXuorVaVkKZ7n3e/eB
         3re38XoitkuxZjIsHBlY2sfzc9MyeITx+MK0hNdTz/4P3hwVyHQxTtogGSezk/+NYOuJ
         T6IA==
X-Google-Smtp-Source: APXvYqyQN7R6BSpr072n52qskPQBVMmzd3IQWnQI+qk4MMW2i6gA9H2POAcCLk9dZyoMIglmWEsqWg==
X-Received: by 2002:a62:5c3:: with SMTP id 186mr3056758pff.144.1565088915615;
        Tue, 06 Aug 2019 03:55:15 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id z24sm15294361pga.2.2019.08.06.03.55.11
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 03:55:14 -0700 (PDT)
Date: Tue, 6 Aug 2019 19:55:09 +0900
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Miguel de Dios <migueldedios@google.com>, Wei Wang <wvw@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH] mm: release the spinlock on zap_pte_range
Message-ID: <20190806105509.GA94582@google.com>
References: <20190729071037.241581-1-minchan@kernel.org>
 <20190729074523.GC9330@dhcp22.suse.cz>
 <20190729082052.GA258885@google.com>
 <20190729083515.GD9330@dhcp22.suse.cz>
 <20190730121110.GA184615@google.com>
 <20190730123237.GR9330@dhcp22.suse.cz>
 <20190730123935.GB184615@google.com>
 <20190730125751.GS9330@dhcp22.suse.cz>
 <20190731054447.GB155569@google.com>
 <20190731072101.GX9330@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731072101.GX9330@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 09:21:01AM +0200, Michal Hocko wrote:
> On Wed 31-07-19 14:44:47, Minchan Kim wrote:
> > On Tue, Jul 30, 2019 at 02:57:51PM +0200, Michal Hocko wrote:
> > > [Cc Nick - the email thread starts http://lkml.kernel.org/r/20190729071037.241581-1-minchan@kernel.org
> > >  A very brief summary is that mark_page_accessed seems to be quite
> > >  expensive and the question is whether we still need it and why
> > >  SetPageReferenced cannot be used instead. More below.]
> > > 
> > > On Tue 30-07-19 21:39:35, Minchan Kim wrote:
> [...]
> > > > commit bf3f3bc5e73
> > > > Author: Nick Piggin <npiggin@suse.de>
> > > > Date:   Tue Jan 6 14:38:55 2009 -0800
> > > > 
> > > >     mm: don't mark_page_accessed in fault path
> > > > 
> > > >     Doing a mark_page_accessed at fault-time, then doing SetPageReferenced at
> > > >     unmap-time if the pte is young has a number of problems.
> > > > 
> > > >     mark_page_accessed is supposed to be roughly the equivalent of a young pte
> > > >     for unmapped references. Unfortunately it doesn't come with any context:
> > > >     after being called, reclaim doesn't know who or why the page was touched.
> > > > 
> > > >     So calling mark_page_accessed not only adds extra lru or PG_referenced
> > > >     manipulations for pages that are already going to have pte_young ptes anyway,
> > > >     but it also adds these references which are difficult to work with from the
> > > >     context of vma specific references (eg. MADV_SEQUENTIAL pte_young may not
> > > >     wish to contribute to the page being referenced).
> > > > 
> > > >     Then, simply doing SetPageReferenced when zapping a pte and finding it is
> > > >     young, is not a really good solution either. SetPageReferenced does not
> > > >     correctly promote the page to the active list for example. So after removing
> > > >     mark_page_accessed from the fault path, several mmap()+touch+munmap() would
> > > >     have a very different result from several read(2) calls for example, which
> > > >     is not really desirable.
> > > 
> > > Well, I have to say that this is rather vague to me. Nick, could you be
> > > more specific about which workloads do benefit from this change? Let's
> > > say that the zapped pte is the only referenced one and then reclaim
> > > finds the page on inactive list. We would go and reclaim it. But does
> > > that matter so much? Hot pages would be referenced from multiple ptes
> > > very likely, no?
> > 
> > As Nick mentioned in the description, without mark_page_accessed in
> > zapping part, repeated mmap + touch + munmap never acticated the page
> > while several read(2) calls easily promote it.
> 
> And is this really a problem? If we refault the same page then the
> refaults detection should catch it no? In other words is the above still
> a problem these days?

I admit we have been not fair for them because read(2) syscall pages are
easily promoted regardless of zap timing unlike mmap-based pages.

However, if we remove the mark_page_accessed in the zap_pte_range, it
would make them more unfair in that read(2)-accessed pages are easily
promoted while mmap-based page should go through refault to be promoted.

I also want to remove the costly overhead from the hot path but couldn't
come up with nice solution.

