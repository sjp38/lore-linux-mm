Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B44A46B0007
	for <linux-mm@kvack.org>; Sat, 26 May 2018 13:59:02 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 70-v6so5638465wmb.2
        for <linux-mm@kvack.org>; Sat, 26 May 2018 10:59:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g81-v6sor2829858wmc.51.2018.05.26.10.59.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 26 May 2018 10:59:01 -0700 (PDT)
Date: Sat, 26 May 2018 20:58:58 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] proc: prevent a task from writing on its own /proc/*/mem
Message-ID: <20180526175858.GA19115@avx2>
References: <1527346246-1334-1-git-send-email-s.mesoraca16@gmail.com>
 <20180526154819.GA14016@avx2>
 <CAJHCu1LgSUJdiZEfParCH7aLERWM1bgwC7e8wQKgmkNE01_4KA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAJHCu1LgSUJdiZEfParCH7aLERWM1bgwC7e8wQKgmkNE01_4KA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Cc: Kernel Hardening <kernel-hardening@lists.openwall.com>, linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Akinobu Mita <akinobu.mita@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, Davidlohr Bueso <dave@stgolabs.net>, Kees Cook <keescook@chromium.org>

On Sat, May 26, 2018 at 07:30:47PM +0200, Salvatore Mesoraca wrote:
> 2018-05-26 17:48 GMT+02:00 Alexey Dobriyan <adobriyan@gmail.com>:
> > On Sat, May 26, 2018 at 04:50:46PM +0200, Salvatore Mesoraca wrote:
> >> Prevent a task from opening, in "write" mode, any /proc/*/mem
> >> file that operates on the task's mm.
> >> /proc/*/mem is mainly a debugging means and, as such, it shouldn't
> >> be used by the inspected process itself.
> >> Current implementation always allow a task to access its own
> >> /proc/*/mem file.
> >> A process can use it to overwrite read-only memory, making
> >> pointless the use of security_file_mprotect() or other ways to
> >> enforce RO memory.
> >
> > You can do it in security_ptrace_access_check()
> 
> No, because that hook is skipped when mm == current->mm:
> https://elixir.bootlin.com/linux/v4.17-rc6/source/kernel/fork.c#L1111

OK

> > or security_file_open()
> 
> This is true, but it looks a bit overkill to me, especially since many of
> the macros/functions used to handle proc's files won't be in scope
> for an external LSM.
> Is there any particular reason why you prefer it done via LSM?

Well, it exists to implement all kinds of non-standard restrictions.

You're probably blacklisting mprotect() and worry that compromised
program might use /proc/self/mem instead. But you need to blacklist
much more that mprotect(). I think forking a dummy "worker" process
to open your /proc/*/mem and pass a descriptor back should still work
with your patch.
