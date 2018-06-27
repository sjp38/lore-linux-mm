Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B45D16B0010
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 12:02:19 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id i14-v6so1552870wrq.1
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 09:02:19 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c6-v6si4163826wri.363.2018.06.27.09.02.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 09:02:18 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5RFxOns107215
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 12:02:16 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jvcj7kpru-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 12:02:15 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 27 Jun 2018 17:02:12 +0100
Date: Wed, 27 Jun 2018 19:02:07 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: why do we still need bootmem allocator?
References: <20180625140754.GB29102@dhcp22.suse.cz>
 <CABGGisyVpfYCz7-5AGB-3Ld9hcuikPVk=19xPc1AwffjhsV+kg@mail.gmail.com>
 <20180627112655.GD4291@rapoport-lnx>
 <CAL_JsqL6dV9+tP9CQ7XoCoaf0wUO6NgHZ2-QNUyQMZx2pny+xA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAL_JsqL6dV9+tP9CQ7XoCoaf0wUO6NgHZ2-QNUyQMZx2pny+xA@mail.gmail.com>
Message-Id: <20180627160206.GB19182@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Herring <robh@kernel.org>
Cc: mhocko@kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, "open list:GENERIC INCLUDE/ASM HEADER FILES" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jun 27, 2018 at 07:33:55AM -0600, Rob Herring wrote:
> On Wed, Jun 27, 2018 at 5:27 AM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> >
> > Hi,
> >
> > On Mon, Jun 25, 2018 at 10:09:41AM -0600, Rob Herring wrote:
> > > On Mon, Jun 25, 2018 at 8:08 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > Hi,
> > > > I am wondering why do we still keep mm/bootmem.c when most architectures
> > > > already moved to nobootmem. Is there any fundamental reason why others
> > > > cannot or this is just a matter of work?
> > >
> > > Just because no one has done the work. I did a couple of arches
> > > recently (sh, microblaze, and h8300) mainly because I broke them with
> > > some DT changes.
> >
> > I've tried running the current upstream on h8300 gdb simulator and it
> > failed:
> 
> It seems my patch[1] is still not applied. The maintainer said he applied it.

I've applied it manually. Without it unflatten_and_copy_device_tree() fails
to allocate memory. It indeed can be fixed with moving bootmem_init()
before, as you've noted in the commit message.

I'll try to dig deeper into it.
 
> > [    0.000000] BUG: Bad page state in process swapper  pfn:00004
> > [    0.000000] page:007ed080 count:0 mapcount:-128 mapping:00000000
> > index:0x0
> > [    0.000000] flags: 0x0()
> > [    0.000000] raw: 00000000 0040bdac 0040bdac 00000000 00000000 00000002
> > ffffff7f 00000000
> > [    0.000000] page dumped because: nonzero mapcount
> > ---Type <return> to continue, or q <return> to quit---
> > [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.18.0-rc2+ #50
> > [    0.000000] Stack from 00401f2c:
> > [    0.000000]   00401f2c 001116cb 007ed080 00401f40 000e20e6 00401f54
> > 0004df14 00000000
> > [    0.000000]   007ed080 007ed000 00401f5c 0004df8c 00401f90 0004e982
> > 00000044 00401fd1
> > [    0.000000]   007ed000 007ed000 00000000 00000004 00000008 00000000
> > 00000003 00000011
> > [    0.000000]
> > [    0.000000] Call Trace:
> > [    0.000000]         [<000e20e6>] [<0004df14>] [<0004df8c>] [<0004e982>]
> > [    0.000000]         [<00051a28>] [<00001000>] [<00000100>]
> > [    0.000000] Disabling lock debugging due to kernel taint
> >
> > With v4.13 I was able to get to "no valid init found".
> >
> > I had a quick look at h8300 memory initialization and it seems it has
> > starting pfn set to 0 while fdt defines memory start at 4M.
> 
> Perhaps there's another issue.
> 
> Rob
> 
> [1] https://patchwork.kernel.org/patch/10290317/
> 

-- 
Sincerely yours,
Mike.
