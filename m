Message-ID: <42EE0021.3010208@yahoo.com.au>
Date: Mon, 01 Aug 2005 20:57:37 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
References: <20050801032258.A465C180EC0@magilla.sf.frob.com> <42EDDB82.1040900@yahoo.com.au> <20050801091956.GA3950@elte.hu> <42EDEAFE.1090600@yahoo.com.au> <20050801101547.GA5016@elte.hu>
In-Reply-To: <20050801101547.GA5016@elte.hu>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, Roland McGrath <roland@redhat.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:

> 
> Hugh's posting said:
> 
>  "it's trying to avoid an endless loop of finding the pte not writable 
>   when ptrace is modifying a page which the user is currently protected 
>   against writing to (setting a breakpoint in readonly text, perhaps?)"
> 
> i'm wondering, why should that case generate an infinite fault? The 
> first write access should copy the shared-library page into a private 
> page and map it into the task's MM, writable. If this make-writable 

It will be mapped readonly.

> operation races with a read access then we return a minor fault and the 
> page is still readonly, but retrying the write should then break up the 
> COW protection and generate a writable page, and a subsequent 
> follow_page() success. If the page cannot be made writable, shouldnt the 
> vma flags reflect this fact by not having the VM_MAYWRITE flag, and 
> hence get_user_pages() should have returned with -EFAULT earlier?
> 

If it cannot be written to, then yes. If it can be written to
but is mapped readonly then you have the problem.

Aside, that brings up an interesting question - why should readonly
mappings of writeable files (with VM_MAYWRITE set) disallow ptrace
write access while readonly mappings of readonly files not? Or am I
horribly confused?

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
