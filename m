Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF69D8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 10:41:55 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id v2so6269668plg.6
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 07:41:55 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 61si2014118plz.117.2019.01.17.07.41.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 07:41:54 -0800 (PST)
Date: Thu, 17 Jan 2019 16:41:51 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCHv4 07/13] node: Add heterogenous memory access attributes
Message-ID: <20190117154151.GA3970@kroah.com>
References: <20190116175804.30196-1-keith.busch@intel.com>
 <20190116175804.30196-8-keith.busch@intel.com>
 <CAJZ5v0jCEdhKndgZgJ=SdHgFBM1Bcxusm_crYzAOTZDx3s=PdQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJZ5v0jCEdhKndgZgJ=SdHgFBM1Bcxusm_crYzAOTZDx3s=PdQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Keith Busch <keith.busch@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Jan 17, 2019 at 04:03:42PM +0100, Rafael J. Wysocki wrote:
>  On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
> >
> > Heterogeneous memory systems provide memory nodes with different latency
> > and bandwidth performance attributes. Provide a new kernel interface for
> > subsystems to register the attributes under the memory target node's
> > initiator access class. If the system provides this information, applications
> > may query these attributes when deciding which node to request memory.
> >
> > The following example shows the new sysfs hierarchy for a node exporting
> > performance attributes:
> >
> >   # tree -P "read*|write*" /sys/devices/system/node/nodeY/classZ/
> >   /sys/devices/system/node/nodeY/classZ/
> >   |-- read_bandwidth
> >   |-- read_latency
> >   |-- write_bandwidth
> >   `-- write_latency
> >
> > The bandwidth is exported as MB/s and latency is reported in nanoseconds.
> > Memory accesses from an initiator node that is not one of the memory's
> > class "Z" initiator nodes may encounter different performance than
> > reported here. When a subsystem makes use of this interface, initiators
> > of a lower class number, "Z", have better performance relative to higher
> > class numbers. When provided, class 0 is the highest performing access
> > class.
> >
> > Signed-off-by: Keith Busch <keith.busch@intel.com>
> > ---
> >  drivers/base/Kconfig |  8 ++++++++
> >  drivers/base/node.c  | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
> >  include/linux/node.h | 25 +++++++++++++++++++++++++
> >  3 files changed, 81 insertions(+)
> >
> > diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
> > index 3e63a900b330..6014980238e8 100644
> > --- a/drivers/base/Kconfig
> > +++ b/drivers/base/Kconfig
> > @@ -149,6 +149,14 @@ config DEBUG_TEST_DRIVER_REMOVE
> >           unusable. You should say N here unless you are explicitly looking to
> >           test this functionality.
> >
> > +config HMEM_REPORTING
> > +       bool
> > +       default y

default y is only if the machine will not boot without it.  Please never
make a new option y unless you really really have to have it on all
machines in the world.

Hint, not here.

greg k-h
