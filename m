Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 552A86B01EF
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 10:40:38 -0400 (EDT)
Message-ID: <4BCDBCC4.60401@redhat.com>
Date: Tue, 20 Apr 2010 10:40:04 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone pressure
References: <20100322235053.GD9590@csn.ul.ie> <4BA940E7.2030308@redhat.com> <20100324145028.GD2024@csn.ul.ie> <4BCC4B0C.8000602@linux.vnet.ibm.com> <20100419214412.GB5336@cmpxchg.org>
In-Reply-To: <20100419214412.GB5336@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, gregkh@novell.com, Corrado Zoccolo <czoccolo@gmail.com>
List-ID: <linux-mm.kvack.org>

On 04/19/2010 05:44 PM, Johannes Weiner wrote:

> What do people think?

It has potential advantages and disadvantages.

On smaller desktop systems, it is entirely possible that
the working set is close to half of the page cache.  Your
patch reduces the amount of memory that is protected on
the active file list, so it may cause part of the working
set to get evicted.

On the other hand, having a smaller active list frees up
more memory for sequential (streaming, use-once) disk IO.
This can be useful on systems with large IO subsystems
and small memory (like Christian's s390 virtual machine,
with 256MB RAM and 4 disks!).

I wonder if we could not find some automatic way to
balance between these two situations, for example by
excluding currently-in-flight pages from the calculations.

In Christian's case, he could have 160MB of cache (buffer
+ page cache), of which 70MB is in flight to disk at a
time.  It may be worthwhile to exclude that 70MB from the
total and aim for 45MB active file and 45MB inactive file
pages on his system.  That way IO does not get starved.

On a desktop system, which needs the working set protected
and does less IO, we will automatically protect more of
the working set - since there is no IO to starve.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
