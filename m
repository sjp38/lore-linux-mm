Date: Mon, 24 Nov 2003 07:36:43 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [RFC] Make balance_dirty_pages zone aware (1/2)
Message-ID: <1034580000.1069688202@[10.10.2.4]>
In-Reply-To: <20031123143627.1754a3f0.akpm@osdl.org>
References: <3FBEB27D.5010007@us.ibm.com> <20031123143627.1754a3f0.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, colpatch@us.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

>> Currently the VM decides to start doing background writeback of pages if 
>>  10% of the systems pages are dirty, and starts doing synchronous 
>>  writeback of pages if 40% are dirty.  This is great for smaller memory 
>>  systems, but in larger memory systems (>2GB or so), a process can dirty 
>>  ALL of lowmem (ZONE_NORMAL, 896MB) without hitting the 40% dirty page 
>>  ratio needed to force the process to do writeback. 
> 
> Yes, it has been that way for a year or so.  I was wondering if anyone
> would hit any problems in practice.  Have you hit any problem in practice?
> 
> I agree that the per-zonification of this part of the VM/VFS makes some
> sense, although not _complete_ sense, because as you've seen, we need to
> perform writeout against all zones' pages if _any_ zone exceeds dirty
> limits.  This could do nasty things on a 1G highmem machine, due to the
> tiny highmem zone.  So maybe that zone should not trigger writeback.
> 
> However the simplest fix is of course to decrease the default value of the
> dirty thresholds - put them back to the 2.4 levels.  It all depends upon
> the nature of the problems which you have been observing?

I'm not sure that'll fix the problem for NUMA boxes, which is where we 
started. When any node fills up completely with dirty pages (which would
only require one process doing a streaming write (eg an ftp download),
it seems we'll get into trouble. If we change the thresholds from 40% to
20%, that just means you need a slightly larger system to trigger it,
it never fixes the problem ;-(

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
