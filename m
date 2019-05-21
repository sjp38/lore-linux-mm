Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF21AC04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 11:30:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64DF4217D4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 11:30:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="gaz82++3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64DF4217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B42856B0003; Tue, 21 May 2019 07:30:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF3BF6B0005; Tue, 21 May 2019 07:30:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BA186B0006; Tue, 21 May 2019 07:30:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 63AB46B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 07:30:44 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 5so12150356pff.11
        for <linux-mm@kvack.org>; Tue, 21 May 2019 04:30:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=u3aOCF7DfNjOUaUxeGwv8GNryvyR8Wto9mzcT26En+8=;
        b=gXD1644PYUTPaP8k9jQxlgU6uSrESqQM21kieQ4gNVM4QhRb5FMB2gm+7nEim0vfJ1
         N9JdBlZZdMqhoDpifeQamqFUYxoZJNQZbgX0U2Cal16Zeabp/64kWbGJ+TOtII1sLhny
         /O+84oUrGVSoydYFkU+KtVE7G17zJaoqOo4ug3aBczf1vuMbLNNTO2RcISHzq7NC/Jtf
         DTrjlwGIAOTaNORXFjbL4Tm9+5DFRJoxZjXE0jw1iR3guyCYD5oMsdhgehweedKitC6O
         gn6kR98k8CyCww4gLQHUVv7L3Ht6rTE+avoJwxsCManavFoRcaq/JSCzCdqG7bF0WL/B
         hm7g==
X-Gm-Message-State: APjAAAWMUzKgBJuW48lA15Suq7okeTOLBJf+7iqwnS5WMQgBQ7to1qvA
	uQ57NTgupf5VKaJJfbrxS79lv3qn8KjpbV/O/tkGRA5XCyEjAXBPBL8tpL3yA9SJPsu8XWN+g3J
	ECFy3WI7OjnufWs8PV/vvbmeEz/X5PFROKgK3f9dEMf8T/kFPrcuqxzdl9FSbfbELHg==
X-Received: by 2002:a63:2118:: with SMTP id h24mr82427461pgh.320.1558438243856;
        Tue, 21 May 2019 04:30:43 -0700 (PDT)
X-Received: by 2002:a63:2118:: with SMTP id h24mr82427385pgh.320.1558438242987;
        Tue, 21 May 2019 04:30:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558438242; cv=none;
        d=google.com; s=arc-20160816;
        b=YiKnQwonI7lBL6s1ErUo4m9ozbrCUzx1FmmpTEv/shzx62kP7Gtw2A4hODjDndV8JW
         s4MttAdhtCxBHss0fpVO7gysRcakfZI8kpbfcjJZuBrJY9zEMSHvPFvK2/sLv+koQZsL
         PfTQqKF+bdGDOyK8KeGHNwQbeC6wGIkR33Sp8ggCaUvJ3igARe9F68y2GJj7f+W0y17+
         jeejIsYFyVo0ffqnw2F8kZpERXEraXJEzBRW3y5LaDQyWeRh9jxuF1znx3JHrBBmoBtn
         GBHXMdNwLnxDxp6WKLsA8hzWPVVOF6ivzSQfmUtooa20NZl8oGoJl561CIlQRL7CllGo
         4T5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=u3aOCF7DfNjOUaUxeGwv8GNryvyR8Wto9mzcT26En+8=;
        b=uClEnBq3+v+ML7hOjmN9ImYF9Ezo9bLKigaZpVoXBlLuoBYJ0j5l6EyYit+r2HZt3Z
         bhLL6FpGdODPBl3U0Z0tqbtyQm5GYXfaB/fEAwI2fUwLXlan1BZ2k9rcUakIRF9EeFd4
         ddxq8O6yza29wOGx53Qbr60GwqY0bfhjfgzFjI6N2g6oD0ai6o6cskFPgZSa7ZK1XS6U
         wNB+Hp/wsM6dvrxH32gdlDEaxsW8ZqTQYB3PDdpVUBhe/Tnu1HGDC9KlXj7Tn25Ra5xk
         g1rf5sQ7kuhaS1G8R8uR+DKRI6kWkcsZIboKn6q7ITa76CHiyWBQ9AH8OYGvt1eXou+C
         hFTw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=gaz82++3;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.41 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t21sor22021102pfa.46.2019.05.21.04.30.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 04:30:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=gaz82++3;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.41 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=u3aOCF7DfNjOUaUxeGwv8GNryvyR8Wto9mzcT26En+8=;
        b=gaz82++3GLFJz+NYZhFL463z/kKlo0LB5+AxLKqcQcr25Au3ZagpLlvofHN5Kpj31X
         kKXIkGUhEsVjvdFSZ1d9PRzo003Fl0lhi4bSXQVhk/+mPI+7pAgVTbXn4EQzd9U/mwHq
         gquUUPQt543lEQ+4PXdzsTAOpSkEYbWHEAmXQTyZM9jGFlIg7oiB7Y8cMzZLBeBGhcrs
         a8pv+97z6xSh6oHkeUiv08wxgPQz+quul0dy+DPgC86FWigNnRECU/8+AvNsOhqLHP+H
         cZz8qTYbyXJfIab5RamvA2Lmh8sxenfTxdj9jemGrLjFEZjGdr72jiaeIfRVSj4Xnb7q
         Wb6A==
X-Google-Smtp-Source: APXvYqwJPD0ZUEtL4HulVslE71s0X020brUXLDTYwpPLeLG7JLmhdoNZKge0vYtjnm0wXLCQDZ2gEQ==
X-Received: by 2002:a63:4342:: with SMTP id q63mr80473096pga.435.1558438242250;
        Tue, 21 May 2019 04:30:42 -0700 (PDT)
Received: from brauner.io ([208.54.39.182])
        by smtp.gmail.com with ESMTPSA id d9sm25956682pgj.34.2019.05.21.04.30.35
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 21 May 2019 04:30:41 -0700 (PDT)
Date: Tue, 21 May 2019 13:30:32 +0200
From: Christian Brauner <christian@brauner.io>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
Message-ID: <20190521113029.76iopljdicymghvq@brauner.io>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190521084158.s5wwjgewexjzrsm6@brauner.io>
 <20190521110552.GG219653@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190521110552.GG219653@google.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 08:05:52PM +0900, Minchan Kim wrote:
> On Tue, May 21, 2019 at 10:42:00AM +0200, Christian Brauner wrote:
> > On Mon, May 20, 2019 at 12:52:47PM +0900, Minchan Kim wrote:
> > > - Background
> > > 
> > > The Android terminology used for forking a new process and starting an app
> > > from scratch is a cold start, while resuming an existing app is a hot start.
> > > While we continually try to improve the performance of cold starts, hot
> > > starts will always be significantly less power hungry as well as faster so
> > > we are trying to make hot start more likely than cold start.
> > > 
> > > To increase hot start, Android userspace manages the order that apps should
> > > be killed in a process called ActivityManagerService. ActivityManagerService
> > > tracks every Android app or service that the user could be interacting with
> > > at any time and translates that into a ranked list for lmkd(low memory
> > > killer daemon). They are likely to be killed by lmkd if the system has to
> > > reclaim memory. In that sense they are similar to entries in any other cache.
> > > Those apps are kept alive for opportunistic performance improvements but
> > > those performance improvements will vary based on the memory requirements of
> > > individual workloads.
> > > 
> > > - Problem
> > > 
> > > Naturally, cached apps were dominant consumers of memory on the system.
> > > However, they were not significant consumers of swap even though they are
> > > good candidate for swap. Under investigation, swapping out only begins
> > > once the low zone watermark is hit and kswapd wakes up, but the overall
> > > allocation rate in the system might trip lmkd thresholds and cause a cached
> > > process to be killed(we measured performance swapping out vs. zapping the
> > > memory by killing a process. Unsurprisingly, zapping is 10x times faster
> > > even though we use zram which is much faster than real storage) so kill
> > > from lmkd will often satisfy the high zone watermark, resulting in very
> > > few pages actually being moved to swap.
> > > 
> > > - Approach
> > > 
> > > The approach we chose was to use a new interface to allow userspace to
> > > proactively reclaim entire processes by leveraging platform information.
> > > This allowed us to bypass the inaccuracy of the kernel’s LRUs for pages
> > > that are known to be cold from userspace and to avoid races with lmkd
> > > by reclaiming apps as soon as they entered the cached state. Additionally,
> > > it could provide many chances for platform to use much information to
> > > optimize memory efficiency.
> > > 
> > > IMHO we should spell it out that this patchset complements MADV_WONTNEED
> > > and MADV_FREE by adding non-destructive ways to gain some free memory
> > > space. MADV_COLD is similar to MADV_WONTNEED in a way that it hints the
> > > kernel that memory region is not currently needed and should be reclaimed
> > > immediately; MADV_COOL is similar to MADV_FREE in a way that it hints the
> > > kernel that memory region is not currently needed and should be reclaimed
> > > when memory pressure rises.
> > > 
> > > To achieve the goal, the patchset introduce two new options for madvise.
> > > One is MADV_COOL which will deactive activated pages and the other is
> > > MADV_COLD which will reclaim private pages instantly. These new options
> > > complement MADV_DONTNEED and MADV_FREE by adding non-destructive ways to
> > > gain some free memory space. MADV_COLD is similar to MADV_DONTNEED in a way
> > > that it hints the kernel that memory region is not currently needed and
> > > should be reclaimed immediately; MADV_COOL is similar to MADV_FREE in a way
> > > that it hints the kernel that memory region is not currently needed and
> > > should be reclaimed when memory pressure rises.
> > > 
> > > This approach is similar in spirit to madvise(MADV_WONTNEED), but the
> > > information required to make the reclaim decision is not known to the app.
> > > Instead, it is known to a centralized userspace daemon, and that daemon
> > > must be able to initiate reclaim on its own without any app involvement.
> > > To solve the concern, this patch introduces new syscall -
> > > 
> > > 	struct pr_madvise_param {
> > > 		int size;
> > > 		const struct iovec *vec;
> > > 	}
> > > 
> > > 	int process_madvise(int pidfd, ssize_t nr_elem, int *behavior,
> > > 				struct pr_madvise_param *restuls,
> > > 				struct pr_madvise_param *ranges,
> > > 				unsigned long flags);
> > > 
> > > The syscall get pidfd to give hints to external process and provides
> > > pair of result/ranges vector arguments so that it could give several
> > > hints to each address range all at once.
> > > 
> > > I guess others have different ideas about the naming of syscall and options
> > > so feel free to suggest better naming.
> > 
> > Yes, all new syscalls making use of pidfds should be named
> > pidfd_<action>. So please make this pidfd_madvise.
> 
> I don't have any particular preference but just wondering why pidfd is
> so special to have it as prefix of system call name.

It's a whole new API to address processes. We already have
clone(CLONE_PIDFD) and pidfd_send_signal() as you have seen since you
exported pidfd_to_pid(). And we're going to have pidfd_open(). Your
syscall works only with pidfds so it's tied to this api as well so it
should follow the naming scheme. This also makes life easier for
userspace and is consistent.

> 
> > 
> > Please make sure to Cc me on this in the future as I'm maintaining
> > pidfds. Would be great to have Jann on this too since he's been touching
> > both mm and parts of the pidfd stuff with me.
> 
> Sure!

Thanks!

