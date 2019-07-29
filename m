Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D7E6C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 09:17:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3BA3206DD
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 09:17:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3BA3206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F4728E0005; Mon, 29 Jul 2019 05:17:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87CBE8E0002; Mon, 29 Jul 2019 05:17:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 744A68E0005; Mon, 29 Jul 2019 05:17:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 21E398E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 05:17:41 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o13so37908790edt.4
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 02:17:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=iNNe+WWPHMeC8bUtBPXbVDY36//V6+aGdo5wx5TBPYY=;
        b=YZ/gEUA9FM4PwyW5e6rD3YBgvYXkikpeBGCL8jubT4T73LTTvWXNE54bIsfZCREAFd
         5sMCoSCUYbIeJyOAm5ElWZ3tn2nOy+qQdsnqr9k7csYSRSipx4gSIVDWYKqjR/5B8ucd
         ELBnIMM/fIdISuEMwjgV8uflDxkxmmn9hzUUCnZYRBqQx+acXu2nys8E8Bg73Qo/qXBt
         xeNjCXiVa0WQuHs+LMj9dlGJyCs5TNh7z5JTSTPFmbjmrSZIm8uNvSD0drlynCEi//Ig
         D8KwsKDVP7XgjiW5fueMvQ1WDXr4nSgrOb6Up7bTEyYH44M9rnQrB49UgW6f3jvF8du3
         5vww==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXQBqD9FL4LkCJ1Uh5NZe18arK+0FWKDDjJU4dKrSNCBewOLxAu
	Owpwn5VU1wZM9Brn2vOSLkbtKMYQa0cYy9BVRcKIDk67RgjiKFVEhBXSiO7l7aU5BIAwVNBfGe7
	VJeOQ+2ZNm6Bb4ghIMxK47Eg5QrrM52q4mkkSRX+2ya7nkap3H/mFDgNTWdJrPpQ=
X-Received: by 2002:a17:906:fac7:: with SMTP id lu7mr49526341ejb.109.1564391860690;
        Mon, 29 Jul 2019 02:17:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJfwhJa8d59aWaSNoTOyCeimb3gZ7zzgcwo4qWkv6I3MrLEjFDW2p0jEtrFTfPaFeyUjo5
X-Received: by 2002:a17:906:fac7:: with SMTP id lu7mr49526293ejb.109.1564391860004;
        Mon, 29 Jul 2019 02:17:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564391860; cv=none;
        d=google.com; s=arc-20160816;
        b=BDoVZdxIx6YjocnxgJrsS5R7hTrRu+JpMKXhkau3tD6YNHOABQXc+ABwrOJNEGi0eR
         k1TR/r0Q4QIbmVLFveaiN9pKxdwuOfXiSSisLfWN0nFmHIdW3Gm7Tcw0QZ8BC50eZGXV
         QxHF6oS4quN4+7KfmRc3KRRHARRt4G4Nz6TJ+I7MC1GSuhoNbkmRv8O0PnhqMUI19pRy
         OYzlivJ9QTmAL2ywsf6E29lqPTJseJ0f4S+kVMGDG8A5uA/wM/awDeQqRIb3xZGeyOPZ
         yrf/SjN8WulqMp81dqiqb14m4DjuS1R9TT581oFvs8o6COj+kkwAVwohiCSQL4sV7gkr
         h4Vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=iNNe+WWPHMeC8bUtBPXbVDY36//V6+aGdo5wx5TBPYY=;
        b=HTZruR1d5muYmhnf4i1EQnu8v9Q3Db8I+4HCyD40FxOwn8i4ZeXIYkAuja30qgEwlD
         dZbdSiJ3X8V6QBKO6sj4WCz+gzi+G6+3NjnTzZjLX0svS3vSI/ONFEqLQq7DNl+BQryc
         O1Qqf+K/Iqx19N3OEfCVJyU2qLkI7OHOEE3D0dTC7qGIx8/YDLsr9J978IkFy1vqZIyv
         duLzFy2g0yuAEoF3MdHNotnXY09aGOUdiKBNRhnH6zUJ0XIXyyZzVWGEGfjbZkZvO9ea
         42Z/9mUhZVBzczgHTnS0/7GC4w6KOfkIHDOEhRKog9IG1ROLEHiL+LhIL4K56/JAnOBh
         1sVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b30si16908354edb.12.2019.07.29.02.17.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 02:17:39 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2C442AEFD;
	Mon, 29 Jul 2019 09:17:39 +0000 (UTC)
Date: Mon, 29 Jul 2019 11:17:38 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC] mm/memcontrol: reclaim severe usage over high limit
 in get_user_pages loop
Message-ID: <20190729091738.GF9330@dhcp22.suse.cz>
References: <156431697805.3170.6377599347542228221.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <156431697805.3170.6377599347542228221.stgit@buzz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun 28-07-19 15:29:38, Konstantin Khlebnikov wrote:
> High memory limit in memory cgroup allows to batch memory reclaiming and
> defer it until returning into userland. This moves it out of any locks.
> 
> Fixed gap between high and max limit works pretty well (we are using
> 64 * NR_CPUS pages) except cases when one syscall allocates tons of
> memory. This affects all other tasks in cgroup because they might hit
> max memory limit in unhandy places and\or under hot locks.
> 
> For example mmap with MAP_POPULATE or MAP_LOCKED might allocate a lot
> of pages and push memory cgroup usage far ahead high memory limit.
> 
> This patch uses halfway between high and max limits as threshold and
> in this case starts memory reclaiming if mem_cgroup_handle_over_high()
> called with argument only_severe = true, otherwise reclaim is deferred
> till returning into userland. If high limits isn't set nothing changes.
> 
> Now long running get_user_pages will periodically reclaim cgroup memory.
> Other possible targets are generic file read/write iter loops.

I do see how gup can lead to a large high limit excess, but could you be
more specific why is that a problem? We should be reclaiming the similar
number of pages cumulatively.
-- 
Michal Hocko
SUSE Labs

