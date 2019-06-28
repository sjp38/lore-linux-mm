Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D050C5B57A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 07:10:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 198CD2133F
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 07:10:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 198CD2133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A40136B0003; Fri, 28 Jun 2019 03:10:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EEBF8E0003; Fri, 28 Jun 2019 03:10:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B7338E0002; Fri, 28 Jun 2019 03:10:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 401386B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 03:10:55 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b33so8042764edc.17
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 00:10:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=OWlEgFi+9l5eCWLRLWI5CkJSk8sU1D874zUwZJ7hipM=;
        b=acgQJI+1Kq8UDMmok68FodwP7lwWYA9M4v6QCjDZ646FyUPyp5PVt5ZEyOv6R+7vzp
         qUeJUOEWuRi+KjbLvI7dT0Dqo9EMBee5dH/rc96gDoNY3FGST4cLb9NTYuGy3hjNKo9E
         3DHIO7lsq4wVye3eQxYgL9zH8EvHjqDoXo8MWZ3rFOStUXlbiVH8K9U91CBdJkCfRxCj
         jfrFGQkSodK2EYhf10J100ejbHDWqKlnT9jlN5+TGnj/YBQ48oyv2GOjrFtOKQNaxxkB
         C2aitK1otrnOU/Qg3e+wnERbGnFreyudjYxoWhwH0Kd+9f2lIfNqyemw5WBjIEltW8z9
         YMuw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU7LRpwxpPoPvJOCF+mBp+6r0DvwzxNHtpOhwLg+FMH9iyLTwZP
	5yKsxs3zgLdMy8zX+glS9Ic5E579AveM4CdiJ0c8hsrCKBgHcBzRyUlpVXFE7UErST6rB9TR5lx
	NBbintid1xNI8dQrWDuZP1dp3+pZuFkhFz0K+goi8RiEc4DI46gOzm/WJ7FkLsOo=
X-Received: by 2002:a17:906:590d:: with SMTP id h13mr7217197ejq.210.1561705854839;
        Fri, 28 Jun 2019 00:10:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJZbhgj1WRaOKAzABGIQIu6mN89/tosHGMtaCaQV4R0HNTn+68ufx37ZvPBWyf5yEFV98Q
X-Received: by 2002:a17:906:590d:: with SMTP id h13mr7217150ejq.210.1561705854034;
        Fri, 28 Jun 2019 00:10:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561705854; cv=none;
        d=google.com; s=arc-20160816;
        b=FDnniH4Ut5UGcpcS9H1OavBjmCFoqPKyEfteiI4lqCrEhSplqA3vJ20Zyxp9aMS9x+
         6lbdcoAyH1THIOg9xah6OHH7nYN9Qk3hyvJvOD8rGbdDglBiMynyRuziZxFAAn3PSo0R
         cMUeh1u1mbzm2WaIPvYpmzwpoweSgOM+EvpabXZ4NZ2BxHLrIQ2/7NlZG6k6HlX0OMkc
         8WwjOBDj8jhVSXv0WMdRQ4SUKWOKAYFh3XXvS9Dl9D0H0BOE7wSS+vgstjBTZTyiG3A/
         TXXwFOqiw50xhCugxG9A6Y8kzbKRoiFzua9GBWx1bxpWlgLN6RHAjSSLGDo+PzQkMIzT
         M8gA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=OWlEgFi+9l5eCWLRLWI5CkJSk8sU1D874zUwZJ7hipM=;
        b=lVk5QIR29rLH2ac5YDsrCV5JP60twLc5ZyiUA/HNWYZypVl45LhgGBKGNW101weVuc
         H9qE0dn0V42zJ/AKAYw50B7Aunc1NbhkByxuHTOPIK4fzNuoEB48KktXI09pnUD9fZv0
         2GR+jzSCkzIU26PeQBvyPJ3eN/+osH5rgjKxxrps9J5a7Lxs3JZo5dxUnD3AjVykFhos
         PNYlCkqAuUns4mHDWQxF5ieaprgmsijHVz9ICUdfRtUTgMMpmZB3b1m/xtD9w4fTy0rf
         yv5QZkKDqFz4QUVVe7kDLn4QeG+1LjiC3M2z5o5WrINBVakIZjSAop6U9YxmZ7m6NEC3
         2tWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h44si1262616eda.49.2019.06.28.00.10.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 00:10:54 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A3B15B16F;
	Fri, 28 Jun 2019 07:10:51 +0000 (UTC)
Date: Fri, 28 Jun 2019 09:10:49 +0200
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
Subject: Re: [PATCH 1/2] mm, memcontrol: Add memcg_iterate_all()
Message-ID: <20190628071049.GA2751@dhcp22.suse.cz>
References: <20190624174219.25513-1-longman@redhat.com>
 <20190624174219.25513-2-longman@redhat.com>
 <20190627150746.GD5303@dhcp22.suse.cz>
 <2213070d-34c3-4f40-d780-ac371a9cbbbe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2213070d-34c3-4f40-d780-ac371a9cbbbe@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 27-06-19 17:03:06, Waiman Long wrote:
> On 6/27/19 11:07 AM, Michal Hocko wrote:
> > On Mon 24-06-19 13:42:18, Waiman Long wrote:
> >> Add a memcg_iterate_all() function for iterating all the available
> >> memory cgroups and call the given callback function for each of the
> >> memory cgruops.
> > Why is a trivial wrapper any better than open coded usage of the
> > iterator?
> 
> Because the iterator is only defined within memcontrol.c. So an
> alternative may be to put the iterator into a header file that can be
> used by others. Will take a look at that.

That would be preferred.

Thanks!
-- 
Michal Hocko
SUSE Labs

