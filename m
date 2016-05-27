Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id E6C1D6B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 04:26:02 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id w16so43304692lfd.0
        for <linux-mm@kvack.org>; Fri, 27 May 2016 01:26:02 -0700 (PDT)
Received: from fnsib-smtp01.srv.cat (fnsib-smtp01.srv.cat. [46.16.60.186])
        by mx.google.com with ESMTPS id x124si8153386lfd.231.2016.05.27.01.26.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 01:26:01 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit
Date: Fri, 27 May 2016 10:25:59 +0200
From: "guillermo.julian" <guillermo.julian@naudit.es>
Subject: Re: [PATCH] mm: fix overflow in vm_map_ram
Reply-To: guillermo.julian@naudit.es
In-Reply-To: <20160526142837.662100b01ff094be9a28f01b@linux-foundation.org>
References: <etPan.57175fb3.7a271c6b.2bd@naudit.es>
 <20160526142837.662100b01ff094be9a28f01b@linux-foundation.org>
Message-ID: <08d280dc9c9fe037805e3ff74d7dad02@naudit.es>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

El 2016-05-26 23:28, Andrew Morton escribiA3:
> On Wed, 20 Apr 2016 12:53:33 +0200 Guillermo Juli__n Moreno
> <guillermo.julian@naudit.es> wrote:
> 
>> 
>> When remapping pages accounting for 4G or more memory space, the
>> operation 'count << PAGE_SHIFT' overflows as it is performed on an
>> integer. Solution: cast before doing the bitshift.
> 
> Yup.
> 
> We need to work out which kernel versions to fix.  What are the runtime
> effects of this?  Are there real drivers in the tree which actually map
> more than 4G?

Looking at the references of vm_map_ram, it is only used in three 
drivers (XFS, v4l2-core and android/ion). However, in the vmap() code, 
the same bug is likely to occur (vmalloc.c:1557), and that function is 
more frequently used. But if it has gone unnoticed until now, most 
probably it isn't a critical issue (4G memory allocations are usually 
not needed. In fact this bug surfaced during a performance test in a 
modified driver, not in a regular configuration.

> 
> I fixed vm_unmap_ram() as well, but I didn't test it.  I wonder why you
> missed that...

The initial test didn't fail so I didn't notice the unmap was not 
working, so I completely forgot to check that function.

> 
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index ae7d20b..97257e4 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1114,7 +1114,7 @@ EXPORT_SYMBOL(vm_unmap_ram);
>> */
>> void *vm_map_ram(struct page **pages, unsigned int count, int node, 
>> pgprot_t prot)
>> {
>> - unsigned long size = count << PAGE_SHIFT;
>> + unsigned long size = ((unsigned long) count) << PAGE_SHIFT;
>> unsigned long addr;
>> void *mem;
>> 
> 
> Your email client totally messes up the patches.  Please fix that for
> next time.

Sorry about that, I didn't notice it ate the tabs. I checked and this 
time it shouldn't happen.

> 
> 
> From: Guillermo Juli_n Moreno <guillermo.julian@naudit.es>
> Subject: mm: fix overflow in vm_map_ram()
> 
> When remapping pages accounting for 4G or more memory space, the
> operation 'count << PAGE_SHIFT' overflows as it is performed on an
> integer. Solution: cast before doing the bitshift.
> 
> [akpm@linux-foundation.org: fix vm_unmap_ram() also]
> Link: http://lkml.kernel.org/r/etPan.57175fb3.7a271c6b.2bd@naudit.es
> Signed-off-by: Guillermo Juli_n Moreno <guillermo.julian@naudit.es>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/vmalloc.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff -puN mm/vmalloc.c~mm-fix-overflow-in-vm_map_ram mm/vmalloc.c
> --- a/mm/vmalloc.c~mm-fix-overflow-in-vm_map_ram
> +++ a/mm/vmalloc.c
> @@ -1105,7 +1105,7 @@ EXPORT_SYMBOL_GPL(vm_unmap_aliases);
>   */
>  void vm_unmap_ram(const void *mem, unsigned int count)
>  {
> -	unsigned long size = count << PAGE_SHIFT;
> +	unsigned long size = (unsigned long)count << PAGE_SHIFT;
>  	unsigned long addr = (unsigned long)mem;
> 
>  	BUG_ON(!addr);
> @@ -1140,7 +1140,7 @@ EXPORT_SYMBOL(vm_unmap_ram);
>   */
>  void *vm_map_ram(struct page **pages, unsigned int count, int node,
> pgprot_t prot)
>  {
> -	unsigned long size = count << PAGE_SHIFT;
> +	unsigned long size = (unsigned long)count << PAGE_SHIFT;
>  	unsigned long addr;
>  	void *mem;
> 
> _

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
