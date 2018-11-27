Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id F34566B49AB
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 12:43:08 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id o13so4088209otl.20
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 09:43:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 201sor2178116oib.7.2018.11.27.09.43.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 09:43:07 -0800 (PST)
MIME-Version: 1.0
References: <20181114224921.12123-2-keith.busch@intel.com> <20181114224921.12123-3-keith.busch@intel.com>
 <CAPcyv4jNpgzpfG1awrxspTeQ1JOK-4-Wu6Kb6cd6NGY6Atj3cg@mail.gmail.com>
In-Reply-To: <CAPcyv4jNpgzpfG1awrxspTeQ1JOK-4-Wu6Kb6cd6NGY6Atj3cg@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 27 Nov 2018 09:42:54 -0800
Message-ID: <CAPcyv4hMFc7K=FjHWiMVAiOxVC-s0itPjVTs_-7KrFhg4h_SXQ@mail.gmail.com>
Subject: Re: [PATCH 2/7] node: Add heterogenous memory performance
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ACPI <linux-acpi@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Greg KH <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Mon, Nov 26, 2018 at 11:00 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
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

Sorry, I misread patch1, this series does allow publishing the
multi-initiator case that shares the same performance profile to a
given target.

> It seems a precursor to these patches is arranges for offline node
> devices to be created for the ACPI proximity domains that are
> offline-by default for reserved memory ranges.

Likely still need this though because node devices don't tend to show
up until they have a cpu or online memory.
