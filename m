Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 70D406B026B
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 09:34:11 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id f10-v6so240899pgv.22
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 06:34:11 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b18-v6si3973412pls.292.2018.06.27.06.34.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 06:34:09 -0700 (PDT)
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id EA2EB26331
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 13:34:08 +0000 (UTC)
Received: by mail-io0-f175.google.com with SMTP id u23-v6so1900669ioc.13
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 06:34:08 -0700 (PDT)
MIME-Version: 1.0
References: <20180625140754.GB29102@dhcp22.suse.cz> <CABGGisyVpfYCz7-5AGB-3Ld9hcuikPVk=19xPc1AwffjhsV+kg@mail.gmail.com>
 <20180627112655.GD4291@rapoport-lnx>
In-Reply-To: <20180627112655.GD4291@rapoport-lnx>
From: Rob Herring <robh@kernel.org>
Date: Wed, 27 Jun 2018 07:33:55 -0600
Message-ID: <CAL_JsqL6dV9+tP9CQ7XoCoaf0wUO6NgHZ2-QNUyQMZx2pny+xA@mail.gmail.com>
Subject: Re: why do we still need bootmem allocator?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: mhocko@kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, "open list:GENERIC INCLUDE/ASM HEADER FILES" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jun 27, 2018 at 5:27 AM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
>
> Hi,
>
> On Mon, Jun 25, 2018 at 10:09:41AM -0600, Rob Herring wrote:
> > On Mon, Jun 25, 2018 at 8:08 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > Hi,
> > > I am wondering why do we still keep mm/bootmem.c when most architectures
> > > already moved to nobootmem. Is there any fundamental reason why others
> > > cannot or this is just a matter of work?
> >
> > Just because no one has done the work. I did a couple of arches
> > recently (sh, microblaze, and h8300) mainly because I broke them with
> > some DT changes.
>
> I've tried running the current upstream on h8300 gdb simulator and it
> failed:

It seems my patch[1] is still not applied. The maintainer said he applied it.

> [    0.000000] BUG: Bad page state in process swapper  pfn:00004
> [    0.000000] page:007ed080 count:0 mapcount:-128 mapping:00000000
> index:0x0
> [    0.000000] flags: 0x0()
> [    0.000000] raw: 00000000 0040bdac 0040bdac 00000000 00000000 00000002
> ffffff7f 00000000
> [    0.000000] page dumped because: nonzero mapcount
> ---Type <return> to continue, or q <return> to quit---
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.18.0-rc2+ #50
> [    0.000000] Stack from 00401f2c:
> [    0.000000]   00401f2c 001116cb 007ed080 00401f40 000e20e6 00401f54
> 0004df14 00000000
> [    0.000000]   007ed080 007ed000 00401f5c 0004df8c 00401f90 0004e982
> 00000044 00401fd1
> [    0.000000]   007ed000 007ed000 00000000 00000004 00000008 00000000
> 00000003 00000011
> [    0.000000]
> [    0.000000] Call Trace:
> [    0.000000]         [<000e20e6>] [<0004df14>] [<0004df8c>] [<0004e982>]
> [    0.000000]         [<00051a28>] [<00001000>] [<00000100>]
> [    0.000000] Disabling lock debugging due to kernel taint
>
> With v4.13 I was able to get to "no valid init found".
>
> I had a quick look at h8300 memory initialization and it seems it has
> starting pfn set to 0 while fdt defines memory start at 4M.

Perhaps there's another issue.

Rob

[1] https://patchwork.kernel.org/patch/10290317/
