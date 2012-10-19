Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 014746B005D
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 09:43:01 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 19 Oct 2012 09:43:00 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 508F9C9004C
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 09:42:54 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9JDgsPg319924
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 09:42:54 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9JDgpxM012363
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 10:42:53 -0300
Message-ID: <508158D6.4040806@linux.vnet.ibm.com>
Date: Fri, 19 Oct 2012 06:42:46 -0700
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/5] memory-hotplug: update mce_bad_pages when removing
 the memory
References: <1350475735-26136-1-git-send-email-wency@cn.fujitsu.com> <1350475735-26136-3-git-send-email-wency@cn.fujitsu.com> <507ECA43.3070402@linux.vnet.ibm.com> <20121018152008.ada8fea5.akpm@linux-foundation.org>
In-Reply-To: <20121018152008.ada8fea5.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: wency@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Christoph Lameter <cl@linux.com>

On 10/18/2012 03:20 PM, Andrew Morton wrote:
> On Wed, 17 Oct 2012 08:09:55 -0700
> Dave Hansen <dave@linux.vnet.ibm.com> wrote:
>>> +#ifdef CONFIG_MEMORY_FAILURE
>>> +static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
>>> +{
>>> +	int i;
>>> +
>>> +	if (!memmap)
>>> +		return;
>>
>> I guess free_section_usemap() does the same thing.
> 
> What does this observation mean?

sparse_remove_one_section() has an if(ms->section_mem_map) statement.
Inside that if() block is the only place in the function where 'memmap'
can get set.

Currently, sparse_remove_one_section() calls in to free_section_usemap()
ouside of that if() block.  With this patch new call to
clear_hwpoisoned_pages() is done in the same place, both passing 'memmap'.

However, both free_section_usemap() and clear_hwpoisoned_pages() check
'memmap' for NULL and immediately return if so.  That's a bit silly
since it could hide garbage coming back from sparse_decode_mem_map().
Seems like we should just call them both inside that if() block, or
reorganize sparse_remove_one_section(), maybe like this:

void sparse_remove_one_section(struct zone *zone, struct mem_section *ms)
{
        struct page *memmap = NULL;
        unsigned long *usemap = NULL;

        if (!ms->section_mem_map)
		return;

        usemap = ms->pageblock_flags;
        memmap = sparse_decode_mem_map(ms->section_mem_map,
                                                __section_nr(ms));
        ms->section_mem_map = 0;
        ms->pageblock_flags = NULL;

        free_section_usemap(memmap, usemap);
	clear_hwpoisoned_pages(usemap, ...);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
