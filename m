Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A45DF8D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:14:39 -0500 (EST)
Date: Thu, 20 Jan 2011 17:14:36 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [BUG]thp: BUG at mm/huge_memory.c:1350
Message-ID: <20110120161436.GB21494@random.random>
References: <20110120154935.GA1760@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110120154935.GA1760@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello Minchan,

On Fri, Jan 21, 2011 at 12:49:35AM +0900, Minchan Kim wrote:
> Hi Andrea,
> 
> I hit thg BUG 2 time during 5 booting.
> I applied khugepaged: fix pte_unmap for highpte x86_32 based on 2.6.38-rc1.

This is again 32bit which rings a bell because clearly it didn't have
a whole lot of testing (not remotely comparable to the amount of
testing x86-64 had), but it's not necessarily 32bit related. It still
would be worth to know if it still happens after you disable
CONFIG_HIGHMEM (to rule out 32bit issues in not well tested kmaps).

The rmap walk simply didn't find an hugepmd pointing to the page. Or
the mapcount was left pinned after the page got somehow unmapped.

I wonder why pages are added to swap and the system is so low on
memory during boot. How much memory do you have in the 32bit system?
Do you boot with something like mem=256m?  This is also the Xorg
process, which is a bit more special than most and it may have device
drivers attached to the pages.

One critical thing is that split_huge_page must be called when
splitting vmas, see split_huge_page_address and
__vma_adjust_trans_huge, right now it's called from vma_adjust
only. If anything is wrong in that function, or if any place adjusting
the vma is not covered by that function, it may result in exactly the
problem you run into. If drivers are mangling over the vmas that would
also explain it.

If you happen to have crash dump with vmlinux that would be the best
debug option for this, also if you can reproduce it in a VM that will
make it easier to reproduce without your hardware. Otherwise we'll
find another way.

Thanks a lot,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
