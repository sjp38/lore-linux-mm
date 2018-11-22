Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 02D796B2C82
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 13:08:14 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id p128so3937619oib.2
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 10:08:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n185-v6sor17519442oif.113.2018.11.22.10.08.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Nov 2018 10:08:12 -0800 (PST)
MIME-Version: 1.0
References: <20181114224902.12082-1-keith.busch@intel.com> <1ed406b2-b85f-8e02-1df0-7c39aa21eca9@arm.com>
 <4ea6e80f-80ba-6992-8aa0-5c2d88996af7@intel.com> <b79804b0-32ee-03f9-fa62-a89684d46be6@arm.com>
 <c6abb754-0d82-8739-fe08-24e9402bae75@intel.com> <aae34dde-fa70-870a-9b74-fff9e385bfc9@arm.com>
In-Reply-To: <aae34dde-fa70-870a-9b74-fff9e385bfc9@arm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 22 Nov 2018 10:08:01 -0800
Message-ID: <CAPcyv4hj61o+TDTSGxYSMMXMn7YiOGP0fj6R-cquPodN4VeT9A@mail.gmail.com>
Subject: Re: [PATCH 0/7] ACPI HMAT memory sysfs representation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: anshuman.khandual@arm.com
Cc: Dave Hansen <dave.hansen@intel.com>, Keith Busch <keith.busch@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ACPI <linux-acpi@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>

On Thu, Nov 22, 2018 at 3:52 AM Anshuman Khandual
<anshuman.khandual@arm.com> wrote:
>
>
>
> On 11/19/2018 11:07 PM, Dave Hansen wrote:
> > On 11/18/18 9:44 PM, Anshuman Khandual wrote:
> >> IIUC NUMA re-work in principle involves these functional changes
> >>
> >> 1. Enumerating compute and memory nodes in heterogeneous environment (short/medium term)
> >
> > This patch set _does_ that, though.
> >
> >> 2. Enumerating memory node attributes as seen from the compute nodes (short/medium term)
> >
> > It does that as well (a subset at least).
> >
> > It sounds like the subset that's being exposed is insufficient for yo
> > We did that because we think doing anything but a subset in sysfs will
> > just blow up sysfs:  MAX_NUMNODES is as high as 1024, so if we have 4
> > attributes, that's at _least_ 1024*1024*4 files if we expose *all*
> > combinations.
> Each permutation need not be a separate file inside all possible NODE X
> (/sys/devices/system/node/nodeX) directories. It can be a top level file
> enumerating various attribute values for a given (X, Y) node pair based
> on an offset something like /proc/pid/pagemap.
>
> >
> > Do we agree that sysfs is unsuitable for exposing attributes in this manner?
> >
>
> Yes, for individual files. But this can be worked around with an offset
> based access from a top level global attributes file as mentioned above.
> Is there any particular advantage of using individual files for each
> given attribute ? I was wondering that a single unsigned long (u64) will
> be able to pack 8 different attributes where each individual attribute
> values can be abstracted out in 8 bits.

sysfs has a 4K limit, and in general I don't think there is much
incremental value to go describe the entirety of the system from sysfs
or anywhere else in the kernel for that matter. It's simply too much
information to reasonably consume. Instead the kernel can describe the
coarse boundaries and some semblance of "best" access initiator for a
given target. That should cover the "80%" case of what applications
want to discover, for the other "20%" we likely need some userspace
library that can go parse these platform specific information sources
and supplement the kernel view. I also think a simpler kernel starting
point gives us room to go pull in more commonly used attributes if it
turns out they are useful, and avoid going down the path of exporting
attributes that have questionable value in practice.
