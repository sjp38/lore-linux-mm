Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DECBC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:25:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 207E920659
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:25:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 207E920659
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BAF038E0007; Wed, 31 Jul 2019 09:25:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B5CFD8E0001; Wed, 31 Jul 2019 09:25:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A26A08E0007; Wed, 31 Jul 2019 09:25:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 56BE18E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:25:36 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k22so42427734ede.0
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 06:25:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hEDYlVVYWMC1Ij5F+RgIQsJIlwLt6Apx6ynIPK4Rls8=;
        b=Kfbo0vGYRfQmSKgMesSEOsR/zbzKHDHUlUPUHl3O5eynNEfYhUvvXt5X0/N2MuvRiZ
         v78salOEPXBMn/5R04A06xtPO8O7LTNOQWTDLt2rNDifChRAGztTtl5QI33g7r0kDRcQ
         V5E67MzkeMMGFjvGsNxQ4y3vzgiXlwO341SwVlkogFHR8pROmB8ABl131Kw23dDd82Jm
         Fr9Z97BC+rzp9D3Z9BVRfijmOz88hz7vpnGsetuw8rmRxuWP6kQJ4H4drH9aufjTAhWU
         /WFAk0W95w80c3IRmlQt2H29amimaBv0Xy2/EiQe24bBFHjdiXCD/r7lQmC/SCEkYrFI
         v68w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW3jI6OfTQ74zOXFrau0S0VlK3n0mcken6/aMGn09Kh6ATRy9p3
	fNHFP2RG1HfFCsO0PWGyZw/9vleZ39QTLzjVbD/XdDc7ovQgeVAITIvA2S+IgGA7tfEoJnwdRkE
	lKSfOsdGIVg6OTWxLiwVZjm1BgF5GLZhqoPiB6il4Lq+aQU7DnGCj6/NfjRdZkNI=
X-Received: by 2002:a17:906:1804:: with SMTP id v4mr96560629eje.188.1564579535902;
        Wed, 31 Jul 2019 06:25:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy49uYAlaiGruckaSHHiUfql5Oa4TPfi7AQr3kS7QVZ2rwfMI+JeuCjD8noHtTmqzXKD1ie
X-Received: by 2002:a17:906:1804:: with SMTP id v4mr96560565eje.188.1564579535151;
        Wed, 31 Jul 2019 06:25:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564579535; cv=none;
        d=google.com; s=arc-20160816;
        b=1A9Uuvv66tQspnFNIp34sf6rhHM3bnK+GN932QLoKESmXkn4ki0CRrn3b3wi6q4Y79
         D66dY/7Qc2LM6vttd9DMRS/XTCxOpDEEd42KmC6afYkmGCySaNaZlgXFk5ZWkwS8JM9U
         DHm25M1DeEM6NAJtkTJw6Dq28rnc50HfpLwOJHu0RZvywxGEutIq5F4Uy4yCFiKiz3o/
         mbhd4Jsg0+AhWsl7B6uOQkeuPZi+FJ9el/BHnazzkVEZENy4lOuPZkfANBeSoC09S6ky
         2Adx62tUvuo1Pj07SQokvuvB+D/iGNMYmlGwr7KXyHqSYuTEofdke/qhT9+qhA8p7R8o
         gvnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hEDYlVVYWMC1Ij5F+RgIQsJIlwLt6Apx6ynIPK4Rls8=;
        b=BK2Iu51lhOdyx85AaA+gwtnkmROQxYHvNv0E3OL5V1o7Xs0q+NOg87ehzxzCQCM9o/
         15zBuC8lP+wfOqAsRMfwAAjdATdGoPCkXSDrmHJk4lXy0xhhqKsJ8aVFaRVU8+5oXGrs
         4D1ZDWm35snpTiGPWJVqIsppUx/2223V6ptq50YCNHqHOZ5YUeIshzR3JNpFLoJN3Muz
         l78QrQ+OS/NfacFGskFELMaCZpEzBHj34pQT+eN3n5+Iyz64YZTBIbFreaV7LpkLNS2z
         AMXS0XjeF4uQrv9HeHQnCwEURsVlOzw/jLiaR/XIZItOB7fvW3jU8UrnK6nZiV+lk2W8
         nFMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m7si18733268ejc.279.2019.07.31.06.25.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 06:25:35 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AD6DAAE21;
	Wed, 31 Jul 2019 13:25:34 +0000 (UTC)
Date: Wed, 31 Jul 2019 15:25:34 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v1] drivers/base/memory.c: Don't store end_section_nr in
 memory blocks
Message-ID: <20190731132534.GQ9330@dhcp22.suse.cz>
References: <20190731122213.13392-1-david@redhat.com>
 <20190731124356.GL9330@dhcp22.suse.cz>
 <f0894c30-105a-2241-a505-7436bc15b864@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f0894c30-105a-2241-a505-7436bc15b864@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 31-07-19 15:12:12, David Hildenbrand wrote:
> On 31.07.19 14:43, Michal Hocko wrote:
> > On Wed 31-07-19 14:22:13, David Hildenbrand wrote:
> >> Each memory block spans the same amount of sections/pages/bytes. The size
> >> is determined before the first memory block is created. No need to store
> >> what we can easily calculate - and the calculations even look simpler now.
> > 
> > While this cleanup helps a bit, I am not sure this is really worth
> > bothering. I guess we can agree when I say that the memblock interface
> > is suboptimal (to put it mildly).  Shouldn't we strive for making it
> > a real hotplug API in the future? What do I mean by that? Why should
> > be any memblock fixed in size? Shouldn't we have use hotplugable units
> > instead (aka pfn range that userspace can work with sensibly)? Do we
> > know of any existing userspace that would depend on the current single
> > section res. 2GB sized memblocks?
> 
> Short story: It is already ABI (e.g.,
> /sys/devices/system/memory/block_size_bytes) - around since 2005 (!) -
> since we had memory block devices.
> 
> I suspect that it is mainly manually used. But I might be wrong.

Any pointer to the real userspace depending on it? Most usecases I am
aware of rely on udev events and either onlining or offlining the memory
in the handler.

I know we have documented this as an ABI and it is really _sad_ that
this ABI didn't get through normal scrutiny any user visible interface
should go through but these are sins of the past...

> Long story:
> 
> How would you want to number memory blocks? At least no longer by phys
> index. For now, memory blocks are ordered and numbered by their block id.

memory_${mem_section_nr_of_start_pfn}

> Admins might want to online parts of a DIMM MOVABLE/NORMAL, to more
> reliably use huge pages but still have enough space for kernel memory
> (e.g., page tables). They might like that a DIMM is actually a set of
> memory blocks instead of one big chunk.

They might. Do they though? There are many theoretical usecases but
let's face it, there is a cost given to the current state. E.g. the
number of memblock directories is already quite large on machines with a
lot of memory even though they use large blocks. That has negative
implications already (e.g. the number of events you get, any iteration
on the /sys etc.). Also 2G memblocks are quite arbitrary and they
already limit the above usecase some, right?

> IOW: You can consider it a restriction to add e.g., DIMMs only in one
> bigger chunks.
> 
> > 
> > All that being said, I do not oppose to the patch but can we start
> > thinking about the underlying memblock limitations rather than micro
> > cleanups?
> 
> I am pro cleaning up what we have right now, not expect it to eventually
> change some-when in the future. (btw, I highly doubt it will change)

I do agree, but having the memblock fixed size doesn't really go along
with variable memblock size if we ever go there. But as I've said I am
not really against the patch.
-- 
Michal Hocko
SUSE Labs

