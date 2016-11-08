Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3B54F6B025E
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 10:03:45 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 83so71925512pfx.1
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 07:03:45 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50109.outbound.protection.outlook.com. [40.107.5.109])
        by mx.google.com with ESMTPS id s5si18499585pfj.271.2016.11.08.07.03.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 08 Nov 2016 07:03:42 -0800 (PST)
Subject: Re: [PATCH 4/7] mm: defer vmalloc from atomic context
References: <1477149440-12478-1-git-send-email-hch@lst.de>
 <1477149440-12478-5-git-send-email-hch@lst.de>
 <25c117ae-6d06-9846-6a88-ae6221ad6bfe@virtuozzo.com>
 <CAJWu+oppRL5kD9qPcdCbFAbEkE7bN+kmrvTuaueVZnY+WtK_tg@mail.gmail.com>
 <a40cccff-3a6e-b0be-5d06-bac6cdb0e1e6@virtuozzo.com>
 <20161107150947.GA11279@lst.de>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <747aa42a-c236-ee25-eef5-59644687f01b@virtuozzo.com>
Date: Tue, 8 Nov 2016 18:03:58 +0300
MIME-Version: 1.0
In-Reply-To: <20161107150947.GA11279@lst.de>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Joel Fernandes <joelaf@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jisheng Zhang <jszhang@marvell.com>, Chris Wilson <chris@chris-wilson.co.uk>, John Dias <joaodias@google.com>, "open
 list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-rt-users@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>



On 11/07/2016 06:09 PM, Christoph Hellwig wrote:
> On Mon, Nov 07, 2016 at 06:01:45PM +0300, Andrey Ryabinin wrote:
>>> So because in_atomic doesn't work for !CONFIG_PREEMPT kernels, can we
>>> always defer the work in these cases?
>>>
>>> So for non-preemptible kernels, we always defer:
>>>
>>> if (!IS_ENABLED(CONFIG_PREEMPT) || in_atomic()) {
>>>   // defer
>>> }
>>>
>>> Is this fine? Or any other ideas?
>>>
>>
>> What's wrong with my idea?
>> We can add vfree_in_atomic() and use it to free vmapped stacks
>> and for any other places where vfree() used 'in_atomict() && !in_interrupt()' context.
> 
> I somehow missed the mail, sorry.  That beeing said always defer is
> going to suck badly in terms of performance, so I'm not sure it's an all
> that good idea.
> 
> vfree_in_atomic sounds good, but I wonder if we'll need to annotate
> more callers than just the stacks.  I'm fairly bust this week, do you
> want to give that a spin?  Otherwise I'll give it a try towards the
> end of this week or next week.
> 

Yeah, it appears that we need more annotations. I've found another case in free_ldt_struct(),
and I bet it won't be the last.
I'll send patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
