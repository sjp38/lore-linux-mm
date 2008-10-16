From: Bodo Eggert <7eggert@gmx.de>
Subject: Re: no way to swapoff a deleted swap file?
Reply-To: 7eggert@gmx.de
Date: Fri, 17 Oct 2008 01:43:15 +0200
References: <bnlDw-5vQ-7@gated-at.bofh.it> <bnwpg-2EA-17@gated-at.bofh.it> <bnJFK-3bu-7@gated-at.bofh.it>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
Message-Id: <E1KqcUt-0003vU-ES@be1.7eggert.dyndns.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <peterz@infradead.org>, Peter Cordes <peter@cordes.ca>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> wrote:
> On Thu, 16 Oct 2008, Peter Zijlstra wrote:
>> On Wed, 2008-10-15 at 17:21 -0300, Peter Cordes wrote:

>> > I unlinked a swapfile without realizing I was still swapping on it.
>> > Now my /proc/swaps looks like this:
>> > Filename                                Type            Size    Used
>> > Priority
>> > /var/tmp/EXP/cache/swap/1\040(deleted)  file            1288644 1448       -1
>> > /var/tmp/EXP/cache/swap/2\040(deleted)  file            1433368 0  -2

>> >  If kswapd0 had a fd open on the swap files, swapoff /proc/$PID/fd/3
>> > could possibly work.  But it looks like the files are open but with no
>> > user-space accessable file descriptors to them.  Which makes sense,
>> > except for this case.
>> 
>> Right, except that kswapd is per node, so we'd either have to add it to
>> all kswapd instances or a random one. Also, kthreads don't seem to have
>> a files table afaict.
>> 
>> But yes, I see your problem and it makes sense to look for a nice
>> solution.
> 
> No immediate answer springs to my mind.
> 
> It's not something I'd want to add a new system call for.
> I guess we could put a magic file for each swap area
> somewhere down in /sys, and allow swapoff to act upon that.

I think the original idea of something like /proc/$PID/fd/ is not too bad.
I don't know if it's possible to have the same mechanism in sysfs. I guess
not, but with the rest of the vm knobs being in /proc, I would not be too sad.

Maybe it's possible to clone(CLONE_FILES) the kswapds. This would allow to
have /proc/sys/vm/swapfiles point to one of the correct /proc/$kwapd/fd/.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
