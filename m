Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id F3FCC6B0038
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 10:03:08 -0500 (EST)
Received: by mail-ie0-f178.google.com with SMTP id rp18so22139649iec.9
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 07:03:08 -0800 (PST)
Received: from resqmta-po-05v.sys.comcast.net (resqmta-po-05v.sys.comcast.net. [2001:558:fe16:19:96:114:154:164])
        by mx.google.com with ESMTPS id j7si3889645igx.15.2015.01.28.07.03.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 07:03:08 -0800 (PST)
Date: Wed, 28 Jan 2015 09:03:06 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mmotm 2015-01-22-15-04: qemu failure due to 'mm: memcontrol:
 remove unnecessary soft limit tree node test'
In-Reply-To: <20150127172439.GA8623@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.11.1501280900000.31753@gentwo.org>
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org> <20150123050802.GB22751@roeck-us.net> <20150123141817.GA22926@phnom.home.cmpxchg.org> <alpine.DEB.2.11.1501230908560.15325@gentwo.org> <20150127172439.GA8623@dhcp22.suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>

On Tue, 27 Jan 2015, Michal Hocko wrote:

> Admittedly, I was checking only SLAB allocator when reviewing and
> assuming SLUB would behave in the same way :/
> But maybe I have misinterpreted the slab code as well and
> get_node(struct kmem_cache *, int node) returns non-NULL for !online
> nodes.

Oh. Just allocate from node 12345 in SLAB and you will also have a strange
failure.

> I have briefly checked the code and it seems that many users are aware
> of this and use the same construct Johannes used in the end or they use
> cpu_to_node. But then there are other users doing:
> net/openvswitch/flow_table.c:
>         /* Initialize the default stat node. */
>         stats = kmem_cache_alloc_node(flow_stats_cache,
>                                       GFP_KERNEL | __GFP_ZERO, 0);
>
> and this can blow up if Node0 is not online. I haven't checked other

Node 0 is special in many architectures and is guaranteed to exist.
PowerPC is a notable exception which causes frequent issues with NUMA
changes.

> That being said I have no problem with checking node_online in the memcg
> code which was reported to blow up here. I am just thinking whether it
> is safe to simply blow up like that.

Node numbers must be legitimate in order to be used. Same thing with
processor numbers. We cannot always check if they are online. The numbers
in use must be sane. We have notifier subsystems that do callbacks to
allow subsystems to add and remove new nodes and processors. Those should
be used to ensure that only legitimate node and processor numbers are
used.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
