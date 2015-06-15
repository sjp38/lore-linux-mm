Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 715E26B0038
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 16:48:46 -0400 (EDT)
Received: by laka10 with SMTP id a10so18228293lak.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 13:48:45 -0700 (PDT)
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com. [209.85.217.178])
        by mx.google.com with ESMTPS id ej7si11337010lad.149.2015.06.15.13.48.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 13:48:44 -0700 (PDT)
Received: by lblr1 with SMTP id r1so34636881lbl.0
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 13:48:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150615202856.GA13273@gmail.com>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
 <20150613185828.GA32376@redhat.com> <20150614075943.GA810@gmail.com>
 <20150614200623.GB19582@redhat.com> <87bnghit74.fsf@tassilo.jf.intel.com>
 <CALCETrUp5Xm1ZmzoSEGrq1D05myAUhCzNgXvv-Cga8xjEi-CeQ@mail.gmail.com> <20150615202856.GA13273@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 15 Jun 2015 13:48:23 -0700
Message-ID: <CALCETrW6uYSD47As0UZ3t=PoVKA-BY4bLM50mRKXJeXBX5Zg4w@mail.gmail.com>
Subject: Re: why do we need vmalloc_sync_all?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

On Mon, Jun 15, 2015 at 1:28 PM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Andy Lutomirski <luto@amacapital.net> wrote:
>
>> On Sun, Jun 14, 2015 at 7:47 PM, Andi Kleen <andi@firstfloor.org> wrote:
>> > Oleg Nesterov <oleg@redhat.com> writes:
>> >>
>> >> But again, the kernel no longer does this? do_page_fault() does
>> >> vmalloc_fault() without notify_die(). If it fails, I do not see how/why a
>> >> modular DIE_OOPS handler could try to resolve this problem and trigger
>> >> another fault.
>> >
>> > The same problem can happen from NMI handlers or machine check handlers. It's
>> > not necessarily tied to page faults only.
>>
>> AIUI, the point of the one and only vmalloc_sync_all call is to prevent
>> infinitely recursive faults when we call a notify_die callback.  The only thing
>> that it could realistically protect is module text or static non-per-cpu module
>> data, since that's the only thing that's reliably already in the init pgd.  I'm
>> with Oleg: I don't see how that can happen, since do_page_fault fixes up vmalloc
>> faults before it calls notify_die.
>
> Yes, but what I meant is that it can happen if due to an unrelated kernel bug and
> unlucky timing we have installed this new handler just when that other unrelated
> kernel bug triggers: say a #GPF crash in kernel code.

I still don't see the problem.

CPU A: crash and start executing do_page_fault

CPU B: register_die_notifier

CPU A: notify_die

now we get a vmalloc fault, fix it up, and return to do_page_fault and
print the oops.

>
> In any case it should all be mooted with the removal of lazy PGD instantiation.

Agreed.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
