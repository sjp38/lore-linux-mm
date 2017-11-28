Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B1296B0253
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 12:58:03 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id w1so303339pgq.21
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 09:58:03 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i1sor10906500plt.127.2017.11.28.09.58.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Nov 2017 09:58:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+bprRRzTD5DjSTZt8oobhYcD-eTOT_VwWwcTZBhRH1KUg@mail.gmail.com>
References: <1511841842-3786-1-git-send-email-zhouzhouyi@gmail.com>
 <CAABZP2zEup53ZcNKOEUEMx_aRMLONZdYCLd7s5J4DLTccPxC-A@mail.gmail.com>
 <CACT4Y+YE5POWUoDj2sUv2NDKeimTRyxCpg1yd7VpZnqeYJ+Qcg@mail.gmail.com>
 <CAABZP2zB8vKswQXicYq5r8iNOKz21CRyw1cUiB2s9O+ZMb+JvQ@mail.gmail.com>
 <CACT4Y+YkVbkwAm0h7UJH08woiohJT9EYObhxpE33dP0A4agtkw@mail.gmail.com>
 <CAABZP2zjoSDTNkn_qMqi+NCHOzzQZSj-LvfCjPy_tg-FZeUWZg@mail.gmail.com>
 <CACT4Y+ah6q-xoakyPL7v-+Knp8ZaFbnRRk_Ki6Wsmz3C8Pe8XQ@mail.gmail.com>
 <CAABZP2yS524XEiyu=kkVx7ff1ySTtE=WWETNDrZ_toEm0mwqyQ@mail.gmail.com>
 <CACT4Y+aAhHSW=qBFLy7S1wWLsJsjW83y8uC4nQy0N9Hf8HoMKQ@mail.gmail.com>
 <CAABZP2wxDxAHJ_f022Ha7gyffukgo0PPOv2uJQphwFXGO_fL1w@mail.gmail.com> <CACT4Y+bprRRzTD5DjSTZt8oobhYcD-eTOT_VwWwcTZBhRH1KUg@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 28 Nov 2017 18:57:41 +0100
Message-ID: <CACT4Y+aRGC9vVaHCXmeEiL5ywjQRTK+yNn+TAWKPLB3Gpd4U_A@mail.gmail.com>
Subject: Re: [PATCH 1/1] kasan: fix livelock in qlist_move_cache
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouyi Zhou <zhouzhouyi@gmail.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Nov 28, 2017 at 6:56 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Tue, Nov 28, 2017 at 12:30 PM, Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:
>> Hi,
>>    By using perf top, qlist_move_cache occupies 100% cpu did really
>> happen in my environment yesterday, or I
>> won't notice the kasan code.
>>    Currently I have difficulty to let it reappear because the frontend
>> guy modified some user mode code.
>>    I can repeat again and again now is
>> kgdb_breakpoint () at kernel/debug/debug_core.c:1073
>> 1073 wmb(); /* Sync point after breakpoint */
>> (gdb) p quarantine_batch_size
>> $1 = 3601946
>>    And by instrument code, maximum
>> global_quarantine[quarantine_tail].bytes reached is 6618208.
>
> On second thought, size does not matter too much because there can be
> large objects. Quarantine always quantize by objects, we can't part of
> an object into one batch, and another part of the object into another
> object. But it's not a problem, because overhead per objects is O(1).
> We can push a single 4MB object and overflow target size by 4MB and
> that will be fine.
> Either way, 6MB is not terribly much too. Should take milliseconds to process.
>
>
>
>
>>    I do think drain quarantine right in quarantine_put is a better
>> place to drain because cache_free is fine in
>> that context. I am willing do it if you think it is convenient :-)


Andrey, do you know of any problems with draining quarantine in push?
Do you have any objections?

But it's still not completely clear to me what problem we are solving.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
