Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 85DD46B004F
	for <linux-mm@kvack.org>; Fri,  1 May 2009 10:06:06 -0400 (EDT)
Message-ID: <49FB01C1.6050204@redhat.com>
Date: Fri, 01 May 2009 10:05:53 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: evict use-once pages first (v2)
References: <20090428044426.GA5035@eskimo.com>	<20090428192907.556f3a34@bree.surriel.com>	<1240987349.4512.18.camel@laptop>	<20090429114708.66114c03@cuia.bos.redhat.com>	<20090430072057.GA4663@eskimo.com>	<20090430174536.d0f438dd.akpm@linux-foundation.org>	<20090430205936.0f8b29fc@riellaptop.surriel.com>	<20090430181340.6f07421d.akpm@linux-foundation.org>	<20090430215034.4748e615@riellaptop.surriel.com> <20090430195439.e02edc26.akpm@linux-foundation.org>
In-Reply-To: <20090430195439.e02edc26.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: elladan@eskimo.com, peterz@infradead.org, linux-kernel@vger.kernel.org, tytso@mit.edu, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>> When we implement working set protection, we might as well
>> do it for frequently accessed unmapped pages too.  There is
>> no reason to restrict this protection to mapped pages.
> 
> Well.  Except for empirical observation, which tells us that biasing
> reclaim to prefer to retain mapped memory produces a better result.

That used to be the case because file-backed and
swap-backed pages shared the same set of LRUs,
while each following a different page reclaim
heuristic!

Today:
1) file-backed and swap-backed pages are separated,
2) the majority of mapped pages are on the swap-backed LRUs
3) the accessed bit on active pages no longer means much,
    for good scalability reasons, and
4) because of (3), we cannot really provide special treatment
    to any individual page any more, however

This means we need to provide our working set protection
on a per-list basis, by tweaking the scan rate or avoiding
scanning of the active file list alltogether under certain
conditions.

As a side effect, this will help protect frequently accessed
file pages (good for ftp and nfs servers), indirect blocks,
inode buffers and other frequently used metadata.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
