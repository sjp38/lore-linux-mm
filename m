Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5FCFA6B0009
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 15:34:29 -0500 (EST)
Received: by mail-yk0-f169.google.com with SMTP id a85so215023995ykb.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 12:34:29 -0800 (PST)
Received: from mail-yk0-x22c.google.com (mail-yk0-x22c.google.com. [2607:f8b0:4002:c07::22c])
        by mx.google.com with ESMTPS id t9si1061187ywe.237.2016.01.26.12.34.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 12:34:28 -0800 (PST)
Received: by mail-yk0-x22c.google.com with SMTP id u68so86428660ykd.2
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 12:34:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56A7CD28.8060402@candw.ms>
References: <20160126183751.9072.22772.stgit@dwillia2-desk3.amr.corp.intel.com>
	<56A7CD28.8060402@candw.ms>
Date: Tue, 26 Jan 2016 12:34:28 -0800
Message-ID: <CAPcyv4hGFT65MQc8a49hiMyWahsWMv=ynC3vEaQKhAaL1-Oy+w@mail.gmail.com>
Subject: Re: [PATCH] mm: fix pfn_t to page conversion in vm_insert_mixed
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julian Margetson <runaway@candw.ms>
Cc: Maling list - DRI developers <dri-devel@lists.freedesktop.org>, Dave Hansen <dave@sr71.net>, David Airlie <airlied@linux.ie>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Tomi Valkeinen <tomi.valkeinen@ti.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jan 26, 2016 at 11:46 AM, Julian Margetson <runaway@candw.ms> wrote:
> On 1/26/2016 2:37 PM, Dan Williams wrote:
>
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
>  mm/memory.c |    9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/mm/memory.c b/mm/memory.c
> index 30991f83d0bf..93ce37989471 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1591,10 +1591,15 @@ int vm_insert_mixed(struct vm_area_struct *vma,
> unsigned long addr,
>   * than insert_pfn).  If a zero_pfn were inserted into a VM_MIXEDMAP
>   * without pte special, it would there be refcounted as a normal page.
>   */
> - if (!HAVE_PTE_SPECIAL && pfn_t_valid(pfn)) {
> + if (!HAVE_PTE_SPECIAL && !pfn_t_devmap(pfn) && pfn_t_valid(pfn)) {
>   struct page *page;
>
> - page = pfn_t_to_page(pfn);
> + /*
> + * At this point we are committed to insert_page()
> + * regardless of whether the caller specified flags that
> + * result in pfn_t_has_page() == false.
> + */
> + page = pfn_to_page(pfn_t_to_pfn(pfn));
>   return insert_page(vma, addr, page, vma->vm_page_prot);
>   }
>   return insert_pfn(vma, addr, pfn, vma->vm_page_prot);
>
>
>
> [   16.503323] systemd[1]: Mounting FUSE Control File System...
> [   42.703092] Oops: Machine check, sig: 7 [#1]
> [   42.707624] PREEMPT Canyonlands
> [   42.710959] Modules linked in:
> [   42.714201] CPU: 0 PID: 553 Comm: Xorg Not tainted 4.5.0-rc1-Sam460ex #1
> [   42.721283] task: ee1e45c0 ti: ecd46000 task.ti: ecd46000
> [   42.726983] NIP: 1fed2480 LR: 1fed2404 CTR: 1fed24d0
> [   42.732227] REGS: ecd47f10 TRAP: 0214   Not tainted  (4.5.0-rc1-Sam460ex)
> [   42.739395] MSR: 0002d000 <CE,EE,PR,ME>  CR: 28004262  XER: 00000000
> [   42.746244]
> GPR00: 1f396134 bfcb0970 b77fc6f0 b6fbeffc b67d5008 00000780 00000004
> 00000000
> GPR08: 00000000 b6fbeffc 00000000 bfcb0920 1fed2404 2076dff4 00000000
> 00000780
> GPR16: 00000000 00000020 00000000 00000000 00001e00 209be650 00000438
> b67d5008
> GPR24: 00000780 bfcb09c8 209a8728 b6fbf000 b6fbf000 b67d5008 1ffdaff4
> 00001e00
> [   42.778096] NIP [1fed2480] 0x1fed2480
> [   42.781967] LR [1fed2404] 0x1fed2404
> [   42.785741] Call Trace:
> [   42.943688] ---[ end trace 5d20a91d2d30d9d6 ]---
> [   42.948311]
> [   46.641774] Machine check in kernel mode.
> [   46.645805] Data Write PLB Error
> [   46.649031] Machine Check exception is imprecise
> [   46.653658] Vector: 214  at [eccfbf10]
> [   46.657408]     pc: 1ffa9480
> [   46.660325]     lr: 1ffa9404
> [   46.663241]     sp: bf9252b0
> [   46.666123]    msr: 2d000
> [   46.668746]   current = 0xee1e73c0
> [   46.672149]     pid   = 663, comm = Xorg
> [   46.676074] Linux version 4.5.0-rc1-Sam460ex (root@julian-VirtualBox)

Ok, I think the patch is still needed for the issue Tomi reported,
this appears to be a separate bug.

Can you send me your kernel config?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
