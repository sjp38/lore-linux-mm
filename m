Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id E48286B0032
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 15:42:43 -0500 (EST)
Received: by mail-la0-f49.google.com with SMTP id gf13so44889484lab.8
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 12:42:43 -0800 (PST)
Received: from fiona.linuxhacker.ru ([217.76.32.60])
        by mx.google.com with ESMTPS id kx2si7633909lac.30.2015.02.02.12.42.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Feb 2015 12:42:41 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: Export __vmalloc_node
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <alpine.DEB.2.10.1502020940530.5117@chino.kir.corp.google.com>
Date: Mon, 2 Feb 2015 15:31:05 -0500
Content-Transfer-Encoding: 7bit
Message-Id: <F1318F2A-AEE8-4E92-A1FE-510A1EB2FCB2@linuxhacker.ru>
References: <1422846627-26890-1-git-send-email-green@linuxhacker.ru> <1422846627-26890-2-git-send-email-green@linuxhacker.ru> <alpine.DEB.2.10.1502020940530.5117@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Hello!

On Feb 2, 2015, at 12:45 PM, David Rientjes wrote:

> On Sun, 1 Feb 2015, green@linuxhacker.ru wrote:
> 
>> From: Oleg Drokin <green@linuxhacker.ru>
>> 
>> vzalloc_node helpfully suggests to use __vmalloc_node if a more tight
>> control over allocation flags is needed, but in fact __vmalloc_node
>> is not only not exported, it's also static, so could not be used
>> outside of mm/vmalloc.c
>> Make it to be available as it was apparently intended.
>> 
> 
> __vmalloc_node() is for the generalized functionality that is needed for 
> the vmalloc API and not part of the API itself.  I think what you want to 
> do is add a vmalloc_node_gfp(), or more specifically a vzalloc_node_gfp(), 
> to do GFP_NOFS when needed.

So, the comment for the vzalloc_node reads:
 * For tight control over page level allocator and protection flags
 * use __vmalloc_node() instead.
 */
void *vzalloc_node(unsigned long size, int node)

Very similar to the comment for vzalloc:
 *      For tight control over page level allocator and protection flags
 *      use __vmalloc() instead.
 */
void *vzalloc(unsigned long size)

__vmalloc is exported and is allowed to be used everywhere.

Should we then just take down the __vmalloc_node comment near vzalloc_node
to no longer confuse people?

> 
>> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
>> ---
>> include/linux/vmalloc.h |  3 +++
>> mm/vmalloc.c            | 10 ++++------
>> 2 files changed, 7 insertions(+), 6 deletions(-)
>> 
>> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
>> index b87696f..7eb2c46 100644
>> --- a/include/linux/vmalloc.h
>> +++ b/include/linux/vmalloc.h
>> @@ -73,6 +73,9 @@ extern void *vmalloc_exec(unsigned long size);
>> extern void *vmalloc_32(unsigned long size);
>> extern void *vmalloc_32_user(unsigned long size);
>> extern void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot);
>> +extern void *__vmalloc_node(unsigned long size, unsigned long align,
>> +			    gfp_t gfp_mask, pgprot_t prot, int node,
>> +			    const void *caller);
>> extern void *__vmalloc_node_range(unsigned long size, unsigned long align,
>> 			unsigned long start, unsigned long end, gfp_t gfp_mask,
>> 			pgprot_t prot, int node, const void *caller);
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 39c3388..b882d95 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1552,9 +1552,6 @@ void *vmap(struct page **pages, unsigned int count,
>> }
>> EXPORT_SYMBOL(vmap);
>> 
>> -static void *__vmalloc_node(unsigned long size, unsigned long align,
>> -			    gfp_t gfp_mask, pgprot_t prot,
>> -			    int node, const void *caller);
>> static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>> 				 pgprot_t prot, int node)
>> {
>> @@ -1685,13 +1682,14 @@ fail:
>>  *	allocator with @gfp_mask flags.  Map them into contiguous
>>  *	kernel virtual space, using a pagetable protection of @prot.
>>  */
>> -static void *__vmalloc_node(unsigned long size, unsigned long align,
>> -			    gfp_t gfp_mask, pgprot_t prot,
>> -			    int node, const void *caller)
>> +void *__vmalloc_node(unsigned long size, unsigned long align,
>> +		     gfp_t gfp_mask, pgprot_t prot, int node,
>> +		     const void *caller)
>> {
>> 	return __vmalloc_node_range(size, align, VMALLOC_START, VMALLOC_END,
>> 				gfp_mask, prot, node, caller);
>> }
>> +EXPORT_SYMBOL(__vmalloc_node);
>> 
>> void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot)
>> {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
