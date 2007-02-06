Message-ID: <45C842A0.8010804@yahoo.com.au>
Date: Tue, 06 Feb 2007 19:56:00 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 3/3] mm: make read_cache_page synchronous
References: <20070206054925.21042.50546.sendpatchset@linux.site>	<20070206054957.21042.18724.sendpatchset@linux.site> <20070206002839.f02a47bc.akpm@linux-foundation.org>
In-Reply-To: <20070206002839.f02a47bc.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Tue,  6 Feb 2007 09:02:33 +0100 (CET) Nick Piggin <npiggin@suse.de> wrote:
> 
> 
>>Ensure pages are uptodate after returning from read_cache_page, which allows
>>us to cut out most of the filesystem-internal PageUptodate_NoLock calls.
> 
> 
> Normally it's good to rename functions when we change their behaviour, but
> I guess any missed (or out-of-tree) filesystems will just end up doing a
> pointless wait_on_page_locked() and will continue to work OK, yes?

Yeah.

> 
> 
>>I didn't have a great look down the call chains, but this appears to fixes 7
>>possible use-before uptodate in hfs, 2 in hfsplus, 1 in jfs, a few in ecryptfs,
>>1 in jffs2, and a possible cleared data overwritten with readpage in block2mtd.
>>All depending on whether the filler is async and/or can return with a !uptodate
>>page.
>>
>>Also, a memory leak in sys_swapon().
> 
> 
> Separate patch?

Well its fixed by virtue of read_cache_page now correctly dropping the page
refcount if it finds the page !uptodate, rather than any special logic I
added.

I can do another patch though. No problem, I'll be resending the series after
this round of feedback.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
