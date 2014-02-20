Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id C489A6B009E
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 13:29:11 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id j15so3362662qaq.25
        for <linux-mm@kvack.org>; Thu, 20 Feb 2014 10:29:11 -0800 (PST)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id g88si2327209qgf.126.2014.02.20.10.29.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Feb 2014 10:29:03 -0800 (PST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Thu, 20 Feb 2014 11:29:02 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id AF30C19D805E
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 11:28:58 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1KISx5P10223880
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 19:28:59 +0100
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1KISx5c029830
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 11:28:59 -0700
Date: Thu, 20 Feb 2014 10:28:47 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] mm: return NUMA_NO_NODE in local_memory_node if
 zonelists are not setup
Message-ID: <20140220182847.GA24745@linux.vnet.ibm.com>
References: <20140219231641.GA413@linux.vnet.ibm.com>
 <20140219231714.GB413@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1402201004460.11829@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1402201004460.11829@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, Anton Blanchard <anton@samba.org>, linuxppc-dev@lists.ozlabs.org

On 20.02.2014 [10:05:39 -0600], Christoph Lameter wrote:
> On Wed, 19 Feb 2014, Nishanth Aravamudan wrote:
> 
> > We can call local_memory_node() before the zonelists are setup. In that
> > case, first_zones_zonelist() will not set zone and the reference to
> > zone->node will Oops. Catch this case, and, since we presumably running
> > very early, just return that any node will do.
> 
> Really? Isnt there some way to avoid this call if zonelists are not setup
> yet?

How do I best determine if zonelists aren't setup yet?

The call-path in question (after my series is applied) is:

arch/powerpc/kernel/setup_64.c::setup_arch ->
	arch/powerpc/mm/numa.c::do_init_bootmem() ->
		cpu_numa_callback() ->
			numa_setup_cpu() ->
				map_cpu_to_node() ->
					update_numa_cpu_node() ->
						set_cpu_numa_mem()

and setup_arch() is called before build_all_zonelists(NULL, NULL) in
start_kernel(). This seemed like the most reasonable path, as it's used
on hotplug as well.

I'm open to suggestsions!

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
