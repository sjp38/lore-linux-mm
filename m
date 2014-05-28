Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id C8E196B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 16:37:18 -0400 (EDT)
Received: by mail-yk0-f174.google.com with SMTP id 9so8809536ykp.5
        for <linux-mm@kvack.org>; Wed, 28 May 2014 13:37:18 -0700 (PDT)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id x21si33776757yhj.14.2014.05.28.13.37.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 28 May 2014 13:37:18 -0700 (PDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Wed, 28 May 2014 14:37:17 -0600
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id CA0063E40047
	for <linux-mm@kvack.org>; Wed, 28 May 2014 14:37:15 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4SKa3q88323566
	for <linux-mm@kvack.org>; Wed, 28 May 2014 22:36:04 +0200
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4SKbFSx017587
	for <linux-mm@kvack.org>; Wed, 28 May 2014 14:37:15 -0600
Date: Wed, 28 May 2014 13:37:11 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: NUMA topology question wrt. d4edc5b6
Message-ID: <20140528203711.GB11652@linux.vnet.ibm.com>
References: <20140521200451.GB5755@linux.vnet.ibm.com>
 <537E6285.3050000@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <537E6285.3050000@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, nfont@linux.vnet.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Anton Blanchard <anton@samba.org>, Dave Hansen <dave@sr71.net>, "linuxppc-dev@lists.ozlabs.org list" <linuxppc-dev@lists.ozlabs.org>, Linux MM <linux-mm@kvack.org>

On 23.05.2014 [02:18:05 +0530], Srivatsa S. Bhat wrote:
> 
> [ Adding a few more CC's ]
> 
> On 05/22/2014 01:34 AM, Nishanth Aravamudan wrote:
> > Hi Srivatsa,
> > 
> > After d4edc5b6 ("powerpc: Fix the setup of CPU-to-Node mappings during
> > CPU online"), cpu_to_node() looks like:
> > 
> > static inline int cpu_to_node(int cpu)
> > {
> >         int nid;
> > 
> >         nid = numa_cpu_lookup_table[cpu];
> > 
> >         /*
> >          * During early boot, the numa-cpu lookup table might not have been
> >          * setup for all CPUs yet. In such cases, default to node 0.
> >          */
> >         return (nid < 0) ? 0 : nid;
> > }
> > 
> > However, I'm curious if this is correct in all cases. I have seen
> > several LPARs that do not have any CPUs on node 0. In fact, because node
> > 0 is statically set online in the initialization of the N_ONLINE
> > nodemask, 0 is always present to Linux, whether it is present on the
> > system. I'm not sure what the best thing to do here is, but I'm curious
> > if you have any ideas? I would like to remove the static initialization
> > of node 0, as it's confusing to users to see an empty node (particularly
> > when it's completely separate in the numbering from other nodes), but
> > we trip a panic (refer to:
> > http://www.spinics.net/lists/linux-mm/msg73321.html).
> > 
> 
> Ah, I see. I didn't have any particular reason to default it to zero.
> I just did that because the existing code before this patch did the same
> thing. (numa_cpu_lookup_table[] is a global array, so it will be initialized
> with zeros. So if we access it before populating it via numa_setup_cpu(),
> it would return 0. So I retained that behaviour with the above conditional).

Ok, that seems reasonable to me (keeping the behavior the same as it was
before).

> Will something like the below [totally untested] patch solve the boot-panic?
> I understand that as of today first_online_node will still pick 0 since
> N_ONLINE is initialized statically, but with your proposed change to that
> init code, I guess the following patch should avoid the boot panic.
> 
> [ But note that first_online_node is hard-coded to 0, if MAX_NUMNODES is = 1.
> So we'll have to fix that if powerpc can have a single node system whose node
> is numbered something other than 0. Can that happen as well? ]

I think all single-node systems are only Node 0, but I'm not 100% on
that.

> And regarding your question about what is the best way to fix this
> whole Linux MM's assumption about node0, I'm not really sure.. since I
> am not really aware of the extent to which the MM subsystem is
> intertwined with this assumption and what it would take to cure that
> :-(

Well, at this point, it might be fine to just leave it alone, as it
seems to be more trouble than it's worth -- and really the only
confusion is on those LPARs where there really isn't a Node 0. I'll take
another look later this week.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
