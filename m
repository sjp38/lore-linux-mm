Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB916B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 14:47:13 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id q63so106607315pfb.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 11:47:13 -0800 (PST)
Received: from smtp687.redcondor.net (smtp687.redcondor.net. [208.80.206.87])
        by mx.google.com with ESMTPS id wu1si3793789pab.71.2016.01.26.11.47.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 11:47:12 -0800 (PST)
Subject: Re: [PATCH] mm: fix pfn_t to page conversion in vm_insert_mixed
References: <20160126183751.9072.22772.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Julian Margetson <runaway@candw.ms>
Message-ID: <56A7CD28.8060402@candw.ms>
Date: Tue, 26 Jan 2016 15:46:48 -0400
MIME-Version: 1.0
In-Reply-To: <20160126183751.9072.22772.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: multipart/alternative;
 boundary="------------030006020806020305080205"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, dri-devel@lists.freedesktop.org
Cc: Dave Hansen <dave@sr71.net>, David Airlie <airlied@linux.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tomi Valkeinen <tomi.valkeinen@ti.com>, akpm@linux-foundation.org

This is a multi-part message in MIME format.
--------------030006020806020305080205
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

On 1/26/2016 2:37 PM, Dan Williams wrote:
> pfn_t_to_page() honors the flags in the pfn_t value to determine if a
> pfn is backed by a page.  However, vm_insert_mixed() was originally
> written to use pfn_valid() to make this determination.  To restore the
> old/correct behavior, ignore the pfn_t flags in the !pfn_t_devmap() case
> and fallback to trusting pfn_valid().
>
> Fixes: 01c8f1c44b83 ("mm, dax, gpu: convert vm_insert_mixed to pfn_t")
> Cc: Dave Hansen <dave@sr71.net>
> Cc: David Airlie <airlied@linux.ie>
> Reported-by: Julian Margetson <runaway@candw.ms>
> Reported-by: Tomi Valkeinen <tomi.valkeinen@ti.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>   mm/memory.c |    9 +++++++--
>   1 file changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/mm/memory.c b/mm/memory.c
> index 30991f83d0bf..93ce37989471 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1591,10 +1591,15 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
>   	 * than insert_pfn).  If a zero_pfn were inserted into a VM_MIXEDMAP
>   	 * without pte special, it would there be refcounted as a normal page.
>   	 */
> -	if (!HAVE_PTE_SPECIAL && pfn_t_valid(pfn)) {
> +	if (!HAVE_PTE_SPECIAL && !pfn_t_devmap(pfn) && pfn_t_valid(pfn)) {
>   		struct page *page;
>   
> -		page = pfn_t_to_page(pfn);
> +		/*
> +		 * At this point we are committed to insert_page()
> +		 * regardless of whether the caller specified flags that
> +		 * result in pfn_t_has_page() == false.
> +		 */
> +		page = pfn_to_page(pfn_t_to_pfn(pfn));
>   		return insert_page(vma, addr, page, vma->vm_page_prot);
>   	}
>   	return insert_pfn(vma, addr, pfn, vma->vm_page_prot);
>
>
>
[   16.503323] systemd[1]: Mounting FUSE Control File System...
[   42.703092] Oops: Machine check, sig: 7 [#1]
[   42.707624] PREEMPT Canyonlands
[   42.710959] Modules linked in:
[   42.714201] CPU: 0 PID: 553 Comm: Xorg Not tainted 4.5.0-rc1-Sam460ex #1
[   42.721283] task: ee1e45c0 ti: ecd46000 task.ti: ecd46000
[   42.726983] NIP: 1fed2480 LR: 1fed2404 CTR: 1fed24d0
[   42.732227] REGS: ecd47f10 TRAP: 0214   Not tainted  (4.5.0-rc1-Sam460ex)
[   42.739395] MSR: 0002d000 <CE,EE,PR,ME>  CR: 28004262  XER: 00000000
[   42.746244]
GPR00: 1f396134 bfcb0970 b77fc6f0 b6fbeffc b67d5008 00000780 00000004 00000000
GPR08: 00000000 b6fbeffc 00000000 bfcb0920 1fed2404 2076dff4 00000000 00000780
GPR16: 00000000 00000020 00000000 00000000 00001e00 209be650 00000438 b67d5008
GPR24: 00000780 bfcb09c8 209a8728 b6fbf000 b6fbf000 b67d5008 1ffdaff4 00001e00
[   42.778096] NIP [1fed2480] 0x1fed2480
[   42.781967] LR [1fed2404] 0x1fed2404
[   42.785741] Call Trace:
[   42.943688] ---[ end trace 5d20a91d2d30d9d6 ]---
[   42.948311]
[   46.641774] Machine check in kernel mode.
[   46.645805] Data Write PLB Error
[   46.649031] Machine Check exception is imprecise
[   46.653658] Vector: 214  at [eccfbf10]
[   46.657408]     pc: 1ffa9480
[   46.660325]     lr: 1ffa9404
[   46.663241]     sp: bf9252b0
[   46.666123]    msr: 2d000
[   46.668746]   current = 0xee1e73c0
[   46.672149]     pid   = 663, comm = Xorg
[   46.676074] Linux version 4.5.0-rc1-Sam460ex (root@julian-VirtualBox) (gcc version 4.8.2 (Ubuntu 4.8.2-16ubuntu3) ) #1 PREEMPT Tue Jan 26 15:40:11 AST 2016
[   46.690001] enter ? for help
[   46.692886] mon>  <no input ...>
[   48.696175] Oops: Machine check, sig: 7 [#2]
[   48.700706] PREEMPT Canyonlands
[   48.704049] Modules linked in:
[   48.707292] CPU: 0 PID: 663 Comm: Xorg Tainted: G      D         4.5.0-rc1-Sam460ex #1
[   48.715657] task: ee1e73c0 ti: eccfa000 task.ti: eccfa000
[   48.721359] NIP: 1ffa9480 LR: 1ffa9404 CTR: 1ffa94d0
[   48.726602] REGS: eccfbf10 TRAP: 0214   Tainted: G      D          (4.5.0-rc1-Sam460ex)
[   48.735055] MSR: 0002d000 <CE,EE,PR,ME>  CR: 28004262  XER: 00000000
[   48.741913]
GPR00: 1f46d134 bf9252b0 b78b46f0 b7076ffc b688d008 00000780 00000004 00000000
GPR08: 00000000 b7076ffc 00000000 bf925260 1ffa9404 20844ff4 00000000 00000780
GPR16: 00000000 00000020 00000000 00000000 00001e00 20a7e638 00000438 b688d008
GPR24: 00000780 bf925308 20a68748 b7077000 b7077000 b688d008 200b1ff4 00001e00
[   48.773765] NIP [1ffa9480] 0x1ffa9480
[   48.777634] LR [1ffa9404] 0x1ffa9404
[   48.781409] Call Trace:
[   48.783993] ---[ end trace 5d20a91d2d30d9d7 ]---
[   48.788614]
[   51.289144] Machine check in kernel mode.
[   51.293175] Data Write PLB Error
[   51.296401] Machine Check exception is imprecise
[   51.301028] Vector: 214  at [ee225f10]
[   51.304778]     pc: 1fc2e480
[   51.307694]     lr: 1fc2e404
[   51.310612]     sp: bfbd0390
[   51.313493]    msr: 2f900
[   51.316115]   current = 0xecce2840
[   51.319519]     pid   = 680, comm = Xorg
[   51.323444] Linux version 4.5.0-rc1-Sam460ex (root@julian-VirtualBox) (gcc version 4.8.2 (Ubuntu 4.8.2-16ubuntu3) ) #1 PREEMPT Tue Jan 26 15:40:11 AST 2016
[   51.337370] enter ? for help
[   51.340256] mon>  <no input ...>
[   53.343544] Oops: Machine check, sig: 7 [#3]
[   53.348067] PREEMPT Canyonlands
[   53.351411] Modules linked in:
[   53.354653] CPU: 0 PID: 680 Comm: Xorg Tainted: G      D         4.5.0-rc1-Sam460ex #1
[   53.363019] task: ecce2840 ti: ee224000 task.ti: ee224000
[   53.368720] NIP: 1fc2e480 LR: 1fc2e404 CTR: 1fc2e4d0
[   53.373963] REGS: ee225f10 TRAP: 0214   Tainted: G      D          (4.5.0-rc1-Sam460ex)
[   53.382415] MSR: 0002f900 <CE,EE,PR,FP,ME>  CR: 28004262  XER: 00000000
[   53.389560]
GPR00: 1f0f2134 bfbd0390 b7fad6f0 b776fffc b6f86008 00000780 00000004 00000000
GPR08: 00000000 b776fffc 00000000 bfbd0340 1fc2e404 204c9ff4 00000000 00000780
GPR16: 00000000 00000020 00000000 00000000 00001e00 206f7650 00000438 b6f86008
GPR24: 00000780 bfbd03e8 206e1760 b7770000 b7770000 b6f86008 1fd36ff4 00001e00
[   53.421412] NIP [1fc2e480] 0x1fc2e480
[   53.425283] LR [1fc2e404] 0x1fc2e404
[   53.429057] Call Trace:
[   53.431641] ---[ end trace 5d20a91d2d30d9d8 ]---
[   53.436261]
[   56.443200] Machine check in kernel mode.
[   56.447237] Data Write PLB Error
[   56.450463] Machine Check exception is imprecise
[   56.455091] Vector: 214  at [ecc07f10]
[   56.458841]     pc: 1fa8a484
[   56.461757]     lr: 1fa8a404
[   56.464674]     sp: bffd7a20
[   56.467556]    msr: 2f900
[   56.470178]   current = 0xeced1140
[   56.473581]     pid   = 693, comm = Xorg
[   56.477506] Linux version 4.5.0-rc1-Sam460ex (root@julian-VirtualBox) (gcc version 4.8.2 (Ubuntu 4.8.2-16ubuntu3) ) #1 PREEMPT Tue Jan 26 15:40:11 AST 2016
[   56.491432] enter ? for help
[   56.494310] mon>  <no input ...>


--------------030006020806020305080205
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=utf-8" http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <div class="moz-cite-prefix">On 1/26/2016 2:37 PM, Dan Williams
      wrote:<br>
    </div>
    <blockquote
cite="mid:20160126183751.9072.22772.stgit@dwillia2-desk3.amr.corp.intel.com"
      type="cite">
      <pre wrap="">pfn_t_to_page() honors the flags in the pfn_t value to determine if a
pfn is backed by a page.  However, vm_insert_mixed() was originally
written to use pfn_valid() to make this determination.  To restore the
old/correct behavior, ignore the pfn_t flags in the !pfn_t_devmap() case
and fallback to trusting pfn_valid().

Fixes: 01c8f1c44b83 ("mm, dax, gpu: convert vm_insert_mixed to pfn_t")
Cc: Dave Hansen <a class="moz-txt-link-rfc2396E" href="mailto:dave@sr71.net">&lt;dave@sr71.net&gt;</a>
Cc: David Airlie <a class="moz-txt-link-rfc2396E" href="mailto:airlied@linux.ie">&lt;airlied@linux.ie&gt;</a>
Reported-by: Julian Margetson <a class="moz-txt-link-rfc2396E" href="mailto:runaway@candw.ms">&lt;runaway@candw.ms&gt;</a>
Reported-by: Tomi Valkeinen <a class="moz-txt-link-rfc2396E" href="mailto:tomi.valkeinen@ti.com">&lt;tomi.valkeinen@ti.com&gt;</a>
Signed-off-by: Dan Williams <a class="moz-txt-link-rfc2396E" href="mailto:dan.j.williams@intel.com">&lt;dan.j.williams@intel.com&gt;</a>
---
 mm/memory.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 30991f83d0bf..93ce37989471 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1591,10 +1591,15 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 	 * than insert_pfn).  If a zero_pfn were inserted into a VM_MIXEDMAP
 	 * without pte special, it would there be refcounted as a normal page.
 	 */
-	if (!HAVE_PTE_SPECIAL &amp;&amp; pfn_t_valid(pfn)) {
+	if (!HAVE_PTE_SPECIAL &amp;&amp; !pfn_t_devmap(pfn) &amp;&amp; pfn_t_valid(pfn)) {
 		struct page *page;
 
-		page = pfn_t_to_page(pfn);
+		/*
+		 * At this point we are committed to insert_page()
+		 * regardless of whether the caller specified flags that
+		 * result in pfn_t_has_page() == false.
+		 */
+		page = pfn_to_page(pfn_t_to_pfn(pfn));
 		return insert_page(vma, addr, page, vma-&gt;vm_page_prot);
 	}
 	return insert_pfn(vma, addr, pfn, vma-&gt;vm_page_prot);



</pre>
    </blockquote>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <pre class="western">
[   16.503323] systemd[1]: Mounting FUSE Control File System...
[   42.703092] Oops: Machine check, sig: 7 [#1]
[   42.707624] PREEMPT Canyonlands
[   42.710959] Modules linked in:
[   42.714201] CPU: 0 PID: 553 Comm: Xorg Not tainted 4.5.0-rc1-Sam460ex #1
[   42.721283] task: ee1e45c0 ti: ecd46000 task.ti: ecd46000
[   42.726983] NIP: 1fed2480 LR: 1fed2404 CTR: 1fed24d0
[   42.732227] REGS: ecd47f10 TRAP: 0214   Not tainted  (4.5.0-rc1-Sam460ex)
[   42.739395] MSR: 0002d000 &lt;CE,EE,PR,ME&gt;  CR: 28004262  XER: 00000000
[   42.746244] 
GPR00: 1f396134 bfcb0970 b77fc6f0 b6fbeffc b67d5008 00000780 00000004 00000000 
GPR08: 00000000 b6fbeffc 00000000 bfcb0920 1fed2404 2076dff4 00000000 00000780 
GPR16: 00000000 00000020 00000000 00000000 00001e00 209be650 00000438 b67d5008 
GPR24: 00000780 bfcb09c8 209a8728 b6fbf000 b6fbf000 b67d5008 1ffdaff4 00001e00 
[   42.778096] NIP [1fed2480] 0x1fed2480
[   42.781967] LR [1fed2404] 0x1fed2404
[   42.785741] Call Trace:
[   42.943688] ---[ end trace 5d20a91d2d30d9d6 ]---
[   42.948311] 
[   46.641774] Machine check in kernel mode.
[   46.645805] Data Write PLB Error
[   46.649031] Machine Check exception is imprecise
[   46.653658] Vector: 214  at [eccfbf10]
[   46.657408]     pc: 1ffa9480
[   46.660325]     lr: 1ffa9404
[   46.663241]     sp: bf9252b0
[   46.666123]    msr: 2d000
[   46.668746]   current = 0xee1e73c0
[   46.672149]     pid   = 663, comm = Xorg
[   46.676074] Linux version 4.5.0-rc1-Sam460ex (root@julian-VirtualBox) (gcc version 4.8.2 (Ubuntu 4.8.2-16ubuntu3) ) #1 PREEMPT Tue Jan 26 15:40:11 AST 2016
[   46.690001] enter ? for help
[   46.692886] mon&gt;  &lt;no input ...&gt;
[   48.696175] Oops: Machine check, sig: 7 [#2]
[   48.700706] PREEMPT Canyonlands
[   48.704049] Modules linked in:
[   48.707292] CPU: 0 PID: 663 Comm: Xorg Tainted: G      D         4.5.0-rc1-Sam460ex #1
[   48.715657] task: ee1e73c0 ti: eccfa000 task.ti: eccfa000
[   48.721359] NIP: 1ffa9480 LR: 1ffa9404 CTR: 1ffa94d0
[   48.726602] REGS: eccfbf10 TRAP: 0214   Tainted: G      D          (4.5.0-rc1-Sam460ex)
[   48.735055] MSR: 0002d000 &lt;CE,EE,PR,ME&gt;  CR: 28004262  XER: 00000000
[   48.741913] 
GPR00: 1f46d134 bf9252b0 b78b46f0 b7076ffc b688d008 00000780 00000004 00000000 
GPR08: 00000000 b7076ffc 00000000 bf925260 1ffa9404 20844ff4 00000000 00000780 
GPR16: 00000000 00000020 00000000 00000000 00001e00 20a7e638 00000438 b688d008 
GPR24: 00000780 bf925308 20a68748 b7077000 b7077000 b688d008 200b1ff4 00001e00 
[   48.773765] NIP [1ffa9480] 0x1ffa9480
[   48.777634] LR [1ffa9404] 0x1ffa9404
[   48.781409] Call Trace:
[   48.783993] ---[ end trace 5d20a91d2d30d9d7 ]---
[   48.788614] 
[   51.289144] Machine check in kernel mode.
[   51.293175] Data Write PLB Error
[   51.296401] Machine Check exception is imprecise
[   51.301028] Vector: 214  at [ee225f10]
[   51.304778]     pc: 1fc2e480
[   51.307694]     lr: 1fc2e404
[   51.310612]     sp: bfbd0390
[   51.313493]    msr: 2f900
[   51.316115]   current = 0xecce2840
[   51.319519]     pid   = 680, comm = Xorg
[   51.323444] Linux version 4.5.0-rc1-Sam460ex (root@julian-VirtualBox) (gcc version 4.8.2 (Ubuntu 4.8.2-16ubuntu3) ) #1 PREEMPT Tue Jan 26 15:40:11 AST 2016
[   51.337370] enter ? for help
[   51.340256] mon&gt;  &lt;no input ...&gt;
[   53.343544] Oops: Machine check, sig: 7 [#3]
[   53.348067] PREEMPT Canyonlands
[   53.351411] Modules linked in:
[   53.354653] CPU: 0 PID: 680 Comm: Xorg Tainted: G      D         4.5.0-rc1-Sam460ex #1
[   53.363019] task: ecce2840 ti: ee224000 task.ti: ee224000
[   53.368720] NIP: 1fc2e480 LR: 1fc2e404 CTR: 1fc2e4d0
[   53.373963] REGS: ee225f10 TRAP: 0214   Tainted: G      D          (4.5.0-rc1-Sam460ex)
[   53.382415] MSR: 0002f900 &lt;CE,EE,PR,FP,ME&gt;  CR: 28004262  XER: 00000000
[   53.389560] 
GPR00: 1f0f2134 bfbd0390 b7fad6f0 b776fffc b6f86008 00000780 00000004 00000000 
GPR08: 00000000 b776fffc 00000000 bfbd0340 1fc2e404 204c9ff4 00000000 00000780 
GPR16: 00000000 00000020 00000000 00000000 00001e00 206f7650 00000438 b6f86008 
GPR24: 00000780 bfbd03e8 206e1760 b7770000 b7770000 b6f86008 1fd36ff4 00001e00 
[   53.421412] NIP [1fc2e480] 0x1fc2e480
[   53.425283] LR [1fc2e404] 0x1fc2e404
[   53.429057] Call Trace:
[   53.431641] ---[ end trace 5d20a91d2d30d9d8 ]---
[   53.436261] 
[   56.443200] Machine check in kernel mode.
[   56.447237] Data Write PLB Error
[   56.450463] Machine Check exception is imprecise
[   56.455091] Vector: 214  at [ecc07f10]
[   56.458841]     pc: 1fa8a484
[   56.461757]     lr: 1fa8a404
[   56.464674]     sp: bffd7a20
[   56.467556]    msr: 2f900
[   56.470178]   current = 0xeced1140
[   56.473581]     pid   = 693, comm = Xorg
[   56.477506] Linux version 4.5.0-rc1-Sam460ex (root@julian-VirtualBox) (gcc version 4.8.2 (Ubuntu 4.8.2-16ubuntu3) ) #1 PREEMPT Tue Jan 26 15:40:11 AST 2016
[   56.491432] enter ? for help
[   56.494310] mon&gt;  &lt;no input ...&gt;</pre>
    <title></title>
    <meta name="generator" content="LibreOffice 4.4.5.2 (Windows)">
    <style type="text/css">
		@page { margin: 0.79in }
		pre.cjk { font-family: "NSimSun", monospace }
		p { margin-bottom: 0.1in; line-height: 120% }
	</style>
  </body>
</html>

--------------030006020806020305080205--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
