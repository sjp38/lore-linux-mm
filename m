Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD4C6B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 10:03:54 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id d8so6695942pgt.1
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 07:03:54 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 68si7138284ple.516.2017.09.19.07.03.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Sep 2017 07:03:52 -0700 (PDT)
Date: Tue, 19 Sep 2017 17:03:46 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv7 08/19] x86/mm: Make PGDIR_SHIFT and PTRS_PER_P4D
 variable
Message-ID: <20170919140345.hienjh7hoegc4ffm@black.fi.intel.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
 <20170918105553.27914-9-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170918105553.27914-9-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 18, 2017 at 10:55:42AM +0000, Kirill A. Shutemov wrote:
> For boot-time switching between 4- and 5-level paging we need to be able
> to fold p4d page table level at runtime. It requires variable
> PGDIR_SHIFT and PTRS_PER_P4D.
> 
> The change doesn't affect the kernel image size much:
> 
>    text    data     bss     dec     hex filename
> 10710172        4879964  860160 16450296         fb02f8 vmlinux.before
> 10710340        4880000  860160 16450500         fb03c4 vmlinux.after
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Fixup for the patch:

diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index a1d983a45ab0..10dcbec70ef9 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -428,7 +428,7 @@ static void walk_p4d_level(struct seq_file *m, struct pg_state *st, pgd_t addr,
 }
 
 #define pgd_large(a) (pgtable_l5_enabled ? pgd_large(a) : p4d_large(__p4d(pgd_val(a))))
-#define pgd_none(a)  (pgtable_l5_enabled ? pgd_none(a) : pgd_none(a))
+#define pgd_none(a)  (pgtable_l5_enabled ? pgd_none(a) : p4d_none(__p4d(pgd_val(a))))
 
 static inline bool is_hypervisor_range(int idx)
 {
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
