Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A29B6B0007
	for <linux-mm@kvack.org>; Sat, 26 May 2018 13:31:09 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id c8-v6so5675501uae.5
        for <linux-mm@kvack.org>; Sat, 26 May 2018 10:31:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e26-v6sor13050465uab.221.2018.05.26.10.31.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 26 May 2018 10:31:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180526154819.GA14016@avx2>
References: <1527346246-1334-1-git-send-email-s.mesoraca16@gmail.com> <20180526154819.GA14016@avx2>
From: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Date: Sat, 26 May 2018 19:30:47 +0200
Message-ID: <CAJHCu1LgSUJdiZEfParCH7aLERWM1bgwC7e8wQKgmkNE01_4KA@mail.gmail.com>
Subject: Re: [PATCH] proc: prevent a task from writing on its own /proc/*/mem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Kernel Hardening <kernel-hardening@lists.openwall.com>, linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Akinobu Mita <akinobu.mita@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, Davidlohr Bueso <dave@stgolabs.net>, Kees Cook <keescook@chromium.org>

2018-05-26 17:48 GMT+02:00 Alexey Dobriyan <adobriyan@gmail.com>:
> On Sat, May 26, 2018 at 04:50:46PM +0200, Salvatore Mesoraca wrote:
>> Prevent a task from opening, in "write" mode, any /proc/*/mem
>> file that operates on the task's mm.
>> /proc/*/mem is mainly a debugging means and, as such, it shouldn't
>> be used by the inspected process itself.
>> Current implementation always allow a task to access its own
>> /proc/*/mem file.
>> A process can use it to overwrite read-only memory, making
>> pointless the use of security_file_mprotect() or other ways to
>> enforce RO memory.
>
> You can do it in security_ptrace_access_check()

No, because that hook is skipped when mm == current->mm:
https://elixir.bootlin.com/linux/v4.17-rc6/source/kernel/fork.c#L1111

> or security_file_open()

This is true, but it looks a bit overkill to me, especially since many of
the macros/functions used to handle proc's files won't be in scope
for an external LSM.
Is there any particular reason why you prefer it done via LSM?

Thank you,

Salvatore
