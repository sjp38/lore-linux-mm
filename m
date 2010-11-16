Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BA01E6B00FE
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 10:34:58 -0500 (EST)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from spt2.w1.samsung.com ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LBZ005G8HWNW230@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 16 Nov 2010 15:33:59 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LBZ00AIQHWN8M@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 16 Nov 2010 15:33:59 +0000 (GMT)
Date: Tue, 16 Nov 2010 16:33:59 +0100
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 0/3] hwmem: Hardware memory driver
In-reply-to: 
 <C832F8F5D375BD43BFA11E82E0FE9FE0081BE739A0@EXDCVYMBSTM005.EQ1STM.local>
Message-id: <op.vl9r6xld7p4s8u@pikus>
Content-transfer-encoding: Quoted-Printable
References: 
 <1289912882-23996-1-git-send-email-johan.xx.mossberg@stericsson.com>
 <op.vl9p52wp7p4s8u@pikus>
 <C832F8F5D375BD43BFA11E82E0FE9FE0081BE739A0@EXDCVYMBSTM005.EQ1STM.local>
Sender: owner-linux-mm@kvack.org
To: Johan MOSSBERG <johan.xx.mossberg@stericsson.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Nov 2010 16:25:20 +0100, Johan MOSSBERG <johan.xx.mossberg@st=
ericsson.com> wrote:

> Micha=C5=82 Nazarewicz wrote:
>> In particular, I'll try to figure out what you mean by defragmentatio=
n
>> and see whethe it could be added to CMA.
>
> I mean the ability to move allocated buffers to free more
> contiguous space. To support this in CMA the API(s) would have to
> change.
> * A buffer's physical address cannot be used to identify it as the
> physical address can change.
> * Pin/unpin functions would have to be added so that you can pin a
> buffer when hardware uses it.
> * The allocators needs to be able to inform CMA that they have
> moved a buffer. This is so that CMA can keep track of what memory
> is free so that it can supply the free memory to the kernel for
> temporary use there.

I don't think those are fundamentally against CMA and as such I see
no reason why such calls could not be added to CMA.  Allocators that
do not support defragmentation could just ignore those calls.

In particular, a cma_alloc() could return a pointer to an opaque
struct cma and to get physical address user would have to pin the
buffer with, say, cma_pin() and then call cma_phys() to obtain
physical address.

As a matter of fact, in the version of CMA I'm currently working on,
cma_alloc() returns a pointer to a transparent structure, so the
above would not be a huge change.

I'm only wondering if treating "unpin" as "free" and pin as another
"alloc" would not suffice?

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
