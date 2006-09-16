Message-ID: <450BAAF4.1080509@yahoo.com.au>
Date: Sat, 16 Sep 2006 17:42:44 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] PAGE_RW Should be added to PAGE_COPY ?
References: <20060915033842.C205FFB045@ncic.ac.cn> <Pine.LNX.4.64.0609150514190.7397@blonde.wat.veritas.com> <Pine.LNX.4.64.0609151431320.22674@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0609151431320.22674@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Yingchao Zhou <yc_zhou@ncic.ac.cn>, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@osdl.org>, alan <alan@redhat.com>, zxc <zxc@ncic.ac.cn>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

(adding linux-mm)

Hugh Dickins wrote:

>>but for the app to use a shared mapping instead of a private.
> 
> 
> But that suggestion wasn't helpful: you'd much prefer not to
> restrict what areas of userspace are used in this way.
> 
> The problem, as I now see it, is precisely with do_wp_page()'s
> TestSetPageLocked, as you first said.  There is indeed a small
> but real chance that will fail.  At some time in the past I did
> realize that, but pushed it to the back of my mind, waiting for
> someone actually to complain: now you have.
> 
> Yes, it would be good if we could do that check in some other,
> reliable way.  The problem is that can_share_swap_page has to
> check page_mapcount (and PageSwapCache) and page_swapcount in
> an atomic way: the page lock is what we have used to guard the
> movement between mapcount and swapcount.
> 
> I'll try to think whether we can do that better,
> but not until next week.

I don't think TestSetPageLocked is the problem. Indeed you may be
able to get around a few specific cases say, by turning that into
a plain lock_page()... but the problem is still fundamentally COW.

In other words, one should always be able to return 0 from that
can_share_swap_page and have the system continue to work... right?
Because even if you hadn't done that mprotect trick, you may still
have a problem because the page may *have* to be copied on write
if it is shared over fork.

So if we filled in the missing mm/ implementation of VM_DONTCOPY
(and call it MAP_DONTCOPY rather than the confusing MAP_DONTFORK)
such that it withstands such an mprotect sequence, we can then ask
that all userspace drivers do their get_user_pages memory on these
types of vmas.

Would that work?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
