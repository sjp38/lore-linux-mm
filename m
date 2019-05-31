Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90F88C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 14:00:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 563C4269F3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 14:00:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 563C4269F3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2DA26B026F; Fri, 31 May 2019 10:00:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB7C66B0272; Fri, 31 May 2019 10:00:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7EED6B027A; Fri, 31 May 2019 10:00:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2B66B026F
	for <linux-mm@kvack.org>; Fri, 31 May 2019 10:00:55 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id p14so14174111edc.4
        for <linux-mm@kvack.org>; Fri, 31 May 2019 07:00:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=F3ibO4l5v1KK1GEmolnDVMq1hme10V8sx2WSVMioo/E=;
        b=oGmZmAcp/Dy8m6A9FqLiVhd4eXaAiZQ8QXOBkhTgKOnb1RNmnTpkIEo4DcNoVIRt8x
         NZKUUouL7xGol8+xnE9M4tc/d8Fir/buLyKdy2+JsE2HflAdf1f1wYcEAPK9CcZfp2hZ
         Cuo31qth8+5S10u0OqvIq82WjFHcmOnJNMV/sAJRhuqxgUVeGY/9ALvkGHhlJgFJTnzR
         a0S6zl8j0QB/UGU4GYP918l/8pTiPEm+uJz9rmKIOLVfhuVDWHxjkbWkVp2yyK1ixoeW
         9fhyRZ0QJ1IrXp4Q9BAk06ZL+XKG/2oEAxeU3K6ndxB34gxQcFGSOT696Kia6iAI0d2N
         zunQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUV8k7e1mxaXzNmb9fxd6hef/y8i251w6+f8VUWRKIHgBZ46828
	p30s/djq7HStxv+kdY2znQc1bEYLdFvLgDiru6F2B54lDsf/jFRIVY2m6uil7StoPhEx4eVschO
	d35UfuZAhPO9pXg9Jeoxc8UVdNcv1EBhVRwFZ8oqAxIQSIDnyDwjkTH1cQIQHwCs=
X-Received: by 2002:a50:9952:: with SMTP id l18mr11524374edb.150.1559311254985;
        Fri, 31 May 2019 07:00:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxa252gg+UIuG5+v3gESaq41e99NvCC/nNC8s3TLlHL18Alxl+k0IOsodcMY+VKB1tyZQRJ
X-Received: by 2002:a50:9952:: with SMTP id l18mr11524252edb.150.1559311253939;
        Fri, 31 May 2019 07:00:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559311253; cv=none;
        d=google.com; s=arc-20160816;
        b=hVo+JTTLYFddkqJ2NM6zR8gm0GwKhddWN9vanawoBF3eIR+lB+FPnos/MvIDio7ziF
         ZlBIvJzdhCf+QuV7ppSL9SaBWPhr9H2YXf0I9OqMPaN8UPrBNsf2COhWKEBlw91ZbheN
         kUjqlXdp7enZskZchw5dgb3rdDcaQmoYTSl5wUuCNS6AHZU5RWgvCAptg72qK3vjggsp
         tfgDWgqi3SnYimaTwby+hcXTLVqK+qEy7nwAjTYPv8mVHYOMJWQSznGQ02Z9nRqmNFiS
         5sQJygdLv648dPZRydq9yFYJoUprmqJw8S7tb0A26hbvspTKSSiq08VfVnvMH9R/P3PD
         dDCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=F3ibO4l5v1KK1GEmolnDVMq1hme10V8sx2WSVMioo/E=;
        b=VEWXVzFWe3c43YJOXV08uYsptLBFWMqBeD6PeUNFlmYNxNASFczbGgb8Ijz7UsMEAS
         pimtwfYjz9y7P25By4EpJb2LWS+RfAwYFdGwoASg3m7D2ifwfmbganHL6AIhbZpVaayT
         rSYAn79vYWRc+SjBd6RRPT3D5QHd5WnsXJRMFiEWs3Lq1iuL52ohKNhY8whaIZZuj0+Z
         2R1BACznLD0JPr/kHvWNwJ+LcbYf+oykAdaAfvHhpZpdwuFxR01hdIWx/1PcqAzrUloS
         Q/knzk0xCr58NYNzMCGYEVZAEO6X6ajbL6kPv2fd5qhKBs+x21MlNpaZ8aP79RZqrOvF
         Ivow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hh16si3951391ejb.161.2019.05.31.07.00.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 07:00:53 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C44A5AFD1;
	Fri, 31 May 2019 14:00:52 +0000 (UTC)
Date: Fri, 31 May 2019 16:00:50 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, oleksandr@redhat.com,
	hdanton@sina.com
Subject: Re: [RFCv2 5/6] mm: introduce external memory hinting API
Message-ID: <20190531140050.GS6896@dhcp22.suse.cz>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-6-minchan@kernel.org>
 <20190531083757.GH6896@dhcp22.suse.cz>
 <20190531131859.GB195463@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531131859.GB195463@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 31-05-19 22:19:00, Minchan Kim wrote:
> On Fri, May 31, 2019 at 10:37:57AM +0200, Michal Hocko wrote:
> > On Fri 31-05-19 15:43:12, Minchan Kim wrote:
> > > There is some usecase that centralized userspace daemon want to give
> > > a memory hint like MADV_[COLD|PAGEEOUT] to other process. Android's
> > > ActivityManagerService is one of them.
> > > 
> > > It's similar in spirit to madvise(MADV_WONTNEED), but the information
> > > required to make the reclaim decision is not known to the app. Instead,
> > > it is known to the centralized userspace daemon(ActivityManagerService),
> > > and that daemon must be able to initiate reclaim on its own without
> > > any app involvement.
> > > 
> > > To solve the issue, this patch introduces new syscall process_madvise(2).
> > > It could give a hint to the exeternal process of pidfd.
> > > 
> > >  int process_madvise(int pidfd, void *addr, size_t length, int advise,
> > > 			unsigned long cookie, unsigned long flag);
> > > 
> > > Since it could affect other process's address range, only privileged
> > > process(CAP_SYS_PTRACE) or something else(e.g., being the same UID)
> > > gives it the right to ptrace the process could use it successfully.
> > > 
> > > The syscall has a cookie argument to privode atomicity(i.e., detect
> > > target process's address space change since monitor process has parsed
> > > the address range of target process so the operaion could fail in case
> > > of happening race). Although there is no interface to get a cookie
> > > at this moment, it could be useful to consider it as argument to avoid
> > > introducing another new syscall in future. It could support *atomicity*
> > > for disruptive hint(e.g., MADV_DONTNEED|FREE).
> > > flag argument is reserved for future use if we need to extend the API.
> > 
> > Providing an API that is incomplete will not fly. Really. As this really
> > begs for much more discussion and it would be good to move on with the
> > core idea of the pro active memory memory management from userspace
> > usecase. Could you split out the core change so that we can move on and
> > leave the external for a later discussion. I believe this would lead to
> > a smoother integration.
> 
> No problem but I need to understand what you want a little bit more because
> I thought this patchset is already step by step so if we reach the agreement
> of part of them like [1-5/6], it could be merged first.
> 
> Could you say how you want to split the patchset for forward progress?

I would start with new madvise modes and once they are in a shape to be
merged then we can start the remote madvise API. I believe that even
local process reclaim modes are interesting and useful. I haven't heard
anybody objecting to them without having a remote API so far.
-- 
Michal Hocko
SUSE Labs

