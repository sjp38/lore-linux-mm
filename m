Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 217C06B00E1
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 17:42:06 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so3838351pdb.24
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 14:42:05 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ap6si8567321pad.345.2014.02.21.14.42.04
        for <linux-mm@kvack.org>;
        Fri, 21 Feb 2014 14:42:05 -0800 (PST)
Date: Fri, 21 Feb 2014 14:42:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm: return NUMA_NO_NODE in local_memory_node if
 zonelists are not setup
Message-Id: <20140221144203.8d7b0d7039846c0304f86141@linux-foundation.org>
In-Reply-To: <20140220182847.GA24745@linux.vnet.ibm.com>
References: <20140219231641.GA413@linux.vnet.ibm.com>
	<20140219231714.GB413@linux.vnet.ibm.com>
	<alpine.DEB.2.10.1402201004460.11829@nuc>
	<20140220182847.GA24745@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, Anton Blanchard <anton@samba.org>, linuxppc-dev@lists.ozlabs.org

On Thu, 20 Feb 2014 10:28:47 -0800 Nishanth Aravamudan <nacc@linux.vnet.ibm.com> wrote:

> On 20.02.2014 [10:05:39 -0600], Christoph Lameter wrote:
> > On Wed, 19 Feb 2014, Nishanth Aravamudan wrote:
> > 
> > > We can call local_memory_node() before the zonelists are setup. In that
> > > case, first_zones_zonelist() will not set zone and the reference to
> > > zone->node will Oops. Catch this case, and, since we presumably running
> > > very early, just return that any node will do.
> > 
> > Really? Isnt there some way to avoid this call if zonelists are not setup
> > yet?
> 
> How do I best determine if zonelists aren't setup yet?
> 
> The call-path in question (after my series is applied) is:
> 
> arch/powerpc/kernel/setup_64.c::setup_arch ->
> 	arch/powerpc/mm/numa.c::do_init_bootmem() ->
> 		cpu_numa_callback() ->
> 			numa_setup_cpu() ->
> 				map_cpu_to_node() ->
> 					update_numa_cpu_node() ->
> 						set_cpu_numa_mem()
> 
> and setup_arch() is called before build_all_zonelists(NULL, NULL) in
> start_kernel(). This seemed like the most reasonable path, as it's used
> on hotplug as well.
> 

But the call to local_memory_node() you added was in start_secondary(),
which isn't in that trace.

I do agree that calling local_memory_node() too early then trying to
fudge around the consequences seems rather wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
