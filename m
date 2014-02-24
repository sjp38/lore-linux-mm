Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0526B0114
	for <linux-mm@kvack.org>; Mon, 24 Feb 2014 14:43:36 -0500 (EST)
Received: by mail-qa0-f50.google.com with SMTP id cm18so6585187qab.37
        for <linux-mm@kvack.org>; Mon, 24 Feb 2014 11:43:36 -0800 (PST)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id k1si1107346qaf.5.2014.02.24.11.43.34
        for <linux-mm@kvack.org>;
        Mon, 24 Feb 2014 11:43:35 -0800 (PST)
Date: Mon, 24 Feb 2014 13:43:31 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm: return NUMA_NO_NODE in local_memory_node if
 zonelists are not setup
In-Reply-To: <20140221235616.GA25399@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1402241342480.20839@nuc>
References: <20140219231641.GA413@linux.vnet.ibm.com> <20140219231714.GB413@linux.vnet.ibm.com> <alpine.DEB.2.10.1402201004460.11829@nuc> <20140220182847.GA24745@linux.vnet.ibm.com> <20140221144203.8d7b0d7039846c0304f86141@linux-foundation.org>
 <20140221235616.GA25399@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, Anton Blanchard <anton@samba.org>, linuxppc-dev@lists.ozlabs.org

On Fri, 21 Feb 2014, Nishanth Aravamudan wrote:

> I added two calls to local_memory_node(), I *think* both are necessary,
> but am willing to be corrected.
>
> One is in map_cpu_to_node() and one is in start_secondary(). The
> start_secondary() path is fine, AFAICT, as we are up & running at that
> point. But in [the renamed function] update_numa_cpu_node() which is
> used by hotplug, we get called from do_init_bootmem(), which is before
> the zonelists are setup.
>
> I think both calls are necessary because I believe the
> arch_update_cpu_topology() is used for supporting firmware-driven
> home-noding, which does not invoke start_secondary() again (the
> processor is already running, we're just updating the topology in that
> situation).
>
> Then again, I could special-case the do_init_bootmem callpath, which is
> only called at kernel init time?

Well taht looks to be simpler.

> > I do agree that calling local_memory_node() too early then trying to
> > fudge around the consequences seems rather wrong.
>
> If the answer is to simply not call local_memory_node() early, I'll
> submit a patch to at least add a comment, as there's nothing in the code
> itself to prevent this from happening and is guaranteed to oops.

Ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
