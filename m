Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA16001
	for <linux-mm@kvack.org>; Sun, 29 Nov 1998 11:05:02 -0500
Date: Mon, 30 Nov 1998 11:13:44 GMT
Message-Id: <199811301113.LAA02870@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [2.1.130-3] Page cache DEFINATELY too persistant... feature?
In-Reply-To: <m1ogpsp93f.fsf@flinx.ccr.net>
References: <199811261236.MAA14785@dax.scot.redhat.com>
	<Pine.LNX.3.95.981126094159.5186D-100000@penguin.transmeta.com>
	<199811271602.QAA00642@dax.scot.redhat.com>
	<m1ogpsp93f.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 28 Nov 1998 01:31:00 -0600, ebiederm+eric@ccr.net (Eric W. Biederman)
said:

>>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:
ST> Hi,
ST> Looks like I have a handle on what's wrong with the 2.1.130 vm (in
ST> particular, its tendency to cache too much at the expense of
ST> swapping).

> I really should look and play with this but I have one question.

> Why does it make sense when we want memory, to write every page
> we can to swap before we free any memory?

What makes you think we do?

2.1.130 tries to shrink cache until a shrink_mmap() pass fails.  Then it
gives the swapper a chance, swapping a batch of pages and unlinking them
from the ptes.  The pages so release still stay in the page cache at
this point, btw, and will be picked up again from memory if they get
referenced before the page finally gets discarded.  We then go back to
shrink_mmap(), hopefully with a larger population of recyclable pages as
a result of the swapout, and we start using that again.

We only run one batch of swapouts before returning to shrink_mmap.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
