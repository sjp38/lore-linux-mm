Date: Fri, 2 May 2003 06:18:57 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.68-mm4
Message-ID: <20030502131857.GH8978@holomorphy.com>
References: <20030502020149.1ec3e54f.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030502020149.1ec3e54f.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 02, 2003 at 02:01:49AM -0700, Andrew Morton wrote:
> +dont-set-kernel-pgd-on-PAE.patch
>  little ia32 optimisation/cleanup

It looks like no one listened to my commentary on the set_pgd() patch.

Remove pointless #ifdef, pointless set_pgd(), and a mysterious line
full of nothing but whitespace after the #endif, and update commentary.

-- wli

$ diffstat ../patches/mm4-2.5.68-2
 fault.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff -urpN mm4-2.5.68-1/arch/i386/mm/fault.c mm4-2.5.68-2/arch/i386/mm/fault.c
--- mm4-2.5.68-1/arch/i386/mm/fault.c	2003-05-02 05:32:27.000000000 -0700
+++ mm4-2.5.68-2/arch/i386/mm/fault.c	2003-05-02 05:54:14.000000000 -0700
@@ -333,16 +333,12 @@ vmalloc_fault:
 
 		if (!pgd_present(*pgd_k))
 			goto no_context;
+
 		/*
-		 * kernel pmd pages are shared among all processes
-		 * with PAE on.  Since vmalloc pages are always
-		 * in the kernel area, this will always be a 
-		 * waste with PAE on.
+		 * set_pgd(pgd, *pgd_k); here would be useless on PAE
+		 * and redundant with the set_pmd() on non-PAE.
 		 */
-#ifndef CONFIG_X86_PAE
-		set_pgd(pgd, *pgd_k);
-#endif
-		
+
 		pmd = pmd_offset(pgd, address);
 		pmd_k = pmd_offset(pgd_k, address);
 		if (!pmd_present(*pmd_k))
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
