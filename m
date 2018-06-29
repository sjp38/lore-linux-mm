Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3990F6B0005
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:19:41 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id l8-v6so2072405ita.4
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 08:19:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a80-v6sor614356ita.128.2018.06.29.08.19.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Jun 2018 08:19:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAAeHK+wJbbCZd+-X=9oeJgsqQJiq8h+Aagz3SQMPaAzCD+pvFw@mail.gmail.com>
References: <cover.1529507994.git.andreyknvl@google.com> <CAAeHK+zqtyGzd_CZ7qKZKU-uZjZ1Pkmod5h8zzbN0xCV26nSfg@mail.gmail.com>
 <20180626172900.ufclp2pfrhwkxjco@armageddon.cambridge.arm.com>
 <CAAeHK+yqWKTdTG+ymZ2-5XKiDANV+fmUjnQkRy-5tpgphuLJRA@mail.gmail.com> <CAAeHK+wJbbCZd+-X=9oeJgsqQJiq8h+Aagz3SQMPaAzCD+pvFw@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 29 Jun 2018 17:19:36 +0200
Message-ID: <CAAeHK+x4jaN9w8O+hYJ0835Ln=rQ8VT1=ZrKLNsBOT92+iOwdQ@mail.gmail.com>
Subject: Re: [PATCH v4 0/7] arm64: untag user pointers passed to the kernel
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-doc@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, linux-kselftest@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgeniy Stepanov <eugenis@google.com>

a bunch of compat
a bunch of ioctl that use ptr to stored ints

ipc/shm.c:1355
ipc/shm.c:1566

mm/process_vm_access.c:178:20
mm/process_vm_access.c:180:19
substraction => harmless

mm/process_vm_access.c:221:4
?

mm/memory.c:4679:14
should be __user pointer

fs/fuse/file.c:1256:9
?

kernel/kthread.c:73:9
?

mm/migrate.c:1586:10
mm/migrate.c:1660:24

lib/iov_iter.c
???

kernel/futex.c:502
uses user addr as key

kernel/futex.c:730
gup, fixed

lib/strncpy_from_user.c:110:13
fixed?

lib/strnlen_user.c:112
fixed?

fs/readdir.c:369
???



On Thu, Jun 28, 2018 at 9:30 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> On Wed, Jun 27, 2018 at 5:05 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> On Tue, Jun 26, 2018 at 7:29 PM, Catalin Marinas
>> <catalin.marinas@arm.com> wrote:
>>> While I support this work, as a maintainer I'd like to understand
>>> whether we'd be in a continuous chase of ABI breaks with every kernel
>>> release or we have a better way to identify potential issues. Is there
>>> any way to statically analyse conversions from __user ptr to long for
>>> example? Or, could we get the compiler to do this for us?
>>
>>
>> OK, got it, I'll try to figure out a way to find these conversions.
>
> I've prototyped a checker on top of clang static analyzer (initially
> looked at sparse, but couldn't find any documentation or examples).
> The results are here [1], search for "warning: user pointer cast".
> Sharing in case anybody wants to take a look, will look at them myself
> tomorrow.
>
> [1] https://gist.github.com/xairy/433edd5c86456a64026247cb2fef2115
