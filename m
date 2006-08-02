Message-ID: <44CFEF7F.1070209@yahoo.com.au>
Date: Wed, 02 Aug 2006 10:19:11 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch][rfc] possible lock_page fix for Andrea's nopage vs invalidate
 race?
References: <44CF3CB7.7030009@yahoo.com.au> <20060801142749.GC6455@opteron.random>
In-Reply-To: <20060801142749.GC6455@opteron.random>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Tue, Aug 01, 2006 at 09:36:23PM +1000, Nick Piggin wrote:

>>I suppose we should think about fixing it some day?
> 
> 
> I was thinking about this every few days too, but I already submitted
> two fixes and I got somewhat contradictory reviews of them, so I
> wasn't sure what to do given that for mainline it's mostly a DoS
> because the VM lacks the proper bugchecks in the objrmap layer to
> autodetect the leak (the bugchecks I'm talking about only exists only
> in the sles9 VM, Hugh removed them while merging objrmap into
> mainline, and the fact they existed in sles9 is why we noticed and
> tracked down this leak). We already fixed the bug in sles9 a while ago
> with my second fix, but I obviously agree we have to fix it in
> mainline as well some day too, infact I wouldn't mind to add the
> bugchecks too to be sure something like this doesn't go unnoticed
> again (especially now that in sles10 we're in VM sync with mainline).

Well, I don't think it would be out of the question to add bug checks
for obscure conditions if they might have actually detected bugs for
us. It is common to see bug fixes also adding a BUG_ON to ensure similar
problems or future regressions are noticed. I can't remember Hugh's
reason for not wanting the check there, though.

> 
> I really appreciate this third way being implemented. It looks quite
> nice. Great work.

Thanks, glad you like it :)

Hugh did mention a 2% slowdown in lmbench tests due to the lock page
(but maybe that was before removing the truncate_count stuff?). That
isn't good, but it actually seems to speed up kbuild (which is very
do_no_page intensive). I didn't get enough samples to be statistically
significant, but it looks like 1s speedup on shmfs, and 3/4s on ext3.

So if the lmbench slowdown is still there, I think kbuild trumps it.
However, my testing is just on a P4, so it would be good to check a
wider range of architectures too. I'll spend a bit of time with that
when I get a chance.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
