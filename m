Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 763F06B0089
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 20:22:08 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so629395pad.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 17:22:07 -0800 (PST)
Date: Tue, 20 Nov 2012 17:22:05 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] x86/mm: Don't flush the TLB on #WP pmd fixups
In-Reply-To: <20121120120251.GA15742@gmail.com>
Message-ID: <alpine.DEB.2.00.1211201720520.6232@chino.kir.corp.google.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org> <20121119162909.GL8218@suse.de> <alpine.DEB.2.00.1211191644340.24618@chino.kir.corp.google.com> <alpine.DEB.2.00.1211191703270.24618@chino.kir.corp.google.com> <20121120060014.GA14065@gmail.com>
 <alpine.DEB.2.00.1211192213420.5498@chino.kir.corp.google.com> <20121120074445.GA14539@gmail.com> <alpine.DEB.2.00.1211200001420.16449@chino.kir.corp.google.com> <20121120090637.GA14873@gmail.com> <20121120120251.GA15742@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Tue, 20 Nov 2012, Ingo Molnar wrote:

> Subject: x86/mm: Don't flush the TLB on #WP pmd fixups
> From: Ingo Molnar <mingo@kernel.org>
> Date: Tue Nov 20 14:46:34 CET 2012
> 
> If we have a write protection #PF and fix up the pmd then the
> hugetlb code [the only user of pmdp_set_access_flags], in its
> do_huge_pmd_wp_page() page fault resolution function calls
> pmdp_set_access_flags() to mark the pmd permissive again,
> and flushes the TLB.
> 
> This TLB flush is unnecessary: a flush on #PF is guaranteed on
> most (all?) x86 CPUs, and even in the worst-case we'll generate
> a spurious fault.
> 
> So remove it.
> 

This patch did not cause the 2% speedup that you reported with THP 
enabled for me:

   numa/core at ec05a2311c35:           136918.34 SPECjbb2005 bops
   numa/core at 01aa90068b12:           128315.19 SPECjbb2005 bops (-6.3%)
   numa/core at 01aa90068b12 + patch:   128184.77 SPECjbb2005 bops (-6.4%)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
