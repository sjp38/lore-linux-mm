Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3C7026B00A4
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 11:24:08 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id i13so5465438qae.33
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 08:24:07 -0700 (PDT)
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
        by mx.google.com with ESMTPS id l52si8763409qge.135.2014.03.17.08.24.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 08:24:07 -0700 (PDT)
Received: by mail-qc0-f181.google.com with SMTP id e9so5964751qcy.26
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 08:24:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140317144551.GG6091@linux.intel.com>
References: <1394838199-29102-1-git-send-email-toshi.kani@hp.com>
	<20140314233233.GA8310@node.dhcp.inet.fi>
	<20140316024613.GF6091@linux.intel.com>
	<20140317114321.GA30191@node.dhcp.inet.fi>
	<20140317144551.GG6091@linux.intel.com>
Date: Mon, 17 Mar 2014 17:24:07 +0200
Message-ID: <CAON-v2zuknEAEKRCnCzA+KTEjD8Cq-MukmX6BicZ6zpewsLs2w@mail.gmail.com>
Subject: Re: [RFC PATCH] Support map_pages() for DAX
From: Amit Golander <amit@plexistor.com>
Content-Type: multipart/alternative; boundary=089e0149c39cad973704f4cf027f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Toshi Kani <toshi.kani@hp.com>, kirill.shutemov@linux.intel.com, david@fromorbit.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--089e0149c39cad973704f4cf027f
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Mar 17, 2014 at 4:45 PM, Matthew Wilcox <willy@linux.intel.com>wrote:

> On Mon, Mar 17, 2014 at 01:43:21PM +0200, Kirill A. Shutemov wrote:
> > On Sat, Mar 15, 2014 at 10:46:13PM -0400, Matthew Wilcox wrote:
> > > I'm actually working on this now.  The basic idea is to put an entry in
> > > the radix tree for each page.  For zero pages, that's a pagecache page.
> > > For pages that map to the media, it's an exceptional entry.  Radix tree
> > > exceptional entries take two bits, leaving us with 30 or 62 bits
> depending
> > > on sizeof(void *).  We can then take two more bits for Dirty and Lock,
> > > leaving 28 or 60 bits that we can use to cache the PFN on the page,
> > > meaning that we won't have to call the filesystem's get_block as often.
> >
> > Sound reasonable to me. Implementation of ->map_pages should be trivial
> > with this.
> >
> > Few questions:
> >  - why would you need Dirty for DAX?
>
> One of the areas ignored by the original XIP code was CPU caches.  Maybe
> s390 has write-through caches or something, but on x86 we need to write
> back
> the lines from the CPU cache to the memory on an msync().  We'll also need
> to do this for a write(), although that's a SMOP.
>

Indeed CLFLUSH has to be used extensively in order to guarantee that the
data is seen by the memory controller. This adds many instructions to the
execution path, and more importantly is associated with a substantial
latency penalty. This sub-optimal behavior derives from the current
hardware implementation (e.g Intel E5-26xx v2), which does not ADR-protect
WB caches. Hopefully, in the future, processor vendors will extend the ADR
protection to the WB caches, which will free us from the need to CLFLUSH.



> >  - are you sure that 28 bits is enough for PFN everywhere?
> >    ARM with LPAE can have up to 40 physical address lines. Is there any
> >    32-bit machine with more address lines?
>
> It's clearly not enough :-)  My plan is to have a pair of functions
> pfn_to_rte() and rte_to_pfn() with default implementations that work well
> on 64-bit and can be overridden by address-space deficient architectures.
> If rte_to_pfn() returns RTE_PFN_UNKNOWN (which is probably -1), we'll
> just go off and call get_block and ->direct_access.  This will be a
> well-tested codepath because it'll be the same as the codepath used the
> first time we look up a block.
>
> Architectures can use whatever fancy scheme they like to optimise
> rte_to_pfn() ... I don't think suggesting that enabling DAX grows
> the radix tree entries from 32 to 64 bit would be a popular idea, but
> that'd be something for those architecture maintainers to figure out.
> I certainly don't care much about an x86-32 kernel with DAX ... I can
> see it maybe being interesting in a virtualisation environment, but
> probably not.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--089e0149c39cad973704f4cf027f
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">On Mon, Mar 17, 2014 at 4:45 PM, Matthew Wilcox <span dir=3D"ltr">&=
lt;<a href=3D"mailto:willy@linux.intel.com" target=3D"_blank">willy@linux.i=
ntel.com</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"">On Mon, Mar 17, 2014 at 01:4=
3:21PM +0200, Kirill A. Shutemov wrote:<br>
&gt; On Sat, Mar 15, 2014 at 10:46:13PM -0400, Matthew Wilcox wrote:<br>
</div><div class=3D"">&gt; &gt; I&#39;m actually working on this now. =A0Th=
e basic idea is to put an entry in<br>
&gt; &gt; the radix tree for each page. =A0For zero pages, that&#39;s a pag=
ecache page.<br>
&gt; &gt; For pages that map to the media, it&#39;s an exceptional entry. =
=A0Radix tree<br>
&gt; &gt; exceptional entries take two bits, leaving us with 30 or 62 bits =
depending<br>
&gt; &gt; on sizeof(void *). =A0We can then take two more bits for Dirty an=
d Lock,<br>
&gt; &gt; leaving 28 or 60 bits that we can use to cache the PFN on the pag=
e,<br>
&gt; &gt; meaning that we won&#39;t have to call the filesystem&#39;s get_b=
lock as often.<br>
&gt;<br>
&gt; Sound reasonable to me. Implementation of -&gt;map_pages should be tri=
vial<br>
&gt; with this.<br>
&gt;<br>
&gt; Few questions:<br>
&gt; =A0- why would you need Dirty for DAX?<br>
<br>
</div>One of the areas ignored by the original XIP code was CPU caches. =A0=
Maybe<br>
s390 has write-through caches or something, but on x86 we need to write bac=
k<br>
the lines from the CPU cache to the memory on an msync(). =A0We&#39;ll also=
 need<br>
to do this for a write(), although that&#39;s a SMOP.<br></blockquote><div>=
<br></div><div>Indeed CLFLUSH has to be used extensively in order to guaran=
tee that the data is seen by the memory controller. This adds many instruct=
ions to the execution path, and more importantly is associated with a subst=
antial latency penalty. This sub-optimal behavior derives from the current =
hardware implementation (e.g Intel E5-26xx v2), which does not ADR-protect =
WB caches. Hopefully, in the future, processor vendors will extend the ADR =
protection to the WB caches, which will free us from the need to CLFLUSH.</=
div>
<div><br></div><div><br></div><blockquote class=3D"gmail_quote" style=3D"ma=
rgin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<div class=3D""><br>
&gt; =A0- are you sure that 28 bits is enough for PFN everywhere?<br>
&gt; =A0 =A0ARM with LPAE can have up to 40 physical address lines. Is ther=
e any<br>
&gt; =A0 =A032-bit machine with more address lines?<br>
<br>
</div>It&#39;s clearly not enough :-) =A0My plan is to have a pair of funct=
ions<br>
pfn_to_rte() and rte_to_pfn() with default implementations that work well<b=
r>
on 64-bit and can be overridden by address-space deficient architectures.<b=
r>
If rte_to_pfn() returns RTE_PFN_UNKNOWN (which is probably -1), we&#39;ll<b=
r>
just go off and call get_block and -&gt;direct_access. =A0This will be a<br=
>
well-tested codepath because it&#39;ll be the same as the codepath used the=
<br>
first time we look up a block.<br>
<br>
Architectures can use whatever fancy scheme they like to optimise<br>
rte_to_pfn() ... I don&#39;t think suggesting that enabling DAX grows<br>
the radix tree entries from 32 to 64 bit would be a popular idea, but<br>
that&#39;d be something for those architecture maintainers to figure out.<b=
r>
I certainly don&#39;t care much about an x86-32 kernel with DAX ... I can<b=
r>
see it maybe being interesting in a virtualisation environment, but<br>
probably not.<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-fsdeve=
l&quot; in<br>
the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">major=
domo@vger.kernel.org</a><br>
More majordomo info at =A0<a href=3D"http://vger.kernel.org/majordomo-info.=
html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a><br>
</div></div></blockquote></div><br></div></div>

--089e0149c39cad973704f4cf027f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
