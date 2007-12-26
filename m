Date: Wed, 26 Dec 2007 13:01:49 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.22-stable causes oomkiller to be invoked
In-Reply-To: <20071221044508.GA11996@linux.vnet.ibm.com>
Message-ID: <Pine.LNX.4.64.0712261258050.16862@schroedinger.engr.sgi.com>
References: <20071214095023.b5327703.akpm@linux-foundation.org>
 <20071214182802.GC2576@linux.vnet.ibm.com> <20071214150533.aa30efd4.akpm@linux-foundation.org>
 <20071215035200.GA22082@linux.vnet.ibm.com> <20071214220030.325f82b8.akpm@linux-foundation.org>
 <20071215104434.GA26325@linux.vnet.ibm.com> <20071217045904.GB31386@linux.vnet.ibm.com>
 <Pine.LNX.4.64.0712171143280.12871@schroedinger.engr.sgi.com>
 <20071217120720.e078194b.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0712171222470.29500@schroedinger.engr.sgi.com>
 <20071221044508.GA11996@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, htejun@gmail.com, gregkh@suse.de, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Balbir Singh <balbir@in.ibm.com>, maneesh@linux.vnet.ibm.com, lkml <linux-kernel@vger.kernel.org>, stable@kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Dec 2007, Dhaval Giani wrote:

> No, it does not stop the oom I am seeing here.

Duh. Disregard that patch. It looks like check_pgt_cache() is not called. 
This could happen if tlb_flush_mmu is never called during the 
fork/terminate sequences in your script. pgd_free is called *after* a 
possible tlb flush so the pgd page is on the quicklist (which is good for 
the next process which needs a pgd). The tlb_flush_mmu's during pte 
eviction should trim the quicklist. For some reason this is not happening 
on your box (it works here).

Could you try this script that insures that check_pgt_cache is called 
after every pgd_free?

Index: linux-2.6/arch/x86/mm/pgtable_32.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/pgtable_32.c	2007-12-26 12:55:10.000000000 -0800
+++ linux-2.6/arch/x86/mm/pgtable_32.c	2007-12-26 12:55:54.000000000 -0800
@@ -366,6 +366,15 @@ void pgd_free(pgd_t *pgd)
 		}
 	/* in the non-PAE case, free_pgtables() clears user pgd entries */
 	quicklist_free(0, pgd_dtor, pgd);
+
+	/*
+	 * We must call check_pgd_cache() here because the pgd is freed after
+	 * tlb flushing and the call to check_pgd_cache. In some cases the VM
+	 * may not call tlb_flush_mmu during process termination (??).
+	 * If this is repeated then we may never call check_pgd_cache.
+	 * The quicklist will grow and grow. So call check_pgd_cache here.
+	 */
+	check_pgt_cache();
 }
 
 void check_pgt_cache(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
