Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 135FD8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 21:01:24 -0400 (EDT)
Subject: Re: [PATCH]mmap: add alignment for some variables
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20110329152434.d662706f.akpm@linux-foundation.org>
References: <1301277536.3981.27.camel@sli10-conroe>
	 <m2oc4v18x8.fsf@firstfloor.org>	<1301360054.3981.31.camel@sli10-conroe>
	 <20110329152434.d662706f.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 30 Mar 2011 09:01:22 +0800
Message-ID: <1301446882.3981.33.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Wed, 2011-03-30 at 06:24 +0800, Andrew Morton wrote:
> On Tue, 29 Mar 2011 08:54:14 +0800
> Shaohua Li <shaohua.li@intel.com> wrote:
> 
> > -struct percpu_counter vm_committed_as;
> > +struct percpu_counter vm_committed_as ____cacheline_internodealigned_in_smp;
> 
> Why ____cacheline_internodealigned_in_smp?  That's pretty aggressive.
> 
> afacit the main benefit from this will occur if the read-only
> vm_committed_as.counters lands in the same cacheline as some
> write-frequently storage.
vm_committed_as can be frequently updated in some workloads too.

> But that's a complete mad guess and I'd prefer not to have to guess.
is below updated patch better to you?

Make some variables have correct alignment/section to avoid cache issue.
In a workload which heavily does mmap/munmap, the variables will be used
frequently.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 mm/mmap.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

Index: linux/mm/mmap.c
===================================================================
--- linux.orig/mm/mmap.c	2011-03-30 08:45:05.000000000 +0800
+++ linux/mm/mmap.c	2011-03-30 08:59:23.000000000 +0800
@@ -84,10 +84,14 @@ pgprot_t vm_get_page_prot(unsigned long
 }
 EXPORT_SYMBOL(vm_get_page_prot);
 
-int sysctl_overcommit_memory = OVERCOMMIT_GUESS;  /* heuristic overcommit */
-int sysctl_overcommit_ratio = 50;	/* default is 50% */
+int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_GUESS;  /* heuristic overcommit */
+int sysctl_overcommit_ratio __read_mostly = 50;	/* default is 50% */
 int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
-struct percpu_counter vm_committed_as;
+/*
+ * Make sure vm_committed_as in one cacheline and not cacheline shared with
+ * other variables. It can be updated by several CPUs frequently.
+ */
+struct percpu_counter vm_committed_as ____cacheline_internodealigned_in_smp;
 
 /*
  * Check that a process has enough memory to allocate a new virtual



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
