Received: from m2.gw.fujitsu.co.jp ([10.0.50.72]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i976jfUI015849 for <linux-mm@kvack.org>; Thu, 7 Oct 2004 15:45:41 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s1.gw.fujitsu.co.jp by m2.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i976jff1025350 for <linux-mm@kvack.org>; Thu, 7 Oct 2004 15:45:41 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s1.gw.fujitsu.co.jp (s1 [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0D611216F54
	for <linux-mm@kvack.org>; Thu,  7 Oct 2004 15:45:41 +0900 (JST)
Received: from fjmail506.fjmail.jp.fujitsu.com (fjmail506-0.fjmail.jp.fujitsu.com [10.59.80.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B2EDC216FC3
	for <linux-mm@kvack.org>; Thu,  7 Oct 2004 15:45:40 +0900 (JST)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail506.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I570075WC4385@fjmail506.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Thu,  7 Oct 2004 15:45:40 +0900 (JST)
Date: Thu, 07 Oct 2004 15:51:15 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: align vmemmap to ia64's granule
In-reply-to: <4164E20D.5020400@jp.fujitsu.com>
Message-id: <4164E763.8020003@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
References: <B8E391BBE9FE384DAA4C5C003888BE6F0226680C@scsmsx401.amr.corp.intel.com>
 <4164E20D.5020400@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, "Martin J. Bligh" <mbligh@aracnet.com>, LinuxIA64 <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi, Tony

This patch make vmemmap to be aligned with ia64's granule size, against 2.6.9-rc3.
Please apply this, if vmemmap is expected to be aligned with the granule size.

Kame <kamezawa.hiroyu@jp.fujitsu.com>

Hiroyuki KAMEZAWA wrote:
> Hi,
> Luck, Tony wrote:
> 
>>> Because pfn_valid() often returns 0 in inner loop of free_pages_bulk(),
>>> I want to avoid page fault caused by using get_user() in pfn_valid().
>>
>>
>>
>> How often?  Surely this is only a problem at the edges of blocks
>> of memory?  I suppose it depends on whether your discontig memory
>> appears in blocks much smaller than MAXORDER.  But even there it
>> should only be an issue coalescing buddies that are bigger than
>> the granule size (since all of the pages in a granule on ia64 are
>> guaranteed to exist, the buddy of any page must also exist).

> node's start_pfn and end_pfn is aligned to granule size, but holes in 
> memmap is not.
> The vmemmap is aligned to # of page structs in one page.


---

  test-kernel-kamezawa/arch/ia64/mm/init.c |    2 ++
  1 files changed, 2 insertions(+)

diff -puN arch/ia64/mm/init.c~vmemmap_align_granule arch/ia64/mm/init.c
--- test-kernel/arch/ia64/mm/init.c~vmemmap_align_granule	2004-10-07 15:24:08.322733968 +0900
+++ test-kernel-kamezawa/arch/ia64/mm/init.c	2004-10-07 15:30:58.623358792 +0900
@@ -411,6 +411,8 @@ virtual_memmap_init (u64 start, u64 end,

  	args = (struct memmap_init_callback_data *) arg;

+	start = GRANULEROUNDDOWN(start);
+	end  = GRANULEROUNDUP(end);
  	map_start = vmem_map + (__pa(start) >> PAGE_SHIFT);
  	map_end   = vmem_map + (__pa(end) >> PAGE_SHIFT);


_


-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
