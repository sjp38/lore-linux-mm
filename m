From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <20020219161412.B16613@flint.arm.linux.org.uk> 
References: <20020219161412.B16613@flint.arm.linux.org.uk>  <22292.1014134494@redhat.com> 
Subject: Re: rmap for ARMV. 
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Tue, 19 Feb 2002 16:42:11 +0000
Message-ID: <7261.1014136931@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: riel@conectiva.com.br, linux-mm@kvack.org, linux-arm-kernel@lists.arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

linux@arm.linux.org.uk said:
>  When rmap gets merged into the 2.5 kernel series, I'll look at what
> can be done to sort out the pte situation - we could re-jig the page
> tables so a 'pgd' is 8 bytes per entry (made up of two hardware PTE
> pointers), the second level page tables end up being 2K hardware + 2K
> for Linux, which nicely maps to a page per PTE as viewed by Linux.

That would probably make sense - I didn't really want to do something that 
intrusive myself. In the meantime, this is also required:

--- linux-2.4.17-arm-rmap.patch	19 Feb 2002 15:59:41 -0000	1.1
+++ linux-2.4.17-arm-rmap.patch	19 Feb 2002 16:24:11 -0000
@@ -39,7 +39,7 @@
  	if (block & 2047)
  		BUG();
  
-@@ -475,11 +495,31 @@
+@@ -475,11 +495,32 @@
  			PTRS_PER_PTE * sizeof(pte_t), 0);
  }
  
@@ -54,6 +54,7 @@
 +		struct page * page = virt_to_page(pte);
 +
 +		kmem_cache_free(pte_rmap_cache, page->mapping);
++		page->mapping = NULL;
 +	}
 +}
 +


--
dwmw2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
