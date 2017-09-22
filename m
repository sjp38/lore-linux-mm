Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 247E16B0038
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 12:27:21 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id u2so3501214itb.7
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 09:27:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 193si109082oib.40.2017.09.22.09.27.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Sep 2017 09:27:19 -0700 (PDT)
Date: Fri, 22 Sep 2017 09:27:14 -0700
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] mm/device-public-memory: Fix edge case in
 _vm_normal_page()
Message-ID: <20170922162713.GA4144@redhat.com>
References: <1506092178-20351-1-git-send-email-arbab@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1506092178-20351-1-git-send-email-arbab@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 22, 2017 at 09:56:18AM -0500, Reza Arbab wrote:
> With device public pages at the end of my memory space, I'm getting
> output from _vm_normal_page():
> 
> BUG: Bad page map in process migrate_pages  pte:c0800001ffff0d06 pmd:f95d3000
> addr:00007fff89330000 vm_flags:00100073 anon_vma:c0000000fa899320 mapping:          (null) index:7fff8933
> file:          (null) fault:          (null) mmap:          (null) readpage:          (null)
> CPU: 0 PID: 13963 Comm: migrate_pages Tainted: P    B      OE 4.14.0-rc1-wip #155
> Call Trace:
> [c0000000f965f910] [c00000000094d55c] dump_stack+0xb0/0xf4 (unreliable)
> [c0000000f965f950] [c0000000002b269c] print_bad_pte+0x28c/0x340
> [c0000000f965fa00] [c0000000002b59c0] _vm_normal_page+0xc0/0x140
> [c0000000f965fa20] [c0000000002b6e64] zap_pte_range+0x664/0xc10
> [c0000000f965fb00] [c0000000002b7858] unmap_page_range+0x318/0x670
> [c0000000f965fbd0] [c0000000002b8074] unmap_vmas+0x74/0xe0
> [c0000000f965fc20] [c0000000002c4a18] exit_mmap+0xe8/0x1f0
> [c0000000f965fce0] [c0000000000ecbdc] mmput+0xac/0x1f0
> [c0000000f965fd10] [c0000000000f62e8] do_exit+0x348/0xcd0
> [c0000000f965fdd0] [c0000000000f6d2c] do_group_exit+0x5c/0xf0
> [c0000000f965fe10] [c0000000000f6ddc] SyS_exit_group+0x1c/0x20
> [c0000000f965fe30] [c00000000000b184] system_call+0x58/0x6c
> 
> The pfn causing this is the very last one. Correct the bounds check
> accordingly.
> 
> Fixes: df6ad69838fc ("mm/device-public-memory: device memory cache coherent with CPU")

Reviewed-by: Jerome Glisse <jglisse@redhat.com>


> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> ---
>  mm/memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index ec4e154..a728bed 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -845,7 +845,7 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
>  		 * vm_normal_page() so that we do not have to special case all
>  		 * call site of vm_normal_page().
>  		 */
> -		if (likely(pfn < highest_memmap_pfn)) {
> +		if (likely(pfn <= highest_memmap_pfn)) {
>  			struct page *page = pfn_to_page(pfn);
>  
>  			if (is_device_public_page(page)) {
> -- 
> 1.8.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
