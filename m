Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1B25E6B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 12:37:14 -0500 (EST)
Received: by obcwo20 with SMTP id wo20so1253341obc.5
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 09:37:13 -0800 (PST)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id n9si718796obr.70.2015.03.03.09.37.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Mar 2015 09:37:13 -0800 (PST)
Received: by oifz81 with SMTP id z81so837842oif.0
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 09:37:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1503031041340.14643@gentwo.org>
References: <54F57716.80809@samsung.com> <CACT4Y+YQ3cuUvRrT_19RbxFVWHGnzviSFi0-ud88jq9g9jUZog@mail.gmail.com>
 <54F5D5CC.6070901@samsung.com> <alpine.DEB.2.11.1503031041340.14643@gentwo.org>
From: Dmitry Chernenkov <dmitryc@google.com>
Date: Tue, 3 Mar 2015 21:36:52 +0400
Message-ID: <CAA6XgkFRWGZnfpaH5bBSah9SEMpvaJc6CvsaZDXgK-B3mQNYig@mail.gmail.com>
Subject: Re: [RFC] slub memory quarantine
Content-Type: multipart/alternative; boundary=001a11c2ee9ef37575051065c8fd
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Sasha Levin <sasha.levin@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>, LKML <linux-kernel@vger.kernel.org>

--001a11c2ee9ef37575051065c8fd
Content-Type: text/plain; charset=UTF-8

I'm working on a different set of tools for KASan, independent of
slub_debug (so it can be turned off either by cmdline flag or kernel
config). Most of the ideas are taken from the userspace ASan.

- Use our own data structures (metadata, redzones, stacks, quarantine), so
the same code works in SLAB/SLUB, and Kasan is less dependent on allocator
internals.
- Redzone size is flexible based on object size.
- Store alloc/free stacks separately, in a compact structure (stack depot)
and index them via a hashtable, so we don't store identical stacks multiple
times. SLUB_DEBUG stacks have overhead of 256 bytes per object. Stack depot
takes ~100 times less.
- Quarantine is global (not per-slab or per-cache), with per-cpu queues
periodically flushed into a global one. kmem_cache_destroy and
kmem_cache_shrink launch a scan of quarantine to return all objects from
associated caches to the freelist. Thus, we don't need a separate shrinker
hook.



On Tue, Mar 3, 2015 at 7:42 PM, Christoph Lameter <cl@linux.com> wrote:

> On Tue, 3 Mar 2015, Andrey Ryabinin wrote:
>
> > On 03/03/2015 12:10 PM, Dmitry Vyukov wrote:
> > > Please hold on with this.
> > > Dmitry Chernenkov is working on a quarantine that works with both slub
> > > and slab, does not cause spurious OOMs and does not depend on
> > > slub-debug which has unacceptable performance (acquires global lock).
> >
> > I think that it's a separate issue. KASan already depend on slub_debug -
> it required for redzones/user tracking.
> > I think that some parts slub debugging (like user tracking and this
> quarantine)
> > could be moved (for CONFIG_KASAN=y) to the fast path without any locking.
>
> In general these features need to be ifdeffed out since they add
> significant overhead for the data structures and execution paths.
>
>

--001a11c2ee9ef37575051065c8fd
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">I&#39;m working on a different set of tools for KASan, ind=
ependent of slub_debug (so it can be turned off either by cmdline flag or k=
ernel config). Most of the ideas are taken from the userspace ASan.<div><br=
><div>- Use our own data structures (metadata, redzones, stacks, quarantine=
), so the same code works in SLAB/SLUB, and Kasan is less dependent on allo=
cator internals.</div><div>- Redzone size is flexible based on object size.=
</div><div>- Store alloc/free stacks separately, in a compact structure (st=
ack depot) and index them via a hashtable, so we don&#39;t store identical =
stacks multiple times. SLUB_DEBUG stacks have overhead of 256 bytes per obj=
ect. Stack depot takes ~100 times less.</div><div>- Quarantine is global (n=
ot per-slab or per-cache), with per-cpu queues periodically flushed into a =
global one. kmem_cache_destroy and kmem_cache_shrink launch a scan of quara=
ntine to return all objects from associated caches to the freelist. Thus, w=
e don&#39;t need a separate shrinker hook.</div><div><br></div><div><br></d=
iv></div></div><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">On=
 Tue, Mar 3, 2015 at 7:42 PM, Christoph Lameter <span dir=3D"ltr">&lt;<a hr=
ef=3D"mailto:cl@linux.com" target=3D"_blank">cl@linux.com</a>&gt;</span> wr=
ote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border=
-left:1px #ccc solid;padding-left:1ex"><span class=3D"">On Tue, 3 Mar 2015,=
 Andrey Ryabinin wrote:<br>
<br>
&gt; On 03/03/2015 12:10 PM, Dmitry Vyukov wrote:<br>
&gt; &gt; Please hold on with this.<br>
&gt; &gt; Dmitry Chernenkov is working on a quarantine that works with both=
 slub<br>
&gt; &gt; and slab, does not cause spurious OOMs and does not depend on<br>
&gt; &gt; slub-debug which has unacceptable performance (acquires global lo=
ck).<br>
&gt;<br>
&gt; I think that it&#39;s a separate issue. KASan already depend on slub_d=
ebug - it required for redzones/user tracking.<br>
&gt; I think that some parts slub debugging (like user tracking and this qu=
arantine)<br>
&gt; could be moved (for CONFIG_KASAN=3Dy) to the fast path without any loc=
king.<br>
<br>
</span>In general these features need to be ifdeffed out since they add<br>
significant overhead for the data structures and execution paths.<br>
<br>
</blockquote></div><br></div>

--001a11c2ee9ef37575051065c8fd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
