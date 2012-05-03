Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 8335E6B0081
	for <linux-mm@kvack.org>; Wed,  2 May 2012 21:03:07 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1SPkRj-0001Os-AF
	for linux-mm@kvack.org; Thu, 03 May 2012 03:03:03 +0200
Received: from 121.50.20.41 ([121.50.20.41])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 03 May 2012 03:03:03 +0200
Received: from minchan by 121.50.20.41 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 03 May 2012 03:03:03 +0200
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] vmalloc: add warning in __vmalloc
Date: Thu, 03 May 2012 10:02:52 +0900
Message-ID: <4FA1D93C.9000306@kernel.org>
References: <1335932890-25294-1-git-send-email-minchan@kernel.org> <20120502124610.175e099c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
In-Reply-To: <20120502124610.175e099c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On 05/03/2012 04:46 AM, Andrew Morton wrote:

> On Wed,  2 May 2012 13:28:09 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> 
>> Now there are several places to use __vmalloc with GFP_ATOMIC,
>> GFP_NOIO, GFP_NOFS but unfortunately __vmalloc calls map_vm_area
>> which calls alloc_pages with GFP_KERNEL to allocate page tables.
>> It means it's possible to happen deadlock.
>> I don't know why it doesn't have reported until now.
>>
>> Firstly, I tried passing gfp_t to lower functions to support __vmalloc
>> with such flags but other mm guys don't want and decided that
>> all of caller should be fixed.
>>
>> http://marc.info/?l=linux-kernel&m=133517143616544&w=2
>>
>> To begin with, let's listen other's opinion whether they can fix it
>> by other approach without calling __vmalloc with such flags.
>>
>> So this patch adds warning in __vmalloc_node_range to detect it and
>> to be fixed hopely. __vmalloc_node_range isn't random chocie because
>> all caller which has gfp_mask of map_vm_area use it through __vmalloc_area_node.
>> And __vmalloc_area_node is current static function and is called by only
>> __vmalloc_node_range. So warning in __vmalloc_node_range would cover all
>> vmalloc functions which have gfp_t argument.
>>
>> I Cced related maintainers.
>> If I miss someone, please Cced them.
>>
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1648,6 +1648,10 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>>  	void *addr;
>>  	unsigned long real_size = size;
>>  
>> +	WARN_ON_ONCE(!(gfp_mask & __GFP_WAIT) ||
>> +			!(gfp_mask & __GFP_IO) ||
>> +			!(gfp_mask & __GFP_FS));
>> +
>>  	size = PAGE_ALIGN(size);
>>  	if (!size || (size >> PAGE_SHIFT) > totalram_pages)
>>  		goto fail;
> 
> Well.  What are we actually doing here?  Causing the kernel to spew a
> warning due to known-buggy callsites, so that users will report the
> warnings, eventually goading maintainers into fixing their stuff.
> 
> This isn't very efficient :(


Yes. I hope maintainers fix it before merging this.

> 
> It would be better to fix that stuff first, then add the warning to
> prevent reoccurrences.  Yes, maintainers are very naughty and probably
> do need cattle prods^W^W warnings to motivate them to fix stuff, but we
> should first make an effort to get these things fixed without
> irritating and alarming our users.  
> 
> Where are these offending callsites?


dm:
__alloc_buffer_wait_no_callback

ubi:
ubi_dbg_check_write
ubi_dbg_check_all_ff

ext4 :
ext4_kvmalloc

gfs2 :
gfs2_alloc_sort_buffer

ntfs :
__ntfs_malloc

ubifs :
dbg_dump_leb
scan_check_cb
dump_lpt_leb
dbg_check_ltab_lnum
dbg_scan_orphans

mm :
alloc_large_system_hash

ceph :
fill_inode
ceph_setxattr
ceph_removexattr
ceph_x_build_authorizer
ceph_decode_buffer
ceph_alloc_middle



> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
