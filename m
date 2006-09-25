Message-ID: <451744A9.7050405@yahoo.com.au>
Date: Mon, 25 Sep 2006 12:53:29 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] PAGE_RW Should be added to PAGE_COPY ?
References: <20060915033842.C205FFB045@ncic.ac.cn> <Pine.LNX.4.64.0609150514190.7397@blonde.wat.veritas.com> <Pine.LNX.4.64.0609151431320.22674@blonde.wat.veritas.com> <450BAAF4.1080509@yahoo.com.au> <Pine.LNX.4.64.0609231835570.32262@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0609231835570.32262@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Yingchao Zhou <yc_zhou@ncic.ac.cn>, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@osdl.org>, alan <alan@redhat.com>, zxc <zxc@ncic.ac.cn>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:

>On Sat, 16 Sep 2006, Nick Piggin wrote:
>
>>... but the problem is still fundamentally COW.
>>
>
>Well, yes, we wouldn't have all these problems if we didn't have
>to respect COW.  But generally a process can, one way or another,
>make sure it won't get into those problems: Yingchao is concerned
>with the way the TestSetPageLocked unpredictably upsets correctness.
>I'd say it's a more serious error than the general problems with COW.
>

But correctness is no more upset here than with any other reason that
the page gets COWed.

>>In other words, one should always be able to return 0 from that
>>can_share_swap_page and have the system continue to work... right?
>>Because even if you hadn't done that mprotect trick, you may still
>>have a problem because the page may *have* to be copied on write
>>if it is shared over fork.
>>
>
>Most processes won't fork, and exec has freed them from sharing
>their parents pages, and their private file mappings aren't being
>used as buffers.  Maybe Yingchao will later have to worry about
>those cases, but for now it seems not.
>

So we should still solve it for once and for all just by turning off
COW completely.

>>So if we filled in the missing mm/ implementation of VM_DONTCOPY
>>(and call it MAP_DONTCOPY rather than the confusing MAP_DONTFORK)
>>such that it withstands such an mprotect sequence, we can then ask
>>that all userspace drivers do their get_user_pages memory on these
>>types of vmas.
>>
>
>(madvise MADV_DONTFORK)
>
>For the longest time I couldn't understand you there at all, perhaps
>distracted by your parenthetical line: at last I think you're proposing
>we tweak mprotect to behave differently on a VM_DONTCOPY area.
>
>But differently in what way?  Allow it to ignore Copy-On-Write?
>

Well I think that we should have a flag that just prevents copy
on write from ever happening. Maybe that would mean it be easiest
to implement in mmap rather than as madvise, but that should be
OK.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
