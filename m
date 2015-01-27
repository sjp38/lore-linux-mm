Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id E92B26B0073
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 12:24:44 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id l61so16147093wev.8
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 09:24:44 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cu5si4254257wib.48.2015.01.27.09.24.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 Jan 2015 09:24:43 -0800 (PST)
Date: Tue, 27 Jan 2015 18:24:39 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mmotm 2015-01-22-15-04: qemu failure due to 'mm: memcontrol:
 remove unnecessary soft limit tree node test'
Message-ID: <20150127172439.GA8623@dhcp22.suse.cz>
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org>
 <20150123050802.GB22751@roeck-us.net>
 <20150123141817.GA22926@phnom.home.cmpxchg.org>
 <alpine.DEB.2.11.1501230908560.15325@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1501230908560.15325@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>

On Fri 23-01-15 09:17:44, Christoph Lameter wrote:
> On Fri, 23 Jan 2015, Johannes Weiner wrote:
> 
> > Is the assumption of this patch wrong?  Does the specified node have
> > to be online for the fallback to work?

Admittedly, I was checking only SLAB allocator when reviewing and
assuming SLUB would behave in the same way :/
But maybe I have misinterpreted the slab code as well and
get_node(struct kmem_cache *, int node) returns non-NULL for !online
nodes.

> Nodes that are offline have no control structures allocated and thus
> allocations will likely segfault when the address of the controls
> structure for the node is accessed.
> 
> If we wanted to prevent that then every allocation would have to add a
> check to see if the nodes are online which would impact performance.

I have briefly checked the code and it seems that many users are aware
of this and use the same construct Johannes used in the end or they use
cpu_to_node. But then there are other users doing:
net/openvswitch/flow_table.c:
        /* Initialize the default stat node. */
        stats = kmem_cache_alloc_node(flow_stats_cache,
                                      GFP_KERNEL | __GFP_ZERO, 0);

and this can blow up if Node0 is not online. I haven't checked other
callers but are we sure they all are aware of !online nodes? E.g.
dev_to_node() will return a node which is assigned to a device. I do not
see where exactly this is set to anything else than -1 (I got quickly
lost in set_dev_node callers). E.g. PCI bus sets its affinity from
bus->sysdata which seems to be initialized in pci_acpi_scan_root and
that is checking for an online node. Is it possible that some devices
will get the node from BIOS or by other means?

That being said I have no problem with checking node_online in the memcg
code which was reported to blow up here. I am just thinking whether it
is safe to simply blow up like that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
