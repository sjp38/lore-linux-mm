Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id CD34A6B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 08:29:24 -0400 (EDT)
Received: by laclj5 with SMTP id lj5so1367384lac.3
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 05:29:24 -0700 (PDT)
Received: from forward-corp1g.mail.yandex.net (forward-corp1g.mail.yandex.net. [2a02:6b8:0:1402::10])
        by mx.google.com with ESMTPS id bm7si1626282lbc.82.2015.09.25.05.29.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 05:29:23 -0700 (PDT)
Subject: Re: [PATCH 03/16] page-flags: introduce page flags policies wrt
 compound pages
References: <20150921153509.fef7ecdf313ef74307c43b65@linux-foundation.org>
 <1443106264-78075-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1443106264-78075-4-git-send-email-kirill.shutemov@linux.intel.com>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <56053E1D.7050001@yandex-team.ru>
Date: Fri, 25 Sep 2015 15:29:17 +0300
MIME-Version: 1.0
In-Reply-To: <1443106264-78075-4-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 24.09.2015 17:50, Kirill A. Shutemov wrote:
> This patch adds a third argument to macros which create function
> definitions for page flags.  This argument defines how page-flags helpers
> behave on compound functions.
>
> For now we define four policies:
>
> - PF_ANY: the helper function operates on the page it gets, regardless
>    if it's non-compound, head or tail.
>
> - PF_HEAD: the helper function operates on the head page of the compound
>    page if it gets tail page.
>
> - PF_NO_TAIL: only head and non-compond pages are acceptable for this
>    helper function.
>
> - PF_NO_COMPOUND: only non-compound pages are acceptable for this helper
>    function.
>
> For now we use policy PF_ANY for all helpers, which matches current
> behaviour.
>
> We do not enforce the policy for TESTPAGEFLAG, because we have flags
> checked for random pages all over the kernel.  Noticeable exception to
> this is PageTransHuge() which triggers VM_BUG_ON() for tail page.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>   include/linux/page-flags.h | 154 ++++++++++++++++++++++++++-------------------
>   1 file changed, 90 insertions(+), 64 deletions(-)
>
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 713d3f2c2468..1b3babe5ff69 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -154,49 +154,68 @@ static inline int PageCompound(struct page *page)
>   	return test_bit(PG_head, &page->flags) || PageTail(page);
>   }
>
> +/* Page flags policies wrt compound pages */
> +#define PF_ANY(page, enforce)	page
> +#define PF_HEAD(page, enforce)	compound_head(page)
> +#define PF_NO_TAIL(page, enforce) ({					\
> +		if (enforce)						\
> +			VM_BUG_ON_PAGE(PageTail(page), page);		\
> +		else							\
> +			page = compound_head(page);			\
> +		page;})
> +#define PF_NO_COMPOUND(page, enforce) ({					\
> +		if (enforce)						\
> +			VM_BUG_ON_PAGE(PageCompound(page), page);	\

Linux next-20150925 crashes here (at least in lkvm)
if CONFIG_DEFERRED_STRUCT_PAGE_INIT=y

[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: noapic noacpi pci=conf1 reboot=k 
panic=1 i8042.direct=1 i8042.dumbkbd=1 i8042.nopnp=1 console=ttyS0 
earlyprintk=serial i8042.noaux=1  root=/dev/root rw 
rootflags=rw,trans=virtio,version=9p2000.L rootfstype=9p init=/virt/init 
  ip=dhcp
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] BUG: unable to handle kernel NULL pointer dereference at 
000000000000000c
[    0.000000] IP: [<ffffffff811aaafb>] dump_page_badflags+0x2b/0xe0
[    0.000000] PGD 0
[    0.000000] Oops: 0000 [#1] SMP
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 
4.3.0-rc2-next-20150925+ #2
[    0.000000] task: ffffffff81c12580 ti: ffffffff81c00000 task.ti: 
ffffffff81c00000
[    0.000000] RIP: 0010:[<ffffffff811aaafb>]  [<ffffffff811aaafb>] 
dump_page_badflags+0x2b/0xe0
[    0.000000] RSP: 0000:ffffffff81c03ea8  EFLAGS: 00010002
[    0.000000] RAX: 000000000000000c RBX: ffffea00006dfd40 RCX: 
0000000000000100
[    0.000000] RDX: 0000000000000001 RSI: ffffffff81a4aeb8 RDI: 
ffffea00006dfd40
[    0.000000] RBP: ffffffff81c03ec0 R08: 0000000000000000 R09: 
0000000000000000
[    0.000000] R10: 0000000000000001 R11: 0000000000000000 R12: 
0000000000000000
[    0.000000] R13: 000000000001b7f7 R14: ffffffff81fe50c0 R15: 
ffffffff81c03fb0
[    0.000000] FS:  0000000000000000(0000) GS:ffff88001a400000(0000) 
knlGS:0000000000000000
[    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    0.000000] CR2: 000000000000000c CR3: 0000000001c0b000 CR4: 
00000000000406b0
[    0.000000] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[    0.000000] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 
0000000000000400
[    0.000000] Stack:
[    0.000000]  000000000001b7f5 ffffea00006dfd40 000000000001b7f7 
ffffffff81c03ed0
[    0.000000]  ffffffff811aabc0 ffffffff81c03ef8 ffffffff81785eda 
ffffffff81c03f10
[    0.000000]  0000000000000040 ffffffff81fd99c0 ffffffff81c03f30 
ffffffff81f66600
[    0.000000] Call Trace:
[    0.000000]  [<ffffffff811aabc0>] dump_page+0x10/0x20
[    0.000000]  [<ffffffff81785eda>] reserve_bootmem_region+0xd9/0xe2
[    0.000000]  [<ffffffff81f66600>] free_all_bootmem+0x4b/0x11a
[    0.000000]  [<ffffffff81f5428d>] mem_init+0x6a/0x9d
[    0.000000]  [<ffffffff81f37d48>] start_kernel+0x214/0x46a
[    0.000000]  [<ffffffff81f37120>] ? early_idt_handler_array+0x120/0x120
[    0.000000]  [<ffffffff81f374d7>] x86_64_start_reservations+0x2a/0x2c
[    0.000000]  [<ffffffff81f3760f>] x86_64_start_kernel+0x136/0x145
[    0.000000] Code: e8 3b 7b 5e 00 55 48 89 e5 41 55 41 54 49 89 d4 53 
48 8b 57 20 48 89 fb 4c 8b 4f 10 4c 8b 47 08 48 8d 42 ff 83 e2 01 48 0f 
44 c7 <48> 8b 00 a8 80 75 4b 8b 4f 18 8b 57 1c 49 89 f5 31 c0 48 89 fe
[    0.000000] RIP  [<ffffffff811aaafb>] dump_page_badflags+0x2b/0xe0
[    0.000000]  RSP <ffffffff81c03ea8>
[    0.000000] CR2: 000000000000000c
[    0.000000] ---[ end trace cb88537fdc8fa200 ]---


> +		page;})
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
