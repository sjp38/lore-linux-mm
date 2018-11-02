Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 63EAC6B0269
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 12:05:38 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id g12-v6so848864lji.3
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 09:05:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m4-v6sor1053901lji.36.2018.11.02.09.05.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Nov 2018 09:05:36 -0700 (PDT)
Received: from mail-lj1-f179.google.com (mail-lj1-f179.google.com. [209.85.208.179])
        by smtp.gmail.com with ESMTPSA id e14-v6sm1570735ljl.43.2018.11.02.09.05.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 09:05:34 -0700 (PDT)
Received: by mail-lj1-f179.google.com with SMTP id z80-v6so2202062ljb.8
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 09:05:33 -0700 (PDT)
MIME-Version: 1.0
References: <1541164962-28533-1-git-send-email-will.deacon@arm.com>
 <20181102145638.gehn7eszv22lelh6@kshutemo-mobl1> <CAG48ez38PmTKPq_UQ4q39bwtWmb7epyet3-iSvt5b7JfwmCniw@mail.gmail.com>
 <20181102152516.dkqpeubxh6c3phl2@kshutemo-mobl1>
In-Reply-To: <20181102152516.dkqpeubxh6c3phl2@kshutemo-mobl1>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 2 Nov 2018 09:05:17 -0700
Message-ID: <CAHk-=wjTM5588YwhAYQiH7fCu0itRjHYJZ8WaG1y_bx=6JUhtQ@mail.gmail.com>
Subject: Re: [PATCH] mremap: properly flush TLB before releasing the page
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill@shutemov.name
Cc: Jann Horn <jannh@google.com>, will.deacon@arm.com, Greg KH <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, mhocko@kernel.org, hughd@google.com

On Fri, Nov 2, 2018 at 8:25 AM Kirill A. Shutemov <kirill@shutemov.name> wrote:
>
> I wounder if it would be cheaper to fix this by taking i_mmap_lock_write()
> unconditionally in mremap() path rather than do a lot of flushing.

That wouldn't help. Think anonymous pages and try_to_free() rmap walk.
So then I think we'd have to take the anonvma lock or something.

And it's not like we are likely to even do any more flushes, really.
We don't flush for each page, only for each page table. So every 512
pages or so.

                     Linus
