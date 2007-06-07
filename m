Message-ID: <4667B862.3080809@shadowen.org>
Date: Thu, 07 Jun 2007 08:48:50 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: SLUB: Use ilog2 instead of series of constant comparisons.
References: <Pine.LNX.4.64.0705211250410.27950@schroedinger.engr.sgi.com>	 <20070606100817.7af24b74.akpm@linux-foundation.org>	 <Pine.LNX.4.64.0706061053290.11553@schroedinger.engr.sgi.com>	 <20070606131121.a8f7be78.akpm@linux-foundation.org> <29495f1d0706061329o457d3c97q3a93c4ab2581a1c@mail.gmail.com>
In-Reply-To: <29495f1d0706061329o457d3c97q3a93c4ab2581a1c@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Martin Bligh <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

Nish Aravamudan wrote:
> On 6/6/07, Andrew Morton <akpm@linux-foundation.org> wrote:
>> On Wed, 6 Jun 2007 11:36:07 -0700 (PDT) Christoph Lameter
>> <clameter@sgi.com> wrote:
>>
>> > On Wed, 6 Jun 2007, Andrew Morton wrote:
>> >
>> > > This caused test.kernel.org's power4 build to blow up:
>> > >
>> > > http://test.kernel.org/abat/93315/debug/test.log.0
>> > >
>> > > fs/built-in.o(.text+0x148420): In function
>> `.CalcNTLMv2_partial_mac_key':
>> > > : undefined reference to `.____ilog2_NaN'
>> >
>> > Hmmm... Weird message that does not allow too much analysis.
>> > The __ilog2_NaN comes about if 0 or a negative number is passed to
>> ilog.
>> > There is no way for that to happen since we check for KMALLOC_MIN_SIZE
>> > and KMALLOC_MAX_SIZE in kmalloc_index() and an unsigned value is used.
>> >
>> > There is also nothing special in CalcNTLMv2_partial_mac_key(). Two
>> > kmallocs of 33 bytes and 132 bytes each.
>>
>> Yes, the code all looks OK.  I suspect this is another case of the
>> compiler
>> failing to remove unreachable stuff.
>>
>> > Buggy compiler (too much stress on constant folding)? Or hardware?
>> Can we
>> > rerun the test?
>>
>> It happened multiple times:
>> http://test.kernel.org/functional/pSeries-101_2.html
>>
>> I'm sure there's a way of extracting the compiler version out of
>> test.kernel.org but I can't see it there.  Andy, maybe we should toss
>> a gcc
>> --version in there or something?
> 
> I went and looked at one of the GOOD jobs and acc'g to that, the gcc is
> 
> gcc version 3.3.3 (SuSE Linux)
> 
> (http://test.kernel.org/abat/93029/summary)
> 
> I agree, seems like it would be handy to spit that out somewhere nicer
> and easier to get to. Maybe the machine links at the top should point
> to a summary page which has a link to the .config, machine info, etc?
> (more indirection, but may be ok).

They probably should be replicated with the job as the machine may
change compiler at some time in its life.  If for no other reason that
there should be a break in the kernbench graph if it does ... :)

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
