Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id E27F36B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 16:49:22 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id md12so3022565pbc.40
        for <linux-mm@kvack.org>; Thu, 22 May 2014 13:49:22 -0700 (PDT)
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com. [202.81.31.141])
        by mx.google.com with ESMTPS id il2si1084768pbc.87.2014.05.22.13.49.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 22 May 2014 13:49:21 -0700 (PDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 23 May 2014 06:49:18 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 8B2D22BB0052
	for <linux-mm@kvack.org>; Fri, 23 May 2014 06:49:14 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4MKRjAx59179234
	for <linux-mm@kvack.org>; Fri, 23 May 2014 06:27:46 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4MKnDf3015942
	for <linux-mm@kvack.org>; Fri, 23 May 2014 06:49:13 +1000
Message-ID: <537E6285.3050000@linux.vnet.ibm.com>
Date: Fri, 23 May 2014 02:18:05 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: NUMA topology question wrt. d4edc5b6
References: <20140521200451.GB5755@linux.vnet.ibm.com>
In-Reply-To: <20140521200451.GB5755@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, nfont@linux.vnet.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Anton Blanchard <anton@samba.org>, Dave Hansen <dave@sr71.net>, "linuxppc-dev@lists.ozlabs.org list" <linuxppc-dev@lists.ozlabs.org>, Linux MM <linux-mm@kvack.org>


[ Adding a few more CC's ]

On 05/22/2014 01:34 AM, Nishanth Aravamudan wrote:
> Hi Srivatsa,
> 
> After d4edc5b6 ("powerpc: Fix the setup of CPU-to-Node mappings during
> CPU online"), cpu_to_node() looks like:
> 
> static inline int cpu_to_node(int cpu)
> {
>         int nid;
> 
>         nid = numa_cpu_lookup_table[cpu];
> 
>         /*
>          * During early boot, the numa-cpu lookup table might not have been
>          * setup for all CPUs yet. In such cases, default to node 0.
>          */
>         return (nid < 0) ? 0 : nid;
> }
> 
> However, I'm curious if this is correct in all cases. I have seen
> several LPARs that do not have any CPUs on node 0. In fact, because node
> 0 is statically set online in the initialization of the N_ONLINE
> nodemask, 0 is always present to Linux, whether it is present on the
> system. I'm not sure what the best thing to do here is, but I'm curious
> if you have any ideas? I would like to remove the static initialization
> of node 0, as it's confusing to users to see an empty node (particularly
> when it's completely separate in the numbering from other nodes), but
> we trip a panic (refer to:
> http://www.spinics.net/lists/linux-mm/msg73321.html).
> 

Ah, I see. I didn't have any particular reason to default it to zero.
I just did that because the existing code before this patch did the same
thing. (numa_cpu_lookup_table[] is a global array, so it will be initialized
with zeros. So if we access it before populating it via numa_setup_cpu(),
it would return 0. So I retained that behaviour with the above conditional).

Will something like the below [totally untested] patch solve the boot-panic?
I understand that as of today first_online_node will still pick 0 since
N_ONLINE is initialized statically, but with your proposed change to that
init code, I guess the following patch should avoid the boot panic.

[ But note that first_online_node is hard-coded to 0, if MAX_NUMNODES is = 1.
So we'll have to fix that if powerpc can have a single node system whose node
is numbered something other than 0. Can that happen as well? ]


And regarding your question about what is the best way to fix this whole Linux
MM's assumption about node0, I'm not really sure.. since I am not really aware
of the extent to which the MM subsystem is intertwined with this assumption
and what it would take to cure that :-(

Regards,
Srivatsa S. Bhat


diff --git a/arch/powerpc/include/asm/topology.h b/arch/powerpc/include/asm/topology.h
index c920215..58e6469 100644
--- a/arch/powerpc/include/asm/topology.h
+++ b/arch/powerpc/include/asm/topology.h
@@ -18,6 +18,7 @@ struct device_node;
  */
 #define RECLAIM_DISTANCE 10
 
+#include <linux/nodemask.h>
 #include <asm/mmzone.h>
 
 static inline int cpu_to_node(int cpu)
@@ -30,7 +31,7 @@ static inline int cpu_to_node(int cpu)
 	 * During early boot, the numa-cpu lookup table might not have been
 	 * setup for all CPUs yet. In such cases, default to node 0.
 	 */
-	return (nid < 0) ? 0 : nid;
+	return (nid < 0) ? first_online_node : nid;
 }
 
 #define parent_node(node)	(node)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
