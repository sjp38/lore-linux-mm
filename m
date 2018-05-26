Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7CEF76B0007
	for <linux-mm@kvack.org>; Sat, 26 May 2018 13:53:13 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id e1-v6so2170847pgv.4
        for <linux-mm@kvack.org>; Sat, 26 May 2018 10:53:13 -0700 (PDT)
Received: from sonic313-26.consmr.mail.gq1.yahoo.com (sonic313-26.consmr.mail.gq1.yahoo.com. [98.137.65.89])
        by mx.google.com with ESMTPS id j5-v6si21131855pgt.449.2018.05.26.10.53.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 May 2018 10:53:12 -0700 (PDT)
Subject: Re: [PATCH] proc: prevent a task from writing on its own /proc/*/mem
References: <1527346246-1334-1-git-send-email-s.mesoraca16@gmail.com>
 <20180526154819.GA14016@avx2>
 <CAJHCu1LgSUJdiZEfParCH7aLERWM1bgwC7e8wQKgmkNE01_4KA@mail.gmail.com>
From: Casey Schaufler <casey@schaufler-ca.com>
Message-ID: <df12287e-7c19-61a6-b94a-5b7186a1e2a3@schaufler-ca.com>
Date: Sat, 26 May 2018 10:53:04 -0700
MIME-Version: 1.0
In-Reply-To: <CAJHCu1LgSUJdiZEfParCH7aLERWM1bgwC7e8wQKgmkNE01_4KA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>, Alexey Dobriyan <adobriyan@gmail.com>
Cc: Kernel Hardening <kernel-hardening@lists.openwall.com>, linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Akinobu Mita <akinobu.mita@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, Davidlohr Bueso <dave@stgolabs.net>, Kees Cook <keescook@chromium.org>

On 5/26/2018 10:30 AM, Salvatore Mesoraca wrote:
> 2018-05-26 17:48 GMT+02:00 Alexey Dobriyan <adobriyan@gmail.com>:
>> On Sat, May 26, 2018 at 04:50:46PM +0200, Salvatore Mesoraca wrote:
>>> Prevent a task from opening, in "write" mode, any /proc/*/mem
>>> file that operates on the task's mm.
>>> /proc/*/mem is mainly a debugging means and, as such, it shouldn't
>>> be used by the inspected process itself.
>>> Current implementation always allow a task to access its own
>>> /proc/*/mem file.
>>> A process can use it to overwrite read-only memory, making
>>> pointless the use of security_file_mprotect() or other ways to
>>> enforce RO memory.
>> You can do it in security_ptrace_access_check()
> No, because that hook is skipped when mm == current->mm:
> https://elixir.bootlin.com/linux/v4.17-rc6/source/kernel/fork.c#L1111
>
>> or security_file_open()
> This is true, but it looks a bit overkill to me, especially since many of
> the macros/functions used to handle proc's files won't be in scope
> for an external LSM.
> Is there any particular reason why you prefer it done via LSM?

If you did a Yama style LSM it would be easy to configure.
Even though it might make no sense to allow this behavior,
someone, somewhere is counting on it.

>
> Thank you,
>
> Salvatore
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
