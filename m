Received: from alogconduit1ah.ccr.net (ccr@alogconduit1ag.ccr.net [208.130.159.7])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA17248
	for <linux-mm@kvack.org>; Fri, 9 Apr 1999 04:33:55 -0400
Subject: Re: [patch] arca-vm-2.2.5
References: <199904062253.PAA12352@piglet.twiddle.net> <Pine.HPP.3.96.990407174343.13413D-100000@gra-ux1.iram.es> <19990407170743.A22786@anjala.mit.edu>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 09 Apr 1999 01:58:42 -0500
In-Reply-To: Arvind Sankar's message of "Wed, 7 Apr 1999 17:07:43 -0400"
Message-ID: <m1n20iwa8t.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Arvind Sankar <arvinds@MIT.EDU>
Cc: Gabriel Paubert <paubert@iram.es>, davem@redhat.com, mingo@chiara.csoma.elte.hu, sct@redhat.com, andrea@e-mind.com, cel@monkey.org, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "AS" == Arvind Sankar <arvinds@MIT.EDU> writes:

AS> On Wed, Apr 07, 1999 at 05:59:04PM +0200, Gabriel Paubert wrote:
>> 
>> 
>> On Tue, 6 Apr 1999, David Miller wrote:
>> 
>> >    Date: Wed, 7 Apr 1999 00:49:18 +0200 (CEST)
>> >    From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
>> > 
>> >    It should be 'inode >> 8' (which is done by the log2
>> >    solution). Unless i'm misunderstanding something.
>> > 
>> > Consider that:
>> > 
>> > (((unsigned long) inode) >> (sizeof(struct inode) & ~ (sizeof(struct inode) - 1)))
>> > 
>> > sort of approximates this and avoids the funny looking log2 macro. :-)
>> 
>> May I disagree ? Compute this expression in the case sizeof(struct inode) 
>> is a large power of 2. Say 0x100, the shift count becomes (0x100 & ~0xff),
>> or 0x100. Shifts by amounts larger than or equal to the word size are
>> undefined in C AFAIR (and in practice on most architectures which take
>> the shift count modulo some power of 2). 
>> 

AS> typo there, I guess. the >> should be an integer division. Since the divisor is
AS> a constant power of 2, the compiler will optimize it into a shift.

Actually I believe:
#define DIVISOR(x) (x  & ~((x >> 1) | ~(x >> 1)))

(((unsigned long) inode) / DIVISOR(sizeof(struct inode)))

Is the magic formula.

A smart compiler can figure out the shift, and the DIVISOR macro
makes x into a power of two.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
