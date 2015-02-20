Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 81CC66B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 16:45:43 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so10362632pdb.11
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 13:45:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id tc8si12140402pab.183.2015.02.20.13.45.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 13:45:42 -0800 (PST)
Date: Fri, 20 Feb 2015 13:45:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: hide per-cpu lists in output of show_mem()
Message-Id: <20150220134541.772f0c302a50f115b280917f@linux-foundation.org>
In-Reply-To: <20150220143942.19568.4548.stgit@buzz>
References: <20150220143942.19568.4548.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 20 Feb 2015 17:39:42 +0300 Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:

> This makes show_mem() much less verbose at huge machines. Instead of
> huge and almost useless dump of counters for each per-zone per-cpu
> lists this patch prints sum of these counters for each zone (free_pcp)
> and size of per-cpu list for current cpu (local_pcp).
> 
> Flag SHOW_MEM_PERCPU_LISTS reverts old verbose mode.

Forgot to update the comment:

--- a/mm/page_alloc.c~mm-hide-per-cpu-lists-in-output-of-show_mem-fix
+++ a/mm/page_alloc.c
@@ -3243,8 +3243,11 @@ static void show_migration_types(unsigne
  * Show free area list (used inside shift_scroll-lock stuff)
  * We also calculate the percentage fragmentation. We do this by counting the
  * memory on each free list with the exception of the first item on the list.
- * Suppresses nodes that are not allowed by current's cpuset if
- * SHOW_MEM_FILTER_NODES is passed.
+ *
+ * Bits in @filter:
+ * SHOW_MEM_FILTER_NODES: suppress nodes that are not allowed by current's
+ *   cpuset.
+ * SHOW_MEM_PERCPU_LISTS: display full per-node per-cpu pcp lists
  */
 void show_free_areas(unsigned int filter)
 {


Is there really any point in having SHOW_MEM_PERCPU_LISTS?  There isn't
presently a way of setting it(?).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
