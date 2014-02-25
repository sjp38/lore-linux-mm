Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f47.google.com (mail-oa0-f47.google.com [209.85.219.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8EBC76B0121
	for <linux-mm@kvack.org>; Mon, 24 Feb 2014 21:34:23 -0500 (EST)
Received: by mail-oa0-f47.google.com with SMTP id h16so2963003oag.20
        for <linux-mm@kvack.org>; Mon, 24 Feb 2014 18:34:23 -0800 (PST)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id tk7si11936451obc.29.2014.02.24.18.34.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Feb 2014 18:34:22 -0800 (PST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Mon, 24 Feb 2014 19:34:22 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 604AF1FF003F
	for <linux-mm@kvack.org>; Mon, 24 Feb 2014 19:34:20 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1P2YKx510420710
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 03:34:20 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1P2YJv1019167
	for <linux-mm@kvack.org>; Mon, 24 Feb 2014 19:34:20 -0700
Date: Mon, 24 Feb 2014 18:34:15 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] mm: return NUMA_NO_NODE in local_memory_node if
 zonelists are not setup
Message-ID: <20140225023415.GA6105@linux.vnet.ibm.com>
References: <20140219231641.GA413@linux.vnet.ibm.com>
 <20140219231714.GB413@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1402201004460.11829@nuc>
 <20140220182847.GA24745@linux.vnet.ibm.com>
 <20140221144203.8d7b0d7039846c0304f86141@linux-foundation.org>
 <20140221235616.GA25399@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1402241342480.20839@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1402241342480.20839@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, Anton Blanchard <anton@samba.org>, linuxppc-dev@lists.ozlabs.org

On 24.02.2014 [13:43:31 -0600], Christoph Lameter wrote:
> On Fri, 21 Feb 2014, Nishanth Aravamudan wrote:
> 
> > I added two calls to local_memory_node(), I *think* both are necessary,
> > but am willing to be corrected.
> >
> > One is in map_cpu_to_node() and one is in start_secondary(). The
> > start_secondary() path is fine, AFAICT, as we are up & running at that
> > point. But in [the renamed function] update_numa_cpu_node() which is
> > used by hotplug, we get called from do_init_bootmem(), which is before
> > the zonelists are setup.
> >
> > I think both calls are necessary because I believe the
> > arch_update_cpu_topology() is used for supporting firmware-driven
> > home-noding, which does not invoke start_secondary() again (the
> > processor is already running, we're just updating the topology in that
> > situation).
> >
> > Then again, I could special-case the do_init_bootmem callpath, which is
> > only called at kernel init time?
> 
> Well taht looks to be simpler.

Ok, I'll work on this.

> > > I do agree that calling local_memory_node() too early then trying to
> > > fudge around the consequences seems rather wrong.
> >
> > If the answer is to simply not call local_memory_node() early, I'll
> > submit a patch to at least add a comment, as there's nothing in the code
> > itself to prevent this from happening and is guaranteed to oops.
> 
> Ok.

Thanks!
-Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
