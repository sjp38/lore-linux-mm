Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC34E6B0038
	for <linux-mm@kvack.org>; Wed, 10 May 2017 18:42:53 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h87so7253125pfh.2
        for <linux-mm@kvack.org>; Wed, 10 May 2017 15:42:53 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id b75si323399pfe.49.2017.05.10.15.42.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 May 2017 15:42:53 -0700 (PDT)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id A3CE52034A
	for <linux-mm@kvack.org>; Wed, 10 May 2017 22:42:51 +0000 (UTC)
Received: from mail-ua0-f170.google.com (mail-ua0-f170.google.com [209.85.217.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3EE45202EC
	for <linux-mm@kvack.org>; Wed, 10 May 2017 22:42:49 +0000 (UTC)
Received: by mail-ua0-f170.google.com with SMTP id e28so11801707uah.0
        for <linux-mm@kvack.org>; Wed, 10 May 2017 15:42:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170510082425.5ks5okbjne7xgjtv@gmail.com>
References: <cover.1494160201.git.luto@kernel.org> <1a124281c99741606f1789140f9805beebb119da.1494160201.git.luto@kernel.org>
 <alpine.DEB.2.20.1705092236290.2295@nanos> <20170510055727.g6wojjiis36a6nvm@gmail.com>
 <alpine.DEB.2.20.1705101017590.1979@nanos> <20170510082425.5ks5okbjne7xgjtv@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 10 May 2017 15:42:27 -0700
Message-ID: <CALCETrV-c8n92v040HVw=6OdnNrLvN7ZAcAJ45Xs4wx-7H5r=g@mail.gmail.com>
Subject: Re: [RFC 09/10] x86/mm: Rework lazy TLB to track the actual loaded mm
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

On Wed, May 10, 2017 at 1:24 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Thomas Gleixner <tglx@linutronix.de> wrote:
>
>> On Wed, 10 May 2017, Ingo Molnar wrote:
>> >
>> > * Thomas Gleixner <tglx@linutronix.de> wrote:
>> >
>> > > On Sun, 7 May 2017, Andy Lutomirski wrote:
>> > > >  /* context.lock is held for us, so we don't need any locking. */
>> > > >  static void flush_ldt(void *current_mm)
>> > > >  {
>> > > > +       struct mm_struct *mm = current_mm;
>> > > >         mm_context_t *pc;
>> > > >
>> > > > -       if (current->active_mm != current_mm)
>> > > > +       if (this_cpu_read(cpu_tlbstate.loaded_mm) != current_mm)
>> > >
>> > > While functional correct, this really should compare against 'mm'.
>> > >
>> > > >                 return;
>> > > >
>> > > > -       pc = &current->active_mm->context;
>> > > > +       pc = &mm->context;
>> >
>> > So this appears to be the function:
>> >
>> >  static void flush_ldt(void *current_mm)
>> >  {
>> >         struct mm_struct *mm = current_mm;
>> >         mm_context_t *pc;
>> >
>> >         if (this_cpu_read(cpu_tlbstate.loaded_mm) != current_mm)
>> >                 return;
>> >
>> >         pc = &mm->context;
>> >         set_ldt(pc->ldt->entries, pc->ldt->size);
>> >  }
>> >
>> > why not rename 'current_mm' to 'mm' and remove the 'mm' local variable?
>>
>> Because you cannot dereference a void pointer, i.e. &mm->context ....
>
> Indeed, doh! The naming totally confused me. The way I'd write it is the canonical
> form for such callbacks:
>
>         static void flush_ldt(void *data)
>         {
>                 struct mm_struct *mm = data;
>
> ... which beyond unconfusing me would probably also have prevented any accidental
> use of the 'current_mm' callback argument.
>
>

void *data and void *info both seem fairly common in the kernel.  How
about my personal favorite for non-kernel work, though: void *mm_void?
 It documents what the parameter means and avoids the confusion.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
