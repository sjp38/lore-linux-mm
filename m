Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 839448E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 11:34:45 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id y46-v6so4352328qth.9
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 08:34:45 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n26-v6sor7285691qtf.90.2018.09.19.08.34.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 08:34:44 -0700 (PDT)
MIME-Version: 1.0
References: <20180820212556.GC2230@char.us.oracle.com> <CA+55aFxZCyVZc4ZpRyZ3uDyakRSOG_=2XvnwMo4oejpsieF9=A@mail.gmail.com>
 <1534801939.10027.24.camel@amazon.co.uk> <20180919010337.GC8537@350D>
In-Reply-To: <20180919010337.GC8537@350D>
From: Jonathan Adams <jwadams@google.com>
Date: Wed, 19 Sep 2018 08:34:31 -0700
Message-ID: <CA+VK+GPukeN9iaOAO5VbVqYy9Pp5ig3NOGhmoUXOaM_yBZgAtw@mail.gmail.com>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
Content-Type: multipart/alternative; boundary="00000000000033ac2605763b25e7"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bsingharora@gmail.com
Cc: dwmw@amazon.co.uk, torvalds@linux-foundation.org, konrad.wilk@oracle.com, juerg.haefliger@hpe.com, deepa.srinivasan@oracle.com, Jim Mattson <jmattson@google.com>, andrew.cooper3@citrix.com, linux-kernel@vger.kernel.org, boris.ostrovsky@oracle.com, linux-mm@kvack.org, tglx@linutronix.de, joao.m.martins@oracle.com, pradeep.vincent@oracle.com, ak@linux.intel.com, khalid.aziz@oracle.com, kanth.ghatraju@oracle.com, liran.alon@oracle.com, keescook@google.com, jsteckli@os.inf.tu-dresden.de, kernel-hardening@lists.openwall.com, chris.hyser@oracle.com, tyhicks@canonical.com, john.haxby@oracle.com, jcm@redhat.com

--00000000000033ac2605763b25e7
Content-Type: text/plain; charset="UTF-8"

On Tue, Sep 18, 2018 at 6:03 PM Balbir Singh <bsingharora@gmail.com> wrote:

> On Mon, Aug 20, 2018 at 09:52:19PM +0000, Woodhouse, David wrote:
> > On Mon, 2018-08-20 at 14:48 -0700, Linus Torvalds wrote:
> > >
> > > Of course, after the long (and entirely unrelated) discussion about
> > > the TLB flushing bug we had, I'm starting to worry about my own
> > > competence, and maybe I'm missing something really fundamental, and
> > > the XPFO patches do something else than what I think they do, or my
> > > "hey, let's use our Meltdown code" idea has some fundamental weakness
> > > that I'm missing.
> >
> > The interesting part is taking the user (and other) pages out of the
> > kernel's 1:1 physmap.
> >
> > It's the *kernel* we don't want being able to access those pages,
> > because of the multitude of unfixable cache load gadgets.
>
> I am missing why we need this since the kernel can't access
> (SMAP) unless we go through to the copy/to/from interface
> or execute any of the user pages. Is it because of the dependency
> on the availability of those features?
>
> SMAP protects against kernel accesses to non-PRIV (i.e. userspace)
mappings, but that isn't relevant to what's being discussed here.

Davis is talking about the kernel Direct Map, which is a PRIV (i.e. kernel)
mapping of all physical memory on the system, at VA = (base + PA).  Since
this mapping exists for all physical addresses, speculative load gadgets
(and the processor's prefetch mechanism, etc.) can load arbitrary data even
if it is only otherwise mapped into user space.

XPFO fixes this by unmapping the Direct Map translations when the page is
allocated as a user page. The mapping is only restored:
   1. temporarily re-if the kernel needs direct access to the page (i.e. to
zero it, access it from a device driver, etc),
   2. when the page is freed

And in to doing, significantly reduces the amount of non-kernel data
vulnerable to speculative execution attacks against the kernel.  (and
reduces what data can be loaded into the L1 data cache while in kernel
mode, to be peeked at by the recent L1 Terminal Fault vulnerability).

Does that make sense?

Cheers,
- jonathan

--00000000000033ac2605763b25e7
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><br><div class=3D"gmail_quote"><div dir=3D"ltr">On Tue=
, Sep 18, 2018 at 6:03 PM Balbir Singh &lt;<a href=3D"mailto:bsingharora@gm=
ail.com">bsingharora@gmail.com</a>&gt; wrote:<br></div><blockquote class=3D=
"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(2=
04,204,204);padding-left:1ex">On Mon, Aug 20, 2018 at 09:52:19PM +0000, Woo=
dhouse, David wrote:<br>
&gt; On Mon, 2018-08-20 at 14:48 -0700, Linus Torvalds wrote:<br>
&gt; &gt; <br>
&gt; &gt; Of course, after the long (and entirely unrelated) discussion abo=
ut<br>
&gt; &gt; the TLB flushing bug we had, I&#39;m starting to worry about my o=
wn<br>
&gt; &gt; competence, and maybe I&#39;m missing something really fundamenta=
l, and<br>
&gt; &gt; the XPFO patches do something else than what I think they do, or =
my<br>
&gt; &gt; &quot;hey, let&#39;s use our Meltdown code&quot; idea has some fu=
ndamental weakness<br>
&gt; &gt; that I&#39;m missing.<br>
&gt; <br>
&gt; The interesting part is taking the user (and other) pages out of the<b=
r>
&gt; kernel&#39;s 1:1 physmap.<br>
&gt; <br>
&gt; It&#39;s the *kernel* we don&#39;t want being able to access those pag=
es,<br>
&gt; because of the multitude of unfixable cache load gadgets.<br>
<br>
I am missing why we need this since the kernel can&#39;t access<br>
(SMAP) unless we go through to the copy/to/from interface<br>
or execute any of the user pages. Is it because of the dependency<br>
on the availability of those features?<br><br></blockquote><div>SMAP protec=
ts against kernel accesses to non-PRIV (i.e. userspace) mappings, but that =
isn&#39;t relevant to what&#39;s being discussed here.=C2=A0</div><div><br>=
</div><div>Davis=C2=A0is talking about the kernel Direct Map, which is a PR=
IV (i.e. kernel) mapping of all physical memory on the system, at VA =3D (b=
ase=C2=A0+ PA).=C2=A0 Since this mapping exists for all physical addresses,=
 speculative load gadgets (and the processor&#39;s prefetch mechanism, etc.=
) can load arbitrary data even if it is only otherwise mapped into user spa=
ce.</div><div><br></div><div>XPFO fixes this by unmapping the Direct Map tr=
anslations when the page is allocated as a user page. The mapping is only r=
estored:</div><div>=C2=A0 =C2=A01. temporarily re-if the kernel needs direc=
t access to the page (i.e. to zero it, access it from a device driver, etc)=
,</div><div>=C2=A0 =C2=A02. when the page is freed</div><div><br></div><div=
>And in to doing, significantly reduces the amount of non-kernel data vulne=
rable to speculative execution attacks against the kernel.=C2=A0 (and reduc=
es what data can be loaded into the L1 data cache while in kernel mode, to =
be peeked at by the recent L1 Terminal Fault vulnerability).</div><div><br>=
</div><div>Does that make sense?</div><div><br></div><div>Cheers,</div><div=
>- jonathan</div><div><br></div></div></div>

--00000000000033ac2605763b25e7--
