Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 484616B005D
	for <linux-mm@kvack.org>; Sat,  5 Jan 2013 21:59:54 -0500 (EST)
Received: by mail-ie0-f176.google.com with SMTP id 13so21426037iea.35
        for <linux-mm@kvack.org>; Sat, 05 Jan 2013 18:59:53 -0800 (PST)
Message-ID: <1357441197.9001.6.camel@kernel.cn.ibm.com>
Subject: Re: [PATCH 0/2] pageattr fixes for pmd/pte_present
From: Simon Jeons <simon.jeons@gmail.com>
Date: Sat, 05 Jan 2013 20:59:57 -0600
In-Reply-To: <1355767224-13298-1-git-send-email-aarcange@redhat.com>
References: <1355767224-13298-1-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, "H. Peter
 Anvin" <hpa@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>


What's the status of these two patches?

On Mon, 2012-12-17 at 19:00 +0100, Andrea Arcangeli wrote:
> Hi,
> 
> I got a report for a minor regression introduced by commit
> 027ef6c87853b0a9df53175063028edb4950d476.
> 
> So the problem is, pageattr creates kernel pagetables (pte and pmds)
> that breaks pte_present/pmd_present and the patch above exposed this
> invariant breakage for pmd_present.
> 
> The same problem already existed for the pte and pte_present and it
> was fixed by commit 660a293ea9be709b893d371fbc0328fcca33c33a (if it
> wasn't for that commit, it wouldn't even be a regression). That fix
> avoids the pagefault to use pte_present. I could follow through by
> stopping using pmd_present/pmd_huge too.
> 
> However I think it's more robust to fix pageattr and to clear the
> PSE/GLOBAL bitflags too in addition to the present bitflag. So the
> kernel page fault can keep using the regular
> pte_present/pmd_present/pmd_huge.
> 
> The confusion arises because _PAGE_GLOBAL and _PAGE_PROTNONE are
> sharing the same bit, and in the pmd case we pretend _PAGE_PSE to be
> set only in present pmds (to facilitate split_huge_page final tlb
> flush).
> 
> Andrea Arcangeli (2):
>   Revert "x86, mm: Make spurious_fault check explicitly check the
>     PRESENT bit"
>   pageattr: prevent PSE and GLOABL leftovers to confuse pmd/pte_present
>     and pmd_huge
> 
>  arch/x86/mm/fault.c    |    8 +------
>  arch/x86/mm/pageattr.c |   50 +++++++++++++++++++++++++++++++++++++++++++++--
>  2 files changed, 48 insertions(+), 10 deletions(-)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
