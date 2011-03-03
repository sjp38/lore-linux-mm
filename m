Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3E81C8D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:53:38 -0500 (EST)
Message-ID: <4D6FC6C7.8060001@redhat.com>
Date: Thu, 03 Mar 2011 11:50:15 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Strange minor page fault repeats when SPECjbb2005 is executed
References: <20110303200139.B187.E1E9C6FF@jp.fujitsu.com>
In-Reply-To: <20110303200139.B187.E1E9C6FF@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, Motohiro Kosaki <kosaki.motohiro@jp.fujitsu.com>

On 03/03/2011 06:01 AM, Yasunori Goto wrote:

> In this log, cpu4 and 6 repeat page faults.
> ----
> handle_mm_fault jiffies64=4295160616 cpu=4 address=40019a38 pmdval=0000000070832067 ptehigh=00000000 ptelow=55171067
> handle_mm_fault jiffies64=4295160616 cpu=6 address=40003a38 pmdval=0000000070832067 ptehigh=00000000 ptelow=551ef067
> handle_mm_fault jiffies64=4295160616 cpu=6 address=40003a38 pmdval=0000000070832067 ptehigh=00000000 ptelow=551ef067
> handle_mm_fault jiffies64=4295160616 cpu=4 address=40019a38 pmdval=0000000070832067 ptehigh=00000000 ptelow=55171067
> handle_mm_fault jiffies64=4295160616 cpu=4 address=40019a38 pmdval=0000000070832067 ptehigh=00000000 ptelow=55171067

> I confirmed this phenomenon is reproduced on 2.6.31 and 2.6.38-rc5
> of x86 kernel, and I heard this phenomenon doesn't occur on
> x86-64 kernel from another engineer who found this problem first.
>
> In addition, this phenomenon occurred on 4 boxes, so I think the cause
> is not hardware malfunction.

On what CPU model(s) does this happen?

Obviously the PTE is present and allows read, write and
execute accesses, so the PTE should not cause any faults.

That leaves the TLB. It looks almost like the CPU keeps
re-faulting on a (old?) TLB entry, possibly with wrong
permissions, and does not re-load it from the PTE.

I know this "should not happen" on x86, but I cannot think
of an alternative explanation right now.  Can you try flushing
the TLB entry in question from handle_pte_fault?

It looks like the code already does this for write faults, but
maybe the garbage collection code uses PROT_NONE a lot and is
running into this issue with a read or exec fault?

It would be good to print the fault flags as well in your debug
print, so we know what kind of fault is being repeated...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
