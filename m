Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2AB8D6B0216
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 07:45:03 -0400 (EDT)
Message-ID: <4BBDC181.5040205@redhat.com>
Date: Thu, 08 Apr 2010 14:44:01 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 67] Transparent Hugepage Support #18
References: <patchbomb.1270691443@v2.random> <4BBDA43F.5030309@redhat.com>
In-Reply-To: <4BBDA43F.5030309@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 04/08/2010 12:39 PM, Avi Kivity wrote:
> On 04/08/2010 04:50 AM, Andrea Arcangeli wrote:
>> Hello,
>>
>> I merged memory compaction v7 from Mel, plus his latest incremental 
>> updates
>> into my tree.
>>
>
> A quick benchmark, running 'sort -b 1200M /tmp/largerand > 
> /dev/null'.  The file is 1GB in size, consisting of 15-char base64 
> encoded random string + newline records.
>

That's -S, not -b.

> I'll try running this with a kernel build in parallel.

Results here are less than stellar.  While khugepaged is pulling pages 
together, something is breaking them apart.  Even after memory pressure 
is removed, this behaviour continues.  Can it be that compaction is 
tearing down huge pages?

After about 80 seconds of sort, we only have 40-50MB worth of hugepages, 
even though khugepaged is collapsing 50-100 per second (which should 
have got the job done in 5-10 seconds).

After dropping pagecache, we get about 800MB of large pages, so it looks 
like antifrag/compaction isn't able to deal with pagecache well.  
Dropping dcache adds a further 100MB.

All this with mem=2G.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
