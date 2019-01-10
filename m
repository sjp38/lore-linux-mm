Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6CB8C8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 12:31:47 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id b17so8225675pfc.11
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 09:31:47 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id g32si2452324pgg.400.2019.01.10.09.31.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 09:31:45 -0800 (PST)
Date: Thu, 10 Jan 2019 10:30:17 -0700
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCHv3 07/13] node: Add heterogenous memory access attributes
Message-ID: <20190110173016.GC21095@localhost.localdomain>
References: <20190109174341.19818-1-keith.busch@intel.com>
 <20190109174341.19818-8-keith.busch@intel.com>
 <87y37sit8x.fsf@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87y37sit8x.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Jan 10, 2019 at 06:07:02PM +0530, Aneesh Kumar K.V wrote:
> Keith Busch <keith.busch@intel.com> writes:
> 
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
> 
> How does the definition of performance relate to bandwidth and latency here?. The
> initiator in this class has the least latency and high bandwidth? Can there
> be a scenario where both are not best for the same node? ie, for a
> target Node Y, initiator Node A gives the highest bandwidth but initiator
> Node B gets the least latency. How such a config can be represented? Or is
> that not possible?

I am not aware of a real platform that has an initiator-target pair with
better latency but worse bandwidth than any different initiator paired to
the same target. If such a thing exists and a subsystem wants to report
that, you can register any arbitrary number of groups or classes and
rank them according to how you want them presented.
