Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id BFFCB6B0062
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 08:58:03 -0400 (EDT)
Message-ID: <4FD9DFCE.1070609@redhat.com>
Date: Thu, 14 Jun 2012 08:57:50 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: bugs in page colouring code
References: <20120613152936.363396d5@cuia.bos.redhat.com> <20120614103627.GA25940@aftab.osrc.amd.com>
In-Reply-To: <20120614103627.GA25940@aftab.osrc.amd.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@amd64.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sjhill@mips.com, ralf@linux-mips.org, "H. Peter Anvin" <hpa@linux.intel.com>, Rob Herring <rob.herring@calxeda.com>, Russell King <rmk+kernel@arm.linux.org.uk>, Nicolas Pitre <nico@linaro.org>

On 06/14/2012 06:36 AM, Borislav Petkov wrote:
> On Wed, Jun 13, 2012 at 03:29:36PM -0400, Rik van Riel wrote:

>> For one, there are separate kernel boot arguments to control whether
>> 32 and 64 bit processes need to have their addresses aligned for
>> page colouring.
>>
>> Do we really need that?
>
> Yes.

What do we need it for?

I can see wanting a big knob to disable page colouring
globally for both 32 and 64 bit processes, but why do
we need to control it separately?

I am not too keen on x86 keeping a slightly changed
private copy of arch_align_addr :)

> Mind you, this is only enabled on AMD F15h - all other x86 simply can't
> tweak it without code change.
>
>> Would it be a problem if I discarded that code, in order to get to one
>> common cache colouring implementation?
>
> Sorry, but, we'd like to keep it in.

What is it used for?

>> Secondly, MAP_FIXED never checks for page colouring alignment. I
>> assume the cache aliasing on AMD Bulldozer is merely a performance
>> issue, and we can simply ignore page colouring for MAP_FIXED?
>
> Right, AFAICR, MAP_FIXED is not generally used for shared libs (correct
> me if I'm wrong here, my memory is very fuzzy about it) and since we see
> the perf issue with shared libs, this was fine.

Try stracing /bin/mount one of these days. A whole bunch
of libraries are mapped with MAP_FIXED :)

However, I expect that on x86 many applications expect
MAP_FIXED to just work, and enforcing that would be
more trouble than it's worth.

>> That will be easy to get right in an architecture-independent
>> implementation.
>>
>>
>> A third issue is this:
>>
>>          if (!(current->flags&  PF_RANDOMIZE))
>>                  return addr;
>>
>> Do we really want to skip page colouring merely because the
>> application does not have PF_RANDOMIZE set?  What is this
>> conditional supposed to do?
>
> Linus said that without this we are probably breaking old userspace
> which can't stomach ASLR so we had to respect such userspace which
> clears that flag.

I wonder if that is true, since those userspace programs
probably run fine on ARM, MIPS and other architectures...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
