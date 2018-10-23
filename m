Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 186CE6B0006
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 14:58:19 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id o6-v6so1544672oib.9
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 11:58:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d3-v6sor1122457oia.8.2018.10.23.11.58.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Oct 2018 11:58:18 -0700 (PDT)
MIME-Version: 1.0
References: <20181022201317.8558C1D8@viggo.jf.intel.com> <CAPcyv4hxs-GnmwQU1wPZyg5aydCY5K09-YpSrrLpvU1v_8dbBw@mail.gmail.com>
 <AT5PR8401MB11694012893ED2121D7A345EABF50@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
 <2677a7f9-5dc8-7590-2b8b-a67da1cb6b92@intel.com>
In-Reply-To: <2677a7f9-5dc8-7590-2b8b-a67da1cb6b92@intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 23 Oct 2018 11:58:06 -0700
Message-ID: <CAPcyv4jcgRTR-NnHPpsLm=z8uSLJZYN530nGm5f9k6Q3WGHr0g@mail.gmail.com>
Subject: Re: [PATCH 0/9] Allow persistent memory to be used like normal RAM
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>, Dave Hansen <dave.hansen@linux.intel.com>, Tom Lendacky <thomas.lendacky@amd.com>, Michal Hocko <MHocko@suse.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, "Huang, Ying" <ying.huang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, zwisler@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>

On Tue, Oct 23, 2018 at 11:17 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> >> This series adds a new "driver" to which pmem devices can be
> >> attached.  Once attached, the memory "owned" by the device is
> >> hot-added to the kernel and managed like any other memory.  On
> >
> > Would this memory be considered volatile (with the driver initializing
> > it to zeros), or persistent (contents are presented unchanged,
> > applications may guarantee persistence by using cache flush
> > instructions, fence instructions, and writing to flush hint addresses
> > per the persistent memory programming model)?
>
> Volatile.
>
> >> I expect udev can automate this by setting up a rule to watch for
> >> device-dax instances by UUID and call a script to do the detach /
> >> reattach dance.
> >
> > Where would that rule be stored? Storing it on another device
> > is problematic. If that rule is lost, it could confuse other
> > drivers trying to grab device DAX devices for use as persistent
> > memory.
>
> Well, we do lots of things like stable device naming from udev scripts.
>  We depend on them not being lost.  At least this "fails safe" so we'll
> default to persistence instead of defaulting to "eat your data".
>

Right, and at least for the persistent memory to volatile conversion
case we will have the UUID to positively identify the DAX device. So
it will indeed "fail safe" and just become a dax_pmem device again if
the configuration is lost. We'll likely need to create/use a "by-path"
scheme for non-pmem use cases.
