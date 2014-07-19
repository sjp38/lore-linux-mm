Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4E2706B0035
	for <linux-mm@kvack.org>; Sat, 19 Jul 2014 12:36:35 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id tp5so5670616ieb.28
        for <linux-mm@kvack.org>; Sat, 19 Jul 2014 09:36:35 -0700 (PDT)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id fk1si14091287igb.14.2014.07.19.09.36.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Jul 2014 09:36:34 -0700 (PDT)
Received: by mail-ig0-f174.google.com with SMTP id c1so1600245igq.1
        for <linux-mm@kvack.org>; Sat, 19 Jul 2014 09:36:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1407160308550.1775@eggly.anvils>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com>
	<1402655819-14325-7-git-send-email-dh.herrmann@gmail.com>
	<alpine.LSU.2.11.1407160308550.1775@eggly.anvils>
Date: Sat, 19 Jul 2014 18:36:34 +0200
Message-ID: <CANq1E4SMTcTyWJ5ngbq1c-cu0YWn84vjNZsx6C82EAxYeyh2Dg@mail.gmail.com>
Subject: Re: [RFC v3 6/7] shm: wait for pins to be released when sealing
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>

Hi

On Wed, Jul 16, 2014 at 12:09 PM, Hugh Dickins <hughd@google.com> wrote:
> On Fri, 13 Jun 2014, David Herrmann wrote:
>
>> We currently fail setting SEAL_WRITE in case there're pending page
>> references. This patch extends the pin-tests to wait up to 150ms for all
>> references to be dropped. This is still not perfect in that it doesn't
>> account for harmless read-only pins, but it's much better than a hard
>> failure.
>>
>> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
>
> Right, I didn't look through the patch itself, just compared the result
> with what I sent.  Okay, you prefer to separate out shmem_tag_pins().

The main reason why I split both is to avoid goto-label "restart" and
"restart2".

> Yes, it looks fine.  There's just one change I'd like at this stage,
> something I realized shortly after sending the code fragment: please
> add a call to lru_add_drain() at the head of shmem_tag_pins().  The
> reason being that lru_add_drain() is local to the cpu, so cheap, and
> in many cases will bring down all the raised refcounts right then.
>
> Whereas lru_add_drain_all() in the first scan of shmem_wait_for_pins()
> is much more expensive, involving inter-processor interrupts to do
> that on all cpus: it is appropriate to call it at that point, but we
> really ought to try the cheaper lru_add_drain() at the earlier stage.

I added an lru_add_drain_all() to my shmem_test_pins() function in
Patch 2/7. This patch dropped it again as your wait_for_pins() already
included it and it's quite expensive. But yes, the local
lru_add_drain() makes perfect sense. Fixed!

Thanks
David

> I would also like never to embark on this scan of the radix_tree
> and wait for pins, if the pages were never given out in a VM_SHARED
> mapping - or is that unrealistic, because every memfd is read-write,
> and typical initialization expected to be by mmap() rather than write()?
> But anyway, you're quite right not to get into that at this stage:
> it's best left as an optimization once the basics are safely in.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
