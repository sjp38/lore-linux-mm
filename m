Date: Tue, 6 Feb 2007 00:28:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 3/3] mm: make read_cache_page synchronous
Message-Id: <20070206002839.f02a47bc.akpm@linux-foundation.org>
In-Reply-To: <20070206054957.21042.18724.sendpatchset@linux.site>
References: <20070206054925.21042.50546.sendpatchset@linux.site>
	<20070206054957.21042.18724.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue,  6 Feb 2007 09:02:33 +0100 (CET) Nick Piggin <npiggin@suse.de> wrote:

> Ensure pages are uptodate after returning from read_cache_page, which allows
> us to cut out most of the filesystem-internal PageUptodate_NoLock calls.

Normally it's good to rename functions when we change their behaviour, but
I guess any missed (or out-of-tree) filesystems will just end up doing a
pointless wait_on_page_locked() and will continue to work OK, yes?

> I didn't have a great look down the call chains, but this appears to fixes 7
> possible use-before uptodate in hfs, 2 in hfsplus, 1 in jfs, a few in ecryptfs,
> 1 in jffs2, and a possible cleared data overwritten with readpage in block2mtd.
> All depending on whether the filler is async and/or can return with a !uptodate
> page.
> 
> Also, a memory leak in sys_swapon().

Separate patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
