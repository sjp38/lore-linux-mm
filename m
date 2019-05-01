Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE0A2C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 23:47:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76D2420656
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 23:47:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76D2420656
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1015C6B0005; Wed,  1 May 2019 19:47:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B2206B0006; Wed,  1 May 2019 19:47:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE2B16B0007; Wed,  1 May 2019 19:47:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B42676B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 19:47:47 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s19so328884plp.6
        for <linux-mm@kvack.org>; Wed, 01 May 2019 16:47:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=E1xDmhLIutOUq/n9vtL/An7BxgseCMxmb7cReN8dAw0=;
        b=cA17zQ5l1DsEPNXzcZN8avv0HfFu6FguYpSNaQtvOtTCq+SjgFvaA67P699P63VUS4
         SCppojC7xSb1droziALRaTRLZhHZwL/5gRyWQxKQ2fkjbYq16/iuU5T2KmpR1VVACjpz
         HTs89UU4lw1Y6dKubqZQMn6p6Omto6ZPbc2gHQ8m4VUtsvpLbcTKc2ZkHWPguUDEr0gn
         KV/RTvX453bGBCkjD3BGTqOO7yELp5EalM4gyAvbnFSrk93ouclIXF9fH/4yGS6QN72s
         eO3wTeTzHcvhFWD6jKJ6ucm8kAirGhgltXkMfaEbymqYxVJyE4gM+Bt2uaNzaSCl87fe
         b4Cg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAWhFC1OWN1618Ix5MPF5+aAUl662EsYD0luokuAlCDkrlE53OrG
	TIhirIC8pdJEjCtpW1s+sXB3x2HHBIDh/FI9O+P0V9KEHoDQoeyTan9JovBBQzI5sPW9JbAH5h1
	4oVLpYlj6fYGp/VGE4voakbBCcpn+AEUXjUpM/uKrw/t1VmyClVTk4S2yAEGJAT0=
X-Received: by 2002:a63:6e01:: with SMTP id j1mr738746pgc.442.1556754467085;
        Wed, 01 May 2019 16:47:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDSM8FKlvMN8eCdxi3fk768tXdoGASVt/3acMGQ55ItBmbmYyzW6ZzOy+w1YebDqkuiHo7
X-Received: by 2002:a63:6e01:: with SMTP id j1mr738680pgc.442.1556754465669;
        Wed, 01 May 2019 16:47:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556754465; cv=none;
        d=google.com; s=arc-20160816;
        b=InBdPpL69QsAkQjBeTb4kA2GBS9C+05R62ThBhIzK6AveKt0zGYhUY2LsooFPJFQ+W
         P3Vk2p2kLlnKzPx/nGm93Il1GIPWR2GMJKdKedu57fzr8xO/SU+bCnk38TqEFJKD+lUR
         Zh4t5h7YCUFacjND194kkCnLMpU3IwctT5Xm3Q2SKp/WPko4/CR7/v/0QWaLFwglbUTO
         dX2+WrcAQRyLlg54a4s0u4gl0mUHR0iIPyPr1lp3EDnGR3KaeMW4veUOUJABGt7K6DKu
         KX7B+YmMgtXsNKMa4NWV0xhq1t50wDkQajMCsftYw/IWCuXt4Gqo6ddA0qJh9dgipqxB
         XQEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=E1xDmhLIutOUq/n9vtL/An7BxgseCMxmb7cReN8dAw0=;
        b=B7D4GzxP3qHAdBV85GKIX73Z/UQLLAidStgXS51T1+odV9ov+qNgAFp0KjiWvvNgDV
         klbF5jMfYanJ0gkSfmMfYQdcITzNcn5TwOMruXqiggF3XG1yKufpzHAmFgFeqXrIUdtY
         LWECOfHuEjeTE3PzPuxpthc6PJk4MnXx3jeVEQCj54nsTaGC4WTm7Lq+sGUf46gp7k6y
         5xuuIucPoU4JLcmU7R/lZdtmOHY6vMb/sRxSC++DKdsReJbE+Boi3rFbu8Ru+ovOvl9M
         R948OLxQ9/P4pOjcJ276KP6KVBmXTRMzeB6dFk/YsmkCTFe+/elPBjV9oNGdQA+Yj+r+
         n4oQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id p17si40612963pgl.181.2019.05.01.16.47.45
        for <linux-mm@kvack.org>;
        Wed, 01 May 2019 16:47:45 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-171-240.pa.nsw.optusnet.com.au [49.181.171.240])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 724F343A39D;
	Thu,  2 May 2019 09:47:42 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hLywu-0005T3-OO; Thu, 02 May 2019 09:47:40 +1000
Date: Thu, 2 May 2019 09:47:40 +1000
From: Dave Chinner <david@fromorbit.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [LSF/MM TOPIC] Direct block mapping through fs for device
Message-ID: <20190501234740.GN1454@dread.disaster.area>
References: <20190426013814.GB3350@redhat.com>
 <20190426062816.GG1454@dread.disaster.area>
 <20190426152044.GB13360@redhat.com>
 <20190427012516.GH1454@dread.disaster.area>
 <20190429132643.GB3036@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190429132643.GB3036@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=UJetJGXy c=1 sm=1 tr=0 cx=a_idp_d
	a=LhzQONXuMOhFZtk4TmSJIw==:117 a=LhzQONXuMOhFZtk4TmSJIw==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=E5NmQfObTbMA:10
	a=7-415B0cAAAA:8 a=SQEkvxGnTnKDDvOy9_cA:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 29, 2019 at 09:26:45AM -0400, Jerome Glisse wrote:
> On Sat, Apr 27, 2019 at 11:25:16AM +1000, Dave Chinner wrote:
> > On Fri, Apr 26, 2019 at 11:20:45AM -0400, Jerome Glisse wrote:
> > > On Fri, Apr 26, 2019 at 04:28:16PM +1000, Dave Chinner wrote:
> > > > On Thu, Apr 25, 2019 at 09:38:14PM -0400, Jerome Glisse wrote:
> > > > > I see that they are still empty spot in LSF/MM schedule so i would like to
> > > > > have a discussion on allowing direct block mapping of file for devices (nic,
> > > > > gpu, fpga, ...). This is mm, fs and block discussion, thought the mm side
> > > > > is pretty light ie only adding 2 callback to vm_operations_struct:
> > > > 
> > > > The filesystem already has infrastructure for the bits it needs to
> > > > provide. They are called file layout leases (how many times do I
> > > > have to keep telling people this!), and what you do with the lease
> > > > for the LBA range the filesystem maps for you is then something you
> > > > can negotiate with the underlying block device.
> > > > 
> > > > i.e. go look at how xfs_pnfs.c works to hand out block mappings to
> > > > remote pNFS clients so they can directly access the underlying
> > > > storage. Basically, anyone wanting to map blocks needs a file layout
> > > > lease and then to manage the filesystem state over that range via
> > > > these methods in the struct export_operations:
> > > > 
> > > >         int (*get_uuid)(struct super_block *sb, u8 *buf, u32 *len, u64 *offset);
> > > >         int (*map_blocks)(struct inode *inode, loff_t offset,
> > > >                           u64 len, struct iomap *iomap,
> > > >                           bool write, u32 *device_generation);
> > > >         int (*commit_blocks)(struct inode *inode, struct iomap *iomaps,
> > > >                              int nr_iomaps, struct iattr *iattr);
> > > > 
> > > > Basically, before you read/write data, you map the blocks. if you've
> > > > written data, then you need to commit the blocks (i.e. tell the fs
> > > > they've been written to).
> > > > 
> > > > The iomap will give you a contiguous LBA range and the block device
> > > > they belong to, and you can then use that to whatever smart DMA stuff
> > > > you need to do through the block device directly.
> > > > 
> > > > If the filesystem wants the space back (e.g. because truncate) then
> > > > the lease will be revoked. The client then must finish off it's
> > > > outstanding operations, commit them and release the lease. To access
> > > > the file range again, it must renew the lease and remap the file
> > > > through ->map_blocks....
> > > 
> > > Sorry i should have explain why lease do not work. Here are list of
> > > lease shortcoming AFAIK:
> > >     - only one process
> > 
> > Sorry, what? The lease is taken by a application process that then
> > hands out the mapping to whatever parts of it - processes, threads,
> > remote clients, etc - need access. If your application doesn't
> > have an access co-ordination method, then you're already completely
> > screwed.
> 
> Then i am completely screw :) The thing is that today mmap of a file
> does not mandate any kind of synchronization between process than
> mmap files and thus we have a lot of existing applications that are
> just happy with that programming model and i do not see any reasons
> to force something new on them.

The whole model is fundamentally broken, and instead of making
things really fucking complex to try and work around the brokenness
we should simply /fix the underlying problem/.


> Here i am only trying an optimization by possibly skipping the page
> cache intermediary if filesystem and blocks device allows it and can
> do it (depending on any number of runtime conditions).

And that's where all the problems and demons lie.

> So lease is inherently not compatible with mmap of file by multiple
> processes. I understand you want to push your access model but the
> reality is that we have existing applications that just do not fit
> that model and i do not see any reasons to ask them to change, it
> is never a successful approach.

That's bullshit.

I'm tired of you saying "we must use mmap" and then ignoring the
people saying "mmap on files for direct block device access is
broken - use a layout lease and then /mmap the block device
directly/".

You don't need to change how the applications work - they just need
to add a layer of /access arbitration/ to get direct access to the
block device.

That's the whole point of filesystems - they are an access
arbitration layer for a block device. That's why people use them
instead of manging raw block device space themselves. We have
multiple different applications - some which have nothing to do with
RDMA, peer-to-peer hardware, etc that want direct access to the
block device that is managed by a local filesystem. mmap()ing files
simply doesn't work for them because remote access arbitrartion is a
set of network protocols, not hardware devices.

We want all these application to be able to work together in a sane
way. Your insistence that your applications /must/ use mmap to
directly access block devices, but then /must/ abstract taht direct
access to the block device by mmap()ing files without any guarantee
that the file mapping is stable is a horrible, unstable, and largely
unworkable architecture.

Just because your applications do it now doesn't mean it's the right
way to do it. The stupid thing about all this is that the change to
use layout leases and layout mapping requests in the applications is
actually very minimal (yeah, if you have a layout lease then FIEMAP
output will actually be stable for the lease range!), and if the
applications and systems are set up properly then the probability of
lease revocation is almost non-existent.

You still set up your direct access mapping from the application via
mmap(), except now it's via mmap() on the block device rather than
through the file.

This is exactly the same model as the pNFS remote access - the
remote client is given a block device mapping, and it goes and
accesses it directly via iscsi, iSER, or whatever RDMA transport the
block device provides the pNFS client. The local filesystem that
handed out the layout lease /just doesn't care/ how the application
interacts with the block device or what it does with the mapping.

And guess what? This works with DAX filesystems and block devices,
too, without the application even having to be aware it's on DAX
capable filesystems and hardware.

I'm arguing for a sane, generic method of offloading direct access
to the block device underneath a filesystem. I'm not trying to
change the way your applications or you peer-to-peer application
mappings work. All I want is that these *filesystem bypass*
storage access methods all use the same access arbitration interface
with the same semantics, and so applications can be completely
agnostic as to what filesystem and/or hardware lies underneath them.

> > What's a "device file" and how is that any difference from a normal
> > kernel file?
> 
> Many device driver expose object (for instance all the GPU driver) through
> their device file and allow userspace to mmap the device file to access
> those object. At a given offset in the device file you will find a given
> object and this can be per application or global to all application.

This is irrelevant for how you access the block device underneath
a local filesystem. The application has to do something to map these
objects in the "device file" correctly, just like it needs to do
something to correctly map the storage underneath the filesystem.

> > Please stop trying to invent new and excitingly complex ways to do
> > direct block access because we ialready have infrastructure we know
> > works, we already support and is flexible enough to provide exactly
> > the sort of direct block device access mechainsms that you are
> > asking for.
> 
> I understand you do not like mmap but it has been around long enough
> that it is extensively use and we have to accept that. There is no
> changing all the applications that exist out there and that rely on
> mmap and this is for those applications that such optimization would
> help.

You're arguing that "mmap() works for me, so it's good enough for
everyone" but filesystem engineers have known this is not true
for years. I also really don't buy this "file leases are going to
fundamentally change how applications work" argument. All it changes
is what the application mmap()s to get direct access to the
underlying storage.  It works with any storage hardware and it works
with both local and remote direct access because it completely
avoids the need for the filesystem to manage data transfers and/or
storage hardware.

From the filesystem architecture perspective, we need a clean,
generic, reliable filesystem bypass mechanism people can build any
application on top of. File-backed mappings simply do not provide
the necessary semantics, APIs, guarantees or revocation model
(SIGBUS != revocation model) that we know are required by various
existing userspace applications. Your application(s) are not the
only direct storage access applications people are trying to
implement, nor are they the only ones we'll have to support. They
all need to use the same interface and methods - anything else is
simply going to be an unsupportable, shitty mess.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

