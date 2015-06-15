Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id EA4AA6B0038
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 22:58:09 -0400 (EDT)
Received: by laka10 with SMTP id a10so1473034lak.0
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 19:58:09 -0700 (PDT)
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com. [209.85.217.181])
        by mx.google.com with ESMTPS id uq2si9352119lbc.120.2015.06.14.19.58.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jun 2015 19:58:08 -0700 (PDT)
Received: by lbbqq2 with SMTP id qq2so45109010lbb.3
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 19:58:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87bnghit74.fsf@tassilo.jf.intel.com>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
 <20150613185828.GA32376@redhat.com> <20150614075943.GA810@gmail.com>
 <20150614200623.GB19582@redhat.com> <87bnghit74.fsf@tassilo.jf.intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sun, 14 Jun 2015 19:57:46 -0700
Message-ID: <CALCETrUp5Xm1ZmzoSEGrq1D05myAUhCzNgXvv-Cga8xjEi-CeQ@mail.gmail.com>
Subject: Re: why do we need vmalloc_sync_all?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

On Sun, Jun 14, 2015 at 7:47 PM, Andi Kleen <andi@firstfloor.org> wrote:
> Oleg Nesterov <oleg@redhat.com> writes:
>>
>> But again, the kernel no longer does this? do_page_fault() does vmalloc_fault()
>> without notify_die(). If it fails, I do not see how/why a modular DIE_OOPS
>> handler could try to resolve this problem and trigger another fault.
>
> The same problem can happen from NMI handlers or machine check
> handlers. It's not necessarily tied to page faults only.

AIUI, the point of the one and only vmalloc_sync_all call is to
prevent infinitely recursive faults when we call a notify_die
callback.  The only thing that it could realistically protect is
module text or static non-per-cpu module data, since that's the only
thing that's reliably already in the init pgd.  I'm with Oleg: I don't
see how that can happen, since do_page_fault fixes up vmalloc faults
before it calls notify_die.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
