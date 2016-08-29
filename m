Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA8C83102
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 11:25:23 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o1so322641097qkd.3
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 08:25:23 -0700 (PDT)
Received: from mail-yw0-x234.google.com (mail-yw0-x234.google.com. [2607:f8b0:4002:c05::234])
        by mx.google.com with ESMTPS id w192si10015508ywa.243.2016.08.29.08.25.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 08:25:22 -0700 (PDT)
Received: by mail-yw0-x234.google.com with SMTP id u134so87944558ywg.3
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 08:25:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160826213227.GA11393@node.shutemov.name>
References: <1472229004-9658-1-git-send-email-robert.foss@collabora.com> <20160826213227.GA11393@node.shutemov.name>
From: Will Drewry <wad@chromium.org>
Date: Mon, 29 Aug 2016 10:25:02 -0500
Message-ID: <CAAFS_9HiuMt=Xy=YXmvw0+kqcXw=8qXTx2-2bXaqPc_rjtRZgw@mail.gmail.com>
Subject: Re: [PATCH v1] mm, sysctl: Add sysctl for controlling VM_MAYEXEC taint
Content-Type: multipart/alternative; boundary=001a1141c57cfbafc5053b377829
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Robert Foss <robert.foss@collabora.com>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, vbabka@suse.cz, mhocko@suse.com, mingo@kernel.org, dave.hansen@linux.intel.com, hannes@cmpxchg.org, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, acme@redhat.com, Kees Cook <keescook@chromium.org>, mgorman@techsingularity.net, atomlin@redhat.com, Hugh Dickins <hughd@google.com>, dyoung@redhat.com, Al Viro <viro@zeniv.linux.org.uk>, Daniel Cashman <dcashman@google.com>, w@1wt.eu, idryomov@gmail.com, yang.shi@linaro.org, vkuznets@redhat.com, vdavydov@virtuozzo.com, vitalywool@gmail.com, oleg@redhat.com, gang.chen.5i5j@gmail.com, koct9i@gmail.com, aarcange@redhat.com, aryabinin@virtuozzo.com, kuleshovmail@gmail.com, minchan@kernel.org, mguzik@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ivan Krasin <krasin@google.com>, Roland McGrath <mcgrathr@chromium.org>, Mandeep Singh Baines <msb@chromium.org>, Ben Zhang <benzh@chromium.org>, Filipe Brandenburger <filbranden@chromium.org>

--001a1141c57cfbafc5053b377829
Content-Type: text/plain; charset=UTF-8

On Fri, Aug 26, 2016 at 4:32 PM, Kirill A. Shutemov <kirill@shutemov.name>
wrote:

> On Fri, Aug 26, 2016 at 12:30:04PM -0400, robert.foss@collabora.com wrote:
> > From: Will Drewry <wad@chromium.org>
> >
> > This patch proposes a sysctl knob that allows a privileged user to
> > disable ~VM_MAYEXEC tainting when mapping in a vma from a MNT_NOEXEC
> > mountpoint.  It does not alter the normal behavior resulting from
> > attempting to directly mmap(PROT_EXEC) a vma (-EPERM) nor the behavior
> > of any other subsystems checking MNT_NOEXEC.
>
> Wouldn't it be equal to remounting all filesystems without noexec from
> attacker POV? It's hardly a fence to make additional mprotect(PROT_EXEC)
> call, before starting executing code from such filesystems.
>
> If administrator of the system wants this, he can just mount filesystem
> without noexec, no new kernel code required. And it's more fine-grained
> than this.
>
> So, no, I don't think we should add knob like this. Unless I miss
> something.
>

I don't believe this patch is necessary anymore (though, thank you Robert
for testing and re-sending!).

The primary offenders wrt to needing to mmap/mprotect a file in /dev/shm
was the older nvidia
driver (binary only iirc) and the Chrome Native Client code.

The reason why half-exec is an "ok" (half) mitigation is because it blocks
simple gadgets and other paths for using loadable libraries or binaries
(via glibc) as it disallows mmap(PROT_EXEC) even though it allows
mprotect(PROT_EXEC).  This stops ld in its tracks since it does the obvious
thing and uses mmap(PROT_EXEC).

I think time has marched on and this patch is now something I can toss in
the dustbin of history. Both Chrome's Native Client and an older nvidia
driver relied on creating-then-unlinking a file in tmpfs, but there is now
a better facility!


> NAK.
>

Agreed - this is old and software that predicated it should be gone.. I
hope. :)


>
> > It is motivated by a common /dev/shm, /tmp usecase. There are few
> > facilities for creating a shared memory segment that can be remapped in
> > the same process address space with different permissions.
>
> What about using memfd_create(2) for such cases? You'll get a file
> descriptor from in-kernel tmpfs (shm_mnt) which is not exposed to
> userspace for remount as noexec.
>

This is a relatively old patch ( https://lwn.net/Articles/455256/ ) which
predated memfd_create().  memfd_create() is the right solution to this
problem!


Thanks again!
will

--001a1141c57cfbafc5053b377829
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Fri, Aug 26, 2016 at 4:32 PM, Kirill A. Shutemov <span dir=3D"ltr">&=
lt;<a href=3D"mailto:kirill@shutemov.name" target=3D"_blank">kirill@shutemo=
v.name</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"=
margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-lef=
t:1ex"><span class=3D"m_-2285366891106984446gmail-">On Fri, Aug 26, 2016 at=
 12:30:04PM -0400, <a href=3D"mailto:robert.foss@collabora.com" target=3D"_=
blank">robert.foss@collabora.com</a> wrote:<br>
&gt; From: Will Drewry &lt;<a href=3D"mailto:wad@chromium.org" target=3D"_b=
lank">wad@chromium.org</a>&gt;<br>
&gt;<br>
&gt; This patch proposes a sysctl knob that allows a privileged user to<br>
&gt; disable ~VM_MAYEXEC tainting when mapping in a vma from a MNT_NOEXEC<b=
r>
&gt; mountpoint.=C2=A0 It does not alter the normal behavior resulting from=
<br>
&gt; attempting to directly mmap(PROT_EXEC) a vma (-EPERM) nor the behavior=
<br>
&gt; of any other subsystems checking MNT_NOEXEC.<br>
<br>
</span>Wouldn&#39;t it be equal to remounting all filesystems without noexe=
c from<br>
attacker POV? It&#39;s hardly a fence to make additional mprotect(PROT_EXEC=
)<br>
call, before starting executing code from such filesystems.<br>
<br>
If administrator of the system wants this, he can just mount filesystem<br>
without noexec, no new kernel code required. And it&#39;s more fine-grained=
<br>
than this.<br>
<br>
So, no, I don&#39;t think we should add knob like this. Unless I miss<br>
something.<br></blockquote><div><br></div><div>I don&#39;t believe this pat=
ch is necessary anymore (though, thank you Robert for testing and re-sendin=
g!).=C2=A0</div><div><br></div><div>The primary offenders wrt to needing to=
 mmap/mprotect a file in /dev/shm was the older nvidia</div><div>driver (bi=
nary only iirc) and the Chrome Native Client code.</div><div><br></div><div=
>The reason why half-exec is an &quot;ok&quot; (half) mitigation is because=
 it blocks simple gadgets and other paths for using loadable libraries or b=
inaries (via glibc) as it disallows mmap(PROT_EXEC) even though it allows m=
protect(PROT_EXEC).=C2=A0 This stops ld in its tracks since it does the obv=
ious thing and uses mmap(PROT_EXEC).</div><div><br></div><div>I think time =
has marched on and this patch is now something I can toss in the dustbin of=
 history. Both Chrome&#39;s Native Client and an older nvidia driver relied=
 on creating-then-unlinking a file in tmpfs, but there is now a better faci=
lity!</div><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"marg=
in:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1e=
x">
NAK.<br></blockquote><div><br></div><div>Agreed - this is old and software =
that predicated it should be gone.. I hope. :)</div><div>=C2=A0</div><block=
quote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1=
px solid rgb(204,204,204);padding-left:1ex">
<span class=3D"m_-2285366891106984446gmail-"><br>
&gt; It is motivated by a common /dev/shm, /tmp usecase. There are few<br>
&gt; facilities for creating a shared memory segment that can be remapped i=
n<br>
&gt; the same process address space with different permissions.<br>
<br>
</span>What about using memfd_create(2) for such cases? You&#39;ll get a fi=
le<br>
descriptor from in-kernel tmpfs (shm_mnt) which is not exposed to<br>
userspace for remount as noexec.<br></blockquote><div><br></div><div>This i=
s a relatively old patch (=C2=A0<a href=3D"https://lwn.net/Articles/455256/=
" target=3D"_blank">https://lwn.net/Articles/<wbr>455256/</a> ) which preda=
ted memfd_create(). =C2=A0memfd_create() is the right solution to this prob=
lem!</div><div><br></div><div><br></div><div>Thanks again!</div><div>will</=
div></div></div></div>

--001a1141c57cfbafc5053b377829--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
