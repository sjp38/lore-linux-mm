Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id D93496B0069
	for <linux-mm@kvack.org>; Mon, 13 Oct 2014 14:52:09 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id fb4so8232238wid.16
        for <linux-mm@kvack.org>; Mon, 13 Oct 2014 11:52:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u10si13596194wiz.73.2014.10.13.11.52.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Oct 2014 11:52:08 -0700 (PDT)
Date: Mon, 13 Oct 2014 14:51:56 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] mm, debug: mm-introduce-vm_bug_on_mm-fix-fix.patch
Message-ID: <20141013185156.GA1959@redhat.com>
References: <5420b8b0.9HdYLyyuTikszzH8%akpm@linux-foundation.org>
 <1411464279-20158-1-git-send-email-mhocko@suse.cz>
 <20140923112848.GA10046@dhcp22.suse.cz>
 <20140923201204.GB4252@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140923201204.GB4252@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>

On Tue, Sep 23, 2014 at 04:12:04PM -0400, Dave Jones wrote:
 > On Tue, Sep 23, 2014 at 01:28:48PM +0200, Michal Hocko wrote:
 >  > And there is another one hitting during randconfig. The patch makes my
 >  > eyes bleed but I don't know about other way without breaking out the
 >  > thing into separate parts sounds worse because we can mix with other
 >  > messages then.
 > 
 > how about something along the lines of..
 > 
 >  bufptr = buffer = kmalloc()
 > 
 >  #if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
 > 	bufptr += sprintf(bufptr, "tlb_flush_pending %d\n",
 > 			mm->tlb_flush_pending);
 >  #endif
 > 
 >  #ifdef CONFIG_MMU
 > 	bufptr += sprintf(bufptr, "...
 >  #endif
 > 
 >  ...
 > 
 >  printk(KERN_EMERG "%s", buffer);
 > 
 >  free(buffer);
 > 
 > Still ugly, but looks less like a trainwreck, and keeps the variables
 > with the associated text.
 > 
 > It does introduce an allocation though, which may be problematic
 > in this situation. Depending how big this gets, perhaps make it static
 > instead?

Now that this landed in Linus tree, I took another stab at it.
Something like this ? (Untested beyond compiling).

(The diff doesn't really do it justice, it looks a lot easier to read
 imo after applying).

There's still some checkpatch style nits, but this should be a lot
more maintainable assuming it works.

My one open question is do we care that this isn't reentrant ?
Do we expect parallel calls to dump_mm from multiple cpus ever ?

	Dave

diff --git a/mm/debug.c b/mm/debug.c
index 5ce45c9a29b5..e04e2ae902a1 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -164,74 +164,85 @@ void dump_vma(const struct vm_area_struct *vma)
 }
 EXPORT_SYMBOL(dump_vma);
 
+static char dumpmm_buffer[4096];
+
 void dump_mm(const struct mm_struct *mm)
 {
-	pr_emerg("mm %p mmap %p seqnum %d task_size %lu\n"
-#ifdef CONFIG_MMU
-		"get_unmapped_area %p\n"
-#endif
-		"mmap_base %lu mmap_legacy_base %lu highest_vm_end %lu\n"
-		"pgd %p mm_users %d mm_count %d nr_ptes %lu map_count %d\n"
-		"hiwater_rss %lx hiwater_vm %lx total_vm %lx locked_vm %lx\n"
-		"pinned_vm %lx shared_vm %lx exec_vm %lx stack_vm %lx\n"
-		"start_code %lx end_code %lx start_data %lx end_data %lx\n"
-		"start_brk %lx brk %lx start_stack %lx\n"
-		"arg_start %lx arg_end %lx env_start %lx env_end %lx\n"
-		"binfmt %p flags %lx core_state %p\n"
-#ifdef CONFIG_AIO
-		"ioctx_table %p\n"
-#endif
-#ifdef CONFIG_MEMCG
-		"owner %p "
-#endif
-		"exe_file %p\n"
-#ifdef CONFIG_MMU_NOTIFIER
-		"mmu_notifier_mm %p\n"
-#endif
-#ifdef CONFIG_NUMA_BALANCING
-		"numa_next_scan %lu numa_scan_offset %lu numa_scan_seq %d\n"
-#endif
-#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
-		"tlb_flush_pending %d\n"
-#endif
-		"%s",	/* This is here to hold the comma */
+	char *p = dumpmm_buffer;
+
+	memset(dumpmm_buffer, 0, 4096);
+
+	p += sprintf(p, "mm %p mmap %p seqnum %d task_size %lu\n",
+		mm, mm->mmap, mm->vmacache_seqnum, mm->task_size);
 
-		mm, mm->mmap, mm->vmacache_seqnum, mm->task_size,
 #ifdef CONFIG_MMU
-		mm->get_unmapped_area,
+	p += sprintf(p, "get_unmapped_area %p\n",
+		mm->get_unmapped_area);
 #endif
-		mm->mmap_base, mm->mmap_legacy_base, mm->highest_vm_end,
+	p += sprintf(p,
+		"mmap_base %lu mmap_legacy_base %lu highest_vm_end %lu\n",
+		mm->mmap_base, mm->mmap_legacy_base, mm->highest_vm_end);
+
+	p += sprintf(p,
+		"pgd %p mm_users %d mm_count %d nr_ptes %lu map_count %d\n",
 		mm->pgd, atomic_read(&mm->mm_users),
 		atomic_read(&mm->mm_count),
 		atomic_long_read((atomic_long_t *)&mm->nr_ptes),
-		mm->map_count,
-		mm->hiwater_rss, mm->hiwater_vm, mm->total_vm, mm->locked_vm,
-		mm->pinned_vm, mm->shared_vm, mm->exec_vm, mm->stack_vm,
-		mm->start_code, mm->end_code, mm->start_data, mm->end_data,
-		mm->start_brk, mm->brk, mm->start_stack,
-		mm->arg_start, mm->arg_end, mm->env_start, mm->env_end,
-		mm->binfmt, mm->flags, mm->core_state,
+		mm->map_count);
+
+	p += sprintf(p,
+		"hiwater_rss %lx hiwater_vm %lx total_vm %lx locked_vm %lx\n",
+		mm->hiwater_rss, mm->hiwater_vm, mm->total_vm, mm->locked_vm);
+
+	p += sprintf(p,
+		"pinned_vm %lx shared_vm %lx exec_vm %lx stack_vm %lx\n",
+		mm->pinned_vm, mm->shared_vm, mm->exec_vm, mm->stack_vm);
+
+	p += sprintf(p,
+		"start_code %lx end_code %lx start_data %lx end_data %lx\n",
+		mm->start_code, mm->end_code, mm->start_data, mm->end_data);
+
+	p += sprintf(p,
+		"start_brk %lx brk %lx start_stack %lx\n",
+		mm->start_brk, mm->brk, mm->start_stack);
+
+	p += sprintf(p,
+		"arg_start %lx arg_end %lx env_start %lx env_end %lx\n",
+		mm->arg_start, mm->arg_end, mm->env_start, mm->env_end);
+
+	p += sprintf(p,
+		"binfmt %p flags %lx core_state %p\n",
+		mm->binfmt, mm->flags, mm->core_state);
+
 #ifdef CONFIG_AIO
-		mm->ioctx_table,
+	p += sprintf(p, "ioctx_table %p\n", mm->ioctx_table);
 #endif
+
 #ifdef CONFIG_MEMCG
-		mm->owner,
+	p += sprintf(p, "owner %p ", mm->owner);
 #endif
-		mm->exe_file,
+
+	p += sprintf(p, "exe_file %p\n", mm->exe_file);
+
 #ifdef CONFIG_MMU_NOTIFIER
-		mm->mmu_notifier_mm,
+	p += sprintf(p,	"mmu_notifier_mm %p\n", mm->mmu_notifier_mm);
 #endif
+
 #ifdef CONFIG_NUMA_BALANCING
-		mm->numa_next_scan, mm->numa_scan_offset, mm->numa_scan_seq,
+	p += sprintf(p,
+		"numa_next_scan %lu numa_scan_offset %lu numa_scan_seq %d\n",
+		mm->numa_next_scan, mm->numa_scan_offset, mm->numa_scan_seq);
 #endif
+
 #if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
-		mm->tlb_flush_pending,
+	p += sprintf(p, "tlb_flush_pending %d\n",
+		mm->tlb_flush_pending);
 #endif
-		""		/* This is here to not have a comma! */
-		);
 
-		dump_flags(mm->def_flags, vmaflags_names,
-				ARRAY_SIZE(vmaflags_names));
+	pr_emerg("%s", dumpmm_buffer);
+
+	dump_flags(mm->def_flags, vmaflags_names,
+			ARRAY_SIZE(vmaflags_names));
 }
 
 #endif		/* CONFIG_DEBUG_VM */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
