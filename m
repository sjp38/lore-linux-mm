Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDFF0C48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 15:15:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A27C20B1F
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 15:15:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A27C20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D5226B0003; Thu, 27 Jun 2019 11:15:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0865A8E0003; Thu, 27 Jun 2019 11:15:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB7B78E0002; Thu, 27 Jun 2019 11:15:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9AEB16B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 11:15:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c27so6248831edn.8
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 08:15:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7OR3WboDdjwMiZvKMKTbKP7KeumlfsgbRe9s5up+hVc=;
        b=LTAEbMk5rdMFWeiGHYQTPTgkFBM4gfBg7pAfTU0Z+Cx/1qkN19MHeeU0mW+9DbPH+F
         DRAci5F3C8tDDyo6ARlydtiNFDI7sGp79UuC7TcYJlgUof3J8QhXENFzS4xL/XFy4NJe
         pJpaxaGOoFC2djJur26pZqFcj+owpy+57r+ILJjf4889HZLQiNIDy1UsAbdIV5qfudRD
         JyBchMo9J0uQ9oezQwzLnhKtFbxwmmkgMKWWnMzbjnSFdsi1opRVQF4U5YHK1j1goaKw
         jzl0LErwKLuPYDmuEf4+2+3tx1hYjpfiABvOVOPBuBD1Qt8bb0m7/hiF7aWGMlDRfhJE
         uJtg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXIUporp4g7rLy4I57GkqrI5++dcICNeLCFMe490EtLNDbbpbYW
	d4uBfrS0n3KPwvgcKVKZdgWqJqv7OVb4L25nxvMpenPUaLrIAV0aJcTYbURJWKYwAmFluvfRJTf
	1F9lFZ6n9EMximqmE32Oo4Z9+dVTHr6hiVualg6PVewgeSA33ZIZccu+FpHIZ6dQ=
X-Received: by 2002:a17:906:3043:: with SMTP id d3mr3698708ejd.93.1561648510145;
        Thu, 27 Jun 2019 08:15:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQR2SdzhGp1qzi11YsSYxU+LhCZqHK7BWX9KGO7CUCKNJJg19AteBiGNV+frthA2VCLQMR
X-Received: by 2002:a17:906:3043:: with SMTP id d3mr3698614ejd.93.1561648509221;
        Thu, 27 Jun 2019 08:15:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561648509; cv=none;
        d=google.com; s=arc-20160816;
        b=CS8x6oz1IGhDQlPpM8Ngkb32vL++WOv2bNQJiv9C1rAgM8cDBzSsLzOsx5GQbZk/vB
         Fr0arqSCOSn7/Gpsb8o1xA6dcIMDA8NAyJMbvJ+ne/6nhFY7lqyhW4mETKscBMiTlEb9
         JWng2P1HZrJwSimWTd7tNcyTbVq+uzysEzWpXzK18hu0NlKzErAmvabR7IjNrncRgizl
         2s7MAix6OC3ltv8tfrJn57eZryv5rTYE8iHFXGFQKdkHM/YT1wQ0PHp6fX3iqSz/jtOo
         21Yaag3PhWMUpyJ8M4TCkGYRO20R9hApG37JQ9+HjR3UydEr9Bbm/5KzUQ6XbRc073Rf
         7CvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7OR3WboDdjwMiZvKMKTbKP7KeumlfsgbRe9s5up+hVc=;
        b=zAH9kFG4UMsbgSxjy+I8JduCOQ72iLqcCzIjxQ3A8hG5hBjIbvJRxDArRixNfS0cM+
         VK+SEh2KLBBgqGN6vkEvzWcWCYRqfnfo7ghENQS/cOEaxwDf/YE823zemk5ObMlgq7uW
         6QXQ2muR7daaM2MdIayPsoU3UsMbrEumBtkxCEtCtJKKotBP1wJAFUgA7J4TM2qirGqN
         8NYe2ccbw6iNTEWF/a141rCJqFh7fbl2xG4oIth/B6HHGCN+XszuqJ8q65UqibYpZr/q
         BDPZ+sbcEwCI6f7qaZMGXD59MycTtElgcjoY9U99czogu9NDlWj8VCpS6MorX++TmoTP
         AD1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d16si2106149ede.18.2019.06.27.08.15.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 08:15:09 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A290BABC4;
	Thu, 27 Jun 2019 15:15:08 +0000 (UTC)
Date: Thu, 27 Jun 2019 17:15:06 +0200
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
Subject: Re: [PATCH 2/2] mm, slab: Extend vm/drop_caches to shrink kmem slabs
Message-ID: <20190627151506.GE5303@dhcp22.suse.cz>
References: <20190624174219.25513-1-longman@redhat.com>
 <20190624174219.25513-3-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190624174219.25513-3-longman@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 24-06-19 13:42:19, Waiman Long wrote:
> With the slub memory allocator, the numbers of active slab objects
> reported in /proc/slabinfo are not real because they include objects
> that are held by the per-cpu slab structures whether they are actually
> used or not.  The problem gets worse the more CPUs a system have. For
> instance, looking at the reported number of active task_struct objects,
> one will wonder where all the missing tasks gone.
> 
> I know it is hard and costly to get a real count of active objects.

What exactly is expensive? Why cannot slabinfo reduce the number of
active objects by per-cpu cached objects?

> So
> I am not advocating for that. Instead, this patch extends the
> /proc/sys/vm/drop_caches sysctl parameter by using a new bit (bit 3)
> to shrink all the kmem slabs which will flush out all the slabs in the
> per-cpu structures and give a more accurate view of how much memory are
> really used up by the active slab objects. This is a costly operation,
> of course, but it gives a way to have a clearer picture of the actual
> number of slab objects used, if the need arises.

drop_caches is a terrible interface. It destroys all the caching and
people are just too easy in using it to solve any kind of problem they
think they might have and cause others they might not see immediately.
I am strongly discouraging anybody - except for some tests which really
do want to see reproducible results without cache effects - from using
this interface and therefore I am not really happy to paper over
something that might be a real problem with yet another mode. If SLUB
indeed caches too aggressively on large machines then this should be
fixed.

-- 
Michal Hocko
SUSE Labs

