Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 80ACD6B0253
	for <linux-mm@kvack.org>; Sat,  9 Jul 2016 08:58:26 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id l89so1093096lfi.3
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 05:58:26 -0700 (PDT)
Received: from mail-lf0-f43.google.com (mail-lf0-f43.google.com. [209.85.215.43])
        by mx.google.com with ESMTPS id m8si1195603lfb.157.2016.07.09.05.58.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jul 2016 05:58:24 -0700 (PDT)
Received: by mail-lf0-f43.google.com with SMTP id l188so43438604lfe.2
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 05:58:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu_F03ncqT2wWFte2bFWQ7tSruL0ZaxTBLT9_NEs-1SioQ@mail.gmail.com>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
 <b113b487-acc6-24b8-d58c-425d3c884f4c@redhat.com> <CAKv+Gu_F03ncqT2wWFte2bFWQ7tSruL0ZaxTBLT9_NEs-1SioQ@mail.gmail.com>
From: Laura Abbott <labbott@redhat.com>
Date: Sat, 9 Jul 2016 05:58:22 -0700
Message-ID: <CACpTn7cP+2t-_SFdoE_MggbnMCZssSRJ0WVxkfwvfH1-zT_yAQ@mail.gmail.com>
Subject: Re: [PATCH 0/9] mm: Hardened usercopy
Content-Type: multipart/alternative; boundary=001a114b0e5c7a84e80537337986
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Kees Cook <keescook@chromium.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, sparclinux@vger.kernel.org, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kernel-hardening@lists.openwall.com

--001a114b0e5c7a84e80537337986
Content-Type: text/plain; charset=UTF-8

On Sat, Jul 9, 2016 at 1:25 AM, Ard Biesheuvel <ard.biesheuvel@linaro.org>
wrote:

> On 9 July 2016 at 04:22, Laura Abbott <labbott@redhat.com> wrote:
> > On 07/06/2016 03:25 PM, Kees Cook wrote:
> >>
> >> Hi,
> >>
> >> This is a start of the mainline port of PAX_USERCOPY[1]. After I started
> >> writing tests (now in lkdtm in -next) for Casey's earlier port[2], I
> >> kept tweaking things further and further until I ended up with a whole
> >> new patch series. To that end, I took Rik's feedback and made a number
> >> of other changes and clean-ups as well.
> >>
> >> Based on my understanding, PAX_USERCOPY was designed to catch a few
> >> classes of flaws around the use of copy_to_user()/copy_from_user().
> These
> >> changes don't touch get_user() and put_user(), since these operate on
> >> constant sized lengths, and tend to be much less vulnerable. There
> >> are effectively three distinct protections in the whole series,
> >> each of which I've given a separate CONFIG, though this patch set is
> >> only the first of the three intended protections. (Generally speaking,
> >> PAX_USERCOPY covers what I'm calling CONFIG_HARDENED_USERCOPY (this) and
> >> CONFIG_HARDENED_USERCOPY_WHITELIST (future), and PAX_USERCOPY_SLABS
> covers
> >> CONFIG_HARDENED_USERCOPY_SPLIT_KMALLOC (future).)
> >>
> >> This series, which adds CONFIG_HARDENED_USERCOPY, checks that objects
> >> being copied to/from userspace meet certain criteria:
> >> - if address is a heap object, the size must not exceed the object's
> >>   allocated size. (This will catch all kinds of heap overflow flaws.)
> >> - if address range is in the current process stack, it must be within
> the
> >>   current stack frame (if such checking is possible) or at least
> entirely
> >>   within the current process's stack. (This could catch large lengths
> that
> >>   would have extended beyond the current process stack, or overflows if
> >>   their length extends back into the original stack.)
> >> - if the address range is part of kernel data, rodata, or bss, allow it.
> >> - if address range is page-allocated, that it doesn't span multiple
> >>   allocations.
> >> - if address is within the kernel text, reject it.
> >> - everything else is accepted
> >>
> >> The patches in the series are:
> >> - The core copy_to/from_user() checks, without the slab object checks:
> >>         1- mm: Hardened usercopy
> >> - Per-arch enablement of the protection:
> >>         2- x86/uaccess: Enable hardened usercopy
> >>         3- ARM: uaccess: Enable hardened usercopy
> >>         4- arm64/uaccess: Enable hardened usercopy
> >>         5- ia64/uaccess: Enable hardened usercopy
> >>         6- powerpc/uaccess: Enable hardened usercopy
> >>         7- sparc/uaccess: Enable hardened usercopy
> >> - The heap allocator implementation of object size checking:
> >>         8- mm: SLAB hardened usercopy support
> >>         9- mm: SLUB hardened usercopy support
> >>
> >> Some notes:
> >>
> >> - This is expected to apply on top of -next which contains fixes for the
> >>   position of _etext on both arm and arm64.
> >>
> >> - I couldn't detect a measurable performance change with these features
> >>   enabled. Kernel build times were unchanged, hackbench was unchanged,
> >>   etc. I think we could flip this to "on by default" at some point.
> >>
> >> - The SLOB support extracted from grsecurity seems entirely broken. I
> >>   have no idea what's going on there, I spent my time testing SLAB and
> >>   SLUB. Having someone else look at SLOB would be nice, but this series
> >>   doesn't depend on it.
> >>
> >> Additional features that would be nice, but aren't blocking this series:
> >>
> >> - Needs more architecture support for stack frame checking (only x86
> now).
> >>
> >>
> >
> > Even with the SLUB fixup I'm still seeing this blow up on my arm64
> system.
> > This is a
> > Fedora rawhide kernel + the patches
> >
> > [ 0.666700] usercopy: kernel memory exposure attempt detected from
> > fffffc0008b4dd58 (<kernel text>) (8 bytes)
> > [ 0.666720] CPU: 2 PID: 79 Comm: modprobe Tainted: G        W
> > 4.7.0-0.rc6.git1.1.hardenedusercopy.fc25.aarch64 #1
> > [ 0.666733] Hardware name: AppliedMicro Mustang/Mustang, BIOS 1.1.0 Nov
> 24
> > 2015
> > [ 0.666744] Call trace:
> > [ 0.666756] [<fffffc0008088a20>] dump_backtrace+0x0/0x1e8
> > [ 0.666765] [<fffffc0008088c2c>] show_stack+0x24/0x30
> > [ 0.666775] [<fffffc0008455344>] dump_stack+0xa4/0xe0
> > [ 0.666785] [<fffffc000828d874>] __check_object_size+0x6c/0x230
> > [ 0.666795] [<fffffc00083a5748>] create_elf_tables+0x74/0x420
> > [ 0.666805] [<fffffc00082fb1f0>] load_elf_binary+0x828/0xb70
> > [ 0.666814] [<fffffc0008298b4c>] search_binary_handler+0xb4/0x240
> > [ 0.666823] [<fffffc0008299864>] do_execveat_common+0x63c/0x950
> > [ 0.666832] [<fffffc0008299bb4>] do_execve+0x3c/0x50
> > [ 0.666841] [<fffffc00080e3720>]
> call_usermodehelper_exec_async+0xe8/0x148
> > [ 0.666850] [<fffffc0008084a80>] ret_from_fork+0x10/0x50
> >
> > This happens on every call to execve. This seems to be the first
> > copy_to_user in
> > create_elf_tables. I didn't get a chance to debug and I'm going out of
> town
> > all of next week so all I have is the report unfortunately. config
> attached.
> >
>
> This is a known issue, and a fix is already queued for v4.8 in the arm64
> tree:
>
> 9fdc14c55c arm64: mm: fix location of _etext [0]
>
> which moves _etext up in the linker script so that it does not cover
> .rodata
>
> ARM was suffering from the same problem, and Kees proposed a fix for
> it. I don't know what the status of that patch is, though.
>
> Note that on arm64, we have
>
>   #define ELF_PLATFORM            ("aarch64")
>
> which explains why k_platform points into .rodata in this case. On
> ARM, it points to a writable string (as the code quoted by Rik shows),
> so there it will likely explode elsewhere without the linker script
> fix.
>
> [0]
> https://git.kernel.org/cgit/linux/kernel/git/arm64/linux.git/commit/?h=for-next/core&id=9fdc14c55c
>
> --
> Ard.
>

Ugh, I completely missed that note about the patch on arm64. Sorry for the
noise.

Thanks,
Laura

--001a114b0e5c7a84e80537337986
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_default" style=3D"font-family:comic sa=
ns ms,sans-serif;font-size:xx-large;color:#ff00ff"><br></div><div class=3D"=
gmail_extra"><br><div class=3D"gmail_quote">On Sat, Jul 9, 2016 at 1:25 AM,=
 Ard Biesheuvel <span dir=3D"ltr">&lt;<a href=3D"mailto:ard.biesheuvel@lina=
ro.org" target=3D"_blank">ard.biesheuvel@linaro.org</a>&gt;</span> wrote:<b=
r><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:=
1px #ccc solid;padding-left:1ex"><div><div>On 9 July 2016 at 04:22, Laura A=
bbott &lt;<a href=3D"mailto:labbott@redhat.com" target=3D"_blank">labbott@r=
edhat.com</a>&gt; wrote:<br>
&gt; On 07/06/2016 03:25 PM, Kees Cook wrote:<br>
&gt;&gt;<br>
&gt;&gt; Hi,<br>
&gt;&gt;<br>
&gt;&gt; This is a start of the mainline port of PAX_USERCOPY[1]. After I s=
tarted<br>
&gt;&gt; writing tests (now in lkdtm in -next) for Casey&#39;s earlier port=
[2], I<br>
&gt;&gt; kept tweaking things further and further until I ended up with a w=
hole<br>
&gt;&gt; new patch series. To that end, I took Rik&#39;s feedback and made =
a number<br>
&gt;&gt; of other changes and clean-ups as well.<br>
&gt;&gt;<br>
&gt;&gt; Based on my understanding, PAX_USERCOPY was designed to catch a fe=
w<br>
&gt;&gt; classes of flaws around the use of copy_to_user()/copy_from_user()=
. These<br>
&gt;&gt; changes don&#39;t touch get_user() and put_user(), since these ope=
rate on<br>
&gt;&gt; constant sized lengths, and tend to be much less vulnerable. There=
<br>
&gt;&gt; are effectively three distinct protections in the whole series,<br=
>
&gt;&gt; each of which I&#39;ve given a separate CONFIG, though this patch =
set is<br>
&gt;&gt; only the first of the three intended protections. (Generally speak=
ing,<br>
&gt;&gt; PAX_USERCOPY covers what I&#39;m calling CONFIG_HARDENED_USERCOPY =
(this) and<br>
&gt;&gt; CONFIG_HARDENED_USERCOPY_WHITELIST (future), and PAX_USERCOPY_SLAB=
S covers<br>
&gt;&gt; CONFIG_HARDENED_USERCOPY_SPLIT_KMALLOC (future).)<br>
&gt;&gt;<br>
&gt;&gt; This series, which adds CONFIG_HARDENED_USERCOPY, checks that obje=
cts<br>
&gt;&gt; being copied to/from userspace meet certain criteria:<br>
&gt;&gt; - if address is a heap object, the size must not exceed the object=
&#39;s<br>
&gt;&gt;=C2=A0 =C2=A0allocated size. (This will catch all kinds of heap ove=
rflow flaws.)<br>
&gt;&gt; - if address range is in the current process stack, it must be wit=
hin the<br>
&gt;&gt;=C2=A0 =C2=A0current stack frame (if such checking is possible) or =
at least entirely<br>
&gt;&gt;=C2=A0 =C2=A0within the current process&#39;s stack. (This could ca=
tch large lengths that<br>
&gt;&gt;=C2=A0 =C2=A0would have extended beyond the current process stack, =
or overflows if<br>
&gt;&gt;=C2=A0 =C2=A0their length extends back into the original stack.)<br=
>
&gt;&gt; - if the address range is part of kernel data, rodata, or bss, all=
ow it.<br>
&gt;&gt; - if address range is page-allocated, that it doesn&#39;t span mul=
tiple<br>
&gt;&gt;=C2=A0 =C2=A0allocations.<br>
&gt;&gt; - if address is within the kernel text, reject it.<br>
&gt;&gt; - everything else is accepted<br>
&gt;&gt;<br>
&gt;&gt; The patches in the series are:<br>
&gt;&gt; - The core copy_to/from_user() checks, without the slab object che=
cks:<br>
&gt;&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01- mm: Hardened usercopy<br>
&gt;&gt; - Per-arch enablement of the protection:<br>
&gt;&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02- x86/uaccess: Enable hardened u=
sercopy<br>
&gt;&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A03- ARM: uaccess: Enable hardened =
usercopy<br>
&gt;&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A04- arm64/uaccess: Enable hardened=
 usercopy<br>
&gt;&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A05- ia64/uaccess: Enable hardened =
usercopy<br>
&gt;&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A06- powerpc/uaccess: Enable harden=
ed usercopy<br>
&gt;&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A07- sparc/uaccess: Enable hardened=
 usercopy<br>
&gt;&gt; - The heap allocator implementation of object size checking:<br>
&gt;&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A08- mm: SLAB hardened usercopy sup=
port<br>
&gt;&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A09- mm: SLUB hardened usercopy sup=
port<br>
&gt;&gt;<br>
&gt;&gt; Some notes:<br>
&gt;&gt;<br>
&gt;&gt; - This is expected to apply on top of -next which contains fixes f=
or the<br>
&gt;&gt;=C2=A0 =C2=A0position of _etext on both arm and arm64.<br>
&gt;&gt;<br>
&gt;&gt; - I couldn&#39;t detect a measurable performance change with these=
 features<br>
&gt;&gt;=C2=A0 =C2=A0enabled. Kernel build times were unchanged, hackbench =
was unchanged,<br>
&gt;&gt;=C2=A0 =C2=A0etc. I think we could flip this to &quot;on by default=
&quot; at some point.<br>
&gt;&gt;<br>
&gt;&gt; - The SLOB support extracted from grsecurity seems entirely broken=
. I<br>
&gt;&gt;=C2=A0 =C2=A0have no idea what&#39;s going on there, I spent my tim=
e testing SLAB and<br>
&gt;&gt;=C2=A0 =C2=A0SLUB. Having someone else look at SLOB would be nice, =
but this series<br>
&gt;&gt;=C2=A0 =C2=A0doesn&#39;t depend on it.<br>
&gt;&gt;<br>
&gt;&gt; Additional features that would be nice, but aren&#39;t blocking th=
is series:<br>
&gt;&gt;<br>
&gt;&gt; - Needs more architecture support for stack frame checking (only x=
86 now).<br>
&gt;&gt;<br>
&gt;&gt;<br>
&gt;<br>
&gt; Even with the SLUB fixup I&#39;m still seeing this blow up on my arm64=
 system.<br>
&gt; This is a<br>
&gt; Fedora rawhide kernel + the patches<br>
&gt;<br>
&gt; [ 0.666700] usercopy: kernel memory exposure attempt detected from<br>
&gt; fffffc0008b4dd58 (&lt;kernel text&gt;) (8 bytes)<br>
&gt; [ 0.666720] CPU: 2 PID: 79 Comm: modprobe Tainted: G=C2=A0 =C2=A0 =C2=
=A0 =C2=A0 W<br>
&gt; 4.7.0-0.rc6.git1.1.hardenedusercopy.fc25.aarch64 #1<br>
&gt; [ 0.666733] Hardware name: AppliedMicro Mustang/Mustang, BIOS 1.1.0 No=
v 24<br>
&gt; 2015<br>
&gt; [ 0.666744] Call trace:<br>
&gt; [ 0.666756] [&lt;fffffc0008088a20&gt;] dump_backtrace+0x0/0x1e8<br>
&gt; [ 0.666765] [&lt;fffffc0008088c2c&gt;] show_stack+0x24/0x30<br>
&gt; [ 0.666775] [&lt;fffffc0008455344&gt;] dump_stack+0xa4/0xe0<br>
&gt; [ 0.666785] [&lt;fffffc000828d874&gt;] __check_object_size+0x6c/0x230<=
br>
&gt; [ 0.666795] [&lt;fffffc00083a5748&gt;] create_elf_tables+0x74/0x420<br=
>
&gt; [ 0.666805] [&lt;fffffc00082fb1f0&gt;] load_elf_binary+0x828/0xb70<br>
&gt; [ 0.666814] [&lt;fffffc0008298b4c&gt;] search_binary_handler+0xb4/0x24=
0<br>
&gt; [ 0.666823] [&lt;fffffc0008299864&gt;] do_execveat_common+0x63c/0x950<=
br>
&gt; [ 0.666832] [&lt;fffffc0008299bb4&gt;] do_execve+0x3c/0x50<br>
&gt; [ 0.666841] [&lt;fffffc00080e3720&gt;] call_usermodehelper_exec_async+=
0xe8/0x148<br>
&gt; [ 0.666850] [&lt;fffffc0008084a80&gt;] ret_from_fork+0x10/0x50<br>
&gt;<br>
&gt; This happens on every call to execve. This seems to be the first<br>
&gt; copy_to_user in<br>
&gt; create_elf_tables. I didn&#39;t get a chance to debug and I&#39;m goin=
g out of town<br>
&gt; all of next week so all I have is the report unfortunately. config att=
ached.<br>
&gt;<br>
<br>
</div></div>This is a known issue, and a fix is already queued for v4.8 in =
the arm64 tree:<br>
<br>
9fdc14c55c arm64: mm: fix location of _etext [0]<br>
<br>
which moves _etext up in the linker script so that it does not cover .rodat=
a<br>
<br>
ARM was suffering from the same problem, and Kees proposed a fix for<br>
it. I don&#39;t know what the status of that patch is, though.<br>
<br>
Note that on arm64, we have<br>
<br>
=C2=A0 #define ELF_PLATFORM=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (&quot=
;aarch64&quot;)<br>
<br>
which explains why k_platform points into .rodata in this case. On<br>
ARM, it points to a writable string (as the code quoted by Rik shows),<br>
so there it will likely explode elsewhere without the linker script<br>
fix.<br>
<br>
[0] <a href=3D"https://git.kernel.org/cgit/linux/kernel/git/arm64/linux.git=
/commit/?h=3Dfor-next/core&amp;id=3D9fdc14c55c" rel=3D"noreferrer" target=
=3D"_blank">https://git.kernel.org/cgit/linux/kernel/git/arm64/linux.git/co=
mmit/?h=3Dfor-next/core&amp;id=3D9fdc14c55c</a><br>
<span><font color=3D"#888888"><br>
--<br>
Ard.<br>
</font></span></blockquote></div><br></div>Ugh, I completely missed that no=
te about the patch on arm64. Sorry for the noise.<br><br>Thanks,<br>Laura</=
div>

--001a114b0e5c7a84e80537337986--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
