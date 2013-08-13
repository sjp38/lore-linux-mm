Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 1F3E36B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 13:33:55 -0400 (EDT)
Message-ID: <520A6DFC.1070201@sgi.com>
Date: Tue, 13 Aug 2013 10:33:48 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [RFC v3 0/5] Transparent on-demand struct page initialization
 embedded in the buddy allocator
References: <1375465467-40488-1-git-send-email-nzimmer@sgi.com> <1376344480-156708-1-git-send-email-nzimmer@sgi.com> <CA+55aFwTQLexJkf67P0b7Z7cw8fePjdDSdA4SOkM+Jf+kBPYEA@mail.gmail.com>
In-Reply-To: <CA+55aFwTQLexJkf67P0b7Z7cw8fePjdDSdA4SOkM+Jf+kBPYEA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Robin Holt <holt@sgi.com>, Rob Landley <rob@landley.net>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>



On 8/13/2013 10:09 AM, Linus Torvalds wrote:
> On Mon, Aug 12, 2013 at 2:54 PM, Nathan Zimmer <nzimmer@sgi.com> wrote:
>>
>> As far as extra overhead. We incur an extra function call to
>> ensure_page_is_initialized but that is only really expensive when we find
>> uninitialized pages, otherwise it is a flag check once every PTRS_PER_PMD.
>> To get a better feel for this we ran two quick tests.
> 
> Sorry for coming into this late and for this last version of the
> patch, but I have to say that I'd *much* rather see this delayed
> initialization using another data structure than hooking into the
> basic page allocation ones..
> 
> I understand that you want to do delayed initialization on some TB+
> memory machines, but what I don't understand is why it has to be done
> when the pages have already been added to the memory management free
> list.
> 
> Could we not do this much simpler: make the early boot insert the
> first few gigs of memory (initialized) synchronously into the free
> lists, and then have a background thread that goes through the rest?
> 
> That way the MM layer would never see the uninitialized pages.
> 
> And I bet that *nobody* cares if you "only" have a few gigs of ram
> during the first few minutes of boot, and you mysteriously end up
> getting more and more memory for a while until all the RAM has been
> initialized.
> 
> IOW, just don't call __free_pages_bootmem() on all the pages al at
> once. If we have to remove a few __init markers to be able to do some
> of it later, does anybody really care?
> 
> I really really dislike this "let's check if memory is initialized at
> runtime" approach.
> 
>            Linus
> 

Initially this patch set consisted of diverting a major portion of the
memory to an "absent" list during e820 processing.  A very late initcall
was then used to dispatch a cpu per node to add that nodes's absent
memory.  By nature these ran in parallel so Nathan did the work to
"parallelize" various global resource locks to become per node locks.

This sped up insertion considerably.  And by disabling the "auto-start"
of the insertion process and using a manual start command, you could
monitor the insertion process and find hot spots in the memory
initialization code.

Also small updates to the sys/devices/{memory,node} drivers to also
display the amount of memory still "absent".

-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
