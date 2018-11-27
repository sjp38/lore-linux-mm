Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 978146B49B1
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 12:48:00 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t72so7754237pfi.21
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 09:48:00 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id w2si4172850pgs.264.2018.11.27.09.47.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 09:47:59 -0800 (PST)
Date: Tue, 27 Nov 2018 10:44:57 -0700
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCH 2/7] node: Add heterogenous memory performance
Message-ID: <20181127174457.GB6401@localhost.localdomain>
References: <20181114224921.12123-2-keith.busch@intel.com>
 <20181114224921.12123-3-keith.busch@intel.com>
 <CAPcyv4jNpgzpfG1awrxspTeQ1JOK-4-Wu6Kb6cd6NGY6Atj3cg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jNpgzpfG1awrxspTeQ1JOK-4-Wu6Kb6cd6NGY6Atj3cg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ACPI <linux-acpi@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>

On Mon, Nov 26, 2018 at 11:00:09PM -0800, Dan Williams wrote:
> On Wed, Nov 14, 2018 at 2:53 PM Keith Busch <keith.busch@intel.com> wrote:
> >
> > Heterogeneous memory systems provide memory nodes with latency
> > and bandwidth performance attributes that are different from other
> > nodes. Create an interface for the kernel to register these attributes
> > under the node that provides the memory. If the system provides this
> > information, applications can query the node attributes when deciding
> > which node to request memory.
> >
> > When multiple memory initiators exist, accessing the same memory target
> > from each may not perform the same as the other. The highest performing
> > initiator to a given target is considered to be a local initiator for
> > that target. The kernel provides performance attributes only for the
> > local initiators.
> >
> > The memory's compute node should be symlinked in sysfs as one of the
> > node's initiators.
> >
> > The following example shows the new sysfs hierarchy for a node exporting
> > performance attributes:
> >
> >   # tree /sys/devices/system/node/nodeY/initiator_access
> >   /sys/devices/system/node/nodeY/initiator_access
> >   |-- read_bandwidth
> >   |-- read_latency
> >   |-- write_bandwidth
> >   `-- write_latency
> 
> With the expectation that there will be nodes that are initiator-only,
> target-only, or both I think this interface should indicate that. The
> 1:1 "local" designation of HMAT should not be directly encoded in the
> interface, it's just a shortcut for finding at least one initiator in
> the set that can realize the advertised performance. At least if the
> interface can enumerate the set of initiators then it becomes clear
> whether sysfs can answer a performance enumeration question or if the
> application needs to consult an interface with specific knowledge of a
> given initiator-target pairing.
> 
> It seems a precursor to these patches is arranges for offline node
> devices to be created for the ACPI proximity domains that are
> offline-by default for reserved memory ranges.

The intention is that all initiators symlinked to the memory node share
the initiator_access attributes, as well as itself the node is its own
initiator. There's no limit to how many the new kernel interface in
patch 1/7 allows you to register, so it's not really a 1:1 relationship.

Either instead or in addition to the symlinks, we can export a node_mask
in the initiator_access directory for which these access attributes
apply if that makes the intention more clear.
