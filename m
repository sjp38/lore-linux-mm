Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAFMA6Uw001147
	for <linux-mm@kvack.org>; Tue, 15 Nov 2005 17:10:06 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAFM9r7i061596
	for <linux-mm@kvack.org>; Tue, 15 Nov 2005 15:09:53 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jAFMA50g002672
	for <linux-mm@kvack.org>; Tue, 15 Nov 2005 15:10:06 -0700
Date: Tue, 15 Nov 2005 14:10:03 -0800
From: Mike Kravetz <kravetz@us.ibm.com>
Subject: pfn_to_nid under CONFIG_SPARSEMEM and CONFIG_NUMA
Message-ID: <20051115221003.GA2160@w-mikek2.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andy Whitcroft <apw@shadowen.org>, Anton Blanchard <anton@samba.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The following code/comment is in <linux/mmzone.h> if SPARSEMEM
and NUMA are configured.

/*
 * These are _only_ used during initialisation, therefore they
 * can use __initdata ...  They could have names to indicate
 * this restriction.
 */
#ifdef CONFIG_NUMA
#define pfn_to_nid              early_pfn_to_nid
#endif

However, pfn_to_nid is certainly used in check_pte_range() mm/mempolicy.c.
I wouldn't be surprised to find more non init time uses if you follow all
the call chains.

On ppc64, early_pfn_to_nid now only uses __initdata.  So, I would expect
policy code that calls check_pte_range to cause serious problems on ppc64.

Any suggestions on how this should really be structured?  I'm thinking
of removing the above definition of pfn_to_nid to force each architecture
to provide a (non init only) version.

-- 
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
