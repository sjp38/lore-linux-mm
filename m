Date: Tue, 21 Mar 2000 16:55:32 +0100
From: Jamie Lokier <jamie.lokier@cern.ch>
Subject: Re: Extensions to mincore
Message-ID: <20000321165532.A5461@pcep-jamie.cern.ch>
References: <20000320135939.A3390@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003201318050.23474-100000@funky.monkey.org> <20000321024731.C4271@pcep-jamie.cern.ch> <m1puso1ydn.fsf@flinx.hidden> <20000321113448.A6991@dukat.scot.redhat.com> <20000321161507.D5291@pcep-jamie.cern.ch> <20000321154117.A8113@dukat.scot.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000321154117.A8113@dukat.scot.redhat.com>; from Stephen C. Tweedie on Tue, Mar 21, 2000 at 03:41:17PM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@scot.redhat.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Chuck Lever <cel@monkey.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
> > You're right, that for GC the "!dirty" bit has to mean "since the last
> > time we called mincore".
> 
> And that information is not maintained anywhere.  In fact, it basically
> _can't_ be maintained, since the hardware only maintains one bit and
> we already use that dirty bit.  The only way round this is to use
> mprotect-style munging.

Didn't you read a few paragraphs down, where I explain how to implement
this?  You've got struct page.  It is enough for private mappings, and
we don't need this feature for shared mappings.

> > All threads sharing a page have to synchronise their mincore calls for
> > that page, but that situation is no different to the SEGV method: all
> > threads have to synchronise with the information collected from that,
> > too.
> 
> It's not about synchronising between mincore calls, it's about 
> synchronising mincore calls on one CPU with direct memory references
> modifying page tables on another CPU.

Note, for both GC synchronisation methods I described, the mincore()
call does not happen concurrently with other processors updating the
page flags.  In the first case all threads accessing the GC arena are
blocked, and in the second the entire area is write-protected during the
mincore() call.

So the synchronisation you say isn't possible isn't a required feature.
(I know it's quite easy on x86, but probably not some other CPUs).

It would be enough the say "the mincore accessed/dirty bits are not
guaranteed to be accurate if pages are accessed by concurrent threads
during the mincore call".

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
