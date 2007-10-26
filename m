Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9QKs68N014167
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 16:54:06 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9QKs0KR119928
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 14:54:05 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9QKs0Yv025109
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 14:54:00 -0600
Subject: migrate_pages() failure
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Fri, 26 Oct 2007 13:57:22 -0700
Message-Id: <1193432242.19950.1.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

While playing with hotplug memory remove on x86-64 and ppc64, I noticed
that some of the memory sections can not be offlined. What I noticed is
migrate_pages() fails to move the pages. I added debug and page_owner
to track these pages. I am wondering why they couldn't be migrated ?
Ideas ?

BTW, I did echo 3 > /proc/sys/vm/drop_caches to drop all the
caches before trying to offline (on this cleanly rebooted machine).

nr_failed 0 retry 116
migrate pages failed 3f025/3/3f00000000800
migrate pages failed 3f048/3/3f00000000800
migrate pages failed 3f04c/3/3f00000000800
migrate pages failed 3f06e/3/3f00000000800
migrate pages failed 3f092/3/3f00000000800
migrate pages failed 3f093/3/3f00000000800
migrate pages failed 3f097/3/3f00000000800
migrate pages failed 3f0b2/3/3f00000000800
migrate pages failed 3f0b7/3/3f00000000800
migrate pages failed 3f0b8/3/3f00000000800
migrate pages failed 3f100/3/3f00000000800
migrate pages failed 3f196/3/3f00000000800
migrate pages failed 3f19d/3/3f00000000800
migrate pages failed 3f1b7/3/3f00000000800
migrate pages failed 3f1ba/3/3f00000000800
migrate pages failed 3f1c8/3/3f00000000800


Page owner shows:

Page allocated via order 0, mask 0x120050
PFN 258085 Block 63 type 2          Flags      L
[0xc0000000000bae88] .alloc_pages_current+180
[0xc0000000000f995c] .__find_get_block_slow+88
[0xc000000000093534] .__page_cache_alloc+24
[0xc0000000000f9ed0] .__find_get_block+272
[0xc000000000094598] .find_or_create_page+76
[0xc0000000000fb288] .unlock_buffer+48
[0xc0000000000fa178] .__getblk+312
[0xc0000000000fbb84] .ll_rw_block+348

Page allocated via order 0, mask 0x120050
PFN 258120 Block 63 type 2          Flags      L
[0xc0000000000bae88] .alloc_pages_current+180
[0xc0000000000f995c] .__find_get_block_slow+88
[0xc0000000004ce49c] .__wait_on_bit+232
[0xc000000000093534] .__page_cache_alloc+24
[0xc0000000000f9ed0] .__find_get_block+272
[0xc000000000094598] .find_or_create_page+76
[0xc0000000000fa014] .__find_get_block+596
[0xc0000000000fb288] .unlock_buffer+48

Page allocated via order 0, mask 0x120050
PFN 258124 Block 63 type 2          Flags      L
[0xc0000000000bae88] .alloc_pages_current+180
[0xc0000000000f995c] .__find_get_block_slow+88
[0xc0000000004ce49c] .__wait_on_bit+232
[0xc000000000093534] .__page_cache_alloc+24
[0xc0000000000f9ed0] .__find_get_block+272
[0xc000000000094598] .find_or_create_page+76
[0xc0000000000fb288] .unlock_buffer+48
[0xc0000000000fa178] .__getblk+312


Page allocated via order 0, mask 0x120050
PFN 258158 Block 63 type 2          Flags      L
[0xc0000000000bae88] .alloc_pages_current+180
[0xc0000000000f995c] .__find_get_block_slow+88
[0xc0000000004ce49c] .__wait_on_bit+232
[0xc000000000093534] .__page_cache_alloc+24
[0xc0000000000f9ed0] .__find_get_block+272
[0xc000000000094598] .find_or_create_page+76
[0xc0000000000fa014] .__find_get_block+596
[0xc0000000000fb288] .unlock_buffer+48



Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
