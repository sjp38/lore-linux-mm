Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 952626B0003
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 15:32:43 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r13-v6so1872822wmc.8
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 12:32:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l19-v6sor595988wme.81.2018.08.10.12.32.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 Aug 2018 12:32:39 -0700 (PDT)
Date: Fri, 10 Aug 2018 21:32:37 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v3] resource: Merge resources on a node when hot-adding
 memory
Message-ID: <20180810193237.GA22441@techadventures.net>
References: <20180809025409.31552-1-rashmica.g@gmail.com>
 <20180809181224.0b7417e51215565dbda9f665@linux-foundation.org>
 <CAC6rBs=yYYZw-c02yp6rx-+TN2oUGgrp=uuLhZ=Kc_nnjmTRqA@mail.gmail.com>
 <20180810130052.GC1644@dhcp22.suse.cz>
 <CAC6rBsmkTSSg1RhWkpU-t+tQdyz7NKbfu96tX9BG1=LOGVg-Bw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAC6rBsmkTSSg1RhWkpU-t+tQdyz7NKbfu96tX9BG1=LOGVg-Bw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rashmica Gupta <rashmica.g@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, toshi.kani@hpe.com, tglx@linutronix.de, bp@suse.de, brijesh.singh@amd.com, thomas.lendacky@amd.com, jglisse@redhat.com, gregkh@linuxfoundation.org, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, Vlastimil Babka <vbabka@suse.cz>, malat@debian.org, Bjorn Helgaas <bhelgaas@google.com>, yasu.isimatu@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

On Sat, Aug 11, 2018 at 12:25:39AM +1000, Rashmica Gupta wrote:
> On Fri, Aug 10, 2018 at 11:00 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Fri 10-08-18 16:55:40, Rashmica Gupta wrote:
> > [...]
> >> Most memory hotplug/hotremove seems to be block or section based, and
> >> always adds and removes memory at the same place.
> >
> > Yes and that is hard wired to the memory hotplug code. It is not easy to
> > make it work outside of section units restriction. So whatever your
> > memtrace is doing and if it relies on subsection hotplug it cannot
> > possibly work with the current code.
> >
> > I didn't get to review your patch but if it is only needed for an
> > unmerged code I would rather incline to not merge it unless it is a
> > clear win to the resource subsystem. A report from Oscar shows that this
> > is not the case though.
> >
> 
> Yup, makes sense. I'll work on it and see if I can not break things.

In __case__ we really need this patch, I think that one way to fix this is
to only call merge_node_resources() in case the node is already online.
Something like this (completely untested):

+struct resource *request_resource_and_merge(struct resource *parent,
+                                           struct resource *new, int nid)
+{
+       struct resource *conflict;
+
+       conflict = request_resource_conflict(parent, new);
+
+       if (conflict)
+               return conflict;
+
+#ifdef CONFIG_MEMORY_HOTREMOVE
+       /* We do not need to merge any resources on a node that is being
+        * hot-added together with its memory.
+	 * The node will be allocated later.
+	 */
+       if (node_online(nid))
+       	merge_node_resources(nid, parent);
+#endif /* CONFIG_MEMORY_HOTREMOVE */

Although as Michal said, all memory-hotplug code is section-oriented, so
whatever it is that interacts with it should expect that.
Otherwise it can fail soon or later.

-- 
Oscar Salvador
SUSE L3
