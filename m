Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABC2BC072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 22:16:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 648782075B
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 22:16:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="1U+7o4fD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 648782075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 020976B028F; Tue, 28 May 2019 18:16:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F13246B0290; Tue, 28 May 2019 18:16:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E02F36B0291; Tue, 28 May 2019 18:16:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A96AA6B028F
	for <linux-mm@kvack.org>; Tue, 28 May 2019 18:16:18 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r191so207392pgr.23
        for <linux-mm@kvack.org>; Tue, 28 May 2019 15:16:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=SLwBA8MbvD2QC0ep8E6TWiO4osZD4fu2h/9Z2V53XVU=;
        b=XJYcjSZ9CEyThGCn8+57Mee2j74K5zBaJz7DwskojG8tvRF6lBqFHG7injipXnbacB
         M2YhhavSdAFQT0BWWIOYms67dQR+4dEfV1YfIkiFmZZ5rDXxwZx8yG2jPYhFpeeS0Ubv
         kKCj1zl4ZhbrRE/qizXpM8PeLFQiKtGRKNnR4SKG92Ga5pjTjLhjpPDWOipKe8N0+MLq
         9CkPSfd1Xlg28icMIk2P7a3ZaaYrXUhaAjnpx2iEyDsip6S10doDxmOqvKPX2Bn/zdFh
         gA+r88YjWLddhHpywTl+afeyX6L9WNe5JKEGaymg3Une0e5Zqpilq0Q5s56Gaz3ynGcO
         rx2Q==
X-Gm-Message-State: APjAAAVn9wPuonTv7r5nj2a52eApItq+d2FGcawiGqUZDpXWgLfK9YN6
	7U3bavvp6ha7pcjGY9NoRpmFCZAIYl8jZSuVOx7iR7BuhLrKw7m1FySpbxXzzWLvAXiqSrMfqNU
	yHke+/xjtSYbUZwlhj3lZ1hLVuPWVaNuwgYqsStskAVqi8b+o0nSMsZg4JCmT+tloEw==
X-Received: by 2002:a62:38cc:: with SMTP id f195mr144144570pfa.15.1559081778293;
        Tue, 28 May 2019 15:16:18 -0700 (PDT)
X-Received: by 2002:a62:38cc:: with SMTP id f195mr144144518pfa.15.1559081777497;
        Tue, 28 May 2019 15:16:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559081777; cv=none;
        d=google.com; s=arc-20160816;
        b=sEGA8dYSBk1K8pid2oBRgtvUc6gODlBlJnXCVYQBBN1zynPXqEYY9aWDeg2fYeMjCU
         A8cUnCV3NTNgxjH9bjBrtsonDNt//BterUOdfviHueHcbRo1G9nQSkZ8zRaMUtwzr2Th
         csmEzfRY5rPdA9agiM4eyzbRRdfKCzun/gytp5QtTDVhYVJWhAOe/rxWwa1Z4NyZv3HU
         nCOWf50vJnuuIPi/rIch7imISB/ZPzmki0lniYAuPg9YX2ekTRtE01R2AE8WqM7zcRRl
         uExdODD0pCnl1Gx/A9SQHpVINdML9lNWp0oiPZOElXxe8jPhQwdk4CU+9SOeQ2AXTeCQ
         pE3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=SLwBA8MbvD2QC0ep8E6TWiO4osZD4fu2h/9Z2V53XVU=;
        b=EJJHmQbFSwYbMSOQR23LbOXXVuEZCJhJiy/do8Ckl0C90mPsjjhpkhZnHT4aKuOXu7
         /3NyEYcqcXu9IMhKmAzAVCK/52Kzr/COproFe6vt8Q/OP9Vu3eKezjmM/xFadGZJvl8q
         q3FsfJjgBZYy9p/hx6cW4sVvgUZJNMITW7hZfSd1dDQQFK/h7uEc0oMS/YJWaJpZCp7H
         2/vQovsjCn0PnsCBE6bRwDLxoIv6Dg6UI7QhEVVJGoIXvEWMb6DlQO/YGcWwcWQyStDq
         bBBVdXCBG4N8djCMBNqHdOQqQWkWhGqwA9/0dIiQFxIV82sci4AMiaIRDGUlnf68Xjhc
         H5XQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=1U+7o4fD;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j20sor15672717pfh.40.2019.05.28.15.16.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 15:16:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=1U+7o4fD;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=SLwBA8MbvD2QC0ep8E6TWiO4osZD4fu2h/9Z2V53XVU=;
        b=1U+7o4fD7tmYoGz+yUlK3xEC1BolyoWKEYDkAchX/oKTIdCJ03mkyuokQEfbvRSu2J
         aGd9YozwjkbKIRGDOUx6V5TNQV10fBydRP3/Rref/HmapwqQZiV9R4GRFjbMDQgluno+
         0zHhUoORAlPNG66tv0aBbi6J1l5JMOKKBFrNXSeq1LkzuGBuaLOfIVr2A802gf+RC1pL
         +oa0FYRQhTCfhF5qx4XRkKaaxYuVA6TXhvlkdl7eTRQtFWHk8AIvAGmY8XmG0Lr5F0w0
         2GAmIemcB/o8diV8Hr/dq8X+6wB9bHxgvYLAnWqThhUoTxyo31DHn2/FkNsat0MFD2go
         3t4A==
X-Google-Smtp-Source: APXvYqzGLAcNqO9DPhr8ZWvyM2uL60NP5y+iK/RNsjZJ/jpP+ybbd9xpym9mO2p60BjMJe5T0FHE3Q==
X-Received: by 2002:aa7:8e46:: with SMTP id d6mr117346607pfr.91.1559081776764;
        Tue, 28 May 2019 15:16:16 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:77ab])
        by smtp.gmail.com with ESMTPSA id f30sm3238124pjg.13.2019.05.28.15.16.15
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 15:16:16 -0700 (PDT)
Date: Tue, 28 May 2019 18:16:14 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guro@fb.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kernel Team <Kernel-team@fb.com>, Michal Hocko <mhocko@kernel.org>,
	Rik van Riel <riel@surriel.com>, Shakeel Butt <shakeelb@google.com>,
	Christoph Lameter <cl@linux.com>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v5 6/7] mm: reparent slab memory on cgroup removal
Message-ID: <20190528221614.GD26614@cmpxchg.org>
References: <20190521200735.2603003-1-guro@fb.com>
 <20190521200735.2603003-7-guro@fb.com>
 <20190528183302.zv75bsxxblc6v4dt@esperanza>
 <20190528195808.GA27847@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528195808.GA27847@tower.DHCP.thefacebook.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 07:58:17PM +0000, Roman Gushchin wrote:
> On Tue, May 28, 2019 at 09:33:02PM +0300, Vladimir Davydov wrote:
> > On Tue, May 21, 2019 at 01:07:34PM -0700, Roman Gushchin wrote:
> > > Let's reparent memcg slab memory on memcg offlining. This allows us
> > > to release the memory cgroup without waiting for the last outstanding
> > > kernel object (e.g. dentry used by another application).
> > > 
> > > So instead of reparenting all accounted slab pages, let's do reparent
> > > a relatively small amount of kmem_caches. Reparenting is performed as
> > > a part of the deactivation process.
> > > 
> > > Since the parent cgroup is already charged, everything we need to do
> > > is to splice the list of kmem_caches to the parent's kmem_caches list,
> > > swap the memcg pointer and drop the css refcounter for each kmem_cache
> > > and adjust the parent's css refcounter. Quite simple.
> > > 
> > > Please, note that kmem_cache->memcg_params.memcg isn't a stable
> > > pointer anymore. It's safe to read it under rcu_read_lock() or
> > > with slab_mutex held.
> > > 
> > > We can race with the slab allocation and deallocation paths. It's not
> > > a big problem: parent's charge and slab global stats are always
> > > correct, and we don't care anymore about the child usage and global
> > > stats. The child cgroup is already offline, so we don't use or show it
> > > anywhere.
> > > 
> > > Local slab stats (NR_SLAB_RECLAIMABLE and NR_SLAB_UNRECLAIMABLE)
> > > aren't used anywhere except count_shadow_nodes(). But even there it
> > > won't break anything: after reparenting "nodes" will be 0 on child
> > > level (because we're already reparenting shrinker lists), and on
> > > parent level page stats always were 0, and this patch won't change
> > > anything.
> > > 
> > > Signed-off-by: Roman Gushchin <guro@fb.com>
> > > Reviewed-by: Shakeel Butt <shakeelb@google.com>
> > 
> > This one looks good to me. I can't see why anything could possibly go
> > wrong after this change.
> 
> Hi Vladimir!
> 
> Thank you for looking into the series. Really appreciate it!
> 
> It looks like outstanding questions are:
> 1) synchronization around the dying flag
> 2) removing CONFIG_SLOB in 2/7
> 3) early sysfs_slab_remove()
> 4) mem_cgroup_from_kmem in 7/7
> 
> Please, let me know if I missed anything.
> 
> I'm waiting now for Johanness's review, so I'll address these issues
> in background and post the next (and hopefully) final version.

The todo items here aside, the series looks good to me - although I'm
glad that Vladimir gave it a much more informed review than I could.

