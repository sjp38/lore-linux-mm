Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F42B6B0007
	for <linux-mm@kvack.org>; Sat, 28 Apr 2018 15:10:59 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id e32-v6so3246071ote.23
        for <linux-mm@kvack.org>; Sat, 28 Apr 2018 12:10:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a37-v6sor1843009otj.274.2018.04.28.12.10.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 28 Apr 2018 12:10:58 -0700 (PDT)
MIME-Version: 1.0
References: <20180426215406.GB27853@wotan.suse.de> <20180427053556.GB11339@infradead.org>
 <20180427161456.GD27853@wotan.suse.de> <20180428084221.GD31684@infradead.org> <20180428185514.GW27853@wotan.suse.de>
In-Reply-To: <20180428185514.GW27853@wotan.suse.de>
From: Matthew Wilcox <willy6545@gmail.com>
Date: Sat, 28 Apr 2018 19:10:47 +0000
Message-ID: <CAFhKne8u7KcBkpgiQ0fFZyh5_EorfY-_MJJaEYk3feCOd9LsRQ@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC NOTES] x86 ZONE_DMA love
Content-Type: multipart/alternative; boundary="00000000000071872f056aed61da"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, Dan Carpenter <dan.carpenter@oracle.com>, Julia Lawall <julia.lawall@lip6.fr>, linux-mm@kvack.org, mhocko@kernel.org, cl@linux.com, Jan Kara <jack@suse.cz>, matthew@wil.cx, x86@kernel.org, luto@amacapital.net, martin.petersen@oracle.com, jthumshirn@suse.de, broonie@kernel.org, Juergen Gross <jgross@suse.com>, linux-spi@vger.kernel.org, Joerg Roedel <joro@8bytes.org>, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>

--00000000000071872f056aed61da
Content-Type: text/plain; charset="UTF-8"

Another way we could approach this is to get rid of ZONE_DMA. Make GFP_DMA
a flag which doesn't map to a zone. Rather, it redirects to a separate
allocator. At boot, we hand all memory under 16MB to the DMA allocator. The
DMA allocator can have a shrinker which just hands back all the memory once
we're under memory pressure (if it's never had an allocation).

I think we can get rid of the GFP_DMA support in slab/slub. We still need
to be able to allocate pages to support bounce buffers / dma_alloc_foo, but
there's really no reason to allocate sub-pages at this point.

On Sat, Apr 28, 2018, 14:55 Luis R. Rodriguez, <mcgrof@kernel.org> wrote:

> On Sat, Apr 28, 2018 at 01:42:21AM -0700, Christoph Hellwig wrote:
> > On Fri, Apr 27, 2018 at 04:14:56PM +0000, Luis R. Rodriguez wrote:
> > > Do we have a list of users for x86 with a small DMA mask?
> > > Or, given that I'm not aware of a tool to be able to look
> > > for this in an easy way, would it be good to find out which
> > > x86 drivers do have a small mask?
> >
> > Basically you'll have to grep for calls to dma_set_mask/
> > dma_set_coherent_mask/dma_set_mask_and_coherent and their pci_*
> > wrappers with masks smaller 32-bit.  Some use numeric values,
> > some use DMA_BIT_MASK and various places uses local variables
> > or struct members to parse them, so finding them will be a bit
> > more work.  Nothing a coccinelle expert couldn't solve, though :)
>
> Thing is unless we have a specific flag used consistently I don't believe
> we
> can do this search with Coccinelle. ie, if we have local variables and
> based on
> some series of variables things are set, this makes the grammatical
> expression
> difficult to express.  So Cocinelle is not designed for this purpose.
>
> But I believe smatch [0] is intended exactly for this sort of purpose, is
> that
> right Dan? I gave a cursory look and I think it'd take me significant time
> to
> get such hunt down.
>
> [0] https://lwn.net/Articles/691882/
>
>   Luis
>

--00000000000071872f056aed61da
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto">Another way we could approach this is to get rid of ZONE_=
DMA. Make GFP_DMA a flag which doesn&#39;t map to a zone. Rather, it redire=
cts to a separate allocator. At boot, we hand all memory under 16MB to the =
DMA allocator. The DMA allocator can have a shrinker which just hands back =
all the memory once we&#39;re under memory pressure (if it&#39;s never had =
an allocation).<div dir=3D"auto"><br></div><div dir=3D"auto">I think we can=
 get rid of the GFP_DMA support in slab/slub. We still need to be able to a=
llocate pages to support bounce buffers / dma_alloc_foo, but there&#39;s re=
ally no reason to allocate sub-pages at this point.</div></div><br><div cla=
ss=3D"gmail_quote"><div dir=3D"ltr">On Sat, Apr 28, 2018, 14:55 Luis R. Rod=
riguez, &lt;<a href=3D"mailto:mcgrof@kernel.org">mcgrof@kernel.org</a>&gt; =
wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8e=
x;border-left:1px #ccc solid;padding-left:1ex">On Sat, Apr 28, 2018 at 01:4=
2:21AM -0700, Christoph Hellwig wrote:<br>
&gt; On Fri, Apr 27, 2018 at 04:14:56PM +0000, Luis R. Rodriguez wrote:<br>
&gt; &gt; Do we have a list of users for x86 with a small DMA mask?<br>
&gt; &gt; Or, given that I&#39;m not aware of a tool to be able to look<br>
&gt; &gt; for this in an easy way, would it be good to find out which<br>
&gt; &gt; x86 drivers do have a small mask?<br>
&gt; <br>
&gt; Basically you&#39;ll have to grep for calls to dma_set_mask/<br>
&gt; dma_set_coherent_mask/dma_set_mask_and_coherent and their pci_*<br>
&gt; wrappers with masks smaller 32-bit.=C2=A0 Some use numeric values,<br>
&gt; some use DMA_BIT_MASK and various places uses local variables<br>
&gt; or struct members to parse them, so finding them will be a bit<br>
&gt; more work.=C2=A0 Nothing a coccinelle expert couldn&#39;t solve, thoug=
h :)<br>
<br>
Thing is unless we have a specific flag used consistently I don&#39;t belie=
ve we<br>
can do this search with Coccinelle. ie, if we have local variables and base=
d on<br>
some series of variables things are set, this makes the grammatical express=
ion<br>
difficult to express.=C2=A0 So Cocinelle is not designed for this purpose.<=
br>
<br>
But I believe smatch [0] is intended exactly for this sort of purpose, is t=
hat<br>
right Dan? I gave a cursory look and I think it&#39;d take me significant t=
ime to<br>
get such hunt down.<br>
<br>
[0] <a href=3D"https://lwn.net/Articles/691882/" rel=3D"noreferrer noreferr=
er" target=3D"_blank">https://lwn.net/Articles/691882/</a><br>
<br>
=C2=A0 Luis<br>
</blockquote></div>

--00000000000071872f056aed61da--
