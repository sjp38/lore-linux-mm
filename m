From: Mark_H_Johnson@raytheon.com
Subject: Re: Re: Memory allocation problem
MIME-Version: 1.0
Date: Mon, 5 May 2003 09:20:56 -0500
Message-ID: <OF9A51B4E3.DAF30DA9-ON86256D1D.004ED1EA-86256D1D.004ED26D@hou.us.ray.com>
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: arjanv@redhat.com
Cc: anand kumar <a_santha@rediffmail.com>, kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>On Sun, 2003-05-04 at 21:40, anand kumar wrote:
>> Hi,
>>
>> [query about bigphysarea and Red Hat]
>> Is Red Hat 9 kernel equipped with this patch?

>no it's not, nor are there plans to add it. BigPhysArea is a hack, not a
>solution. The solution is to use the scatter-gather engine on the pci
>card instead of needing to chainsaw physical ram always...

Let me comment on that last point.

It actually depends on the hardware and what your needs are. Using
the SCI (Scaleable Coherent Interface) cards as an example, the hardware
has a limited number of mapping registers (varies by specific card - the
ones we use have 16K of them) to define the memory mapping. Since we map
up to 512 Mbyte of memory, each of the 16K registers map 32 Kbytes. Note
also that the registers that do the mapping are on the machine that is
accessing the remote memory, not the one with the remote memory.

Let me illustrate:

CPU on machine A
  ||
PCI on machine A
  ||
SCI card on machine A [*]
  ||
SCI cables
  ||
SCI card on machine B
  ||
PCI on machine B
  ||
Memory on machine B

When the CPU on machine A does a fetch, the address is mapped to the SCI
card. The SCI card extracts a few bits to look up in the 16K register
the remote machine location / remote address base[*]. Add that to the rest
of the machine A address & send it to machine B. Machine B's SCI card
does a PCI fetch using the address provided (mapped into physcial memory)
and returns the result (eventually making it back to CPU A). Total elapsed
time w/o any caching effects is 2-5 microseconds. A similar process occurs
on writes (though w/ an address / value sent, not recieved).

Note that the driver implementing this card must get memory in chunks
large enough for the largest map on all other machines connected by the
SCI. So, if I mapped 1G or 2G (instead of 512 Mbyte), that means the
driver must be able to allocate 64 Kbyte or 128 Kbyte chunks. You can
get by with smaller chunks only if all other machines agree to use less
mapping space.

Even if the driver was "smart", I believe the linux-mm has a limitation
where you can get to a point where those sizes of fragments are not
available to be allocated. Thus the need for bigphysarea. We have been
doing so for a couple years now. It is also not a "big deal" for us
since we end up adding about a dozen patches total to get the combination
of capabilities we need for our large, real time application.

I can certainly understand not putting something into Red Hat that has
limited applicability. I can also see the point that adding bigphysarea
won't significantly affect the >99% of systems that won't use it (a few
bytes of memory), but would allow those who need it to get it.

  --Mark



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
