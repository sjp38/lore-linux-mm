Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 92C8F6B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 02:48:24 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id w7-v6so2454766ljh.15
        for <linux-mm@kvack.org>; Sun, 29 Jul 2018 23:48:24 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y18-v6sor2206023ljh.106.2018.07.29.23.48.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 29 Jul 2018 23:48:23 -0700 (PDT)
MIME-Version: 1.0
References: <CA+55aFxpFefwVdTGVML99PSFUqwpJXPx5LVCA3D=g2t2_QLNsA@mail.gmail.com>
In-Reply-To: <CA+55aFxpFefwVdTGVML99PSFUqwpJXPx5LVCA3D=g2t2_QLNsA@mail.gmail.com>
From: Amit Pundir <amit.pundir@linaro.org>
Date: Mon, 30 Jul 2018 12:17:46 +0530
Message-ID: <CAMi1Hd0fJuAgP09_KkbjyGwszOXmxcPybKyBxP3U1y5JUqxxSw@mail.gmail.com>
Subject: Re: Linux 4.18-rc7
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, aarcange@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>

On Mon, 30 Jul 2018 at 03:39, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So unless something odd happens, this should be the last rc for 4.18.
>
> Nothing particularly odd happened this last week - we got the usual
> random set of various minor fixes all over. About two thirds of it is
> drivers - networking, staging and usb stands out, but there's a little
> bit of stuff all over (clk, block, gpu, nvme..).
>
> Outside of drivers, the bulk is some core networking stuff, with
> random changes elsewhere (minor arch updates, filesystems, core
> kernel, test scripts).
>
> The appended shortlog gives a flavor of the details.
>
>                   Linus
>
> ---
> Kirill A. Shutemov (3):
>       mm: introduce vma_init()
>       mm: use vma_init() to initialize VMAs on stack and data segments
>       mm: fix vma_is_anonymous() false-positives

Hi, I have run into AOSP userspace crash with v4.18-rc7, leading to
above mm patches. bfd40eaff5ab ("mm: fix vma_is_anonymous()
false-positives") to be specific. The same userspace is working fine
with v4.18-rc6.

I didn't yet look into what is going wrong from userspace point of
view, but I just wanted to give you a heads up on this. I'll be happy
to assist in further debugging/diagnosis if required.

Here is the crash log from logcat, if it helps:
F DEBUG   : *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
F DEBUG   : Build fingerprint:
'Android/db410c32_only/db410c32_only:Q/OC-MR1/102:userdebug/test-key
F DEBUG   : Revision: '0'
F DEBUG   : ABI: 'arm'
F DEBUG   : pid: 2261, tid: 2261, name: zygote  >>> zygote <<<
F DEBUG   : signal 7 (SIGBUS), code 2 (BUS_ADRERR), fault addr 0xec00008
.. <snip> ..
F DEBUG   : backtrace:
F DEBUG   :     #00 pc 00001c04  /system/lib/libc.so (memset+48)
F DEBUG   :     #01 pc 0010c513  /system/lib/libart.so
(create_mspace_with_base+82)
F DEBUG   :     #02 pc 0015c601  /system/lib/libart.so
(art::gc::space::DlMallocSpace::CreateMspace(void*, unsigned int,
unsigned int)+40)
F DEBUG   :     #03 pc 0015c3ed  /system/lib/libart.so
(art::gc::space::DlMallocSpace::CreateFromMemMap(art::MemMap*,
std::__1::basic_string<char, std::__
1::char_traits<char>, std::__1::allocator<char>> const&, unsigned int,
unsigned int, unsigned int, unsigned int, bool)+36)
F DEBUG   :     #04 pc 0013c9ab  /system/lib/libart.so
(art::gc::Heap::Heap(unsigned int, unsigned int, unsigned int,
unsigned int, double, double, unsigned int, unsigned int,
std::__1::basic_string<char, std::__1::char_traits<char>,
std::__1::allocator<char>> const&, art::InstructionSet,
art::gc::CollectorType, art::gc::CollectorType,
art::gc::space::LargeObjectSpaceType, unsigned int, unsigned int,
unsigned int, bool, unsigned int, unsigned int, bool, bool, bool,
bool, bool, bool, bool, bool, bool, bool, bool, unsigned long
long)+1674)
DEBUG   :     #05 pc 00318201  /system/lib/libart.so
(art::Runtime::Init(art::RuntimeArgumentMap&&)+7036)
DEBUG   :     #06 pc 0031af19  /system/lib/libart.so
(art::Runtime::Create(std::__1::vector<std::__1::pair<std::__1::basic_string<char,
std::__1::char_traits<char>, std::__1::allocator<char>>, void const*>,
std::__1::allocator<std::__1::pair<std::__1::basic_string<char,
std::__1::char_traits<char>, std::__1::allocator<char>>, void
const*>>> const&, bool)+68)
F DEBUG   :     #07 pc 0023c353  /system/lib/libart.so (JNI_CreateJavaVM+658)
F DEBUG   :     #08 pc 0000205f  /system/lib/libandroid_runtime.so
(android::AndroidRuntime::startVm(_JavaVM**, _JNIEnv**, bool)+5038)
F DEBUG   :     #09 pc 00002381  /system/lib/libandroid_runtime.so
(android::AndroidRuntime::start(char const*,
android::Vector<android::String8> const&, bool)+196)
F DEBUG   :     #10 pc 0000046b  /system/bin/app_process32 (main+702)

Regards,
Amit Pundir
