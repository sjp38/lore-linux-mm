Received: from alogconduit1ah.ccr.net (ccr@alogconduit1af.ccr.net [208.130.159.6])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA15199
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 13:34:08 -0400
Subject: Re: [patch] arca-vm-2.2.5
References: <Pine.BSF.4.03.9904060124390.12767-100000@funky.monkey.org>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 06 Apr 1999 11:19:58 -0500
In-Reply-To: Chuck Lever's message of "Tue, 6 Apr 1999 01:52:55 -0400 (EDT)"
Message-ID: <m11zhxyb4h.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Chuck Lever <cel@monkey.org>
Cc: Andrea Arcangeli <andrea@e-mind.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "CL" == Chuck Lever <cel@monkey.org> writes:

CL> On Tue, 6 Apr 1999, Andrea Arcangeli wrote:
>> Cool! ;)) But could you tell me _how_ do you design an hash function? Are
>> you doing math or do you use instinct?

CL> math.  i'll post something about this soon.
 
>> >but also the page hash function uses the hash table size as a shift value
>> >when computing the index, so it may combine the interesting bits in a
>> >different (worse) way when you change the hash table size.  i'm planning
>> >to instrument the page hash to see exactly what's going on.
>> 
>> Agreed. This is true. I thought about that and I am resizing the hash
>> table size to the original 11 bit now (since you are confirming that I
>> broken the hash function).

CL> i looked at doug's patch too, and it changes the "page_shift" value
CL> depending on the size of the hash table.  again, this *may* cause unwanted
CL> interactions making the hash function degenerate for certain table sizes.
CL> but i'd like to instrument the hash to watch what really happens.


CL> i ran some simple benchmarks on our 4-way Xeon PowerEdge to see what are
CL> the effects of your patches.  here were the original patches against
CL> 2.2.5.

CL> the page struct alignment patch:

>> --- linux/include/linux/mm.h	Tue Mar  9 01:55:28 1999
>> +++ mm.h	Tue Apr  6 02:00:22 1999
>> @@ -131,0 +133,6 @@
>> +#ifdef __SMP__
>> +	/* cacheline alignment */
>> +	char dummy[(sizeof(void *) * 7 +
>> +		    sizeof(unsigned long) * 2 +
>> +		    sizeof(atomic_t)) % L1_CACHE_BYTES];
>> +#endif

Am I the only one to notice that this little bit of code is totally wrong.
It happens to get it right for cache sizes of 16 & 32 with the current struct
page but the code is 100% backwords.

Eric


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
