Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A1AFC0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 14:37:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C334218A3
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 14:37:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C334218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D010B8E0001; Wed,  3 Jul 2019 10:37:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8A4A6B0007; Wed,  3 Jul 2019 10:37:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B79DA8E0001; Wed,  3 Jul 2019 10:37:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 693CD6B0005
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 10:37:05 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m23so1848731edr.7
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 07:37:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OeAMTyj0tj5DyhQCkmjlDnvMQJ8pA45Ng3YyjVr7r2o=;
        b=bBm26eZLdq7AbdwVEuRincl/24JnryvkY4nbjtic4NMicFtkwHTAngOjHMNw7Qj9RJ
         wRAb2O8kh3AteyH3phijBI9b/bCGWnjC1NEbCH+BaVpjbRKpn9DzFDHJg8rG4uqoHUUJ
         szueazzJQeD0NGBThN2jE40PyR2UdpOUvpscZo1O1b3gZ/O7dWMJP/ErO9Wphq+YzBEY
         8qNSvcs2m0mESaMHW5HOYbHYnoInLzjbwfWO0P3kO5u7QLo+UhIA8iWJnnhbPTHynF26
         2s+nJKRRcVhkpKg2YZ5Xp5h+ok2e0a/bs1gxz5ObYWnMVxW0UcIFKNUIxd4eG+TeXPnk
         zSlw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVIUPpg/TG9YXjouyhzS9lwnWoCJ7Z+I9RH9UHn0/KwZBIB0Ap0
	0vUCr6i4eLnCqkjpICcHLnKe6IVJIMjizRkzHVysoG4c3Lo1BuA1Xghq5DAaTkV9dZLKO6wYrZr
	UuPLiCxKaN9UOtDroWs7wkBHLtn+0s3X6xUPiYZToT6Akg1mk37A8KvwkRyawFDc=
X-Received: by 2002:a17:906:9256:: with SMTP id c22mr34466742ejx.172.1562164624989;
        Wed, 03 Jul 2019 07:37:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPOtciRcCvmLoH78fAanCjTaSfYIBnRNLmR24nudOP9pyNJHAmpM/Ue77wSfEWYEEhjfDN
X-Received: by 2002:a17:906:9256:: with SMTP id c22mr34466685ejx.172.1562164624249;
        Wed, 03 Jul 2019 07:37:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562164624; cv=none;
        d=google.com; s=arc-20160816;
        b=1HSSkoMF7uyPL631C21KMmrzsajCu6W6pniFPJvhZ5I4BTvl8H4KH2AXoxPKWt++C5
         3smaVvXJegmwCdJojowSRQsYMmec0NX9onrDISKilhTaF28juS/q+eO0SRRjibMZb6wd
         IJphqCWLpiMWG6blNx0MiVIS3BMTuHS22qPJuxHsxWEC2yt32w2rtKdD30qMdv969Lc3
         EVYG8kJAkiwVxVrCvGl/LMbTWycquV2yxFPZHOCfOYGyq7A0F/FPjWubYuwWw2O7hdHg
         +bOT/ik4f8qOLTZwrrPetYxd40VeeQlIbGAIj+feQaDaixSEvQ/QqSbt1e8I7wxgFmhr
         Ekkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OeAMTyj0tj5DyhQCkmjlDnvMQJ8pA45Ng3YyjVr7r2o=;
        b=MSp+yqg7jxwH7INlZQqCPQl6PRsHoaMjqUAcQDz9IW/5IU8UW+hSIGDVUOP12HBP/O
         aEFFb4fgtkBapm1zDJYTNbXthj91zSiSg73GXszHHyHsJL5OyTQbxZyl2iNZXNK27UTt
         FJMxNA6BnG3ECSEf9s0tD6g3/OglERROqt4RSGP+K/sI7OAl94NjpM1VSju0ol+iFPsE
         Ko2ZhT867DfADSQlHlUYG0SYvZL4atAf2UJjRO3z83LXBG8h/YY3vxzLSh6LsfRc+WSJ
         t602X2wXVo088LeEBw4wVioMb0x+TvSq5/TNefWPSCdjNahEcB0d0W1xMz1Vb8dh4KCp
         8beQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gh2si1693579ejb.254.2019.07.03.07.37.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 07:37:04 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 11175AF60;
	Wed,  3 Jul 2019 14:37:03 +0000 (UTC)
Date: Wed, 3 Jul 2019 16:37:01 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm, slab: Extend slab/shrink to shrink all the memcg
 caches
Message-ID: <20190703143701.GR978@dhcp22.suse.cz>
References: <20190702183730.14461-1-longman@redhat.com>
 <20190703065628.GK978@dhcp22.suse.cz>
 <9ade5859-b937-c1ac-9881-2289d734441d@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9ade5859-b937-c1ac-9881-2289d734441d@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 03-07-19 09:12:13, Waiman Long wrote:
> On 7/3/19 2:56 AM, Michal Hocko wrote:
> > On Tue 02-07-19 14:37:30, Waiman Long wrote:
> >> Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
> >> file to shrink the slab by flushing all the per-cpu slabs and free
> >> slabs in partial lists. This applies only to the root caches, though.
> >>
> >> Extends this capability by shrinking all the child memcg caches and
> >> the root cache when a value of '2' is written to the shrink sysfs file.
> > Why do we need a new value for this functionality? I would tend to think
> > that skipping memcg caches is a bug/incomplete implementation. Or is it
> > a deliberate decision to cover root caches only?
> 
> It is just that I don't want to change the existing behavior of the
> current code. It will definitely take longer to shrink both the root
> cache and the memcg caches.

Does that matter? To whom and why? I do not expect this interface to be
used heavily.

> If we all agree that the only sensible
> operation is to shrink root cache and the memcg caches together. I am
> fine just adding memcg shrink without changing the sysfs interface
> definition and be done with it.

The existing documentation is really modest on the actual semantic:
Description:
                The shrink file is written when memory should be reclaimed from
                a cache.  Empty partial slabs are freed and the partial list is
                sorted so the slabs with the fewest available objects are used
                first.

which to me sounds like all slabs are free and nobody should be really
thinking of memcgs. This is simply drop_caches kinda thing. We surely do
not want to drop caches only for the root memcg for /proc/sys/vm/drop_caches
right?

-- 
Michal Hocko
SUSE Labs

