Date: Fri, 6 Sep 2002 10:44:05 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Rough cut at shared page tables
Message-ID: <20020906174405.GU18800@holomorphy.com>
References: <61920000.1031332808@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <61920000.1031332808@baldur.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 06, 2002 at 12:20:08PM -0500, Dave McCracken wrote:
> Here's my initial coding of shared page tables.  It sets the pmd read-only,
> so it forks really fast, then unshares it as necessary.  I've tried to keep
> the sharing semantics clean so if/when we add pte sharing for shared files
> the existing code should handle it just fine.

Hmm, do non-i386 arches need to be taught about read-only pmd's?


On Fri, Sep 06, 2002 at 12:20:08PM -0500, Dave McCracken wrote:
> The few feeble attempts I've made at putting in locks are clearly wrong, so
> it only works on UP.

AFAICT one significant source of trouble is that pmd's, once
instantiated, are considered immutable until the process is torn down.
Numerous VM codepaths drop all locks but a readlock on the mm->mmap_sem
while holding a reference to a pmd and expect it to remain valid.

The same issue arises during pagetable reclaim and pmd-based large page
manipulations.


On Fri, Sep 06, 2002 at 12:20:08PM -0500, Dave McCracken wrote:
> I don't see any reason why swap won't work, but I haven't tested it.
> This is also against 2.5.29.  I'm gonna work to merge it forward, but there
> are significant changes since then so I figured I'd toss this out for
> people to get an early look at it.

The swap strategy is interesting. I had originally imagined that a
reference object would be required. But I'm not sure quite how RSS
accounting for processes affected by a swap operation happens here.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
