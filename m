Date: Wed, 15 Oct 2008 08:35:12 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: GIT head no longer boots on x86-64
In-Reply-To: <alpine.LFD.2.00.0810150758310.3288@nehalem.linux-foundation.org>
Message-ID: <alpine.LFD.2.00.0810150815000.3288@nehalem.linux-foundation.org>
References: <alpine.LFD.2.00.0810130752020.3288@nehalem.linux-foundation.org> <1223910693-28693-1-git-send-email-jirislaby@gmail.com> <20081013164717.7a21084a@lxorguk.ukuu.org.uk> <20081015115153.GA16413@elte.hu>
 <alpine.LFD.2.00.0810150758310.3288@nehalem.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Jiri Slaby <jirislaby@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>


On Wed, 15 Oct 2008, Linus Torvalds wrote:
> 
> The code in question already does
> 
> 	VIRTUAL_BUG_ON(!is_vmalloc_addr(vmalloc_addr) &&
>                        !is_module_address(addr));
> 
> and look at that thing and ask yourself: where was the bug again.

Btw, I don't even know if this is a sparc64 issue too, but it sounds 
possible. Sparc64 seems similar to x86-64 in that there is a special range 
for module addresses.

I'm too lazy to check everybody's "module_alloc()", and maybe others do 
too, but use a different symbol, so grepping for it doesn't trigger.

But regardless, a much more correct fix appears to just screw this, and 
make it explicit on the symbol. And only do it if modules are even 
supported.

And if you *really* want to change "is_vmalloc_addr()", then

 (a) do it right, not some crappy x86-64-specific sh*t
 (b) do it like I do it, and make it dependent on modules even being 
     enabled
 (c) and rename it to match what it does.

not the horrible patch I've seen.

Oh, btw. This patch is *totally* untested. I don't even enable modules. So 
if it doesn't compile, it isn't perfect. But while it may not _work_, at 
least it's not _ugly_.

(Quite frankly, I think an even more correct fix is to rename the whole 
"vmalloc_to_page()" function, since it's clearly used for other things 
than vmalloc. Maybe "kernel_virtual_to_page()". Whatever. This is trying 
to be minimal without being totally disgusting).

			Linus

---
 mm/vmalloc.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index bba06c4..f018d7e 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -168,6 +168,21 @@ int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
 }
 EXPORT_SYMBOL_GPL(map_vm_area);
 
+static inline int is_vmalloc_or_module_addr(const void *x)
+{
+	/*
+	 * x86-64 and sparc64 put modules in a special place,
+	 * and fall back on vmalloc() if that fails. Others
+	 * just put it in the vmalloc space.
+	 */
+#if defined(CONFIG_MODULES) && defined(MODULES_VADDR)
+	unsigned long addr = (unsigned long)x;
+	if (addr >= MODULES_VADDR && addr < MODULES_END)
+		return 1;
+#endif
+	return is_vmalloc_addr(x);
+}
+
 /*
  * Map a vmalloc()-space virtual address to the physical page.
  */
@@ -184,8 +199,7 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
 	 * XXX we might need to change this if we add VIRTUAL_BUG_ON for
 	 * architectures that do not vmalloc module space
 	 */
-	VIRTUAL_BUG_ON(!is_vmalloc_addr(vmalloc_addr) &&
-			!is_module_address(addr));
+	VIRTUAL_BUG_ON(!is_vmalloc_or_module_addr(vmalloc_addr));
 
 	if (!pgd_none(*pgd)) {
 		pud = pud_offset(pgd, addr);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
