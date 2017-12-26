Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9068E6B0033
	for <linux-mm@kvack.org>; Tue, 26 Dec 2017 14:06:39 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id x32so21232227ita.1
        for <linux-mm@kvack.org>; Tue, 26 Dec 2017 11:06:39 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [69.252.207.44])
        by mx.google.com with ESMTPS id i78si22193724ioe.130.2017.12.26.11.06.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Dec 2017 11:06:38 -0800 (PST)
Date: Tue, 26 Dec 2017 13:05:34 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 3/5] mm: enlarge NUMA counters threshold size
In-Reply-To: <9fb9af97-167c-6a0b-ded1-2790113ece9a@intel.com>
Message-ID: <alpine.DEB.2.20.1712261300040.10830@nuc-kabylake>
References: <1513665566-4465-1-git-send-email-kemi.wang@intel.com> <1513665566-4465-4-git-send-email-kemi.wang@intel.com> <20171219124045.GO2787@dhcp22.suse.cz> <439918f7-e8a3-c007-496c-99535cbc4582@intel.com> <20171220101229.GJ4831@dhcp22.suse.cz>
 <268b1b6e-ff7a-8f1a-f97c-f94e14591975@intel.com> <alpine.DEB.2.20.1712211107430.22093@nuc-kabylake> <9fb9af97-167c-6a0b-ded1-2790113ece9a@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kemi <kemi.wang@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Fri, 22 Dec 2017, kemi wrote:

> > I think you are fighting a lost battle there. As evident from the timing
> > constraints on packet processing in a 10/40G you will have a hard time to
> > process data if the packets are of regular ethernet size. And we alrady
> > have 100G NICs in operation here.
> >
>
> Not really.
> For 10/40G NIC or even 100G, I admit DPDK is widely used in data center network
> rather than kernel driver in production environment.

Shudder. I would rather have an user space API that is vendor neutral and
that allows the use of multiple NICs. The Linux kernel has an RDMA
subsystem that does just that.

But time budget is difficult to deal with even using RDMA or DPKG where we
can avoid the OS overhead.

> That's due to the slow page allocator and long pipeline processing in network
> protocol stack.

Right the timing budget there for processing a single packet gets below a
microsecond at some point and there its going to be difficult to do much.
Some aggregation / offloading is required and that increases as speeds
become higher.

> That's not easy to change this state in short time, but if we can do something
> here to change it a little, why not.

How much of an improvement is this going to be? If it is significant then
by all means lets do it.

> > We can try to get the performance as high as possible but full rate high
> > speed networking invariable must use offload mechanisms and thus the
> > statistics would only be available from the hardware devices that can do
> > wire speed processing.
> >
>
> I think you may be talking something about SmartNIC (e.g. OpenVswitch offload +
> VF pass through). That's usually used in virtualization environment to eliminate
> the overhead from device emulation and packet processing in software virtual
> switch(OVS or linux bridge).

The switch offloads Can also be used elsewhere. Also the RDMA subsystem
has counters like that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
