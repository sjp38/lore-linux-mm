Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61743C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:40:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29E9321734
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:40:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Jn3UOoYx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29E9321734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D25C96B0283; Tue, 28 May 2019 13:40:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAE0D6B0287; Tue, 28 May 2019 13:40:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9D266B0288; Tue, 28 May 2019 13:40:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 703C06B0283
	for <linux-mm@kvack.org>; Tue, 28 May 2019 13:40:04 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id p7so2824379lfc.5
        for <linux-mm@kvack.org>; Tue, 28 May 2019 10:40:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=Vrqv9/Iv3MI1xIjyN3OV08sjxDNX6ztkzOcRbglOqYU=;
        b=jw+DbIpo+L2nOb7fV4B97+dBgzJa+JF9Dz/1KBGrGf9+0ojgK/qHQL9zDrPwkqrawH
         yraCuzOdlpD2ruV5ei5XDRJVME5uuapKe03Jfo+LxeJXoOmtMEDmcAZFcP1xrkLTmR6A
         IStUsb/JRHs9276nvqAPuIx7UvS9ubFQG6YzXwt0AHC8KmKeEmt7E5dV818ioZAXW3vF
         t3Nw5ptf8P1bG82nJnBgOmuQil0AThXdv94yeV9vlkzvBQSAeGQqpYYqRMIV2sna/ET/
         Q57urjz65KqzOq9FcJN/meszXoTAkxEGi/hE30jsyrIUtICf4FwNf+YwuMz6kiZ8DFmJ
         pJoA==
X-Gm-Message-State: APjAAAW+AlQjxniyYoORILHk0PrJ88mLv1HeQTZBlF9e5bULdFEqbyQo
	Gcv7Zs+HEHIUtBzwaVKny+rQr5eNdSJxG1GBf6TJnJZIKy7FFPezhF9v/AM34KufqYU/4IJwk+6
	LqO+plcUdXzfgZPir6srmL+ehp4cFS5Oe+viVN5/spYYkgo2/kmnGzYeZCkuu8+GXLA==
X-Received: by 2002:ac2:548a:: with SMTP id t10mr2457925lfk.84.1559065203842;
        Tue, 28 May 2019 10:40:03 -0700 (PDT)
X-Received: by 2002:ac2:548a:: with SMTP id t10mr2457896lfk.84.1559065203170;
        Tue, 28 May 2019 10:40:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559065203; cv=none;
        d=google.com; s=arc-20160816;
        b=aAhhCqErwtknjk/lGsRSKCKv56aAt6aiyBR5GWJoNBqDlQqwK8COc49y3rIlxWzLL5
         KkCKOWia7XajbF0D65J8TI6Mb1oUXY+LKaMPyKHi+JNqJbHg9vlyvLWBBXDzEOMSzWWJ
         7WfaOaL6k0id25mE4Et4g4wNGoLlmvuLr3Z1d8AL0/ksOShcQrUYzvNpZ3cHIGrdMpET
         Q8w/EDkAuzgy7c/l/YPbBsxIagxNikNX5Ybpqho28ybUqAVr4lH6LW+wvhMpbu/jaFKn
         S2FjGtnHnnO5WBNJHckjaU38Y8YYmARWGAwGILSCSWXSsqqTy+q1DZRz9Z+ZT7DDI3dt
         XF/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=Vrqv9/Iv3MI1xIjyN3OV08sjxDNX6ztkzOcRbglOqYU=;
        b=bBGl1QW6ab3xIxf/sxwmiwQg+wBRC5ONG7QQRz5j3jMmxZMhFM1lUEIij0VQ8OO6Gm
         644+oMwCJPZEkkXrIhj3xuTPXV2N2zz2RwgKvQ7zhM5TtmFl9+aBJHLiDOp9mqAPseyt
         sg27bFtoaZkgg6YEHeR1FuDDLqZMzpRqEmGjfG3kyz3h1IgGQbOGUWgsALffMu4ORMtv
         2G2TbkrqKtnaf80ngnvjOM1enEPOhvPn6gIAFH+4gQDUBSHxVxgcdiTO1IP5jQFHqXPF
         9pAgTXUBYGXGL6rIB43S8bCHQ/LgeWVLAs/8wuG3DSfmLC07gJ3QTt8KfNmrrGKHgtCA
         2CaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Jn3UOoYx;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r6sor7811984ljg.27.2019.05.28.10.40.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 10:40:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Jn3UOoYx;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=Vrqv9/Iv3MI1xIjyN3OV08sjxDNX6ztkzOcRbglOqYU=;
        b=Jn3UOoYxRmXz0/8P3Xa1ogBoFdvfiEZw2RtmGsb44RMcX1DAy1oLZBJOdc0yUZWgsp
         7xDsDDfSRzse0HMpWGBh+B3/3KZdzQ4RtrR+ai9HHSTWdS3W/lOCz6XGCV5nioxnzy3g
         AwWANrslZw+zkzTcIFqpiBH42mm9qs6k6c4jUaNec5p3+Arjs9kmm3FEZBYRfWmeK26h
         6ejUGFeY6UP0HWbJH8dR+3FOeATW/2hzFzPARvfhKKOZJ6UoquVGdUZ3TROyy3I3JWb4
         3sNArYlNTwUNXs+RoRHymG/wz6N1UARoP5AZjl8pud20oUsrVARyF1KV3pz9bv2T89ep
         c0YA==
X-Google-Smtp-Source: APXvYqwy0DxaU7TAPzZWannjuwTBDJOTg4m8sJCc5t6TldLIBR+KFV2pXC2+7AeA6vbnoN16p4wFfw==
X-Received: by 2002:a2e:129b:: with SMTP id 27mr34359558ljs.104.1559065202827;
        Tue, 28 May 2019 10:40:02 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id q124sm3003954ljq.75.2019.05.28.10.40.01
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 10:40:02 -0700 (PDT)
Date: Tue, 28 May 2019 20:39:59 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Waiman Long <longman@redhat.com>
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
	Shakeel Butt <shakeelb@google.com>,
	Christoph Lameter <cl@linux.com>, cgroups@vger.kernel.org
Subject: Re: [PATCH v5 5/7] mm: rework non-root kmem_cache lifecycle
 management
Message-ID: <20190528173959.h4hq55b3ajlfpjrk@esperanza>
References: <20190521200735.2603003-1-guro@fb.com>
 <20190521200735.2603003-6-guro@fb.com>
 <20190528170828.zrkvcdsj3d3jzzzo@esperanza>
 <96b8a923-49e4-f13e-b1e3-3df4598d849e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <96b8a923-49e4-f13e-b1e3-3df4598d849e@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 01:37:50PM -0400, Waiman Long wrote:
> On 5/28/19 1:08 PM, Vladimir Davydov wrote:
> >>  static void flush_memcg_workqueue(struct kmem_cache *s)
> >>  {
> >> +	/*
> >> +	 * memcg_params.dying is synchronized using slab_mutex AND
> >> +	 * memcg_kmem_wq_lock spinlock, because it's not always
> >> +	 * possible to grab slab_mutex.
> >> +	 */
> >>  	mutex_lock(&slab_mutex);
> >> +	spin_lock(&memcg_kmem_wq_lock);
> >>  	s->memcg_params.dying = true;
> >> +	spin_unlock(&memcg_kmem_wq_lock);
> > I would completely switch from the mutex to the new spin lock -
> > acquiring them both looks weird.
> >
> >>  	mutex_unlock(&slab_mutex);
> >>  
> >>  	/*
> 
> There are places where the slab_mutex is held and sleeping functions
> like kvzalloc() are called. I understand that taking both mutex and
> spinlocks look ugly, but converting all the slab_mutex critical sections
> to spinlock critical sections will be a major undertaking by itself. So
> I would suggest leaving that for now.

I didn't mean that. I meant taking spin_lock wherever we need to access
the 'dying' flag, even if slab_mutex is held. So that we don't need to
take mutex_lock in flush_memcg_workqueue, where it's used solely for
'dying' synchronization.

