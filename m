Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 604E46B004A
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 05:44:21 -0500 (EST)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LC4007OBOHT5C70@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 10:44:17 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LC40052MOHTA2@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 19 Nov 2010 10:44:17 +0000 (GMT)
Date: Fri, 19 Nov 2010 11:44:17 +0100
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 0/3] hwmem: Hardware memory driver
In-reply-to: 
 <C832F8F5D375BD43BFA11E82E0FE9FE0081BE73D53@EXDCVYMBSTM005.EQ1STM.local>
Message-id: <op.vmeyr3fd7p4s8u@pikus>
Content-transfer-encoding: Quoted-Printable
References: 
 <1289912882-23996-1-git-send-email-johan.xx.mossberg@stericsson.com>
 <op.vl9p52wp7p4s8u@pikus>
 <C832F8F5D375BD43BFA11E82E0FE9FE0081BE739A0@EXDCVYMBSTM005.EQ1STM.local>
 <op.vl9r6xld7p4s8u@pikus>
 <C832F8F5D375BD43BFA11E82E0FE9FE0081BE73A1D@EXDCVYMBSTM005.EQ1STM.local>
 <op.vl9xudve7p4s8u@pikus>
 <C832F8F5D375BD43BFA11E82E0FE9FE0081BE73D53@EXDCVYMBSTM005.EQ1STM.local>
Sender: owner-linux-mm@kvack.org
To: Johan MOSSBERG <johan.xx.mossberg@stericsson.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010 10:28:13 +0100, Johan MOSSBERG <johan.xx.mossberg@st=
ericsson.com> wrote:

> Micha=C5=82 Nazarewicz wrote:
>> Do you want to remap user space mappings when page is moved during
>> defragmentation? Or would user need to unmap the region?  Ie. would
>> mmap()ed buffer be pinned?
>
> Remap, i.e. not pinned. That means that the mapper needs to be
> informed before and after a buffer is moved. Maybe add a function
> to CMA where you can register a callback function that is called
> before and after a buffer is moved? The callback function's
> parameters would be buffer, new position and whether it will be
> moved or has been moved. CMA would also need this type of
> information to be able to evict temporary data from the
> destination.

The way I imagine pinning is that the allocator tells CMA that it want
to use given region of memory.  This would make CMA remove any kind of
data that is stored there (in the version of CMA I'm about to post that
basically means migrating pages).

> I'm a little bit worried that this approach put constraints on the
> defragmentation algorithm but I can't think of any scenario where
> we would run into problems. If a defragmentation algorithm does
> temporary moves, and knows it at the time of the move, we would
> have to add a flag to the callback that indicates that the move is
> temporary so that it is not unnecessarily mapped, but that can be
> done when/if the problem occurs. Temporarily moving a buffer to
> scattered memory is not supported either but I suppose that can be
> solved by adding a flag that indicates that the new position is
> scattered, also something that can be done when needed.

I think the question at this moment is whether we need such a mechanism
to be implemented at the this time.  I would rather wait with the
callback mechanism till the rest of the framework works and we have
an algorithm that actually does the defragmentation.

-- =

Best regards,                                        _     _
| Humble Liege of Serenely Enlightened Majesty of  o' \,=3D./ `o
| Computer Science,  Micha=C5=82 "mina86" Nazarewicz       (o o)
+----[mina86*mina86.com]---[mina86*jabber.org]----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
