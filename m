Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAC59C43444
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 18:02:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 953552064C
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 18:02:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 953552064C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 363B28E0005; Thu, 10 Jan 2019 13:02:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33D498E0001; Thu, 10 Jan 2019 13:02:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22A048E0005; Thu, 10 Jan 2019 13:02:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id E8C0B8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:02:21 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id p24so12009802qtl.2
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 10:02:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=hcxMeqApjvmksoGISgtq4OPY73ONUNoB7eLA0+S0lPg=;
        b=iY5WDEMvPFVZxtRtKj2HdBfzONoOyLEKZLLlpjh6jNLTfER1MPSd3NOh6jbJdagsmU
         JBoER7ZzlQIIEElrx3D7KuCxM9HcTowwxqCtO4zfFWz/FXMmUErj1IThmEpZc01g1+hX
         m8wmhJvfv480H+M+A/NPteO+sV2Df91KRpCV3061j3LXmwZLjiQYJ8OxwRJ8xvL9S03O
         l/GaytMoTlkdRSC3uXxQTkIFyaDrGszOCRbozohuyZ97pcrHnuiOJCsNq1STpa2matJ0
         Jf4aproclX2aF5uVISzGr8vzWWvOdcgS2aZ2zulnOQZ+w0UDGN/9QaoBcM6Aswb8/XDk
         fOoQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukdyPTw0HBy+Md/7v6gaYVLPO8vW3eRSmiTXmkJFVXn1bSOzjG6T
	BlermGSFYEix+s/JIlbGR3r67GyJ3CvYZTa5XGUsAcSty0prYDshJGG00kjw2Hl8iZPcta8E96n
	LaYR8L6q8dlONvmw7yjjYw/JTQ9BJSXM1Tz7qJ1Cspr2CXYgOkODrw5F7rIqGKNA/AQ==
X-Received: by 2002:aed:3a69:: with SMTP id n96mr10847827qte.246.1547143341648;
        Thu, 10 Jan 2019 10:02:21 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5amjllecFPcC1hJAoBrfQFuP1bhz+en3v4kT7WifTq8GVeRQaAFZWFqfpGMWj4BLnUm2ai
X-Received: by 2002:aed:3a69:: with SMTP id n96mr10847742qte.246.1547143340566;
        Thu, 10 Jan 2019 10:02:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547143340; cv=none;
        d=google.com; s=arc-20160816;
        b=Gcdvv8HCrbWntY8yzdP+bSIkitgMwF0cgj6LUULFjQagCBD34xFwTARInYb2hUCOYW
         X4Dk9c/h033MkY5vpLZIfirKqnPExv4qTzKeqk5E8GPQ8f7EnbcvXHOSAB9fOSMLLhsV
         cSCcTtSMs6Jii12VPjt005y2R/S601t7V9yThzq6yfIxpAvtTWuBpKBR6Hagf/VLAZEO
         44XirIih7s5D6lVWCDZ+JN8myt1VVDZbYg6INTOGwSR90ls4qVoRnuKN6w92O3wpp2ao
         p0b6L3sNXi7h5MnClDgPeiGKzBt7kppJ/urNrbkWGiukRO+LtfZR57wDriFi4DVV0wqT
         WwRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=hcxMeqApjvmksoGISgtq4OPY73ONUNoB7eLA0+S0lPg=;
        b=Q6O0+TcaXyCX7LrV1nqDUeFK9J98wcxotPrVNW9/+ot8UtylJS+N44YkbSDyLcFWo9
         pUd9QgyMUo6yzQ5uNUFh3XlIwwPf2CSG7y/y1FHJFV/q/g08n/ybW8ZxP/Sau7HmxEP+
         wzfkL+xryjBe2ioYiD6xw7LvCC5fkIRFulnzPqnlfVFs91VYXyboe/I2mhm7pia8HTU9
         9MKCCi4AhFAa3rRJHqMxIQ4LpGyCeMae7XLsldG5UOZ4N+Oejc1wTIsEb7+afTYUY10g
         ZMckDUotewEWGYQXSf5j7k0vknU1A+OoQcCrIhXzlM7EHhp3omh6cdW/uYUFzbvo3+lH
         oUZA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x34si10418702qtd.90.2019.01.10.10.02.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 10:02:20 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D70B4C0587F9;
	Thu, 10 Jan 2019 18:02:18 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.215])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1F7D45C8B3;
	Thu, 10 Jan 2019 18:02:17 +0000 (UTC)
Date: Thu, 10 Jan 2019 13:02:15 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>,
	Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>,
	Liu Jingqi <jingqi.liu@intel.com>,
	Dong Eddie <eddie.dong@intel.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Zhang Yi <yi.z.zhang@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Mel Gorman <mgorman@suse.de>,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20190110180215.GE4394@redhat.com>
References: <20181226131446.330864849@intel.com>
 <20181227203158.GO16738@dhcp22.suse.cz>
 <20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
 <20181228084105.GQ16738@dhcp22.suse.cz>
 <20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com>
 <20181228121515.GS16738@dhcp22.suse.cz>
 <20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
 <20181228195224.GY16738@dhcp22.suse.cz>
 <20190110162556.GC4394@redhat.com>
 <20190110165001.GP31793@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190110165001.GP31793@dhcp22.suse.cz>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 10 Jan 2019 18:02:19 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110180215.uVsxd_YQREjeSUAMrRdAde3IMYaLAxWVjl4GshYQxJI@z>

On Thu, Jan 10, 2019 at 05:50:01PM +0100, Michal Hocko wrote:
> On Thu 10-01-19 11:25:56, Jerome Glisse wrote:
> > On Fri, Dec 28, 2018 at 08:52:24PM +0100, Michal Hocko wrote:
> > > [Ccing Mel and Andrea]
> > > 
> > > On Fri 28-12-18 21:31:11, Wu Fengguang wrote:
> > > > > > > I haven't looked at the implementation yet but if you are proposing a
> > > > > > > special cased zone lists then this is something CDM (Coherent Device
> > > > > > > Memory) was trying to do two years ago and there was quite some
> > > > > > > skepticism in the approach.
> > > > > > 
> > > > > > It looks we are pretty different than CDM. :)
> > > > > > We creating new NUMA nodes rather than CDM's new ZONE.
> > > > > > The zonelists modification is just to make PMEM nodes more separated.
> > > > > 
> > > > > Yes, this is exactly what CDM was after. Have a zone which is not
> > > > > reachable without explicit request AFAIR. So no, I do not think you are
> > > > > too different, you just use a different terminology ;)
> > > > 
> > > > Got it. OK.. The fall back zonelists patch does need more thoughts.
> > > > 
> > > > In long term POV, Linux should be prepared for multi-level memory.
> > > > Then there will arise the need to "allocate from this level memory".
> > > > So it looks good to have separated zonelists for each level of memory.
> > > 
> > > Well, I do not have a good answer for you here. We do not have good
> > > experiences with those systems, I am afraid. NUMA is with us for more
> > > than a decade yet our APIs are coarse to say the least and broken at so
> > > many times as well. Starting a new API just based on PMEM sounds like a
> > > ticket to another disaster to me.
> > > 
> > > I would like to see solid arguments why the current model of numa nodes
> > > with fallback in distances order cannot be used for those new
> > > technologies in the beginning and develop something better based on our
> > > experiences that we gain on the way.
> > 
> > I see several issues with distance. First it does fully abstract the
> > underlying topology and this might be problematic, for instance if
> > you memory with different characteristic in same node like persistent
> > memory connected to some CPU then it might be faster for that CPU to
> > access that persistent memory has it has dedicated link to it than to
> > access some other remote memory for which the CPU might have to share
> > the link with other CPUs or devices.
> > 
> > Second distance is no longer easy to compute when you are not trying
> > to answer what is the fastest memory for CPU-N but rather asking what
> > is the fastest memory for CPU-N and device-M ie when you are trying to
> > find the best memory for a group of CPUs/devices. The answer can
> > changes drasticly depending on members of the groups.
> 
> While you might be right, I would _really_ appreciate to start with a
> simpler model and go to a more complex one based on realy HW and real
> experiences than start with an overly complicated and over engineered
> approach from scratch.
> 
> > Some advance programmer already do graph matching ie they match the
> > graph of their program dataset/computation with the topology graph
> > of the computer they run on to determine what is best placement both
> > for threads and memory.
> 
> And those can still use our mempolicy API to describe their needs. If
> existing API is not sufficient then let's talk about which pieces are
> missing.

I understand people don't want the fully topology thing but device memory
can not be expose as a NUMA node hence at very least we need something
that is not NUMA node only and most likely an API that does not use bitmask
as front facing userspace API. So some kind of UID for memory, one for
each type of memory on each node (and also for each device memory). It
can be a 1 to 1 match with NUMA node id for all regular NUMA node memory
with extra id for device memory (for instance by setting the high bit on
the UID for device memory).


> > > I would be especially interested about a possibility of the memory
> > > migration idea during a memory pressure and relying on numa balancing to
> > > resort the locality on demand rather than hiding certain NUMA nodes or
> > > zones from the allocator and expose them only to the userspace.
> > 
> > For device memory we have more things to think of like:
> >     - memory not accessible by CPU
> >     - non cache coherent memory (yet still useful in some case if
> >       application explicitly ask for it)
> >     - device driver want to keep full control over memory as older
> >       application like graphic for GPU, do need contiguous physical
> >       memory and other tight control over physical memory placement
> 
> Again, I believe that HMM is to target those non-coherent or
> non-accessible memory and I do not think it is helpful to put them into
> the mix here.

HMM is the kernel plumbing it does not expose anything to userspace.
While right now for nouveau the plan is to expose API through nouveau
ioctl this does not scale/work for multiple devices or when you mix
and match different devices. A single API that can handle both device
memory and regular memory would be much more useful. Long term at least
that's what i would like to see.


> > So if we are talking about something to replace NUMA i would really
> > like for that to be inclusive of device memory (which can itself be
> > a hierarchy of different memory with different characteristics).
> 
> I think we should build on the existing NUMA infrastructure we have.
> Developing something completely new is not going to happen anytime soon
> and I am not convinced the result would be that much better either.

The issue with NUMA is that i do not see a way to add device memory as
node as the memory need to be fully manage by the device driver. Also
the number of nodes might get out of hands (think 32 devices per CPU
so with 1024 CPU that's 2^15 max nodes ...) this leads to node mask
taking a full page.

Also the whole NUMA access tracking does not work with devices (it can
be added but right now it is non existent). Forcing page fault to track
access is highly disruptive for GPU while the hw can provide much better
informations without fault and CPU counters might also be something we
might want to use rather than faulting.

I am not saying something new will solve all the issues we have today
with NUMA, actualy i don't believe we can solve all of them. But it
could at least be more flexible in terms of what memory program can
bind to.

Cheers,
Jérôme

