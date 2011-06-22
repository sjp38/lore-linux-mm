Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B858C900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 16:19:05 -0400 (EDT)
Message-ID: <4E024E31.50901@kpanic.de>
Date: Wed, 22 Jun 2011 22:18:57 +0200
From: Stefan Assmann <sassmann@kpanic.de>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de> <20110622110034.89ee399c.akpm@linux-foundation.org>
In-Reply-To: <20110622110034.89ee399c.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, rdunlap@xenotime.net, Nancy Yuen <yuenn@google.com>, Michael Ditto <mditto@google.com>

On 22.06.2011 20:00, Andrew Morton wrote:
> On Wed, 22 Jun 2011 13:18:51 +0200 Stefan Assmann <sassmann@kpanic.de> wrote:
> 

[...]

>> The idea is to allow the user to specify RAM addresses that shouldn't be
>> touched by the OS, because they are broken in some way. Not all machines have
>> hardware support for hwpoison, ECC RAM, etc, so here's a solution that allows to
>> use bitmasks to mask address patterns with the new "badram" kernel command line
>> parameter.
>> Memtest86 has an option to generate these patterns since v2.3 so the only thing
>> for the user to do should be:
>> - run Memtest86
>> - note down the pattern
>> - add badram=<pattern> to the kernel command line
>>
>> The concerning pages are then marked with the hwpoison flag and thus won't be
>> used by the memory managment system.
> 
> The google kernel has a similar capability.  I asked Nancy to comment
> on these patches and she said:

This is the first time I hear about this feature from Google. If I had
known about it I sure would have talked to the person responsible.

> 
> : One, the bad addresses are passed via the kernel command line, which
> : has a limited length.  It's okay if the addresses can be fit into a
> : pattern, but that's not necessarily the case in the google kernel.  And
> : even with patterns, the limit on the command line length limits the
> : number of patterns that user can specify.  Instead we use lilo to pass
> : a file containing the bad pages in e820 format to the kernel.

I see no reason why there couldn't be multiple ways of specifying bad
addresses.

> : 
> : Second, the BadRAM patch expands the address patterns from the command
> : line into individual entries in the kernel's e820 table.  The e820
> : table is a fixed buffer that supports a very small, hard coded number
> : of entries (128).  We require a much larger number of entries (on
> : the order of a few thousand), so much of the google kernel patch deals
> : with expanding the e820 table. Also, with the BadRAM patch, entries
> : that don't fit in the table are silently dropped and this isn't
> : appropriate for us.

So far the use case I had in mind wasn't "thousands of entries". However
expanding the e820 table is probably an issue that could be dealt with
separately ?

> : 
> : Another caveat of mapping out too much bad memory in general.  If too
> : much memory is removed from low memory, a system may not boot.  We
> : solve this by generating good maps.  Our userspace tools do not map out
> : memory below a certain limit, and it verifies against a system's iomap
> : that only addresses from memory is mapped out.

Well if too much low memory is bad, you're screwed anyway, not? :)

> 
> I have a couple of thoughts here:
> 
> - If this patchset is merged and a major user such as google is
>   unable to use it and has to continue to carry a separate patch then
>   that's a regrettable situation for the upstream kernel.

I'm all ears for making things work out for potential users, I just
didn't know.

> 
> - Google's is, afaik, the largest use case we know of: zillions of
>   machines for a number of years.  And this real-world experience tells
>   us that the badram patchset has shortcomings.  Shortcomings which we
>   can expect other users to experience.
> 
> So.  What are your thoughts on these issues?

I'm aware that the implementation I posted is not covering *everything*.
It's a start and I tried to keep it simple and make use of already
existing infrastructure.
At the moment I don't see any arguments why this patchset couldn't play
along nicely or get enhanced to support what Google needs, but I don't
know Googles patches yet.

Thanks!

  Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
