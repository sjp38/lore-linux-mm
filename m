From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14431.32449.832594.222614@dukat.scot.redhat.com>
Date: Tue, 21 Dec 1999 13:21:05 +0000 (GMT)
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3?
In-Reply-To: <Pine.LNX.4.21.9912211056520.24670-100000@Fibonacci.suse.de>
References: <14430.51369.57387.224846@dukat.scot.redhat.com>
	<Pine.LNX.4.21.9912211056520.24670-100000@Fibonacci.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 21 Dec 1999 11:18:03 +0100 (CET), Andrea Arcangeli
<andrea@suse.de> said:

> On Tue, 21 Dec 1999, Stephen C. Tweedie wrote:
>> refile_buffer() checks in buffer.c.  Ideally there should be a
>> system-wide upper bound on dirty data: if each different filesystem
>> starts to throttle writes at 50% of physical memory then you only
>> need two different filesystems to overcommit your memory badly.

> If all FSes shares the dirty list of buffer.c that's not true. 

The entire point of this is that Linus has refused, point blank, to
add the complexity of journaling to the buffer cache.  The journaling
_has_ to be done independently, so we _have_ to have the dirty data
for journal transactions kept outside of the buffer cache.

We cannot use the buffer.c dirty list anyway because bdflush can write
those buffers to disk at any time.  Transactions have to control the
write ordering so we can only feed those writes into the buffer queues
under strict control when we go to commit a transaction.  

> All normal filesystems are using the mark_buffer_dirty() in buffer.c

We're not talking about normal filesystems. :)

> so currently the 40% setting of bdflush is a system-wide number and
> not a per-fs number.

For filesystems that can use that mechanism, sure.  We need to be able
to extend that mechanism so that filesystems with other writeback
mechanisms can use it too.

> If both ext3 and reiserfs are using refile_buffer and both are using
> balance_dirty in the right places as Linus wants, all seems just fine to
> me.

They aren't and they can't.

> I completly agree to change mark_buffer_dirty() to call balance_dirty()
> before returning. 

Agreed.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
