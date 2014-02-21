Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 59E756B00EE
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 18:56:30 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id w8so4063657qac.22
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 15:56:30 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id u9si4766292qar.149.2014.02.21.15.56.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 21 Feb 2014 15:56:29 -0800 (PST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Fri, 21 Feb 2014 16:56:29 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id D2CCF3E4003E
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 16:56:24 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1LNu0N510682692
	for <linux-mm@kvack.org>; Sat, 22 Feb 2014 00:56:00 +0100
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1LNuO7w003575
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 16:56:24 -0700
Date: Fri, 21 Feb 2014 15:56:16 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] mm: return NUMA_NO_NODE in local_memory_node if
 zonelists are not setup
Message-ID: <20140221235616.GA25399@linux.vnet.ibm.com>
References: <20140219231641.GA413@linux.vnet.ibm.com>
 <20140219231714.GB413@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1402201004460.11829@nuc>
 <20140220182847.GA24745@linux.vnet.ibm.com>
 <20140221144203.8d7b0d7039846c0304f86141@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140221144203.8d7b0d7039846c0304f86141@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, Anton Blanchard <anton@samba.org>, linuxppc-dev@lists.ozlabs.org

On 21.02.2014 [14:42:03 -0800], Andrew Morton wrote:
> On Thu, 20 Feb 2014 10:28:47 -0800 Nishanth Aravamudan <nacc@linux.vnet.ibm.com> wrote:
> 
> > On 20.02.2014 [10:05:39 -0600], Christoph Lameter wrote:
> > > On Wed, 19 Feb 2014, Nishanth Aravamudan wrote:
> > > 
> > > > We can call local_memory_node() before the zonelists are setup. In that
> > > > case, first_zones_zonelist() will not set zone and the reference to
> > > > zone->node will Oops. Catch this case, and, since we presumably running
> > > > very early, just return that any node will do.
> > > 
> > > Really? Isnt there some way to avoid this call if zonelists are not setup
> > > yet?
> > 
> > How do I best determine if zonelists aren't setup yet?
> > 
> > The call-path in question (after my series is applied) is:
> > 
> > arch/powerpc/kernel/setup_64.c::setup_arch ->
> > 	arch/powerpc/mm/numa.c::do_init_bootmem() ->
> > 		cpu_numa_callback() ->
> > 			numa_setup_cpu() ->
> > 				map_cpu_to_node() ->
> > 					update_numa_cpu_node() ->
> > 						set_cpu_numa_mem()
> > 
> > and setup_arch() is called before build_all_zonelists(NULL, NULL) in
> > start_kernel(). This seemed like the most reasonable path, as it's used
> > on hotplug as well.
> > 
> 
> But the call to local_memory_node() you added was in start_secondary(),
> which isn't in that trace.

I added two calls to local_memory_node(), I *think* both are necessary,
but am willing to be corrected.

One is in map_cpu_to_node() and one is in start_secondary(). The
start_secondary() path is fine, AFAICT, as we are up & running at that
point. But in [the renamed function] update_numa_cpu_node() which is
used by hotplug, we get called from do_init_bootmem(), which is before
the zonelists are setup.

I think both calls are necessary because I believe the
arch_update_cpu_topology() is used for supporting firmware-driven
home-noding, which does not invoke start_secondary() again (the
processor is already running, we're just updating the topology in that
situation).

Then again, I could special-case the do_init_bootmem callpath, which is
only called at kernel init time?

> I do agree that calling local_memory_node() too early then trying to
> fudge around the consequences seems rather wrong.

If the answer is to simply not call local_memory_node() early, I'll
submit a patch to at least add a comment, as there's nothing in the code
itself to prevent this from happening and is guaranteed to oops.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
