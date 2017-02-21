Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id B50A46B0038
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 01:01:09 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id r141so170021626ita.6
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 22:01:09 -0800 (PST)
Received: from mail-it0-x229.google.com (mail-it0-x229.google.com. [2607:f8b0:4001:c0b::229])
        by mx.google.com with ESMTPS id j90si11003646ioo.193.2017.02.20.22.00.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Feb 2017 22:00:53 -0800 (PST)
Received: by mail-it0-x229.google.com with SMTP id y135so39295997itc.1
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 22:00:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+oaBQ+s5oXqu5TqddKs9LmUbaNNPGM7=gu5On4GYrkSDu0_XA@mail.gmail.com>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
 <20170217141328.164563-34-kirill.shutemov@linux.intel.com>
 <CA+55aFwgbHxV-Ha2n1H=Z7P6bgcQ3D8aW=fr8ZrQ5OnvZ1vOYg@mail.gmail.com>
 <CALCETrW6YBxZw0NJGHe92dy7qfHqRHNr0VqTKV=O4j9r8hcSew@mail.gmail.com>
 <CA+55aFxu0p90nz6-VPFLCLBSpEVx7vNFGP_M8j=YS-Dk-zfJGg@mail.gmail.com>
 <CALCETrW91F0=GLWt4yBJVbt7U=E6nLXDUMNUvTpnmn6XLjaY6g@mail.gmail.com> <CA+oaBQ+s5oXqu5TqddKs9LmUbaNNPGM7=gu5On4GYrkSDu0_XA@mail.gmail.com>
From: Michael Pratt <mpratt@google.com>
Date: Mon, 20 Feb 2017 22:00:12 -0800
Message-ID: <CALoThU9+jW_K7vH99PytuOojVrJvcygzHduwYd2dzfTHQfE2AQ@mail.gmail.com>
Subject: Re: [PATCHv3 33/33] mm, x86: introduce PR_SET_MAX_VADDR and PR_GET_MAX_VADDR
Content-Type: multipart/alternative; boundary=94eb2c08cd5646e3830549041a86
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: luto@amacapital.net
Cc: torvalds@linux-foundation.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, x86@kernel.org, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, hpa@zytor.com, ak@linux.intel.com, dave.hansen@intel.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, catalin.marinas@arm.com, linux-api@vger.kernel.org

--94eb2c08cd5646e3830549041a86
Content-Type: text/plain; charset=UTF-8

On Mon, Feb 20, 2017 at 9:21 PM, Michael Pratt <linux@pratt.im> wrote:

> On Fri, Feb 17, 2017 at 3:02 PM, Andy Lutomirski <luto@amacapital.net>
> wrote:
> > On Fri, Feb 17, 2017 at 1:01 PM, Linus Torvalds
> > <torvalds@linux-foundation.org> wrote:
> >> On Fri, Feb 17, 2017 at 12:12 PM, Andy Lutomirski <luto@amacapital.net>
> wrote:
> >>>
> >>> At the very least, I'd want to see
> >>> MAP_FIXED_BUT_DONT_BLOODY_UNMAP_ANYTHING.  I *hate* the current
> >>> interface.
> >>
> >> That's unrelated, but I guess w could add a MAP_NOUNMAP flag, and then
> >> you can use MAP_FIXED | MAP_NOUNMAP or something.
> >>
> >> But that has nothing to do with the 47-vs-56 bit issue.
> >>
> >>> How about MAP_LIMIT where the address passed in is interpreted as an
> >>> upper bound instead of a fixed address?
> >>
> >> Again, that's a unrelated semantic issue. Right now - if you don't
> >> pass in MAP_FIXED at all, the "addr" argument is used as a starting
> >> value for deciding where to find an unmapped area. But there is no way
> >> to specify the end. That would basically be what the process control
> >> thing would be (not per-system-call, but per-thread ).
> >>
> >
> > What I'm trying to say is: if we're going to do the route of 48-bit
> > limit unless a specific mmap call requests otherwise, can we at least
> > have an interface that doesn't suck?
>

I've got a set of patches that I've meant to send out as an RFC for a while
that tries to address userspace control of address space layout and covers
many of these ideas.

There is a new syscall and set of prctls for controlling the "mmap layout"
(i.e., get_unmapped_area search range) that look something like this:

struct mmap_layout {
unsigned long start;
unsigned long end;
/*
* These are equivalent to mmap_legacy_base and mmap_base,
* but are not really needed in this proposal.
*/
unsigned long low_base;
unsigned long high_base;
unsigned long flags;
};

/* For flags */
#define MMAP_TOPDOWN 1

struct layout_mmap_args {
unsigned long addr;
unsigned long len;
unsigned long prot;
unsigned long flags;
unsigned long fd;
unsigned long off;
struct mmap_layout layout;
};

void *layout_mmap(struct layout_mmap_args *args);

int prctl(PR_GET_MMAP_LAYOUT, struct mmap_layout *layout);
int prctl(PR_SET_MMAP_LAYOUT, struct mmap_layout *layout);

The prctls control the default range that mmap and friends will allocate.
For 56-bit user address space, it could default to [mmap_min_addr, 1<<47),
as Linus suggests. Applications that want the full address space can
increase it to cover the entire range.

The layout_mmap syscall allows one-off mappings that fall outside the
default layout, and nicely solves the "MAP_FIXED but don't unmap anything
problem" by passing an explicit range to check without actually setting
MAP_FIXED.

This idea is quite similar to the MAX_VADDR + default get_unmapped_area
behavior ides, just more generalized to give userspace more control over
the ultimate behavior of get_unmapped_area.


PS. Apologies if my email client screwed up this message. I didn't have
this thread in my client and have tried to import it from another account.

--94eb2c08cd5646e3830549041a86
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Mon, Feb 20, 2017 at 9:21 PM, Michael Pratt <span dir=3D"ltr">&lt;<a=
 href=3D"mailto:linux@pratt.im" target=3D"_blank">linux@pratt.im</a>&gt;</s=
pan> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0p=
x 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">On Fri, Fe=
b 17, 2017 at 3:02 PM, Andy Lutomirski &lt;<a href=3D"mailto:luto@amacapita=
l.net">luto@amacapital.net</a>&gt; wrote:<br>
&gt; On Fri, Feb 17, 2017 at 1:01 PM, Linus Torvalds<br>
&gt; &lt;<a href=3D"mailto:torvalds@linux-foundation.org">torvalds@linux-fo=
undation.org</a><wbr>&gt; wrote:<br>
&gt;&gt; On Fri, Feb 17, 2017 at 12:12 PM, Andy Lutomirski &lt;<a href=3D"m=
ailto:luto@amacapital.net">luto@amacapital.net</a>&gt; wrote:<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt; At the very least, I&#39;d want to see<br>
&gt;&gt;&gt; MAP_FIXED_BUT_DONT_BLOODY_<wbr>UNMAP_ANYTHING.=C2=A0 I *hate* =
the current<br>
&gt;&gt;&gt; interface.<br>
&gt;&gt;<br>
&gt;&gt; That&#39;s unrelated, but I guess w could add a MAP_NOUNMAP flag, =
and then<br>
&gt;&gt; you can use MAP_FIXED | MAP_NOUNMAP or something.<br>
&gt;&gt;<br>
&gt;&gt; But that has nothing to do with the 47-vs-56 bit issue.<br>
&gt;&gt;<br>
&gt;&gt;&gt; How about MAP_LIMIT where the address passed in is interpreted=
 as an<br>
&gt;&gt;&gt; upper bound instead of a fixed address?<br>
&gt;&gt;<br>
&gt;&gt; Again, that&#39;s a unrelated semantic issue. Right now - if you d=
on&#39;t<br>
&gt;&gt; pass in MAP_FIXED at all, the &quot;addr&quot; argument is used as=
 a starting<br>
&gt;&gt; value for deciding where to find an unmapped area. But there is no=
 way<br>
&gt;&gt; to specify the end. That would basically be what the process contr=
ol<br>
&gt;&gt; thing would be (not per-system-call, but per-thread ).<br>
&gt;&gt;<br>
&gt;<br>
&gt; What I&#39;m trying to say is: if we&#39;re going to do the route of 4=
8-bit<br>
&gt; limit unless a specific mmap call requests otherwise, can we at least<=
br>
&gt; have an interface that doesn&#39;t suck?<br></blockquote><div><br></di=
v><div>I&#39;ve got a set of patches that I&#39;ve meant to send out as an =
RFC for a while that tries to address userspace control of address space la=
yout and covers many of these ideas.</div><div><br></div><div>There is a ne=
w syscall and set of prctls for controlling the &quot;mmap layout&quot; (i.=
e., get_unmapped_area search range) that look something like this:</div><di=
v><br></div><div><div>struct mmap_layout {</div><div><span class=3D"gmail-A=
pple-tab-span" style=3D"white-space:pre">	</span>unsigned long start;</div>=
<div><span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</span=
>unsigned long end;</div><div><span style=3D"white-space:pre">	 /*</span></=
div><div><span style=3D"white-space:pre">	 * </span><span style=3D"white-sp=
ace:pre">These are equivalent to mmap_legacy_base and mmap_base,</span><br>=
</div><div><span style=3D"white-space:pre">	 * but are not really needed in=
 this proposal.</span></div><div><span style=3D"white-space:pre">	 */</span=
><span style=3D"white-space:pre"> </span><span style=3D"white-space:pre"><b=
r></span></div><div><span class=3D"gmail-Apple-tab-span" style=3D"white-spa=
ce:pre">	</span>unsigned long low_base;</div><div><span class=3D"gmail-Appl=
e-tab-span" style=3D"white-space:pre">	</span>unsigned long high_base;</div=
><div><span class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</spa=
n>unsigned long flags;</div><div>};</div><div><br></div><div>/* For flags *=
/</div><div>#define MMAP_TOPDOWN<span class=3D"gmail-Apple-tab-span" style=
=3D"white-space:pre">	</span>1</div><div><br></div><div>struct layout_mmap_=
args {</div><div><span class=3D"gmail-Apple-tab-span" style=3D"white-space:=
pre">	</span>unsigned long addr;</div><div><span class=3D"gmail-Apple-tab-s=
pan" style=3D"white-space:pre">	</span>unsigned long len;</div><div><span c=
lass=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</span>unsigned lo=
ng prot;</div><div><span class=3D"gmail-Apple-tab-span" style=3D"white-spac=
e:pre">	</span>unsigned long flags;</div><div><span class=3D"gmail-Apple-ta=
b-span" style=3D"white-space:pre">	</span>unsigned long fd;</div><div><span=
 class=3D"gmail-Apple-tab-span" style=3D"white-space:pre">	</span>unsigned =
long off;</div><div><span class=3D"gmail-Apple-tab-span" style=3D"white-spa=
ce:pre">	</span>struct mmap_layout layout;</div><div>};</div></div><div><br=
></div><div>void *layout_mmap(struct layout_mmap_args *args);<br></div><div=
><br></div><div>int prctl(PR_GET_MMAP_LAYOUT, struct mmap_layout *layout);<=
/div><div>int prctl(PR_SET_MMAP_LAYOUT, struct mmap_layout *layout);</div><=
div><br></div><div>The prctls control the default range that mmap and frien=
ds will allocate. For 56-bit user address space, it could default to [mmap_=
min_addr, 1&lt;&lt;47), as Linus suggests. Applications that want the full =
address space can increase it to cover the entire range.</div><div><br></di=
v><div>The layout_mmap syscall allows one-off mappings that fall outside th=
e default layout, and nicely solves the &quot;MAP_FIXED but don&#39;t unmap=
 anything problem&quot; by passing an explicit range to check without actua=
lly setting MAP_FIXED.</div><div><br></div><div>This idea is quite similar =
to the MAX_VADDR + default get_unmapped_area behavior ides, just more gener=
alized to give userspace more control over the ultimate behavior of get_unm=
apped_area.</div><div><br></div><div><br></div></div>PS. Apologies if my em=
ail client screwed up this message. I didn&#39;t have this thread in my cli=
ent and have tried to import it from another account.</div></div>

--94eb2c08cd5646e3830549041a86--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
