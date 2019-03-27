Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C99EC10F06
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 16:13:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D802A2087C
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 16:13:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D802A2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66FC56B0005; Wed, 27 Mar 2019 12:13:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 620176B0006; Wed, 27 Mar 2019 12:13:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50D976B0007; Wed, 27 Mar 2019 12:13:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 037216B0005
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 12:13:11 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n24so6860953edd.21
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 09:13:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bg3tpBh6DuR3dv1KbA/RP6AkbCjzPoNEIFDkGVKbHa0=;
        b=JnZymw3d45ffZ0kVyNR6p8I9RMDRVl+WWB8b2F3ij7IE5Y1EByWYmPFcaVXqRubjFa
         AwotrdU8WGkEirz/K5HvS+LhSWLoaoG9ldXW1u5ZRQyOdyOtdQndImJCsElUXxCgUL8f
         G1ETr9/KLsLeFScDqJlCT6Fzdc4Ln+xEbBO1aNOQA9XFXY0J6J+AdPbBWXrHVm8VkpaT
         ppZh7jEksoe+T7lNpqCjDrFQdwY6IpXV7Kk0uKoR+5j7nAaQX7bY3omuegC1beCwEbe4
         pRkhxW2IOxqOJofwaZ5cppmlmq964neblaGggtKVnuDlt7M3OJsptuAYzpwBGXdZjFiU
         z3Cw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWsgyLjDGAQ4O6QWVRs+aJLnrVxlj84Fc4lUPwgIc+hMEHayKBV
	UAm7tL1MY2illh0zu51f6/KpXbjDdIsG+RHKtgjbj86xngMYsK+14c20ZU3t82JijgQjWudeQ0D
	fIR75/3t7admR41PL3T4CvQvAgA579rswvHz+KyelySfiMuDKVigp1rQqSNxfrUo=
X-Received: by 2002:a17:906:a2d2:: with SMTP id by18mr14990748ejb.202.1553703190515;
        Wed, 27 Mar 2019 09:13:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2PYIkejLnPt34ovE5IzE00fTJ9Rgyd2YENe4K4Nx2Mj6x987hEgO8ZYbj1ZOWTA5SytqW
X-Received: by 2002:a17:906:a2d2:: with SMTP id by18mr14990687ejb.202.1553703189430;
        Wed, 27 Mar 2019 09:13:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553703189; cv=none;
        d=google.com; s=arc-20160816;
        b=l67keCmRpZehtfHh6ij2VKkAlFD1n57qmz5y0DTsBrzMS9ZEdzb7RWkYVx51R+f0w+
         WLQ7PWYQfE0mMk1Y51Srx8GVpoZ6OneJqwWyiMK8jEgUa+VMPl3YHL5wLqD2Ymo071Gy
         Vqfvqg7MSYZVNAvTBGPoeIZlIoXJXnUQG1bvU+tQwTpSvuoTDIarNxeKQx9Uifp6qamI
         E5bE23ED1VdoRNwP8c8aH1M6dt8ZgKWdQXDRRlT0FTTc89IqPzMtSttqXsZHwu4uZd9y
         TpCPx9SJQbrYWRh11FdOXfSLOhC9NskWFr6kloBTF47HAezhe8LBcwbuZNKIyow2lSjO
         Gf5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bg3tpBh6DuR3dv1KbA/RP6AkbCjzPoNEIFDkGVKbHa0=;
        b=HTp36AQZOnnTZo+ACcVtJ3c2i1R1RRu888nF9ty+D/UouDaW9yo9hJlLh+iZ8AFW/z
         vpQv+xBFiIKdCdtokgCwXgdCYegCsrPinkVRLcEUSB4xeK9EkaqlHH5DzRnlKGXFsYT3
         mVq5NTYlYYnEqKBq8SV7V+3HcpibuDlgSdadYhPrJZftjWoI5JH12pN1bXgwRgEnPx+T
         K062hy3qfPhiFKbV9aYM8S7Hd6xoVMkdU82jJ1TOz3RVJEZcr+kx9B1epEbDsD+qEUj9
         ILpeJFs4rPWExCOYj609lM8CpVSzp8Q445S54PC8xzwGOGeRNIKhBr5fY3ZsJIKMpPNx
         dlyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m21si1930976edq.234.2019.03.27.09.13.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 09:13:09 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 56E54AE0E;
	Wed, 27 Mar 2019 16:13:08 +0000 (UTC)
Date: Wed, 27 Mar 2019 17:13:06 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Toshi Kani <toshi.kani@hpe.com>, Jeff Moyer <jmoyer@redhat.com>,
	Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v5 00/10] mm: Sub-section memory hotplug support
Message-ID: <20190327161306.GM11927@dhcp22.suse.cz>
References: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190322180532.GM32418@dhcp22.suse.cz>
 <CAPcyv4gBGNP95APYaBcsocEa50tQj9b5h__83vgngjq3ouGX_Q@mail.gmail.com>
 <20190325101945.GD9924@dhcp22.suse.cz>
 <CAPcyv4iJCgu-akJM_O8ZtscqWQt=CU-fvx-ViGYeau-NJufmSQ@mail.gmail.com>
 <20190326080408.GC28406@dhcp22.suse.cz>
 <CAPcyv4jUeUPwbfToWQtWX1AxfgFLNpBUhm8BvgJ2Hv1RbNPiog@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jUeUPwbfToWQtWX1AxfgFLNpBUhm8BvgJ2Hv1RbNPiog@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-03-19 17:20:41, Dan Williams wrote:
> On Tue, Mar 26, 2019 at 1:04 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Mon 25-03-19 13:03:47, Dan Williams wrote:
> > > On Mon, Mar 25, 2019 at 3:20 AM Michal Hocko <mhocko@kernel.org> wrote:
> > [...]
> > > > > User-defined memory namespaces have this problem, but 2MB is the
> > > > > default alignment and is sufficient for most uses.
> > > >
> > > > What does prevent users to go and use a larger alignment?
> > >
> > > Given that we are living with 64MB granularity on mainstream platforms
> > > for the foreseeable future, the reason users can't rely on a larger
> > > alignment to address the issue is that the physical alignment may
> > > change from one boot to the next.
> >
> > I would love to learn more about this inter boot volatility. Could you
> > expand on that some more? I though that the HW configuration presented
> > to the OS would be more or less stable unless the underlying HW changes.
> 
> Even if the configuration is static there can be hardware failures
> that prevent a DIMM, or a PCI device to be included in the memory map.
> When that happens the BIOS needs to re-layout the map and the result
> is not guaranteed to maintain the previous alignment.
> 
> > > No, you can't just wish hardware / platform firmware won't do this,
> > > because there are not enough platform resources to give every hardware
> > > device a guaranteed alignment.
> >
> > Guarantee is one part and I can see how nobody wants to give you
> > something as strong but how often does that happen in the real life?
> 
> I expect a "rare" event to happen everyday in a data-center fleet.
> Failure rates tend towards 100% daily occurrence at scale and in this
> case the kernel has everything it needs to mitigate such an event.
> 
> Setting aside the success rate of a software-alignment mitigation, the
> reason I am charging this hill again after a 2 year hiatus is the
> realization that this problem is wider spread than the original
> failing scenario. Back in 2017 the problem seemed limited to custom
> memmap= configurations, and collisions between PMEM and System RAM.
> Now it is clear that the collisions can happen between PMEM regions
> and namespaces as well, and the problem spans platforms from multiple
> vendors. Here is the most recent collision problem:
> https://github.com/pmem/ndctl/issues/76, from a third-party platform.
> 
> The fix for that issue uncovered a bug in the padding implementation,
> and a fix for that bug would result in even more hacks in the nvdimm
> code for what is a core kernel deficiency. Code review of those
> changes resulted in changing direction to go after the core
> deficiency.

This kind of information along with real world examples is exactly what
you should have added into the cover letter. A previous very vague
claims were not really convincing or something that can be considered a
proper justification. Please do realize that people who are not working
with the affected HW are unlikely to have an idea how serious/relevant
those problems really are.

People are asking for a smaller memory hotplug granularity for other
usecases (e.g. memory ballooning into VMs) which are quite dubious to
be honest and not really worth all the code rework. If we are talking
about something that can be worked around elsewhere then it is preferred
because the code base is not in an excellent shape and putting more on
top is just going to cause more headaches.

I will try to find some time to review this more deeply (no promises
though because time is hectic and this is not a simple feature). For the
future, please try harder to write up a proper justification and a
highlevel design description which tells a bit about all important parts
of the new scheme.

-- 
Michal Hocko
SUSE Labs

