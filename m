Subject: [PATCH] don't align initmem poisoning
From: Dave Hansen <haveblue@us.ibm.com>
Content-Type: multipart/mixed; boundary="=-yBhWk7MNapqSGxwQDfV6"
Message-Id: <1097174067.22025.37.camel@localhost>
Mime-Version: 1.0
Date: Thu, 07 Oct 2004 11:36:23 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--=-yBhWk7MNapqSGxwQDfV6
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

The recent initmem poison patch tries to page-align the address that it
memsets.  I think this is unnecessary because __init_begin is
page-aligned already in the linker script:

  /* will be freed after init */
  . = ALIGN(4096);              /* Init code and data */
  __init_begin = .;
  .init.text : {

-- Dave

--=-yBhWk7MNapqSGxwQDfV6
Content-Disposition: attachment; filename=A1-no-page-align-init-poison.patch
Content-Type: text/x-patch; name=A1-no-page-align-init-poison.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/arch/i386/mm/init.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN arch/i386/mm/init.c~A1-no-page-align-init-poison arch/i386/mm/init.c
--- memhotplug/arch/i386/mm/init.c~A1-no-page-align-init-poison	2004-10-07 11:28:46.000000000 -0700
+++ memhotplug-dave/arch/i386/mm/init.c	2004-10-07 11:30:05.000000000 -0700
@@ -723,7 +723,7 @@ void free_initmem(void)
 	for (; addr < (unsigned long)(&__init_end); addr += PAGE_SIZE) {
 		ClearPageReserved(virt_to_page(addr));
 		set_page_count(virt_to_page(addr), 1);
-		memset((void *)(addr & ~(PAGE_SIZE-1)), 0xcc, PAGE_SIZE);
+		memset((void *)addr, 0xcc, PAGE_SIZE);
 		free_page(addr);
 		totalram_pages++;
 	}
_

--=-yBhWk7MNapqSGxwQDfV6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
