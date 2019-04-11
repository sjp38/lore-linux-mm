Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33A2AC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:19:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E06712083E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:19:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E06712083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 677E16B0005; Thu, 11 Apr 2019 11:19:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FD9A6B000D; Thu, 11 Apr 2019 11:19:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C60C6B000E; Thu, 11 Apr 2019 11:19:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id ED0176B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 11:19:17 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h22so1957619edh.1
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 08:19:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gvkErz07z/zs6QLuG75dNvZDEXuPwxUe15TghfaWU2E=;
        b=nX/ckVWmfh32aqT6UzUQfLx3xWmUkSUiAYvfIbbUmyEnlk1nsjd2SqaPyOgYB6QoOd
         ifLWF1jN7oqQOz0bd2qxBn60+2oX5MSi4G/KQgVgbPB8Gfna1iVGAjn0NLuopXqH1xYt
         0HbNX4W4yETNDuNtpXhJRLUcWhBDLTBUdn2cZ1M/flX2WRRT7lN4DLwLb9X1HTTPUCOJ
         55P6DWScwknUQq/PClisLWTBL33wEoxmEMhjPySm3YuR2AF/1PE6WsrSNziW1OZkEoEA
         ZX+y9pGkCirG4flKMmhwJtEaNrDrdvJRnms8rNgNn506u7T88miy+8Bl8nGn16qUbuvn
         g2eg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUZfBpAWIgzGvj0po0rY5quNPg+5ihSplz2G/GSAv5QIdW+TI/2
	QmKKdGtnM9pg6qskrvJNfxScSHsUauHg/UIBx5xR8e3oZr5AtF7mpns/JoUg9aek+ethvSmn/A4
	U5Cf5FMguLoTXCi+M21RtQETa8QBwB+F11djclEMwvFBS8ivneGYdKUXWHN0b5MI=
X-Received: by 2002:aa7:d3d8:: with SMTP id o24mr32333593edr.53.1554995957515;
        Thu, 11 Apr 2019 08:19:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzr2zqrJPazONsBp5xRe0wRqMQQPgitVtH/yzU21omqO5VtjeQDxzmCHfGGhZEwkVikWLtE
X-Received: by 2002:aa7:d3d8:: with SMTP id o24mr32333539edr.53.1554995956743;
        Thu, 11 Apr 2019 08:19:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554995956; cv=none;
        d=google.com; s=arc-20160816;
        b=T95qsW+gAB06ZWfnsz80iweko4ZLmT5lPX3OV9wlgF5SSkSfoo7bZj3hVl/NUCzAaP
         dbQgDReMYQPNj50cwREVRYICXxLmjR5i9t6OLnP+/m/DtjRkT8XiBVDob2wX8XBI6g8k
         o8Mwx5WRmLoPgL/ZjYvsVli865NjoeVdDdLvhNVQfTvrMkR8BqzXVQidh7Jh/RJzCqjO
         oHl2S2oxCjnjS2nc5HVs+sPRuT07F1dEDDtrKitBoCC32etMUcE1PbjL8XxYFscqc17x
         4ISUM7GetnYvvI1jvk9YUjt6noQ/MWKZq09A+3Ok6cnhhEvPQtqNxf5a7jfY2Lb+XHEI
         bP4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gvkErz07z/zs6QLuG75dNvZDEXuPwxUe15TghfaWU2E=;
        b=s/qTo5yEozPySAD4Zvg6vtkj5jWH9cqtwjQh6VAq3M1YIwiy4vukTGi39sL7lGoYhf
         BG46e3SCKMpm5qm9Ki9qamE/Cr4VxsgJAD2kvCdQw9pdjXrx41GX3LC3nYjT2tdrm8KC
         B1CGu6e+HDf4AopY7ROe2xYIzdRGJhIMaQAEwzs7aL5R9CW4y3/aIWqWbCKEKQhscBwL
         xII2tBAygFGHu8U4zzJ3XanoOLjPSRDsVvu7cbNmmxYv2BzWaAHEGveU/5pMdBVmyxc9
         XWp1B9aj7YiBFl4+8XOiA713/BVFip693GBV+/R3SXjIAEmncDSrrnWdjtrn7iu1oRBZ
         1NNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p12si1525849edj.372.2019.04.11.08.19.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 08:19:16 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B93ADABE1;
	Thu, 11 Apr 2019 15:19:15 +0000 (UTC)
Date: Thu, 11 Apr 2019 17:19:11 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Jonathan Corbet <corbet@lwn.net>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>, Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC PATCH 0/2] mm/memcontrol: Finer-grained memory control
Message-ID: <20190411151911.GZ10383@dhcp22.suse.cz>
References: <20190410191321.9527-1-longman@redhat.com>
 <20190410195443.GL10383@dhcp22.suse.cz>
 <daef5f22-0bc2-a637-fa3d-833205623fb6@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <daef5f22-0bc2-a637-fa3d-833205623fb6@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-04-19 10:02:16, Waiman Long wrote:
> On 04/10/2019 03:54 PM, Michal Hocko wrote:
> > On Wed 10-04-19 15:13:19, Waiman Long wrote:
> >> The current control mechanism for memory cgroup v2 lumps all the memory
> >> together irrespective of the type of memory objects. However, there
> >> are cases where users may have more concern about one type of memory
> >> usage than the others.
> >>
> >> We have customer request to limit memory consumption on anonymous memory
> >> only as they said the feature was available in other OSes like Solaris.
> > Please be more specific about a usecase.
> 
> From that customer's point of view, page cache is more like common goods
> that can typically be shared by a number of different groups. Depending
> on which groups touch the pages first, it is possible that most of those
> pages can be disproportionately attributed to one group than the others.
> Anonymous memory, on the other hand, are not shared and so can more
> correctly represent the memory footprint of an application. Of course,
> there are certainly cases where an application can have large private
> files that can consume a lot of cache pages. These are probably not the
> case for the applications used by that customer.

So you are essentially interested in the page cache limiting, right?
This has been proposed several times already and always rejected because
this is not a good idea.

I would really like to see a more specific example where this makes
sense. False sharing can be certainly happen, no questions about that
but then the how big of a problem that is? Please more specifics.

> >> To allow finer-grained control of memory, this patchset 2 new control
> >> knobs for memory controller:
> >>  - memory.subset.list for specifying the type of memory to be under control.
> >>  - memory.subset.high for the high limit of memory consumption of that
> >>    memory type.
> > Please be more specific about the semantic.
> >
> > I am really skeptical about this feature to be honest, though.
> >
> 
> Please see patch 1 which has a more detailed description. This is just
> an overview for the cover letter.

No, please describe the whole design in high level in the cover letter.
I am not going to spend time reviewing specific patches if the whole
idea is not clear beforhand. Design should be clear first before diving
into technical details.
 
> >> For simplicity, the limit is not hierarchical and applies to only tasks
> >> in the local memory cgroup.
> > This is a no-go to begin with.
> 
> The reason for doing that is to introduce as little overhead as
> possible.

We are not going to break semantic based on very vague hand waving about
overhead.

> We can certainly make it hierarchical, but it will complicate
> the code and increase runtime overhead. Another alternative is to limit
> this feature to only leaf memory cgroups. That should be enough to cover
> what the customer is asking for and leave room for future hierarchical
> extension, if needed.

No, this is a broken design that doesn't fall into the over cgroups
design.

-- 
Michal Hocko
SUSE Labs

