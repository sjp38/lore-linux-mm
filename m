Received: from westrelay03.boulder.ibm.com (westrelay03.boulder.ibm.com [9.17.194.24])
	by e31.co.us.ibm.com (8.12.2/8.12.2) with ESMTP id g6V0l2XW047302
	for <linux-mm@kvack.org>; Tue, 30 Jul 2002 20:47:02 -0400
Received: from gateway1.beaverton.ibm.com (gateway1.beaverton.ibm.com [138.95.180.2])
	by westrelay03.boulder.ibm.com (8.12.3/NCO/VER6.3) with ESMTP id g6V0l17j087720
	for <linux-mm@kvack.org>; Tue, 30 Jul 2002 18:47:02 -0600
Received: from flay (mbligh@dyn9-47-17-70.beaverton.ibm.com [9.47.17.70])
	by gateway1.beaverton.ibm.com (8.11.6/8.11.6) with ESMTP id g6V0hPK18496
	for <linux-mm@kvack.org>; Tue, 30 Jul 2002 17:43:25 -0700
Date: Tue, 30 Jul 2002 17:45:30 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: How did paging_init ever work with PAE?
Message-ID: <536090000.1028076330@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

We're crashing in paging_init under certain circumstances, but on
closer inspection, I'm unsure how this ever could have worked.
Obviously it does most of the time, so I'm missing something ....

With PAE on, the code path looks like this:

        pagetable_init();
        load_cr3(swapper_pg_dir);
        if (cpu_has_pae)
                set_in_cr4(X86_CR4_PAE);

Hmmm .... pagetable_init sets up a PGD for PAE use, then we load
cr3 with this table .... then we turn on PAE mode.

How are we surviving in this limbo state between the point when
we reload cr3 and when we turn on PAE? If we take a page fault
(which we will, since reloading cr3 flushes the tlb) is the PGD 
somehow dual purpose and works for non-PAE systems as well?
Are we relying on the global bit on entries on the TLB cache which
we're just praying aren't going to fall out?

Seems very strange ..... any clarification much appreciated.

Thanks,

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
