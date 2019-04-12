Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03129C10F13
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 00:05:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B58EB2184B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 00:05:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B58EB2184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 429706B0010; Thu, 11 Apr 2019 20:05:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DA466B026A; Thu, 11 Apr 2019 20:05:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EF506B026B; Thu, 11 Apr 2019 20:05:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D48B6B0010
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 20:05:54 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id o135so6572983qke.11
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:05:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HRetJUeLLftgWhfLzyhaJFev5gaVAbOvSF9OFxHuLnk=;
        b=KwQlN9k1StacxxPDOCnl2XgkhnTRmq+7RLeg0oPoVBRbwffM0EXQRwyB0tmIJT1V4A
         Su+iZUCJqAnxKIZO64qqtXBYKBblg4WuZmFuxDaLWlyP6kpDrQrMuk/Qr4740ISynoOI
         lEgZytt4nGaOF1aWa0U9AIYll916OiQ042P0V0AUlIrdqlurGZ04rJ8hE9bveNIy6fvU
         3s2DX8fhxxAwkkvEEFnqHBXTKBLe/guc3Qvmfq+FboMugeu6XXgdZIKeLCCFgTdU+pa7
         iaYZ3NabOBOMLIFLx4n3ZKfVG6ogBjivOpzPUG8a26Mmy620qbfT+nq1MKtxZsOZ76i1
         4Y3w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX4AzPNCO99Dg4Eu/oQv2GntqWM5pNrF0Jpf3nbZCumk5Fa94GT
	JusST1VrYHWJPb513ujuqzVgiqNxpNqZYpRg7hQYsK0F/1+gpfQ2uWJ74mC6tFrgKE7FbbV8/CH
	E5GCDb0KS7lW8zfYOEOYwl5DIWJy5N+JFXeq79nhJOthR1Esch8yOJDV5rE2AHtFK8Q==
X-Received: by 2002:a0c:af02:: with SMTP id i2mr43914989qvc.40.1555027553747;
        Thu, 11 Apr 2019 17:05:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxW1U4syjwuLMwl+v0rRdU/8O5W7DlLhRgvCdY6bP8qm0kR/qSQdyZzKfREvSWyTpBigvZ/
X-Received: by 2002:a0c:af02:: with SMTP id i2mr43914937qvc.40.1555027553012;
        Thu, 11 Apr 2019 17:05:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555027553; cv=none;
        d=google.com; s=arc-20160816;
        b=U7ORvUR79uLmP4LSweuJlalNmnLLzaZX36lMprVz2BjmXi6o8WGIP2vT2kDx0kiVQf
         s2ISm8HjtKq4AKqLFmHqVR+bUugl8Dg0ohSAoCFgRF7xD46Ng8EkgfL2doPNcF9Q4nUw
         SPj4yjTA2uoRnX+pZlQa4Nwvt7Ic87s3rCyqDA1N99HkBTBDPALtxUEA6NbrTd+9/Fvg
         X3LYNjuZDDU1S9z+SNIFYhRGRo+IOCexPQnABGy/mOx2h6JXrbrXC6NZTz6o1cZD5ojt
         dGl//sbqCdfFBEeOeqstSzaDcF0I836SEJgxt4UO7G3hXqDzL7dcvQrShBEqq91tmxjl
         t+5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=HRetJUeLLftgWhfLzyhaJFev5gaVAbOvSF9OFxHuLnk=;
        b=MMwrldSju7xtvpc2GZxwwCzMNAvqe9kLs7ozynEy8xe+6VX9rbOPhS5oIZSbMHykAN
         fHLzHNeBK4euSkDSpTq/lfEG8RcABY2xaLglxB5FhcDvCjtknvMVYe5NYXHlBjJHtxit
         lXtKMgdtD7fGQJmAJgNNIFwpTOZU/LgdlxejgNCuDKL1hZQQmjxVRmBNi16/6mJqMwoN
         iWBSeD2PIj44JwiMugHSvPa3c5AfnBekm+pabmEyRoBFJTG+cIHRiHpuIcYDCkLVpzl3
         O6MqQS/8hViTH1xiNqickJGG48P4FiEtF+raaiKbNUvSmbjkArILRLseTq8d+wk775TZ
         E4MA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j10si2160353qvj.46.2019.04.11.17.05.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 17:05:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E0D32859FC;
	Fri, 12 Apr 2019 00:05:51 +0000 (UTC)
Received: from localhost (ovpn-12-23.pek2.redhat.com [10.72.12.23])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id BF09D17966;
	Fri, 12 Apr 2019 00:05:50 +0000 (UTC)
Date: Fri, 12 Apr 2019 08:05:47 +0800
From: Baoquan He <bhe@redhat.com>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, akpm@linux-foundation.org,
	mhocko@suse.com, hannes@cmpxchg.org, dave@stgolabs.net,
	linux-mm@kvack.org
Subject: Re: [PATCH] mm: Simplify shrink_inactive_list()
Message-ID: <20190412000547.GB3856@localhost.localdomain>
References: <155490878845.17489.11907324308110282086.stgit@localhost.localdomain>
 <20190411221310.sz5jtsb563wlaj3v@ca-dmjordan1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411221310.sz5jtsb563wlaj3v@ca-dmjordan1.us.oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 12 Apr 2019 00:05:52 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/11/19 at 06:13pm, Daniel Jordan wrote:
> On Wed, Apr 10, 2019 at 06:07:04PM +0300, Kirill Tkhai wrote:
> > @@ -1934,17 +1935,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
> >  	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
> >  	reclaim_stat->recent_scanned[file] += nr_taken;
> >  
> > -	if (current_is_kswapd()) {
> > -		if (global_reclaim(sc))
> > -			__count_vm_events(PGSCAN_KSWAPD, nr_scanned);
> > -		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_KSWAPD,
> > -				   nr_scanned);
> > -	} else {
> > -		if (global_reclaim(sc))
> > -			__count_vm_events(PGSCAN_DIRECT, nr_scanned);
> > -		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_DIRECT,
> > -				   nr_scanned);
> > -	}
> > +	if (global_reclaim(sc))
> > +		__count_vm_events(PGSCAN_KSWAPD + is_direct, nr_scanned);
> > +	__count_memcg_events(lruvec_memcg(lruvec), PGSCAN_KSWAPD + is_direct,
> > +			     nr_scanned);
> 
> Nice to avoid duplication like this, but now it takes looking at
> vm_event_item.h to understand that (PGSCAN_KSWAPD + is_direct) might mean
> PGSCAN_DIRECT.
> 
> What about this pattern for each block instead, which makes the stat used
> explicit and avoids the header change?
> 
>        stat = current_is_kswapd() ? PG*_KSWAPD : PG*_DIRECT;

Yeah, looks nice. Maybe name it as item or event since we have had stat
locally defined as "struct reclaim_stat stat".

	enum vm_event_item item;
	...
        item = current_is_kswapd() ? PG*_KSWAPD : PG*_DIRECT;

