Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA1IG7bX011950
	for <linux-mm@kvack.org>; Thu, 1 Nov 2007 14:16:07 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA1IFwRv117452
	for <linux-mm@kvack.org>; Thu, 1 Nov 2007 12:16:03 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA1IFwdE030118
	for <linux-mm@kvack.org>; Thu, 1 Nov 2007 12:15:58 -0600
Subject: start_isolate_page_range() question/offline_pages() bug ?
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Thu, 01 Nov 2007 11:19:28 -0800
Message-Id: <1193944769.26106.34.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi KAME,

While testing hotplug memory remove on x86_64, found an issue.

offline_pages()
{

	...
	
	/* set above range as isolated */
        ret = start_isolate_page_range(start_pfn, end_pfn);
	

	... does all the work and successful ...

        /* reset pagetype flags */
        start_isolate_page_range(start_pfn, end_pfn);
        /* removal success */
}

As you can see it calls, start_isolate_page_range() again at
the end. Why ? I am assuming that, to clear MIGRATE_ISOLATE
type for those pages we marked earlier. Isn't it ? But its
wrong. The pages are already set MIGRATE_ISOLATE and it
will end up clearing ONLY the first page in the pageblock.
Shouldn't we clear MIGRATE_ISOLATE for all the pages ?

I see this issue on x86-64, because /sysfs memory block
is 128MB, but pageblock_nr_pages = 512 (2MB).

I can reproduce the problem easily.. by doing ..

echo offline > state
echo online > state
echo offline > state <--- this one will fail
echo offline > state <-- fail
echo offline > state <-- fail

Everytime we do "offline" it clears first page in 2MB
section as part of undo :(

Here is the debug:
	
memory offlining 58000 to 60000 started
Offlined Pages 32768

memory offlining 58000 to 60000 started
isolate failed for pfn 58200 migratetype 4

memory offlining 58000 to 60000 started
isolate failed for pfn 58400 migratetype 4

memory offlining 58000 to 60000 started
isolate failed for pfn 58600 migratetype 4

memory offlining 58000 to 60000 started
isolate failed for pfn 58800 migratetype 4


Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
