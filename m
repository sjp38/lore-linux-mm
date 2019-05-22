Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5969C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:44:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB27420881
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:44:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="QEF+zn6b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB27420881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FFF76B0005; Wed, 22 May 2019 11:44:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B08C6B0006; Wed, 22 May 2019 11:44:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 278796B0007; Wed, 22 May 2019 11:44:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E350B6B0005
	for <linux-mm@kvack.org>; Wed, 22 May 2019 11:44:31 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id j36so1869149pgb.20
        for <linux-mm@kvack.org>; Wed, 22 May 2019 08:44:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Z2dsucXEI+4jvL/MdjM5V2xnzon5dvV20hzmst7SI+w=;
        b=gZ2otuc/S76x/dwsCMGNKYf5iwoJq2A8SuRpLDIrWupnDF/3n9rUHBMqUnsPOCf7tF
         IgvvmJFvJhBQZe7eWxWL8M0jnG314hkePDbXONfad0k1ZI+sI6GXMHf02ocvT/vtZLTR
         NMxrDnWPEIk71inJ8hbBZuqF5R0MxgDuot3aMcPs7JAbishEI5Ygg2PYDmIrD5oea6PU
         oKqKe4CDApHTTo09RpEoWf60QyaqF717cTub9tM1zJt+jQRkarhP1AivqAsRpjnZfsSt
         uPLl7htHnEZ3IxUbF73mPwx84uLep7cOF9hSWGcE6Xpa4dT+/OE0cwqNctWAsA8sovLT
         cOvQ==
X-Gm-Message-State: APjAAAUK17j5NSTPMUPxejOcpOKPzrrPUlIKOyCzSHRb667qP7pHNSj5
	+abGmvLXK2Nj10b+2FGazug5EKQqMJR6UPjm2JdKN/wj2/hEEzvVUBZinJrbVTjssRUq0fvXmr9
	hngLHuvdqYXaDZKKkSIxb4op6QVov8hlgiSWwIm11TyQ3/rtJRWEYv/VmDuX7jfnNfg==
X-Received: by 2002:a63:5c1b:: with SMTP id q27mr92074828pgb.127.1558539871534;
        Wed, 22 May 2019 08:44:31 -0700 (PDT)
X-Received: by 2002:a63:5c1b:: with SMTP id q27mr92074754pgb.127.1558539870660;
        Wed, 22 May 2019 08:44:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558539870; cv=none;
        d=google.com; s=arc-20160816;
        b=wIdHqQIB+Y42SVV8NLPYigBg4QUu+kv0km36nAg0mBXmkvva7wlRbwJqGmF31P9Nnk
         c1lil2Ty6PJlXSYqdspUJej/jqzH6wEu3/7iWc9JWyXsRRY5Umx8RSViaGdq1jyIBPC/
         wgyqEZclBx9VqsWl3IRiBG922R+TiCyer2R2q/ZcnSxppbeDbAwAO1M+x9GzQSKIOm1C
         UnfiRg7kEL+jlxOXH3Z5208+6E/1K560POZZB6Nx4C6hz6rY5dXhYRfsINf/r9Q5QBvC
         IIIivu27p1XMNfp49dlrk4YdOTBXZBVrmp5Vy9ZdGTLRss/z5XnIwDPQq7BK4IAWTWSH
         ncmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Z2dsucXEI+4jvL/MdjM5V2xnzon5dvV20hzmst7SI+w=;
        b=V/MsNB5GxH16i3J8/yhBWoLX943wIptstsBYq3mdV/7nZY3k4AEF1dVjGVxK2/ezMN
         zFAsAN+eXC6w3C+2pB6cE1XJ/lAjBZhmsYjFSrcI93Thk4BOXSc6NPmqbYsOUKED1l+4
         TkQKTvffcWfQBw2j5/zHrdD42r7aPyPvyyRRzTB893z3d9SKkIlhw0XJqIcbmo8KGXOf
         u9WPmENNsJ1gUig62qpCRKWSGgnD2vjqbfHWMVzLhVLU4x00VLLEJ4S7QXD01vcH41nS
         86QKjD4iOWYp7f4OWYqyalV1P0ZnT6ho7AACb0mrW4uAuTaI3WhumYYaKb6uMOrXoL9Q
         faqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=QEF+zn6b;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m18sor26870779pfe.56.2019.05.22.08.44.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 08:44:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=QEF+zn6b;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Z2dsucXEI+4jvL/MdjM5V2xnzon5dvV20hzmst7SI+w=;
        b=QEF+zn6btGpaZqM8f+IKFYqUq9v/Z7nVJc5hwB7Rsx3ybr7C3yoYL92vIvxi9L/hgY
         ZMJ2Ji1yspXAzrAVJ3ADZVQUDcRvEOYsYWQBuaz6bO8miAOlYzoQKQkjOrwC/3tsKjYx
         A4d4jMapVv1bxyua1ChiqHYxhX48A/3uMN1NVH72O/e+tS9Dc3scB9aTEvEvGtjoZi+Q
         98SilnjsnWbW5QH/Bu9WxnIr73P0RyENw74jrmzwv/TG7BUbTqTqZTdG+XUQetFvizXG
         Nclj6JQyDVN70kl/TrSbnI9SyIJtVv8O2G03D/AF5+UjVBLd9OEFjO9HIUrL3bVqgACM
         X8GA==
X-Google-Smtp-Source: APXvYqwNhNcpWibI4Oqtyib2hlUbtVFt/lmAsL6lT2SW95cEyZw8qdJilZn5xKkTMIfePZ7Vf2JUHQ==
X-Received: by 2002:aa7:99c7:: with SMTP id v7mr97012872pfi.103.1558539865858;
        Wed, 22 May 2019 08:44:25 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::ed6d])
        by smtp.gmail.com with ESMTPSA id j184sm25079831pge.83.2019.05.22.08.44.24
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 22 May 2019 08:44:24 -0700 (PDT)
Date: Wed, 22 May 2019 11:44:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, mm-commits@vger.kernel.org,
	tj@kernel.org, guro@fb.com, dennis@kernel.org, chris@chrisdown.name,
	cgroups mailinglist <cgroups@vger.kernel.org>, linux-mm@kvack.org
Subject: Re: + mm-consider-subtrees-in-memoryevents.patch added to -mm tree
Message-ID: <20190522154423.GA24972@cmpxchg.org>
References: <20190212224542.ZW63a%akpm@linux-foundation.org>
 <20190213124729.GI4525@dhcp22.suse.cz>
 <20190516175655.GA25818@cmpxchg.org>
 <20190516180932.GA13208@dhcp22.suse.cz>
 <20190516193943.GA26439@cmpxchg.org>
 <20190517123310.GI6836@dhcp22.suse.cz>
 <20190518013348.GA6655@cmpxchg.org>
 <20190521192351.4d3fd16c6f0e6a0b088779a6@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521192351.4d3fd16c6f0e6a0b088779a6@linux-foundation.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000020, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 07:23:51PM -0700, Andrew Morton wrote:
> On Fri, 17 May 2019 21:33:48 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > - Adoption data suggests that cgroup2 isn't really used yet. RHEL8 was
> >   just released with cgroup1 per default. Fedora is currently debating
> >   a switch. None of the other distros default to cgroup2. There is an
> >   article on the lwn frontpage *right now* about Docker planning on
> >   switching to cgroup2 in the near future. Kubernetes is on
> >   cgroup1. Android is on cgroup1. Shakeel agrees that Facebook is
> >   probably the only serious user of cgroup2 right now. The cloud and
> >   all mainstream container software is still on cgroup1.
> 
> I'm thinking we need a cc:stable so these forthcoming distros are more
> likely to pick up the new behaviour?

Yup, makes sense to me. Thank you!

