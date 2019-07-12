Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81A37C742A8
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:58:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43ADD2084B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:58:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="V/iJunfl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43ADD2084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFEAF8E0125; Fri, 12 Jul 2019 03:58:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD5D28E00DB; Fri, 12 Jul 2019 03:58:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC60D8E0125; Fri, 12 Jul 2019 03:58:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 87D6B8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 03:58:20 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id t2so5243653pgs.21
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 00:58:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=LtqSlKZWetZ9uGFV2K19vEGagHhsXV8pg3vWp1m725Y=;
        b=pf3+zEFBG7Bdd3VTHHvK2QW4ptfhXFt1G1CTiLvDzHYMWbZVCQde4f1z9oj7cRc7zT
         5LaUA5N3gFQuu2FvVMX1Sjl+av4JUlS8VbE06ZZFJUkGD+j4dSQJHU9F1IxcdkQDUDmy
         xQrUzyMP1ohqTTLUwLvhNahVwFW5NRg4/enlYH/VI8mFvBjHgdwuUgHVNT+mMjrtFnv7
         fZKgfHqNsUFEbiGFXbc3C5+/rxOfTN8uFO+z1cbN0WYMtxrj4wuK6fIPlVJ1ro1pumFv
         ynSBcmzY3izJHAqvyCiKOPAhrjhR4fhtsl5e0xBTuQjxC70NZn86Y78Rk6DByV8VWZqN
         ykPw==
X-Gm-Message-State: APjAAAVWFGKUeWRcH9ya0hUmSvcuFUoRUrF8ZLdCpmu/jICPPqktKRH2
	kEO+n/zq2pQD2PvFhuvS9Yx9eQEafDQVqm2pxHPAdaoBPUWw3jX1VIOpXSddLllH4zvqStNOJqw
	5hdpIjezUw4Tst/o8m79AReOHYX5m4CFNhNZG+k1Umf7mGdZN5vSmt0tKNADOat2S6A==
X-Received: by 2002:a63:56:: with SMTP id 83mr9427602pga.145.1562918300091;
        Fri, 12 Jul 2019 00:58:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVr5yRUCIYW+Hqp/vcntn5tDrLwluBEJHWikIsbPVbPdpqazbGrm0QijA/EDivObdZpvCz
X-Received: by 2002:a63:56:: with SMTP id 83mr9427558pga.145.1562918299408;
        Fri, 12 Jul 2019 00:58:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562918299; cv=none;
        d=google.com; s=arc-20160816;
        b=KBOlj02MW5JYoLHzb8YYa8Hijge5pmH9jqA2HX/Ho2RyXA3F7qNTPlLqqz0R71zAGJ
         zmOTlEJHltET1p2qQg15akfqKNYC6YXUIZ6DSBEUeVGZVFm/46lYb4e+1qn1nFZaHPAI
         uyaGHJNGAFS+JSOWlEIfsU7h3MWDK4ZMKMbed1ksGCSnux1MaLkHp8GU3wADG4KencBc
         /8aj89+mR0Ze/VvghKhq0c2KvaVtVumeXZc20Nf1+qQNNsxT7NmqpRxLIT+mdB25h7QL
         R9l6tkIXm9FY9X2KfRhmJYAtEGfwimisqjKY0NUVrvLj+SkeaPsAikvDZMYibqsh2RNH
         gF4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=LtqSlKZWetZ9uGFV2K19vEGagHhsXV8pg3vWp1m725Y=;
        b=EqaNYOLFJQrXjggZwKts06yW7JX2QIz4cLOQcbTtETP3OcIPJuHAhU/Ju+mDb1lyDp
         qWVBocDMRHd/1idAF0MTsdTe0zpEj4Bs/g8yMbI4MnM7rN4X2GHd2mO3c0h+jkzkWLOU
         nHd+4bTR+zjJYAZSOYWgT2U8CdkA59uWBCz4b/cOinJCUoMiDgfejEwsLpsNTiVwVSu+
         /ia7uymzIIpkuLllGiskPiOvsign1jYXKq9cprltdw79jk1ZMGyuB66lYG8JGRn6QA+/
         4vm9KqAxMRpgw1c+MECBMlV5TaH1WOP+dM0IyX41d8b62cAAqMLJuGvAM+/V7w6sTAqh
         DMzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="V/iJunfl";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u21si7454043pgm.431.2019.07.12.00.58.19
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 12 Jul 2019 00:58:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="V/iJunfl";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=LtqSlKZWetZ9uGFV2K19vEGagHhsXV8pg3vWp1m725Y=; b=V/iJunfl8ealcixJfAjaVt7Vrd
	tQUwwlpOMrfElHa7L5+1G8ivCqLA+QLKj++7et5n8GxiXViFsXqzO+QKB50yOVHqQJqPj63zR7Mz/
	oni9H7rrI0E/MaIPnNyX2MvDdFRFA0l6aIhPXeI0fJroCJs0BvecfAMR6kPmcfRvkfXcoZAJqZv39
	WH7yKi2rPXVO0Ik5pkgDA4sGvIwc9mD+A2jkIDR21O9JacqiJHxs/qgg/VPYPQB10dOMf4lUH9bDx
	wAmbgeQC11Xxo56c1HakyQocSdLZdhESnCzqS4A3/c4YMXSo8zEBk+A9qp7YhvUXI29jz1M9lnF0l
	WR3RRI3g==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hlqRd-000690-Dz; Fri, 12 Jul 2019 07:58:17 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id A84E320120CB1; Fri, 12 Jul 2019 09:58:15 +0200 (CEST)
Date: Fri, 12 Jul 2019 09:58:15 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: =?utf-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, mcgrof@kernel.org, keescook@chromium.org,
	linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
	Mel Gorman <mgorman@suse.de>, riel@surriel.com
Subject: Re: [PATCH 1/4] numa: introduce per-cgroup numa balancing locality,
 statistic
Message-ID: <20190712075815.GN3402@hirez.programming.kicks-ass.net>
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <3ac9b43a-cc80-01be-0079-df008a71ce4b@linux.alibaba.com>
 <20190711134754.GD3402@hirez.programming.kicks-ass.net>
 <b027f9cc-edd2-840c-3829-176a1e298446@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <b027f9cc-edd2-840c-3829-176a1e298446@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 11:43:17AM +0800, 王贇 wrote:
> 
> 
> On 2019/7/11 下午9:47, Peter Zijlstra wrote:
> [snip]
> >> +	rcu_read_lock();
> >> +	memcg = mem_cgroup_from_task(p);
> >> +	if (idx != -1)
> >> +		this_cpu_inc(memcg->stat_numa->locality[idx]);
> > 
> > I thought cgroups were supposed to be hierarchical. That is, if we have:
> > 
> >           R
> > 	 / \
> > 	 A
> > 	/\
> > 	  B
> > 	  \
> > 	   t1
> > 
> > Then our task t1 should be accounted to B (as you do), but also to A and
> > R.
> 
> I get the point but not quite sure about this...
> 
> Not like pages there are no hierarchical limitation on locality, also tasks

You can use cpusets to affect that.

> running in a particular group have no influence to others, not to mention the
> extra overhead, does it really meaningful to account the stuff hierarchically?

AFAIU it's a requirement of cgroups to be hierarchical. All our other
cgroup accounting is like that.

