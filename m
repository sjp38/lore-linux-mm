Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 047266B0047
	for <linux-mm@kvack.org>; Wed, 31 Dec 2008 17:04:33 -0500 (EST)
Received: from localhost.localdomain ([96.237.168.40])
 by vms173001.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0KCR00040HBDB70A@vms173001.mailsrvcs.net> for
 linux-mm@kvack.org; Wed, 31 Dec 2008 16:04:27 -0600 (CST)
Date: Wed, 31 Dec 2008 17:04:22 -0500 (EST)
From: Len Brown <lenb@kernel.org>
Subject: Re: [patch][rfc] acpi: do not use kmem caches
In-reply-to: <20081201181047.GK10790@wotan.suse.de>
Message-id: <alpine.LFD.2.00.0812311649230.3854@localhost.localdomain>
MIME-version: 1.0
Content-type: TEXT/PLAIN; charset=US-ASCII
References: <20081201083128.GB2529@wotan.suse.de>
 <84144f020812010318v205579ean57edecf7992ec7ef@mail.gmail.com>
 <20081201120002.GB10790@wotan.suse.de> <4933E2C3.4020400@gmail.com>
 <1228138641.14439.18.camel@penberg-laptop> <4933EE8A.2010007@gmail.com>
 <20081201161404.GE10790@wotan.suse.de> <4934149A.4020604@gmail.com>
 <20081201172044.GB14074@infradead.org>
 <alpine.LFD.2.00.0812011241080.3197@localhost.localdomain>
 <20081201181047.GK10790@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Alexey Starikovskiy <aystarik@gmail.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, linux-acpi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Dec 2008, Nick Piggin wrote:

> If there is good reason to keep them around, I'm fine with that.
> I think Pekka's suggestion of not doing unions but have better
> typing in the code and then allocate the smaller types from
> kmalloc sounds like a good idea.

Yes, I'll take that up with Bob when he comes back from break.
Maybe the ACPICA code can be improved here.

> If the individual kmem caches are here to stay, then the
> kmem_cache_shrink call should go away. Either way we can delete
> some code from slab.

I think they are here to stay.  We are running
an interpreter in kernel-space with arbitrary input,
so I think the ability to easily isolate run-time memory leaks
on a non-debug system is important.

You may hardly ever see the interpreter run on systems
with few run-time ACPI features, but it runs quite routinely
on many systems.

That said, we have not discovered a memory leak
in a very long time...


BTW.
I question that SLUB combining caches is a good idea.
It seems to fly in the face of how zone allocators
avoid fragmentation -- assuming that "like size"
equates to "like use".

But more important to me is that it reduces visibility.

> The OS agnostic code that implements its own allocator is kind
> of a hack -- I don't understand why you would turn on allocator
> debugging and then circumvent it because you find it too slow.
> But I will never maintain that so if it is compiled out for
> Linux, then OK.

The ACPI interpreter also builds into a user-space simulator
and a debugger.  It is extremely valuable for us to be able
to run the same code in the kernel and also in a user-space
test environment.  So there are a number of features in
the interpreter that we shut off when we build into the
Linux kernel.  Sometimes shutting them off is elegant,
sometime it is clumzy.

"Slabs can take a non-trivial amount of memory.
 On bigger machines it can be many megabytes."

I don't think this thread addressed this concern.
Is it something we should follow-up on?

thanks,
Len Brown, Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
