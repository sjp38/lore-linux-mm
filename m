Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F045C282DE
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 09:33:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3F8C2075B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 09:33:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3F8C2075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E78A6B000E; Wed,  5 Jun 2019 05:33:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8973F6B0010; Wed,  5 Jun 2019 05:33:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 760666B0266; Wed,  5 Jun 2019 05:33:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2AC5F6B000E
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 05:33:00 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r5so4816368edd.21
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 02:33:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=CN6NmX86IEzRdIctTNb85wMGuz/D32d5MdlpwXh7LF8=;
        b=LH5F+DfQ7CVIbpQmsYH52G5Q63O1+U+YERmJ66MXVxGxlfGaA0aw1+PqDZjsYmO83c
         3lBx+cIPF/lNVvbLCO+ckNGrz9zH0hVT7pwVSA3zJkNvx72PLZuJd60RPkXblyWWCfgH
         qjVvsAZbuMEqDVpKJOEG7eBkeGor8AXs1vz/6CghhhVpNBV3gC2kTqCAEM8cJuFkheD4
         sBmhhrRYz2rnXaxbHHoxuYIHzghMPIuphsTG5Q2Owi9tccM2IKFOuHFX2sMk7u0U4jcn
         hTWMV2aQi/HOb9BNgABytz9rCdqyw1K8TalbWS5t1RxLLGwQqAbNXtYjeK9SWGR1uzeS
         xM4Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX2DkbA/kfsqqbFOE13EzH3igAtz62tLfYP4Bsux4ioPFgGL6oa
	8Ob1Gi9hR8N3nrhBdNtXTyrSZ/PXHDclReWTSLj/g0X96GIIZ5eE6Ik6VhCB89JIhJI1yu6Ht8j
	m6PRdslzgQX+H4pCHqcGOvzgupCBcW7Lis5f/pxnS8fyUA9HFK0whnm71qJHNSLk=
X-Received: by 2002:a50:cdd0:: with SMTP id h16mr41528830edj.249.1559727179258;
        Wed, 05 Jun 2019 02:32:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIGl/vluyb1WCBNd+BJ6uTqqM3BUZxmfr5wjyDn5Tul1wvPKYyaKvQEnyuG/3Kniu6J2Jo
X-Received: by 2002:a50:cdd0:: with SMTP id h16mr41528770edj.249.1559727178471;
        Wed, 05 Jun 2019 02:32:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559727178; cv=none;
        d=google.com; s=arc-20160816;
        b=YYFyc0lSpNHCqVrbtinCfaBuKdolLgRdSn0hzbXULG3sc5PsOrV9PPWwA/LpP5PBa2
         HotG9fY7vAUB7idZPzbGPpKuJx29qYhNhXuQv8LVFVCVJNaqcZm/DvpZCK6BD8ubjOv+
         /ZU/XmmLw6CH+ydI1gUtTHlNDj/KGBRiS11ssjlakIvrhkzqVe/QXdIO4DggOg2lmVmT
         nNv2+CbJOHynAuuRxPMItQpCcjr0otf724gFqq6FXar8JYxl7Mc5U9W353o+EudCtA5E
         okpstfI6j2qnbOlJm/oAPleeFj3ZozTwoXanl+Lq38pxuxC40Dk8fb1j2ZrLdgt3geF0
         0Wgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=CN6NmX86IEzRdIctTNb85wMGuz/D32d5MdlpwXh7LF8=;
        b=QTu4wMtJcCyetEmZzqEvsPt7FAI34hcExvWxJ1Q5/eu89Ccsq89+FJjsIFPuQqUwDO
         agLoPk/P+FXTQaD7ZS4KodBF9J6xu4uJi7251p6qFEXdAu4OgBodX0RuZHA/wbCwwJN8
         8vUv9fO0MuOS+7iw8eMcpnGAr9KLCOGvJ9KZpnQBY9XohLnN/bGJo5iTPbLENA6flOjp
         6WhpuV/8jdZb/ZjD+vhyEYpctREvi+W495sarSyj2T3i8HoTrcSpwkiUqmDvR/krlBUg
         UKzyzm7Z1Vsbm1dFRRN7brQO/2HfH99mvEDQnnWdXhF8UrsMpvjmaz2h3cwSnps59bic
         LWYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b26si14461966edw.334.2019.06.05.02.32.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 02:32:58 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E493CAEA3;
	Wed,  5 Jun 2019 09:32:57 +0000 (UTC)
Date: Wed, 5 Jun 2019 11:32:57 +0200
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
Message-ID: <20190605093257.GC15685@dhcp22.suse.cz>
References: <20190503223146.2312-1-aarcange@redhat.com>
 <20190503223146.2312-3-aarcange@redhat.com>
 <alpine.DEB.2.21.1905151304190.203145@chino.kir.corp.google.com>
 <20190520153621.GL18914@techsingularity.net>
 <alpine.DEB.2.21.1905201018480.96074@chino.kir.corp.google.com>
 <20190523175737.2fb5b997df85b5d117092b5b@linux-foundation.org>
 <alpine.DEB.2.21.1905281907060.86034@chino.kir.corp.google.com>
 <20190531092236.GM6896@dhcp22.suse.cz>
 <alpine.DEB.2.21.1905311430120.92278@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1905311430120.92278@chino.kir.corp.google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 31-05-19 14:53:35, David Rientjes wrote:
> On Fri, 31 May 2019, Michal Hocko wrote:
> 
> > > The problem which this patch addresses has apparently gone unreported for 
> > > 4+ years since
> > 
> > Can we finaly stop considering the time and focus on the what is the
> > most reasonable behavior in general case please? Conserving mistakes
> > based on an argument that we have them for many years is just not
> > productive. It is very well possible that workloads that suffer from
> > this simply run on older distribution kernels which are moving towards
> > newer kernels very slowly.
> > 
> 
> That's fine, but we also must be mindful of users who have used 
> MADV_HUGEPAGE over the past four years based on its hard-coded behavior 
> that would now regress as a result.

Absolutely, I am all for helping those usecases. First of all we need to
understand what those usecases are though. So far we have only seen very
vague claims about artificial worst case examples when a remote access
dominates the overall cost but that doesn't seem to be the case in real
life in my experience (e.g. numa balancing will correct things or the
over aggressive node reclaim tends to cause problems elsewhere etc.).

That being said I am pretty sure that a new memory policy as proposed
previously that would allow for a node reclaim behavior is a way for
those very specific workloads that absolutely benefit from a local
access. There are however real life usecases that benefit from THP even
on remote nodes as explained by Andrea (most notable kvm) and the only
way those can express their needs is the madvise flag. Not to mention
that the default node reclaim behavior might cause excessive reclaim
as demonstrate by Mel and Anrea and that is certainly not desirable in
itself.

[...]
> > > My goal is to reach a solution that does not cause anybody to incur 
> > > performance penalties as a result of it.
> > 
> > That is certainly appreciated and I can offer my help there as well. But
> > I believe we should start with a code base that cannot generate a
> > swapping storm by a trivial code as demonstrated by Mel. A general idea
> > on how to approve the situation has been already outlined for a default
> > case and a new memory policy has been mentioned as well but we need
> > something to start with and neither of the two is compatible with the
> > __GFP_THISNODE behavior.
> > 
> 
> Thus far, I haven't seen anybody engage in discussion on how to address 
> the issue other than proposed reverts that readily acknowledge they cause 
> other users to regress.  If all nodes are fragmented, the swap storms that 
> are currently reported for the local node would be made worse by the 
> revert -- if remote hugepages cannot be faulted quickly then it's only 
> compounded the problem.

Andrea has outline the strategy to go IIRC. There also has been a
general agreement that we shouldn't be over eager to fall back to remote
nodes if the base page size allocation could be satisfied from a local node.
-- 
Michal Hocko
SUSE Labs

