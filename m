Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0D9A26B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 22:30:12 -0400 (EDT)
Received: by qgdy78 with SMTP id y78so2402886qgd.0
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 19:30:11 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id 190si6915408qha.31.2015.04.22.19.30.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 19:30:11 -0700 (PDT)
Message-ID: <1429756200.4915.19.camel@kernel.crashing.org>
Subject: Re: Interacting with coherent memory on external devices
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 23 Apr 2015 12:30:00 +1000
In-Reply-To: <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com>
	 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
	 <20150422000538.GB6046@gmail.com>
	 <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
	 <20150422131832.GU5561@linux.vnet.ibm.com>
	 <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Wed, 2015-04-22 at 11:16 -0500, Christoph Lameter wrote:
> On Wed, 22 Apr 2015, Paul E. McKenney wrote:
> 
> > I completely agree that some critically important use cases, such as
> > yours, will absolutely require that the application explicitly choose
> > memory placement and have the memory stay there.
> 
> 
> 
> Most of what you are trying to do here is already there and has been done.
> GPU memory is accessible. NICs work etc etc. All without CAPI. What
> exactly are the benefits of CAPI? Is driver simplification? Reduction of
> overhead? If so then the measures proposed are a bit radical and
> may result in just the opposite.

They are via MMIO space. The big differences here are that via CAPI the
memory can be fully cachable and thus have the same characteristics as
normal memory from the processor point of view, and the device shares
the MMU with the host.

Practically what that means is that the device memory *is* just some
normal system memory with a larger distance. The NUMA model is an
excellent representation of it.

> For my use cases the advantage of CAPI lies in the reduction of latency
> for coprocessor communication. I hope that CAPI will allow fast cache to
> cache transactions between a coprocessor and the main one. This is
> improving the ability to exchange data rapidly between a application code
> and some piece of hardware (NIC, GPU, custom hardware etc etc)
> 
> Fundamentally this is currently an design issue since CAPI is running on
> top of PCI-E and PCI-E transactions establish a minimum latency that
> cannot be avoided. So its hard to see how CAPI can improve the situation.

It's on top of the lower layers of PCIe yes, I don't know the exact
latency numbers. It does enable the device to own cache lines though and
vice versa.

> The new thing about CAPI are the cache to cache transactions and
> participation in cache coherency at the cacheline level. That is a
> different approach than the device memory oriented PCI transcactions.
> Perhaps even CAPI over PCI-E can improve the situation there (maybe the
> transactions are lower latency than going to device memory) and hopefully
> CAPI will not forever be bound to PCI-E and thus at some point shake off
> the shackles of a bus designed by a competitor.

Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
