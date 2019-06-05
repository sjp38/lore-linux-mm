Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22A58C28D18
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 16:42:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AEDA20684
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 16:42:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="EpK/aD4e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AEDA20684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 447CB6B026C; Wed,  5 Jun 2019 12:42:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F8886B026F; Wed,  5 Jun 2019 12:42:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E7EA6B0270; Wed,  5 Jun 2019 12:42:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E94996B026C
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 12:42:31 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id u1so13403950pgh.3
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 09:42:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=IR/5u8R+ftfvePhhPnEG7rK5T0D9AZJGfobf430HZK0=;
        b=tHrtM5jIfJy0mcqs46IxA+kHDW+0oAunCyeVhcPwtK2ai5gG22YtTF40GUvCg1jyVr
         jpJ9V4jZWvLqzZ57EVIVi36cVkLJHz8Hf+cY5+eY8sgldaABBmRh/EVOzGPZLnAPPeBb
         p8nsrpfSbXoptIjjJBbt8y+htE3euBgOaDVnYr+xDDEA8hZ28uwwzppcxxOMnqqRhkHk
         ILAWT+feESOsFw8VByuZ9eW2QXgSNneCCbeLEY0Vh3BAqLSxSC1MvdvEXbP+ZV2nhS6s
         gcaUL8odnTyUE3O5gO48XEU9bt/fqm1W/qwEnczEJGemgNyHBXc54UXrbnwTev42e6E3
         YLrQ==
X-Gm-Message-State: APjAAAXyuv5G7BWZRBGLu7NjpvNdRFGrhGbFnOks76CCQKmV5E1olivw
	jkjS1s9m6B6htdiRGOc8dZeWetTyjePOKoqoZ6D+VrOcolBO/rUFCmYJJrbZcUObsYRuhh5zmLQ
	sywEmlx7QKWxbpxLS5VyTZHm4G+Q5alFbALbuPnLO7EzyloPFWWOELGAj9WMo5qUM3g==
X-Received: by 2002:a17:902:a5c5:: with SMTP id t5mr45795602plq.288.1559752951558;
        Wed, 05 Jun 2019 09:42:31 -0700 (PDT)
X-Received: by 2002:a17:902:a5c5:: with SMTP id t5mr45795531plq.288.1559752950844;
        Wed, 05 Jun 2019 09:42:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559752950; cv=none;
        d=google.com; s=arc-20160816;
        b=FlP0OVjUuxd0HDomCo0bxxs29U6PZ2zWhf1t4NtqUoof6Bj+CKyRWfH1UAjLU0NumG
         Pcmlo2Mmd4ECbyUpCRliIA8yyqiYQ2lndecgP0SvvQ5i2yy/lEjlCir+DtIm7sDZQHfW
         a/WOo7jNu85BsKCgIlIZqcNkYINeqEPVXOBg2JwBiR464TzUn7hNPlPJ+hxl7CTQjew/
         Gsp0awNcpWiBrUcJZip2OaQ2GKxIJs0z7AhWFfV0BbtsXLAgY99tUt0Fo83i1F8bSXn2
         +kyU+V8NT2oAQEyA/f3fJsksGiuzTN3q2zm7kJadvKHCXu/zjIcGNip8KOgWheH/x4Si
         7QHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=IR/5u8R+ftfvePhhPnEG7rK5T0D9AZJGfobf430HZK0=;
        b=A/8Kyu8lksVCUWYnXpbgA7MzVm/tt2Sy67x+4m8UfFKkbQ2RSaOHd/zDCMEUTzyLIf
         eA4mc7ppt2a2IQbHAAjkEzmDq0YT1JK6G3bKskDfMDDB8tXFfbMJQZU2fZ6O2gkLQcVT
         wartagnRzmAcbPRuU1SAULQsWwz0zitYfggli0u2G3qPbOoUJb79JjkMXqARzJJNHtk0
         aiIqKG6wUOw8civGmq7CzYVei/qNOzMwMxYhhWq3xSmwSkxA1BHSQyW8n9/7pp0S5AwS
         eHnnHAHe1f4Mq+tpX/4W4cE65KQqas6zsVUshbj5PRaURKPerEgRAERLyblok9BXj3Na
         VIaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="EpK/aD4e";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x189sor9829547pfx.37.2019.06.05.09.42.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 09:42:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="EpK/aD4e";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=IR/5u8R+ftfvePhhPnEG7rK5T0D9AZJGfobf430HZK0=;
        b=EpK/aD4eGRpEC9hMVO208gbI/muqvw8jBmuMlOGu+QCJFEebWFWSoFCERzvwGvuL6K
         ZsZW1YedQmJCDs8eKJRuqXLHpxRuF8EZ0fn2kX/QObnsB/BRL2omZKd+WbVgXyaemLx6
         nIziz08WC5m6Od5vkSTLH9UrAqUvEideQSFn7Kek1qFQR0L0B9Lr6mu9mZtZkMWsYh68
         Lh26494NJ/EqpF12bz4dOK09y5nJtxJbA5Jt04y7H3ZUrW/7ymTys04XVtMiWIRbFDoZ
         avUuRe2ACDkCiyz75JTnDTlW2XCPbiknHuhU5mk9t7MeLU10/Q07/2PW5oCPCQB+ZlqU
         FFAg==
X-Google-Smtp-Source: APXvYqxGZGo/d/XJokbeKLqRlqfQUskb3FoYJTPKNFpIC57YsPlwoH1CmnWwVKyEBqoYUEgWRbnDhQ==
X-Received: by 2002:aa7:9e51:: with SMTP id z17mr48511176pfq.212.1559752950079;
        Wed, 05 Jun 2019 09:42:30 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:cd0c])
        by smtp.gmail.com with ESMTPSA id q125sm44812419pfq.62.2019.06.05.09.42.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Jun 2019 09:42:28 -0700 (PDT)
Date: Wed, 5 Jun 2019 12:42:27 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Shakeel Butt <shakeelb@google.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v6 01/10] mm: add missing smp read barrier on getting
 memcg kmem_cache pointer
Message-ID: <20190605164227.GB12453@cmpxchg.org>
References: <20190605024454.1393507-1-guro@fb.com>
 <20190605024454.1393507-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605024454.1393507-2-guro@fb.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 07:44:45PM -0700, Roman Gushchin wrote:
> Johannes noticed that reading the memcg kmem_cache pointer in
> cache_from_memcg_idx() is performed using READ_ONCE() macro,
> which doesn't implement a SMP barrier, which is required
> by the logic.
> 
> Add a proper smp_rmb() to be paired with smp_wmb() in
> memcg_create_kmem_cache().
> 
> The same applies to memcg_create_kmem_cache() itself,
> which reads the same value without barriers and READ_ONCE().
> 
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Roman Gushchin <guro@fb.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

