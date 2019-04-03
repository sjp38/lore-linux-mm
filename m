Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5535C10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:38:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C76F206B7
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:38:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C76F206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC5D46B0008; Wed,  3 Apr 2019 04:38:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D739C6B000A; Wed,  3 Apr 2019 04:38:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C62FC6B000C; Wed,  3 Apr 2019 04:38:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7AB596B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 04:38:00 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d2so6982382edo.23
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 01:38:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xi5j8B5xWpkT+mF023w+1k9+66znwrl5G8DucQWmov4=;
        b=cxqpIgqfiJ0LXA6O5o/FlXVRVDZ/M0VD3nSTwTTnIe5Jgr9GLXGMEy7KSSA3fyAFSb
         ctKTw/00HdJSciUNEHHNiL/AjS1hSNmpgWx27k+7hl9l20iaotiAT2ereTQynSchi//E
         fPp0PCpaBhfV/UZO9DWx7A/ANkiKU3EAF75v9VxiTBybnXdvQy8wB1iYT99nxUYoeyda
         rq7t+Ynl0Tb9RcVil1MB3hXcrHLbbQjT2/EfZKoWoq4yf0/RiV0JZiG7n4Myp3nZsma0
         8mvZDWBwMG1VYvLB4tMzWh6E+YsaWSX94USqHyZ82ohdvCHABI+pu97QL6S4lwwYv0ZS
         JDrg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXRrz++lZZKZ7DtUf9c+NKIZFl2LNqCCXXmML7OWTH1i9ydqHwO
	ejLcHguff0I0YMLr/TjEDRjEHcjzstk0XOUb0fIN6UgRPQMNnFXnJ1Yh2HPJpUL2wXY/U0p3ayO
	K9ZGe4T4DVNVWyYprwbC3BMz9UnU68B2DfR5KcytPK+Cl9+KCOC2vbN0cvMBTco4=
X-Received: by 2002:a50:f319:: with SMTP id p25mr3407302edm.87.1554280680057;
        Wed, 03 Apr 2019 01:38:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/VHDLXc/gMbJ6GOPGEYWU/VWvfxkxmxnEPTuzVUexodz9SLazEpw6sQ/StRbxkG+nEnB/
X-Received: by 2002:a50:f319:: with SMTP id p25mr3407266edm.87.1554280679337;
        Wed, 03 Apr 2019 01:37:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554280679; cv=none;
        d=google.com; s=arc-20160816;
        b=uqK5hWDgGDEe9KzBqfr/HyX0NJcqWMdyk6erg+qTr44eTWayk50sI/TIpvhXlWNMME
         r4N9uN2eyqbvM3EDeuBVb6+aBm2PF1mn/6AYTPgtpckhcrYR97S/MUGEcQ03YLyul01O
         eC64eteHtIWa5Sb7hWoLqk/BCzgX0wMcLQ6AlebsgblMK3AAtIJj2HT/FIvYfhkRIo6u
         3WTqU0XLYT1gx6NkwjrCPUYePyKYKR4SxMEHPXO2+5dqJUCt7TOYO1taiQ1gaFTy6UKt
         45Ia93JFjQkdA9GGUlXErH+PSSfoQPrRvns0D/8T5mdUBNjZYSQiVR+yk92oa/UVJRLG
         kKVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xi5j8B5xWpkT+mF023w+1k9+66znwrl5G8DucQWmov4=;
        b=BGUUN6jAedR+gGW3V9hYg9G/THCObr3rEYthC0shCrsA25Hu4r4iGT13PUiSoNNkad
         t26iJG5kJX6Lk1Rpnqdt9G+YqV5D/57s3+8Zfem9aW4kCgN/S1HmyP2mhpqGxAIdFXxH
         N4r/I8ol3TBQo9oHbHgtwYQ5BEZW+ASNxcSI/O2MKYNaYaS0mW/C48Oo/UXQj5QgB00D
         BjXTsYe6UN1BwXDaTkiR84GHz8ARdf1IeSO4/nZb7xFpqkEKe//mRWoQ2/2P/oEfPUNE
         8UQ5AqkkzfQTzfzQc+1bpC5vPBpJ0WIFKoA4DV5ItrMJoZdCR1Il1bZq7QzR/d4J58pt
         PTrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w7si1274552edu.115.2019.04.03.01.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 01:37:59 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BD974AD07;
	Wed,  3 Apr 2019 08:37:58 +0000 (UTC)
Date: Wed, 3 Apr 2019 10:37:57 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org,
	dan.j.williams@intel.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
Message-ID: <20190403083757.GC15605@dhcp22.suse.cz>
References: <efb08377-ca5d-4110-d7ae-04a0d61ac294@redhat.com>
 <20190329084547.5k37xjwvkgffwajo@d104.suse.de>
 <20190329134243.GA30026@dhcp22.suse.cz>
 <20190401075936.bjt2qsrhw77rib77@d104.suse.de>
 <20190401115306.GF28293@dhcp22.suse.cz>
 <20190402082812.fefamf7qlzulb7t2@d104.suse.de>
 <20190402124845.GD28293@dhcp22.suse.cz>
 <20190403080113.adj2m3szhhnvzu56@d104.suse.de>
 <20190403081232.GB15605@dhcp22.suse.cz>
 <d55aa259-56c0-9601-ffce-997ea1fb3ac5@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d55aa259-56c0-9601-ffce-997ea1fb3ac5@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 03-04-19 10:17:26, David Hildenbrand wrote:
> On 03.04.19 10:12, Michal Hocko wrote:
> > On Wed 03-04-19 10:01:16, Oscar Salvador wrote:
> >> On Tue, Apr 02, 2019 at 02:48:45PM +0200, Michal Hocko wrote:
> >>> So what is going to happen when you hotadd two memblocks. The first one
> >>> holds memmaps and then you want to hotremove (not just offline) it?
> >>
> >> If you hot-add two memblocks, this means that either:
> >>
> >> a) you hot-add a 256MB-memory-device (128MB per memblock)
> >> b) you hot-add two 128MB-memory-device
> >>
> >> Either way, hot-removing only works for memory-device as a whole, so
> >> there is no problem.
> >>
> >> Vmemmaps are created per hot-added operations, this means that
> >> vmemmaps will be created for the hot-added range.
> >> And since hot-add/hot-remove operations works with the same granularity,
> >> there is no problem.
> > 
> > What does prevent calling somebody arch_add_memory for a range spanning
> > multiple memblocks from a driver directly. In other words aren't you
> 
> To drivers, we only expose add_memory() and friends. And I think this is
> a good idea.
> 
> > making  assumptions about a future usage based on the qemu usecase?
> > 
> 
> As I noted, we only have an issue if add add_memory() and
> remove_memory() is called with different granularity. I gave two
> examples where this might not be the case, but we will have to look int
> the details.

It seems natural that the DIMM will be hot remove all at once because
you cannot hot remove a half of the DIMM, right? But I can envision that
people might want to hotremove a faulty part of a really large DIMM
because they would like to save some resources.

With different users asking for the hotplug functionality, I do not
think we want to make such a strong assumption as hotremove will have
the same granularity as hotadd.


That being said it should be the caller of the hotplug code to tell
the vmemmap allocation strategy. For starter, I would only pack vmemmaps
for "regular" kernel zone memory. Movable zones should be more careful.
We can always re-evaluate later when there is a strong demand for huge
pages on movable zones but this is not the case now because those pages
are not really movable in practice.
-- 
Michal Hocko
SUSE Labs

