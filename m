Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id C12C86B00AA
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 19:30:41 -0500 (EST)
Received: by mail-qc0-f182.google.com with SMTP id w7so2365562qcr.41
        for <linux-mm@kvack.org>; Thu, 20 Feb 2014 16:30:41 -0800 (PST)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id gd5si2191129qab.180.2014.02.20.16.30.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Feb 2014 16:30:41 -0800 (PST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Thu, 20 Feb 2014 17:30:40 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 1BF971FF001A
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 17:30:38 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1L0UaLx10224034
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 01:30:38 +0100
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1L0Uadt007825
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 17:30:36 -0700
Date: Thu, 20 Feb 2014 16:30:27 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: N_NORMAL on NUMA?
Message-ID: <20140221003027.GA12799@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: rientjes@google.com, cl@linux.com, anton@samba.org

I'm confused by the following:

/*
 * Array of node states.
 */
nodemask_t node_states[NR_NODE_STATES] __read_mostly = {
        [N_POSSIBLE] = NODE_MASK_ALL,
        [N_ONLINE] = { { [0] = 1UL } },
#ifndef CONFIG_NUMA
        [N_NORMAL_MEMORY] = { { [0] = 1UL } },
#ifdef CONFIG_HIGHMEM
        [N_HIGH_MEMORY] = { { [0] = 1UL } },
#endif
#ifdef CONFIG_MOVABLE_NODE
        [N_MEMORY] = { { [0] = 1UL } },
#endif
        [N_CPU] = { { [0] = 1UL } },
#endif  /* NUMA */
};

Why are we checking for CONFIG_MOVABLE_NODE above when mm/Kconfig says:

config MOVABLE_NODE
        boolean "Enable to assign a node which has only movable memory"
        depends on HAVE_MEMBLOCK
        depends on NO_BOOTMEM
        depends on X86_64
        depends on NUMA

? Doesn't that mean that you can't have CONFIG_HAVE_MOVABLE_NODE without
CONFIG_NUMA? But we're in a #ifndef CONFIG_NUMA block above...

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
