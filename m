Message-ID: <386160CC.9F36DCE6@idiom.com>
Date: Thu, 23 Dec 1999 02:37:48 +0300
From: Hans Reiser <reiser@idiom.com>
MIME-Version: 1.0
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3?
References: <14430.51369.57387.224846@dukat.scot.redhat.com>
		<Pine.LNX.4.21.9912211056520.24670-100000@Fibonacci.suse.de> <14431.32449.832594.222614@dukat.scot.redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:

> Hi,
>
> On Tue, 21 Dec 1999 11:18:03 +0100 (CET), Andrea Arcangeli
> <andrea@suse.de> said:
>
> > On Tue, 21 Dec 1999, Stephen C. Tweedie wrote:
> >> refile_buffer() checks in buffer.c.  Ideally there should be a
> >> system-wide upper bound on dirty data: if each different filesystem
> >> starts to throttle writes at 50% of physical memory then you only
> >> need two different filesystems to overcommit your memory badly.
>
> > If all FSes shares the dirty list of buffer.c that's not true.

Stephen's global counter really would make things simpler to code.  I would also
like to see each filesystem able to specify a minimum amount it wants reserved
as clean pages, and have a global minimum that is the sum of all of these
amounts for all mounted filesystems.

>
>
> The entire point of this is that Linus has refused, point blank, to
> add the complexity of journaling to the buffer cache.  The journaling
> _has_ to be done independently, so we _have_ to have the dirty data
> for journal transactions kept outside of the buffer cache.
>
> We cannot use the buffer.c dirty list anyway because bdflush can write
> those buffers to disk at any time.  Transactions have to control the
> write ordering so we can only feed those writes into the buffer queues
> under strict control when we go to commit a transaction.
>
> > All normal filesystems are using the mark_buffer_dirty() in buffer.c
>
> We're not talking about normal filesystems. :)
>
> > so currently the 40% setting of bdflush is a system-wide number and
> > not a per-fs number.
>
> For filesystems that can use that mechanism, sure.  We need to be able
> to extend that mechanism so that filesystems with other writeback
> mechanisms can use it too.
>
> > If both ext3 and reiserfs are using refile_buffer and both are using
> > balance_dirty in the right places as Linus wants, all seems just fine to
> > me.
>
> They aren't and they can't.
>
> > I completly agree to change mark_buffer_dirty() to call balance_dirty()
> > before returning.
>
> Agreed.

How can we use a mark_buffer_dirty that calls balance_dirty in a place where we
cannot call balance_dirty?

>
>
> --Stephen

--
Get Linux (http://www.kernel.org) plus ReiserFS
 (http://devlinux.org/namesys).  If you sell an OS or
internet appliance, buy a port of ReiserFS!  If you
need customizations and industrial grade support, we sell them.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
