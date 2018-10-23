Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0CF1B6B0005
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 14:12:17 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id s2so1423344ote.13
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 11:12:17 -0700 (PDT)
Received: from g9t5008.houston.hpe.com (g9t5008.houston.hpe.com. [15.241.48.72])
        by mx.google.com with ESMTPS id b54si997216otd.72.2018.10.23.11.12.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 11:12:15 -0700 (PDT)
From: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Subject: RE: [PATCH 0/9] Allow persistent memory to be used like normal RAM
Date: Tue, 23 Oct 2018 18:12:11 +0000
Message-ID: <AT5PR8401MB11694012893ED2121D7A345EABF50@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
References: <20181022201317.8558C1D8@viggo.jf.intel.com>
 <CAPcyv4hxs-GnmwQU1wPZyg5aydCY5K09-YpSrrLpvU1v_8dbBw@mail.gmail.com>
In-Reply-To: <CAPcyv4hxs-GnmwQU1wPZyg5aydCY5K09-YpSrrLpvU1v_8dbBw@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Dan Williams' <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>, "Hocko, Michal" <MHocko@suse.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, "Huang, Ying" <ying.huang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "zwisler@kernel.org" <zwisler@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>



> -----Original Message-----
> From: Linux-nvdimm [mailto:linux-nvdimm-bounces@lists.01.org] On Behalf O=
f Dan Williams
> Sent: Monday, October 22, 2018 8:05 PM
> Subject: Re: [PATCH 0/9] Allow persistent memory to be used like normal R=
AM
>=20
> On Mon, Oct 22, 2018 at 1:18 PM Dave Hansen <dave.hansen@linux.intel.com>=
 wrote:
...
> This series adds a new "driver" to which pmem devices can be
> attached.  Once attached, the memory "owned" by the device is
> hot-added to the kernel and managed like any other memory.  On

Would this memory be considered volatile (with the driver initializing
it to zeros), or persistent (contents are presented unchanged,
applications may guarantee persistence by using cache flush
instructions, fence instructions, and writing to flush hint addresses
per the persistent memory programming model)?

> > 1. The device re-binding hacks are ham-fisted at best.  We
> >    need a better way of doing this, especially so the kmem
> >    driver does not get in the way of normal pmem devices.
...
> To me this looks like teaching the nvdimm-bus and this dax_kmem driver
> to require explicit matching based on 'id'. The attachment scheme
> would look like this:
>=20
> modprobe dax_kmem
> echo dax0.0 > /sys/bus/nd/drivers/dax_kmem/new_id
> echo dax0.0 > /sys/bus/nd/drivers/dax_pmem/unbind
> echo dax0.0 > /sys/bus/nd/drivers/dax_kmem/bind
>=20
> At step1 the dax_kmem drivers will match no devices and stays out of
> the way of dax_pmem. It learns about devices it cares about by being
> explicitly told about them. Then unbind from the typical dax_pmem
> driver and attach to dax_kmem to perform the one way hotplug.
>=20
> I expect udev can automate this by setting up a rule to watch for
> device-dax instances by UUID and call a script to do the detach /
> reattach dance.

Where would that rule be stored? Storing it on another device
is problematic. If that rule is lost, it could confuse other
drivers trying to grab device DAX devices for use as persistent
memory.

A new namespace mode would record the intended usage in the
device itself, eliminating dependencies. It could join the
other modes like:

	ndctl create-namespace -m raw
		create /dev/pmem4 block device
	ndctl create-namespace -m sector
		create /dev/pmem4s block device
	ndctl create-namespace -m fsdax
		create /dev/pmem4 block device
	ndctl create-namespace -m devdax
		create /dev/dax4.3 character device
		for use as persistent memory
	ndctl create-namespace -m mem
		create /dev/mem4.3 character device
		for use as volatile memory

---
Robert Elliott, HPE Persistent Memory
