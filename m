Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8FA076B0047
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 10:57:52 -0500 (EST)
Message-ID: <4B66F977.5010708@redhat.com>
Date: Mon, 01 Feb 2010 10:55:35 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] remove VM_LOCK_RMAP code
References: <20100128002000.2bf5e365@annuminas.surriel.com> <20100129151423.8b71b88e.akpm@linux-foundation.org> <20100129193410.7ce915d0@annuminas.surriel.com> <20100201061532.GC9085@laptop>
In-Reply-To: <20100201061532.GC9085@laptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, lwoodman@redhat.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On 02/01/2010 01:15 AM, Nick Piggin wrote:
> On Fri, Jan 29, 2010 at 07:34:10PM -0500, Rik van Riel wrote:
>> When a VMA is in an inconsistent state during setup or teardown, the
>> worst that can happen is that the rmap code will not be able to find
>> the page.
>
> OK, but you missed the interesting thing, which is to explain why
> that worst case is not a problem.
>
> rmap of course is not just used for reclaim but also invalidations
> from mappings, and those guys definitely need to know that all
> page table entries have been handled by the time they return.

This is not a problem, because the mapping is in the process
of being torn down (PTEs just got invalidated by munmap), or
set up (no PTEs have been instantiated yet).

The third case is split_vma, where we can have one VMA in an
inconsistent state (rmap cannot find the PTEs), while the
other VMA is still in its original state (rmap finds the PTEs
through that VMA).

That is what makes this safe.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
