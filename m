Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 01B996B003A
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 16:53:00 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id y13so7214265pdi.29
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 13:53:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ml7si22734518pdb.210.2014.09.23.13.52.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Sep 2014 13:52:59 -0700 (PDT)
Date: Tue, 23 Sep 2014 13:52:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, debug: mm-introduce-vm_bug_on_mm-fix-fix.patch
Message-Id: <20140923135258.faf628403a58701da5a981df@linux-foundation.org>
In-Reply-To: <83907.1411489189@turing-police.cc.vt.edu>
References: <5420b8b0.9HdYLyyuTikszzH8%akpm@linux-foundation.org>
	<1411464279-20158-1-git-send-email-mhocko@suse.cz>
	<20140923112848.GA10046@dhcp22.suse.cz>
	<83907.1411489189@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Michal Hocko <mhocko@suse.cz>, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, Sasha Levin <sasha.levin@oracle.com>

On Tue, 23 Sep 2014 12:19:49 -0400 Valdis.Kletnieks@vt.edu wrote:

> On Tue, 23 Sep 2014 13:28:48 +0200, Michal Hocko said:
> > And there is another one hitting during randconfig. The patch makes my
> > eyes bleed
> 
> Amen.  But I'm not seeing a better fix either.
> 
> >  #if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
> > -		"tlb_flush_pending %d\n",
> > +		"tlb_flush_pending %d\n"
> >  #endif
> > -		mm, mm->mmap, mm->vmacache_seqnum, mm->task_size,
> > +		, mm, mm->mmap, mm->vmacache_seqnum, mm->task_size,
> 
> I'm surprised that checkpatch doesn't explode on this.  And I'm starting
> a pool on how soon somebody submits a patch to "fix" this. :)

It is all pretty godawful.  We can eliminate the tricks with the comma
separators by adding an always-there, does-nothing argument:


--- a/mm/debug.c~mm-debug-mm-introduce-vm_bug_on_mm-fix-fixpatch-fix
+++ a/mm/debug.c
@@ -197,7 +197,9 @@ void dump_mm(const struct mm_struct *mm)
 #if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
 		"tlb_flush_pending %d\n"
 #endif
-		, mm, mm->mmap, mm->vmacache_seqnum, mm->task_size,
+		"%s",	/* This is here to hold the comma */
+
+		mm, mm->mmap, mm->vmacache_seqnum, mm->task_size,
 #ifdef CONFIG_MMU
 		mm->get_unmapped_area,
 #endif
@@ -218,16 +220,17 @@ void dump_mm(const struct mm_struct *mm)
 #ifdef CONFIG_MEMCG
 		mm->owner,
 #endif
-		mm->exe_file
+		mm->exe_file,
 #ifdef CONFIG_MMU_NOTIFIER
-		, mm->mmu_notifier_mm
+		mm->mmu_notifier_mm,
 #endif
 #ifdef CONFIG_NUMA_BALANCING
-		, mm->numa_next_scan, mm->numa_scan_offset, mm->numa_scan_seq
+		mm->numa_next_scan, mm->numa_scan_offset, mm->numa_scan_seq,
 #endif
 #if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
-		, mm->tlb_flush_pending
+		mm->tlb_flush_pending,
 #endif
+		""		/* This is here to not have a comma! */
 		);
 
 		dump_flags(mm->def_flags, vmaflags_names,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
