Date: Fri, 16 Nov 2007 14:46:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: page_referenced() and VM_LOCKED
Message-Id: <20071116144641.f12fd610.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <473D1BC9.8050904@google.com>
References: <473D1BC9.8050904@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Nov 2007 20:25:45 -0800
Ethan Solomita <solo@google.com> wrote:

> page_referenced_file() checks for the vma to be VM_LOCKED|VM_MAYSHARE
> and adds returns 1. We don't do the same in page_referenced_anon(). I
> would've thought the point was to treat locked pages as active, never
> pushing them into the inactive list, but since that's not quite what's
> happening I was hoping someone could give me a clue.
> 
> 	Thanks,
> 	-- Ethan
Hmm,

== vmscan.c::shrink_page_list()

   page_referenced()  if returns 1 ->  link to active list
   
   add to swap  # only works if anon

   try_to_unmap()    if VM_LOCKED -> SWAP_FAIL -> link to active list

==

Then, "VM_LOCKED & not referenced" anon page is added to swap cache
(before pushed back to active list)

Seems intended ?

Thanks,
- Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
