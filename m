Message-ID: <42ECB0EC.4000808@yahoo.com.au>
Date: Sun, 31 Jul 2005 21:07:24 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: get_user_pages() with write=1 and force=1 gets read-only pages.
References: <20050730205319.GA1233@lnx-holt.americas.sgi.com> <Pine.LNX.4.61.0507302255390.5143@goblin.wat.veritas.com> <42EC2ED6.2070700@yahoo.com.au> <20050731105234.GA2254@lnx-holt.americas.sgi.com>
In-Reply-To: <20050731105234.GA2254@lnx-holt.americas.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Roland McGrath <roland@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Robin Holt wrote:
> Should there be a check to ensure we don't return VM_FAULT_RACE when the
> pte which was inserted is exactly the same one we would have inserted?

That would slow down the do_xxx_fault fastpaths, though.

Considering VM_FAULT_RACE will only make any difference to get_user_pages
(ie. not the page fault fastpath), and only then in rare cases of a racing
fault on the same pte, I don't think the extra test would be worthwhile.

> Could we generalize that more to the point of only returning VM_FAULT_RACE
> when write access was requested but the racing pte was not writable?
> 

I guess get_user_pages could be changed to retry on VM_FAULT_RACE only if
it is attempting write access... is that worthwhile? I guess so...

> Most of the test cases I have thrown at this have gotten the writer
> faulting first which did not result in problems.  I would hate to slow
> things down if not necessary.  I am unaware of more issues than the one
> I have been tripping.
> 

I think the VM_FAULT_RACE patch as-is should be fairly unintrusive to the
page fault fastpaths. I think weighing down get_user_pages is preferable to
putting logic in the general fault path - though I don't think there should
be too much overhead introduced even there...

Do you think the patch (or at least, the idea) looks like a likely solution
to your problem? Obviously the !i386 architecture specific parts still need
to be filled in...

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
