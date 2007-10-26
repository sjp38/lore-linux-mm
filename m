Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9QN4NeJ019419
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 19:04:23 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9QN4ImT095406
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 17:04:23 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9QN4HVX000800
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 17:04:18 -0600
Subject: Re: migrate_pages() failure
From: Badari Pulavarty <pbadari@gmail.com>
In-Reply-To: <1193432242.19950.1.camel@dyn9047017100.beaverton.ibm.com>
References: <1193432242.19950.1.camel@dyn9047017100.beaverton.ibm.com>
Content-Type: text/plain
Date: Fri, 26 Oct 2007 16:07:47 -0700
Message-Id: <1193440067.19950.7.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: melgor@ie.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-10-26 at 13:57 -0700, Badari Pulavarty wrote:
> Hi,
> 
> While playing with hotplug memory remove on x86-64 and ppc64, I noticed
> that some of the memory sections can not be offlined. What I noticed is
> migrate_pages() fails to move the pages. I added debug and page_owner
> to track these pages. I am wondering why they couldn't be migrated ?
> Ideas ?
> 
> BTW, I did echo 3 > /proc/sys/vm/drop_caches to drop all the
> caches before trying to offline (on this cleanly rebooted machine).
> 
> nr_failed 0 retry 116
> migrate pages failed 3f025/3/3f00000000800
> migrate pages failed 3f048/3/3f00000000800
> migrate pages failed 3f04c/3/3f00000000800
> migrate pages failed 3f06e/3/3f00000000800
> migrate pages failed 3f092/3/3f00000000800
> migrate pages failed 3f093/3/3f00000000800
> migrate pages failed 3f097/3/3f00000000800
> migrate pages failed 3f0b2/3/3f00000000800
> migrate pages failed 3f0b7/3/3f00000000800
> migrate pages failed 3f0b8/3/3f00000000800
> migrate pages failed 3f100/3/3f00000000800
> migrate pages failed 3f196/3/3f00000000800
> migrate pages failed 3f19d/3/3f00000000800
> migrate pages failed 3f1b7/3/3f00000000800
> migrate pages failed 3f1ba/3/3f00000000800
> migrate pages failed 3f1c8/3/3f00000000800
> 

Digged up little more ..

All these pages are "reiserfs" backed file and reiserfs doesn't
have migratepage() handler. reiserfs_releasepage() gives up
since one of the buffer_head attached to the page is dirty or locked :(

Nothing much migrate pages could do :(


Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
