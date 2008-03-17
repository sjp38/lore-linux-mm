Received: by wf-out-1314.google.com with SMTP id 25so5641199wfc.11
        for <linux-mm@kvack.org>; Sun, 16 Mar 2008 19:19:46 -0700 (PDT)
Message-ID: <86802c440803161919h20ed9f78k6e3798ef56668638@mail.gmail.com>
Date: Sun, 16 Mar 2008 19:19:45 -0700
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH] [11/18] Fix alignment bug in bootmem allocator
In-Reply-To: <20080317015825.0C0171B41E0@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080317258.659191058@firstfloor.org>
	 <20080317015825.0C0171B41E0@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Sun, Mar 16, 2008 at 6:58 PM, Andi Kleen <andi@firstfloor.org> wrote:
>
>  Without this fix bootmem can return unaligned addresses when the start of a
>  node is not aligned to the align value. Needed for reliably allocating
>  gigabyte pages.
>  Signed-off-by: Andi Kleen <ak@suse.de>
>
>  ---
>   mm/bootmem.c |    4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
>
>  Index: linux/mm/bootmem.c
>  ===================================================================
>  --- linux.orig/mm/bootmem.c
>  +++ linux/mm/bootmem.c
>  @@ -197,6 +197,7 @@ __alloc_bootmem_core(struct bootmem_data
>   {
>         unsigned long offset, remaining_size, areasize, preferred;
>         unsigned long i, start = 0, incr, eidx, end_pfn;
>  +       unsigned long pfn;
>         void *ret;
>
>         if (!size) {
>  @@ -239,12 +240,13 @@ __alloc_bootmem_core(struct bootmem_data
>         preferred = PFN_DOWN(ALIGN(preferred, align)) + offset;
>         areasize = (size + PAGE_SIZE-1) / PAGE_SIZE;
>         incr = align >> PAGE_SHIFT ? : 1;
>  +       pfn = PFN_DOWN(bdata->node_boot_start);
>
>   restart_scan:
>         for (i = preferred; i < eidx; i += incr) {
>                 unsigned long j;
>                 i = find_next_zero_bit(bdata->node_bootmem_map, eidx, i);
>  -               i = ALIGN(i, incr);
>  +               i = ALIGN(pfn + i, incr) - pfn;
>                 if (i >= eidx)
>                         break;
>                 if (test_bit(i, bdata->node_bootmem_map))
>  --

node_boot_start is not page aligned?

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
