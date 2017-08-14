Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE6F06B0292
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 10:30:14 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 83so137318216pgb.14
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 07:30:14 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id n7si4235619pfh.660.2017.08.14.07.30.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 07:30:13 -0700 (PDT)
Date: Mon, 14 Aug 2017 17:29:08 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv4 01/14] mm/sparsemem: Allocate mem_section at runtime
 for SPARSEMEM_EXTREME
Message-ID: <20170814142907.kkch4ar5jdoeg2cd@black.fi.intel.com>
References: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
 <20170808125415.78842-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808125415.78842-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 08, 2017 at 12:54:02PM +0000, Kirill A. Shutemov wrote:
> Size of mem_section array depends on size of physical address space.
> 
> In preparation for boot-time switching between paging modes on x86-64
> we need to make allocation of mem_section dynamic.
> 
> The patch allocates the array on the first call to
> sparse_memory_present_with_active_regions().
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Fixup for the patch:

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c8eb668eab79..9799c2c58ce6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1144,6 +1144,10 @@ extern struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROOT];
 
 static inline struct mem_section *__nr_to_section(unsigned long nr)
 {
+#ifdef CONFIG_SPARSEMEM_EXTREME
+        if (!mem_section)
+                return NULL;
+#endif
 	if (!mem_section[SECTION_NR_TO_ROOT(nr)])
 		return NULL;
 	return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
