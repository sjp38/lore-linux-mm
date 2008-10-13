From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: GIT head no longer boots on x86-64
Date: Mon, 13 Oct 2008 17:11:33 +0200
Message-Id: <1223910693-28693-1-git-send-email-jirislaby@gmail.com>
In-Reply-To: <alpine.LFD.2.00.0810130752020.3288@nehalem.linux-foundation.org>
References: <alpine.LFD.2.00.0810130752020.3288@nehalem.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jiri Slaby <jirislaby@gmail.com>
List-ID: <linux-mm.kvack.org>

On 10/13/2008 05:03 PM, Linus Torvalds wrote:
> 
> On Mon, 13 Oct 2008, Alan Cox wrote:
> 
>> On Mon, 13 Oct 2008 12:56:54 +0200
>> Jiri Slaby <jirislaby@gmail.com> wrote:
>>
>>> Could you try the debug patch below to see what address is text_poke trying
>>> to translate?
>> BUG? vmalloc_to_page (from text_poke+0x30/0x14a): ffffffffa01e40b1
> 
> Hmm. Last page of code being fixed up, perhaps?
> 
> Does this fix it?

I don't think so. The patch below should.

More background:
I guess SMP kernel running on UP? In such a case the module .text
is patched to use UP locks before the module is added to the modules
list and it thinks there are no valid data at that place while
patching.

Could you test it? The bug disappeared here in qemu. I've checked
callers of the function, and it should not matter for them.

Also the !is_module_address(addr) test is useless now.

---
 include/linux/mm.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c61ba10..45772fd 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -267,6 +267,10 @@ static inline int is_vmalloc_addr(const void *x)
 #ifdef CONFIG_MMU
 	unsigned long addr = (unsigned long)x;
 
+#ifdef CONFIG_X86_64
+	if (addr >= MODULES_VADDR && addr < MODULES_END)
+		return 1;
+#endif
 	return addr >= VMALLOC_START && addr < VMALLOC_END;
 #else
 	return 0;
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
