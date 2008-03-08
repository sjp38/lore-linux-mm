Received: by hs-out-0708.google.com with SMTP id j58so725156hsj.6
        for <linux-mm@kvack.org>; Sat, 08 Mar 2008 01:35:57 -0800 (PST)
Message-ID: <e2e108260803080135w88bba4bt8e6153a1e162c21@mail.gmail.com>
Date: Sat, 8 Mar 2008 10:35:57 +0100
From: "Bart Van Assche" <bart.vanassche@gmail.com>
Subject: Re: Synchronization of the procps tools with /proc/meminfo
In-Reply-To: <787b0d920802191053pea784fdycd3b5119cfb886a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <e2e108260802180755l1c80b13an89ed417c20132f08@mail.gmail.com>
	 <787b0d920802191053pea784fdycd3b5119cfb886a@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Albert Cahalan <acahalan@cs.uml.edu>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2008 at 7:53 PM, Albert Cahalan <acahalan@cs.uml.edu> wrote:
> On Feb 18, 2008 10:55 AM, Bart Van Assche <bart.vanassche@gmail.com> wrote:
>
>  > This leads me to the question: if the layout of /proc/meminfo changes,
>  > who communicates these changes to the procps maintainers ?
>
>  Nobody ever informs me. :-(

Albert, can you please review the patch below ?

Thanks,

Bart.


diff -ru orig/procps-3.2.7/proc/library.map procps-3.2.7/proc/library.map
--- orig/procps-3.2.7/proc/library.map	2005-03-14 05:32:40.000000000 +0100
+++ procps-3.2.7/proc/library.map	2008-03-08 10:17:01.000000000 +0100
@@ -18,6 +18,8 @@
   kb_main_free; kb_main_total; kb_main_used; kb_swap_free;
   kb_swap_total; kb_swap_used; kb_main_shared;
   kb_low_total; kb_low_free; kb_high_total; kb_high_free;
+  kb_swap_cached; kb_anon_pages; kb_bounce; kb_nfs_unstable;
+  kb_slab_reclaimable; kb_slab_unreclaimable;
   vm_pgpgin; vm_pgpgout; vm_pswpin; vm_pswpout;
   free_slabinfo; put_slabinfo; get_slabinfo; get_proc_stats;
 local: *;
diff -ru orig/procps-3.2.7/proc/sysinfo.c procps-3.2.7/proc/sysinfo.c
--- orig/procps-3.2.7/proc/sysinfo.c	2006-06-25 08:41:48.000000000 +0200
+++ procps-3.2.7/proc/sysinfo.c	2008-03-08 10:30:14.000000000 +0100
@@ -8,6 +8,8 @@
 // File for parsing top-level /proc entities. */
 //
 // June 2003, Fabian Frederick, disk and slab info
+// Copyright (c) 2003 Fabian Frederick.
+// Copyright (c) 2008 Bart Van Assche.

 #include <stdio.h>
 #include <stdlib.h>
@@ -503,6 +505,11 @@
 unsigned long kb_swap_free;
 unsigned long kb_swap_total;
 /* recently introduced */
+unsigned long kb_anon_pages;
+unsigned long kb_bounce;
+unsigned long kb_nfs_unstable;
+unsigned long kb_slab_reclaimable;
+unsigned long kb_slab_unreclaimable;
 unsigned long kb_high_free;
 unsigned long kb_high_total;
 unsigned long kb_low_free;
@@ -539,6 +546,8 @@
   char *tail;
   static const mem_table_struct mem_table[] = {
   {"Active",       &kb_active},       // important
+  {"AnonPages",    &kb_anon_pages},
+  {"Bounce",       &kb_bounce},
   {"Buffers",      &kb_main_buffers}, // important
   {"Cached",       &kb_main_cached},  // important
   {"Committed_AS", &kb_committed_as},
@@ -556,10 +565,13 @@
   {"MemFree",      &kb_main_free},    // important
   {"MemShared",    &kb_main_shared},  // important, but now gone!
   {"MemTotal",     &kb_main_total},   // important
+  {"NFS_Unstable", &kb_nfs_unstable},
   {"PageTables",   &kb_pagetables},   // kB version of vmstat
nr_page_table_pages
   {"ReverseMaps",  &nr_reversemaps},  // same as vmstat nr_page_table_pages
   {"Slab",         &kb_slab},         // kB version of vmstat nr_slab
   {"SwapCached",   &kb_swap_cached},
+  {"SReclaimable", &kb_slab_reclaimable},
+  {"SUnreclaim",   &kb_slab_unreclaimable},
   {"SwapFree",     &kb_swap_free},    // important
   {"SwapTotal",    &kb_swap_total},   // important
   {"VmallocChunk", &kb_vmalloc_chunk},
@@ -603,6 +615,7 @@
   }
   kb_swap_used = kb_swap_total - kb_swap_free;
   kb_main_used = kb_main_total - kb_main_free;
+  kb_main_cached += kb_slab_reclaimable + kb_swap_cached + kb_nfs_unstable;
 }

 /*****************************************************************/
diff -ru orig/procps-3.2.7/proc/sysinfo.h procps-3.2.7/proc/sysinfo.h
--- orig/procps-3.2.7/proc/sysinfo.h	2006-06-25 08:41:48.000000000 +0200
+++ procps-3.2.7/proc/sysinfo.h	2008-03-08 10:15:41.000000000 +0100
@@ -30,6 +30,11 @@
 extern unsigned long kb_swap_free;
 extern unsigned long kb_swap_total;
 /* recently introduced */
+extern unsigned long kb_anon_pages;
+extern unsigned long kb_bounce;
+extern unsigned long kb_nfs_unstable;
+extern unsigned long kb_slab_reclaimable;
+extern unsigned long kb_slab_unreclaimable;
 extern unsigned long kb_high_free;
 extern unsigned long kb_high_total;
 extern unsigned long kb_low_free;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
