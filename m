Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB234C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:31:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47BC32173C
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:31:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="1hwtmF+h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47BC32173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD8876B0003; Thu, 11 Apr 2019 11:31:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A888B6B0005; Thu, 11 Apr 2019 11:31:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 976FC6B000D; Thu, 11 Apr 2019 11:31:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 732246B0003
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 11:31:21 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id y1so4611656ybg.1
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 08:31:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=3iJKixxuhPHlPoZGh40Oi3FjBSMfJGKskcYDOhWiKGQ=;
        b=ZOUWmtAsR114oUpYCBWW17DGRwlj3DydOcPhu6N+LvHw/bXhsKbYD1S5NTCuYIXrh4
         2KKVHrNAEVLTQwHl3JhbgyUrxrZpSV8927Yoc2aDBP7tNUb507QT3/YrK4otW+vd65XZ
         zob7f75rmNTDqRCjN+HFMXML39JCkJ+iphSSuS8Ne4xNo8U2Wx3dAW3Uo9b06GKYjoFO
         mSnTne/zeVfyOUVBbSds5BRo8x5DPaaDzQpjwyZUuP0rCi8kF779JksiPrr+RtlsjGm2
         R6upZECu7yTbrDFWgQkVUH2S8NUuHsssj31bpRr0IrWsyTiqUiSED8iKHb1vM1uwqeJA
         jojw==
X-Gm-Message-State: APjAAAX4u3eadBf8aM5sv0yXBPodiJVkrVX+aKNdiwYT7x7CO5ml1Bbi
	llkxcurmTTnkLjBhnnhG4JCwnWEXNbS5GwO5nkdd7nVvEd5J9KTzzqf/oDFTIps81z1E/VNF+BS
	8CqWC/J98BrGE640Bt0/yS8WgkJm3O2EZ4yuX+nUr6LGH2KrXWS9z0RW81DMOQrteVg==
X-Received: by 2002:a81:a115:: with SMTP id y21mr40893835ywg.296.1554996681124;
        Thu, 11 Apr 2019 08:31:21 -0700 (PDT)
X-Received: by 2002:a81:a115:: with SMTP id y21mr40893765ywg.296.1554996680319;
        Thu, 11 Apr 2019 08:31:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554996680; cv=none;
        d=google.com; s=arc-20160816;
        b=jEZr+MeI4/XbSHVgX5dMSsKysKXxgaPAJq5+wBtef5r0QntkVh3a/cLAlDC6K8nT7+
         3RPDumKDYbU999YRLNkDq6mdmGGoVstQtrzoIpXU07CbaxCBhPP3hxigaZhTdNIDMon9
         /brH56R19TOWib3S9/jre78xFk63WJg5MeVwdur5jX3wNCjY4sKEnw4mShYcYRVISvTT
         XFmeqQsUbp0wPK+53KVWhsDrYGnjXjsc46wqQ6l70BtnE9S4loG1GupYyZYsWY7GSHtj
         ryFvv7h8gQutYyHLFMfuUu5Vyg8pmpnLdohM+uwdvOheMVJvQDT0MMv3SV11UYG6x5IB
         gyjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=3iJKixxuhPHlPoZGh40Oi3FjBSMfJGKskcYDOhWiKGQ=;
        b=fRmSxQxRNFI4FXnbLfiWaa0TCXgl6oOwo08MgBWj8NCz88QWAp4DMJzQ73QMtqVngM
         VxB6iSpZAz0/X9BeENjLQpCHSABUOsaoe9h4bPd3zaE8t5H3wEttlHNkoEkmlJwsoe/N
         gEQx52fB6mafmS+FnEenJPvzEql8avGH4fGT46AmIwRtrxSjT+9CrPBwT512xvQ2YtLo
         erWsAk5larMNuhdyhOUU5snJZyEi2YTcivlxmQ8f+44liVEd7cwUwa9/PeqbScqaKly+
         z9Y9wVFc3zdHuPUD87FA1e+rk7yLbYYKTuDFEbZAbGx952mOk+QdfUIs8fdZKz2BFIL/
         0Q+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=1hwtmF+h;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 189sor21782913ybi.189.2019.04.11.08.31.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 08:31:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=1hwtmF+h;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3iJKixxuhPHlPoZGh40Oi3FjBSMfJGKskcYDOhWiKGQ=;
        b=1hwtmF+hHKwJ6ukgkNYfDzhggthKX24NSk2lZP6PHZKK0OuNX/iwCbFuFzPm57tK2P
         gdNbZDktsfSgeGeQ08V+cWQQmM0Jw9isIS3WhHhuBTBJs2BToG6Tb/eO7VtZT59u6C0V
         aMA/z6Z3nDieLbf8Pn1TG/Xw4o+Td3G5OUt8msHHo+q/xNxiOR6PHHQXP5i2DL22SxZS
         yH7x9QB6XSulVn4JbEd2bqKkJKiFN4KVm9Z7DnJO4wXcwe1DtLf+7FHHDf3aOuEHrf0U
         NlNYSwvNKgcrNkisAliIuUeCvEh/7u7of22dG3702V13GJKwj6q5D4lfNuB0qJuxBKmm
         70SA==
X-Google-Smtp-Source: APXvYqzuP7mXVps+wydtaxT46o4Hr126QvRlymscA1wR/cFGUUcqB+O2cYv4Je4UHlaqQtB0/Ye0wQ==
X-Received: by 2002:a25:68cb:: with SMTP id d194mr19752622ybc.33.1554996675392;
        Thu, 11 Apr 2019 08:31:15 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::3:2a81])
        by smtp.gmail.com with ESMTPSA id i139sm11910189ywa.101.2019.04.11.08.31.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Apr 2019 08:31:14 -0700 (PDT)
Date: Thu, 11 Apr 2019 11:31:13 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Waiman Long <longman@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>, Jonathan Corbet <corbet@lwn.net>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>, Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC PATCH 0/2] mm/memcontrol: Finer-grained memory control
Message-ID: <20190411153113.GA32469@cmpxchg.org>
References: <20190410191321.9527-1-longman@redhat.com>
 <20190410195443.GL10383@dhcp22.suse.cz>
 <daef5f22-0bc2-a637-fa3d-833205623fb6@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <daef5f22-0bc2-a637-fa3d-833205623fb6@redhat.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 10:02:16AM -0400, Waiman Long wrote:
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
>
> Anonymous memory, on the other hand, are not shared and so can more
> correctly represent the memory footprint of an application. Of course,
> there are certainly cases where an application can have large private
> files that can consume a lot of cache pages. These are probably not the
> case for the applications used by that customer.

I don't understand what the goal is. What do you accomplish by only
restricting anon memory? Are you trying to contain malfunctioning
applications? Malicious applications?

Cache can apply as much pressure to the system as anon can. So if you
are in the position to ask your applications to behave wrt cache,
surely you can ask them to behave wrt anon as well...?

This also answers only one narrow question out of the many that arise
when heavily sharing cache. The accounting isn't done right,
memory.current of the participating cgroups will make no sense, IO
read and writeback burden is assigned to random cgroups.

> >> For simplicity, the limit is not hierarchical and applies to only tasks
> >> in the local memory cgroup.
> > This is a no-go to begin with.
> 
> The reason for doing that is to introduce as little overhead as
> possible. We can certainly make it hierarchical, but it will complicate
> the code and increase runtime overhead. Another alternative is to limit
> this feature to only leaf memory cgroups. That should be enough to cover
> what the customer is asking for and leave room for future hierarchical
> extension, if needed.

I agree with Michal, this is a no-go. It involves userspace ABI that
we have to maintain indefinitely, so it needs to integrate properly
with the overall model of the cgroup2 interface.

That includes hierarchical support, but as per above it includes wider
questions of how this is supposed to integrate with the concepts of
comprehensive resource control. How it integrates with the accounting
(if you want to support shared pages, they should also be accounted as
shared and not to random groups), the relationships with connected
resources such as IO (in a virtual memory system that can do paging,
memory and IO are fungible, so if you want to be able to share one,
you have to be able to share the other as well to the same extent),
how it integrates with memory.low protection etc.

As it stands, I don't see this patch set addressing any of these.

