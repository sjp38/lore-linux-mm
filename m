Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 33CE36B0055
	for <linux-mm@kvack.org>; Sat, 20 Dec 2008 11:00:00 -0500 (EST)
Date: Sat, 20 Dec 2008 17:02:20 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Corruption with O_DIRECT and unaligned user buffers
Message-ID: <20081220160220.GE6383@random.random>
References: <20081119165819.GE19209@random.random> <20081218152952.GW24856@random.random> <20081219151118.A0AC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081219151118.A0AC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Tim LaBerge <tim.laberge@quantum.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello!

On Fri, Dec 19, 2008 at 03:34:20PM +0900, KOSAKI Motohiro wrote:
> I think gup_pte_range() doesn't change pte attribute.
> Could you explain why get_user_pages_fast() is evil?

It's evil because it was assumed that by just relying on the
local_irq_disable() to prevent the smp tlb flush IPI to run, it'd be
enough to simulate a 'current' pagetable walk that allowed the current
task to run entirely lockless.

Problem is that by being totally lockless it prevents us to know if a
page is under direct-io or not. And if a page is under direct IO with
writing to memory (reading from memory we cannot care less, it's
always ok) we can't merge pages in ksm or we can't mark the pte
readonly in fork etc... If we do things break. The entirely lockless
(but atomic) pagetable walk done by the cpu is different from gup_fast
because the one done by the cpu will never end up writing to the page
through the pci bus in DMA, so the moment the IPI runs whatever I/O is
interrupted (not the case for gup_fast, when gup_fast returns and the
IPI runs and page is then available for sharing to ksm or pte marked
readonly, the direct DMA is still in flight). That's why gup_fast
*can't* be 100% lockless as today, otherwise it's unfixable and broken
and it's not just ksm. This very O_DIRECT bug in fork is 100%
unfixable without adding some serialization to gup_fast. So my patch
fixes it fully only for kernels before the introduction of gup_fast...

My suggestion is to reintroduced the big reader lock (br_lock) of
2.4 and have gup_fast take the read side of it, and fork/ksm take the
write side. It must no be a write-starving lock like the 2.4 one
though or fork would hang forever on large smp. It should be still
faster than get_user_pages.

> Why rhel can't use memory barrier?

Oh it can, just I didn't implemented immediately as I wanted to ship a
simpler patch first, but given the 27% slowdown measured in later
email, I'll definitely have to replace the TestSetPageLocked with
smb_rmb and see if the introduced overhead goes away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
