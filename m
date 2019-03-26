Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E6BCC10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:04:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20F9520856
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:04:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20F9520856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 955CC6B0007; Tue, 26 Mar 2019 04:04:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 905196B0008; Tue, 26 Mar 2019 04:04:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F52C6B000A; Tue, 26 Mar 2019 04:04:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2F4E76B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 04:04:12 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c41so4888004edb.7
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 01:04:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZBS4cQskOdf1qv/Ng28vYbRWL/3ke9BANz0rJpEVpNs=;
        b=VftotoAen9MvMK+tuyCuKGHBSq3n6xKKXQPlM6uVkb/xE/EBpZe38S9GlQ7AuonATP
         lE92JLLK0mcr80u3qJ9i3SwykeDk0ZNcm4WBVBtgmzQvHV/kDKX328q+GRc6ZL19NC2f
         IbkLxX6vfDUnfUNTfK2+EeiSVY0J4En5OfA0AYOJx3VhqHCuz6qlu+FA6zxMtyJDfDd0
         573SASUjpd5sUlWL/bUbS648ulN/zYyhTVtZxJxVx6bjhN7/W2i2rFS6RX3RIw4aHf/I
         cFuXucI8ds0/vUVNooVkkpezVMvipio4UdB2HVw9Xxa2IQkxvbaJUJklUFIv/3uovpth
         WBPw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWjTjLwGbqVdVEgrWeU52x/lQ/sVrYC/hJhfcHnXzjFJNasX7P2
	WIhhDjrbYD7kkcoDNNA2yuW4qR7PMx9gqiROfpOd+RGt4fN2nv13oSMNCUvd+Lcw3iFkp5v0tSX
	yq70eR9XIPb7EChkPYPMZQz4AXS9OPkEXM3pPeR6oKOeypVrfUWvu690czkQdNFU=
X-Received: by 2002:a17:906:b34c:: with SMTP id cd12mr16534150ejb.106.1553587451656;
        Tue, 26 Mar 2019 01:04:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqym+LRjavAdxN9gedhuAxk99YN5bPwZysR33HITP76T3udL1+Jgx+UAAOpNLbyBOBO0EINC
X-Received: by 2002:a17:906:b34c:: with SMTP id cd12mr16534092ejb.106.1553587450473;
        Tue, 26 Mar 2019 01:04:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553587450; cv=none;
        d=google.com; s=arc-20160816;
        b=crU868DpQo1Vg5A8dX4rinCw0Q/G1XiAQivgJAzCvDW4VWtmWLJIhw1EBHiU5OBcWe
         fC2dctY+1wP1KreddZz0/S2/1r2mjM9AJ+i4UnFQhUtp5fXuiBlbglkzjwoS7KyId6+4
         NqtgI7o7UVRrcJJ9Lmezdq/vnjvZvAX93vBWwIdvt9/4immIv23cKJBLcruvqxkE94/J
         4AXFET5Ndd6Inhqj7OFrab03v4vA8qII4RrzrQvonreReFx3SUjimBUAKRGOvVR0sQ+Q
         BpQbuHjzKEbW5b04oTiZ8R5iUj6FwtabY1LGunG3Ax8wk8AAG9R14JhAi4OOamDyjkiO
         fsPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZBS4cQskOdf1qv/Ng28vYbRWL/3ke9BANz0rJpEVpNs=;
        b=hN0To3FDVImc6uKrReHZXUVFz4ysNwFo6gQf4PUvUsjQ4M78/PnStf6slUOftC5g4O
         2NtMdB0hGTORlJ8wO0pufvix5Z9n7wmej8L+Q5Bqfa0M1PzPn2xsrwBga/saOSRq5G6g
         VVKZGdEAK1bZ6oqFJedXzihp5maW9bzg2hM9TVGn4RYCeocgCu8NASFflakunB2ufY9J
         IpuJYDb8FxYAgg8/ezNtrnLdg4q6RTff0M8FgTtmedbKTVY//b0FjtkM8ykCPRiWJvNs
         B8z03pDjRidNQDPDYQNdIxQyjZqeYlgtAA/v6a/lxkVV7kNYHpb4uousm4V6H3q7Uphz
         JFaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b11si3309860edb.69.2019.03.26.01.04.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 01:04:10 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 64AACACF3;
	Tue, 26 Mar 2019 08:04:09 +0000 (UTC)
Date: Tue, 26 Mar 2019 09:04:08 +0100
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
Message-ID: <20190326080408.GC28406@dhcp22.suse.cz>
References: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190322180532.GM32418@dhcp22.suse.cz>
 <CAPcyv4gBGNP95APYaBcsocEa50tQj9b5h__83vgngjq3ouGX_Q@mail.gmail.com>
 <20190325101945.GD9924@dhcp22.suse.cz>
 <CAPcyv4iJCgu-akJM_O8ZtscqWQt=CU-fvx-ViGYeau-NJufmSQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iJCgu-akJM_O8ZtscqWQt=CU-fvx-ViGYeau-NJufmSQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 25-03-19 13:03:47, Dan Williams wrote:
> On Mon, Mar 25, 2019 at 3:20 AM Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > > User-defined memory namespaces have this problem, but 2MB is the
> > > default alignment and is sufficient for most uses.
> >
> > What does prevent users to go and use a larger alignment?
> 
> Given that we are living with 64MB granularity on mainstream platforms
> for the foreseeable future, the reason users can't rely on a larger
> alignment to address the issue is that the physical alignment may
> change from one boot to the next.

I would love to learn more about this inter boot volatility. Could you
expand on that some more? I though that the HW configuration presented
to the OS would be more or less stable unless the underlying HW changes.

> No, you can't just wish hardware / platform firmware won't do this,
> because there are not enough platform resources to give every hardware
> device a guaranteed alignment.

Guarantee is one part and I can see how nobody wants to give you
something as strong but how often does that happen in the real life?

> The effect is that even if the driver deploys a software alignment
> mitigation when it first sees the persistent memory range, that
> alignment can be violated on a subsequent boot leading to data being
> unavailable. There is no facility to communicate to the administrator
> what went wrong in this scenario as several events can trigger a
> physical map layout change. Add / remove of hardware and hardware
> failure are the most likely causes.

This is indeed bad and unexpected! That is exactly something to have in
the chagelog!

> An additional pain point for users is that EFI pre-boot environment
> has little chance to create a namespace that Linux might be able to
> use. The section size is an arbitrary Linux constraint and we should
> not encode something Linux specific that might change in the future
> into OS agnostic software.

This looks like a fair point but please keep in mind that there hotplug
restrictions are on other platforms as well (4MB on Windows IIRC) so
there will be some knowledge required all the time. Besides that there
are likely to be some restrictions depending on the implementation.

[...]
> > > Right, as stated in the cover letter, this does not remove all those
> > > assumptions, it only removes the ones that impact
> > > devm_memremap_pages(). Specifying that sub-section is only supported
> > > in the 'want_memblock=false' case to arch_add_memory().
> >
> > And this is exactly the problem. Having different assumptions depending
> > on whether there is a memblock interface or not is utterly wrong and a
> > maintainability mess.
> 
> In this case I disagree with you. The hotplug code already has the
> want_memblock=false semantic in the implementation.

want_memblock was a hack to allow memory hotplug to not have user
visible sysfs interface. It was added to reduce the code duplication
IIRC. Besides that this hasn't changed the underlying assumptions about
hotplugable units or other invariants that were in place.

> The sub-section
> hotplug infrastructure is a strict superset of what is there already.
> Now, if it created parallel infrastructure that would indeed be a
> maintainability burden, but in this case there are no behavior changes
> for typical memory hotplug as it just hotplugs full sections at a time
> like always. The 'section' concept is not going away.

You are really neglecting many details here. E.g. memory section can be
shared between two different types of memory. We've had some bugs in the
hotplug code when one section can be shared between two different NUMA
nodes (e.g. 4aa9fc2a435a ("Revert "mm, memory_hotplug: initialize struct
pages for the full memory section""). We do not allow to hotremove such
sections because it would open another can of worms. I am not saying
your implementation is incorrect - still haven't time to look deeply -
but stating that this is a strict superset of want_memblock is simply
wrong.
 
[...]
> > Why do we have to go a mile to tweak the kernel, especially something as
> > fragile as memory hotplug, just to support sub mem section ranges. This
> > is somthing that is not clearly explained in the cover letter. Sure you
> > are talking about hacks at the higher level to deal with this but I do
> > not see any fundamental reason to actually support that at all.
> 
> Like it or not, 'struct page' mappings for arbitrary hardware-physical
> memory ranges is a facility that has grown from the pmem case, to hmm,
> and peer-to-peer DMA. Unless you want to do the work to eliminate the
> 'struct page' requirement across the kernel I think it is unreasonable
> to effectively archive the arch_add_memory() implementation and
> prevent it from reacting to growing demands.

I am definitely not blocking memory hotplug to be reused more! All I am
saying is that there is much more ground work to be done before you can
add features like that. There are some general assumptions in the code,
like it or not, and you should start by removing those to build on top.
Pmem/nvidimm development is full of "we have to do it now and find a way
to graft it into the existing infrastructure" pattern that I really
hate. Clean up will come later, I have heard. Have a look at all
zone_device hacks that remained. Why is this any different?

And just to make myself clear. There are places where section cannot go
away because that is the unit in which the memory model maintains struct
pages. But the hotplug code is fill of construct where we iterate mem
sections as one unit and operate on it as whole. Those have to go away
before you can consider subsection hotadd/remove.

> > I can feel your frustration. I am not entirely happy about the section
> > size limitation myself but you have to realize that this is simplicy vs.
> > feature set compromise.
> 
> You have to realize that arch_add_memory() is no longer just a
> front-end for typical memory hotplug. The requirements have changed.
> Simplicity should be maintained for as long as it can get the job
> done, and the simplicity is currently failing.

I do agree. But you also have to realize that this require a lot of
work. As long as users of the api are not willing to do that work then
I am afraid but the facility will remain dumb. But putting hacks to make
a specific usecase (almost)work is not the right way.
-- 
Michal Hocko
SUSE Labs

