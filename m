Message-ID: <447FAD6F.8010306@yahoo.com.au>
Date: Fri, 02 Jun 2006 13:15:59 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: ECC error correction - page isolation
References: <069061BE1B26524C85EC01E0F5CC3CC30163E1F1@rigel.headquarters.spacedev.com> <200606020146.33703.ak@suse.de> <447F94B3.7030807@yahoo.com.au> <200606020510.49877.ak@suse.de>
In-Reply-To: <200606020510.49877.ak@suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Brian Lindahl <Brian.Lindahl@spacedev.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
>>Good summary. I'll just add a couple of things: in recent kernels
>>we have a page migration facility which should be able to take care
>>of moving process and pagecache pages for you, without walking rmap
>>or killing the process (assuming you're talking about correctable
>>ECC errors).
> 
> 
> I think he means uncorrected errors. Correctable errors can be fixed up
> by a scrubber without anything else noticing.

Oh you're probably right.

> 
> Ok if your system doesn't support getting rid of them without an atomic
> operation you might need to "stop the world" on MP, but that's relatively
> easy using stop_machine().
> 
> 
>>This may not quite have the right in-kernel API for you use yet, but
>>it shouldn't be difficult to add.
>>
>>
>>>If it's kernel space there are several cases:
>>>- Free page (count == 0). Easy: ignore it.
>>
>>Also, if you want to isolate the free page, you can allocate it,
>>and tuck it away in a list somewhere (or just forget about it
>>completely).
> 
> 
> Normally it's rare that a bit breaks completely. Usually they just toggle
> for some reason and are ok again if you rewrite them (how to do the rewrite without
> triggering an MCE can be tricky BTW). Or the glitch wasn't in the RAM transistors
> itself, but on some bus, then it might also be ok again on retry. 
> 
> What more often happens is that a DIMM (or rather a chip on a DIMM) breaks 
> completely. In this case you need to remove the whole chip. This
> can be often done in hardware using "chipkill" (which is kind a special
> case of hardware RAM RAID).
> 
> Anyways you usually need to remove a large memory area, much bigger than a page, 
> in this case  and it's more like memory hot unplug (which we don't quite 
> support yet, but it's being worked on ...) 
> 
> Of course that's all for normal systems. If you're in a space craft (as I 
> gather from the original poster's domain name) 
> crossing the Van Allen belts or doing a solar storm it might be very different. 
> But even then I would expect bits to more often just switch than break completely. 
> Maybe for a Jupiter probe it's different and chips might really spoil.

Interesting background, Brian might find it useful. He did say he wanted
to isolate the pages if they're unused, so perhaps non-transient errors
can be detected. Or the system just wants to be overly paranoid?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
