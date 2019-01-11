Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F10E8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 06:32:57 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id w4so5980669otj.2
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 03:32:57 -0800 (PST)
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id x72si26366566oix.204.2019.01.11.03.32.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 03:32:56 -0800 (PST)
Date: Fri, 11 Jan 2019 11:32:38 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
Subject: Re: [PATCHv3 07/13] node: Add heterogenous memory access attributes
Message-ID: <20190111113238.000068b0@huawei.com>
In-Reply-To: <20190110173016.GC21095@localhost.localdomain>
References: <20190109174341.19818-1-keith.busch@intel.com>
	<20190109174341.19818-8-keith.busch@intel.com>
	<87y37sit8x.fsf@linux.ibm.com>
	<20190110173016.GC21095@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, 10 Jan 2019 10:30:17 -0700
Keith Busch <keith.busch@intel.com> wrote:

> On Thu, Jan 10, 2019 at 06:07:02PM +0530, Aneesh Kumar K.V wrote:
> > Keith Busch <keith.busch@intel.com> writes:
> >   
> > > Heterogeneous memory systems provide memory nodes with different latency
> > > and bandwidth performance attributes. Provide a new kernel interface for
> > > subsystems to register the attributes under the memory target node's
> > > initiator access class. If the system provides this information, applications
> > > may query these attributes when deciding which node to request memory.
> > >
> > > The following example shows the new sysfs hierarchy for a node exporting
> > > performance attributes:
> > >
> > >   # tree -P "read*|write*" /sys/devices/system/node/nodeY/classZ/
> > >   /sys/devices/system/node/nodeY/classZ/
> > >   |-- read_bandwidth
> > >   |-- read_latency
> > >   |-- write_bandwidth
> > >   `-- write_latency
> > >
> > > The bandwidth is exported as MB/s and latency is reported in nanoseconds.
> > > Memory accesses from an initiator node that is not one of the memory's
> > > class "Z" initiator nodes may encounter different performance than
> > > reported here. When a subsystem makes use of this interface, initiators
> > > of a lower class number, "Z", have better performance relative to higher
> > > class numbers. When provided, class 0 is the highest performing access
> > > class.  
> > 
> > How does the definition of performance relate to bandwidth and latency here?. The
> > initiator in this class has the least latency and high bandwidth? Can there
> > be a scenario where both are not best for the same node? ie, for a
> > target Node Y, initiator Node A gives the highest bandwidth but initiator
> > Node B gets the least latency. How such a config can be represented? Or is
> > that not possible?  
> 
> I am not aware of a real platform that has an initiator-target pair with
> better latency but worse bandwidth than any different initiator paired to
> the same target. If such a thing exists and a subsystem wants to report
> that, you can register any arbitrary number of groups or classes and
> rank them according to how you want them presented.
> 

It's certainly possible if you are trading off against pin count by going
out of the soc on a serial bus for some large SCM pool and also have a local
SCM pool on a ddr 'like' bus or just ddr on fairly small number of channels
(because some one didn't put memory on all of them).
We will see this fairly soon in production parts.

So need an 'ordering' choice for this circumstance that is predictable.

Jonathan
