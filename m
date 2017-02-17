Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4026B0388
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 18:21:29 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id l25so33908872otd.1
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 15:21:29 -0800 (PST)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id a62si3267633otc.260.2017.02.17.15.21.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 15:21:28 -0800 (PST)
Received: by mail-oi0-x241.google.com with SMTP id u143so1145639oif.3
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 15:21:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrW91F0=GLWt4yBJVbt7U=E6nLXDUMNUvTpnmn6XLjaY6g@mail.gmail.com>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
 <20170217141328.164563-34-kirill.shutemov@linux.intel.com>
 <CA+55aFwgbHxV-Ha2n1H=Z7P6bgcQ3D8aW=fr8ZrQ5OnvZ1vOYg@mail.gmail.com>
 <CALCETrW6YBxZw0NJGHe92dy7qfHqRHNr0VqTKV=O4j9r8hcSew@mail.gmail.com>
 <CA+55aFxu0p90nz6-VPFLCLBSpEVx7vNFGP_M8j=YS-Dk-zfJGg@mail.gmail.com> <CALCETrW91F0=GLWt4yBJVbt7U=E6nLXDUMNUvTpnmn6XLjaY6g@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 17 Feb 2017 15:21:27 -0800
Message-ID: <CA+55aFw4hAe-SUp9K8kfgT+RO60Ow8c=Bi=ZTw9qzHy2D=h8pQ@mail.gmail.com>
Subject: Re: [PATCHv3 33/33] mm, x86: introduce PR_SET_MAX_VADDR and PR_GET_MAX_VADDR
Content-Type: multipart/alternative; boundary=001a113d328a51fe850548c22c1c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm <linux-mm@kvack.org>

--001a113d328a51fe850548c22c1c
Content-Type: text/plain; charset=UTF-8

On Feb 17, 2017 3:02 PM, "Andy Lutomirski" <luto@amacapital.net> wrote:


What I'm trying to say is: if we're going to do the route of 48-bit
limit unless a specific mmap call requests otherwise, can we at least
have an interface that doesn't suck?


No, I'm not suggesting specific mmap calls at all. I'm suggesting the
complete opposite: not having some magical "max address" at all in the VM
layer. Keep all the existing TASK_SIZE defines as-is, and just make those
be the new 56-bit limit.

But to then not make most processes use it, just make the default x86
arch_get_free_area() return an address limited to the old 47-bit limit. So
effectively all legacy programs work exactly the same way they always did.

Then there are escape mechanisms: the process control that expands
that x86 arch_get_free_area()
to give high addresses. That would be the normal thing.

But also, exactly *because* we don't make all those TASK_SIZE changes, you
could - if you wanted to - use MAP_FIXED to just allocate directly in high
virtual space. For example, maybe you just make your own private memory
allocator do that, and all the normal stuff would just continue to use the
low virtual addresses, and you wouldn't even bother with the prctl().

Because let's face it, the number of processes that will want the high
virtual addresses are going to be fairly few and specialised. Maybe even
those will want it only for special things (like mapping a huge area of
nonvolatile memory)

So I'm saying:

 - don't do all these magical TASK_SIZE things at all

 - don't need with generic mm code at all.

 - only change arch_get_free_area() to take one single process control
issue into account.

Keep it simple and stupid, and don't make this address side expansion
something that the core mm code needs to even know about.

    Linus

--001a113d328a51fe850548c22c1c
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><div class=3D"gmail_extra"><br><div class=3D"gma=
il_quote">On Feb 17, 2017 3:02 PM, &quot;Andy Lutomirski&quot; &lt;<a href=
=3D"mailto:luto@amacapital.net">luto@amacapital.net</a>&gt; wrote:<blockquo=
te class=3D"quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pa=
dding-left:1ex"><div class=3D"elided-text">
<br>
</div>What I&#39;m trying to say is: if we&#39;re going to do the route of =
48-bit<br>
limit unless a specific mmap call requests otherwise, can we at least<br>
have an interface that doesn&#39;t suck?<br>
</blockquote></div><br></div></div><div class=3D"gmail_extra" dir=3D"auto">=
No, I&#39;m not suggesting specific mmap calls at all. I&#39;m suggesting t=
he complete opposite: not having some magical &quot;max address&quot; at al=
l in the VM layer. Keep all the existing TASK_SIZE defines as-is, and just =
make those be the new 56-bit limit.</div><div class=3D"gmail_extra" dir=3D"=
auto"><br></div><div class=3D"gmail_extra" dir=3D"auto">But to then not mak=
e most processes use it, just make the default x86 arch_get_free_area() ret=
urn an address limited to the old 47-bit limit. So effectively all legacy p=
rograms work exactly the same way they always did.</div><div class=3D"gmail=
_extra" dir=3D"auto"><br></div><div class=3D"gmail_extra" dir=3D"auto">Then=
 there are escape mechanisms: the process control that expands that x86=C2=
=A0<span style=3D"font-family:sans-serif">arch_get_free_area() to give high=
 addresses. That would be the normal thing.</span></div><div class=3D"gmail=
_extra" dir=3D"auto"><span style=3D"font-family:sans-serif"><br></span></di=
v><div class=3D"gmail_extra" dir=3D"auto"><span style=3D"font-family:sans-s=
erif">But also, exactly *because* we don&#39;t make all those=C2=A0</span><=
span style=3D"font-family:sans-serif">TASK_SIZE changes, you could - if you=
 wanted to - use MAP_FIXED to just allocate directly in high virtual space.=
 For example, maybe you just make your own private memory allocator do that=
, and all the normal stuff would just continue to use the low virtual addre=
sses, and you wouldn&#39;t even bother with the prctl().</span></div><div c=
lass=3D"gmail_extra" dir=3D"auto"><span style=3D"font-family:sans-serif"><b=
r></span></div><div class=3D"gmail_extra" dir=3D"auto"><span style=3D"font-=
family:sans-serif">Because let&#39;s face it, the number of processes that =
will want the high virtual addresses are going to be fairly few and special=
ised. Maybe even those will want it only for special things (like mapping a=
 huge area of nonvolatile memory)</span></div><div class=3D"gmail_extra" di=
r=3D"auto"><span style=3D"font-family:sans-serif"><br></span></div><div cla=
ss=3D"gmail_extra" dir=3D"auto"><span style=3D"font-family:sans-serif">So I=
&#39;m saying:</span></div><div class=3D"gmail_extra" dir=3D"auto"><span st=
yle=3D"font-family:sans-serif"><br></span></div><div class=3D"gmail_extra" =
dir=3D"auto"><span style=3D"font-family:sans-serif">=C2=A0- don&#39;t do al=
l these magical TASK_SIZE things at all</span></div><div class=3D"gmail_ext=
ra" dir=3D"auto"><span style=3D"font-family:sans-serif"><br></span></div><d=
iv class=3D"gmail_extra" dir=3D"auto"><span style=3D"font-family:sans-serif=
">=C2=A0- don&#39;t need with generic mm code at all.</span></div><div clas=
s=3D"gmail_extra" dir=3D"auto"><span style=3D"font-family:sans-serif"><br><=
/span></div><div class=3D"gmail_extra" dir=3D"auto"><span style=3D"font-fam=
ily:sans-serif">=C2=A0- only change=C2=A0</span><span style=3D"font-family:=
sans-serif">arch_get_free_area() to take one single process control issue i=
nto account.</span></div><div class=3D"gmail_extra" dir=3D"auto"><span styl=
e=3D"font-family:sans-serif"><br></span></div><div class=3D"gmail_extra" di=
r=3D"auto"><font face=3D"sans-serif">Keep it simple and stupid, and don&#39=
;t make this address side expansion something that the core mm code needs t=
o even know about.</font></div><div class=3D"gmail_extra" dir=3D"auto"><fon=
t face=3D"sans-serif"><br></font></div><div class=3D"gmail_extra" dir=3D"au=
to"><font face=3D"sans-serif">=C2=A0 =C2=A0 Linus</font></div><div class=3D=
"gmail_extra" dir=3D"auto"><br></div></div>

--001a113d328a51fe850548c22c1c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
