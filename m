Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EFB716B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 04:58:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r83so31443778pfj.5
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 01:58:33 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0089.outbound.protection.outlook.com. [104.47.1.89])
        by mx.google.com with ESMTPS id f9si10099848plo.107.2017.10.05.01.58.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Oct 2017 01:58:29 -0700 (PDT)
From: Guy Shattah <sguy@mellanox.com>
Subject: Re: [RFC] mmap(MAP_CONTIG)
Date: Thu, 5 Oct 2017 08:58:25 +0000
Message-ID: <AM6PR0502MB3783E60F560E6FDE4CD13239BD700@AM6PR0502MB3783.eurprd05.prod.outlook.com>
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>,<3c28baa4-f8f5-a86e-4830-bf3c7c74ed4f@suse.cz>
In-Reply-To: <3c28baa4-f8f5-a86e-4830-bf3c7c74ed4f@suse.cz>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_AM6PR0502MB3783E60F560E6FDE4CD13239BD700AM6PR0502MB3783_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>

--_000_AM6PR0502MB3783E60F560E6FDE4CD13239BD700AM6PR0502MB3783_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

I'm on vacation and having technical difficulties uploading the slides. I'l=
l upload them once I'm back.

Sorry

Guy

Outlook ???? Android<https://aka.ms/ghei36>

________________________________
From: Vlastimil Babka <vbabka@suse.cz>
Sent: Thursday, October 5, 2017 10:06:49 AM
To: Mike Kravetz; linux-mm@kvack.org; linux-kernel@vger.kernel.org; linux-a=
pi@vger.kernel.org
Cc: Marek Szyprowski; Michal Nazarewicz; Aneesh Kumar K.V; Joonsoo Kim; Guy=
 Shattah; Christoph Lameter
Subject: Re: [RFC] mmap(MAP_CONTIG)

On 10/04/2017 01:56 AM, Mike Kravetz wrote:

Hi,

> At Plumbers this year, Guy Shattah and Christoph Lameter gave a presentat=
ion
> titled 'User space contiguous memory allocation for DMA' [1].  The slides

Hm I didn't find slides on that link, are they available?

> point out the performance benefits of devices that can take advantage of
> larger physically contiguous areas.
>
> When such physically contiguous allocations are done today, they are done
> within drivers themselves in an ad-hoc manner.

As Michal N. noted, the drivers might have different requirements. Is
contiguity (without extra requirements) so common that it would benefit
from a userspace API change?
Also how are the driver-specific allocations done today? mmap() on the
driver's device? Maybe we could provide some in-kernel API/library to
make them less "ad-hoc". Conversion to MAP_ANONYMOUS would at first seem
like an improvement in that userspace would be able to use a generic
allocation API and all the generic treatment of anonymous pages (LRU
aging, reclaim, migration etc), but the restrictions you listed below
eliminate most of that?
(It's likely that I just don't have enough info about how it works today
so it's difficult to judge)

> In addition to allocations
> for DMA, allocations of this type are also performed for buffers used by
> coprocessors and other acceleration engines.
>
> As mentioned in the presentation, posix specifies an interface to obtain
> physically contiguous memory.  This is via typed memory objects as descri=
bed
> in the posix_typed_mem_open() man page.  Since Linux today does not follo=
w
> the posix typed memory object model, adding infrastructure for contiguous
> memory allocations seems to be overkill.  Instead, a proposal was suggest=
ed
> to add support via a mmap flag: MAP_CONTIG.
>
> mmap(MAP_CONTIG) would have the following semantics:
> - The entire mapping (length size) would be backed by physically contiguo=
us
>   pages.
> - If 'length' physically contiguous pages can not be allocated, then mmap
>   will fail.
> - MAP_CONTIG only works with MAP_ANONYMOUS mappings.
> - MAP_CONTIG will lock the associated pages in memory.  As such, the same
>   privileges and limits that apply to mlock will also apply to MAP_CONTIG=
.
> - A MAP_CONTIG mapping can not be expanded.
> - At fork time, private MAP_CONTIG mappings will be converted to regular
>   (non-MAP_CONTIG) mapping in the child.  As such a COW fault in the chil=
d
>   will not require a contiguous allocation.
>
> Some implementation considerations:
> - alloc_contig_range() or similar will be used for allocations larger
>   than MAX_ORDER.
> - MAP_CONTIG should imply MAP_POPULATE.  At mmap time, all pages for the
>   mapping must be 'pre-allocated', and they can only be used for the mapp=
ing,
>   so it makes sense to 'fault in' all pages.
> - Using 'pre-allocated' pages in the fault paths may be intrusive.
> - We need to keep keep track of those pre-allocated pages until the vma i=
s
>   tore down, especially if free_contig_range() must be called.
>
> Thoughts?
> - Is such an interface useful?
> - Any other ideas on how to achieve the same functionality?
> - Any thoughts on implementation?
>
> I have started down the path of pre-allocating contiguous pages at mmap
> time and hanging those off the vma(vm_private_data) with some kludges to
> use the pages at fault time.  It is really ugly, which is why I am not
> sharing the code.  Hoping for some comments/suggestions.
>
> [1] https://emea01.safelinks.protection.outlook.com/?url=3Dhttps%3A%2F%2F=
www.linuxplumbersconf.org%2F2017%2Focw%2Fproposals%2F4669&data=3D02%7C01%7C=
sguy%40mellanox.com%7Ca0ee0fe4f0f74074b69b08d50bbfa7d5%7Ca652971c7d2e4d9ba6=
a4d149256f461b%7C0%7C0%7C636427840155156528&sdata=3DGYlJ926fwQKSUIKbP7AVI01=
dasvK%2F0JEWLS%2FoNwJbyU%3D&reserved=3D0
>


--_000_AM6PR0502MB3783E60F560E6FDE4CD13239BD700AM6PR0502MB3783_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<meta name=3D"Generator" content=3D"Microsoft Exchange Server">
<!-- converted from text --><style><!-- .EmailQuote { margin-left: 1pt; pad=
ding-left: 4pt; border-left: #800000 2px solid; } --></style>
</head>
<body>
<div>
<div dir=3D"auto" style=3D"direction:ltr; margin:0; padding:0; font-family:=
sans-serif; font-size:11pt; color:black; background-color:white">
I'm on vacation and having technical difficulties uploading the slides. I'l=
l upload them once I'm back.<br>
<br>
</div>
<div dir=3D"auto" style=3D"direction:ltr; margin:0; padding:0; font-family:=
sans-serif; font-size:11pt; color:black; background-color:white">
Sorry<br>
<br>
</div>
<div dir=3D"auto" style=3D"direction:ltr; margin:0; padding:0; font-family:=
sans-serif; font-size:11pt; color:black; background-color:white">
Guy<br>
<br>
</div>
<div dir=3D"auto" style=3D"direction:ltr; margin:0; padding:0; font-family:=
sans-serif; font-size:11pt; color:black; background-color:white">
<div dir=3D"auto" style=3D"direction:ltr; margin:0; padding:0; font-family:=
sans-serif; font-size:11pt; color:black; background-color:white">
<a href=3D"https://aka.ms/ghei36">Outlook &#1506;&#1489;&#1493;&#1512; Andr=
oid</a></div>
<br>
</div>
<hr tabindex=3D"-1" style=3D"display:inline-block; width:98%">
<div id=3D"x_divRplyFwdMsg" dir=3D"ltr"><font face=3D"Calibri, sans-serif" =
color=3D"#000000" style=3D"font-size:11pt"><b>From:</b> Vlastimil Babka &lt=
;vbabka@suse.cz&gt;<br>
<b>Sent:</b> Thursday, October 5, 2017 10:06:49 AM<br>
<b>To:</b> Mike Kravetz; linux-mm@kvack.org; linux-kernel@vger.kernel.org; =
linux-api@vger.kernel.org<br>
<b>Cc:</b> Marek Szyprowski; Michal Nazarewicz; Aneesh Kumar K.V; Joonsoo K=
im; Guy Shattah; Christoph Lameter<br>
<b>Subject:</b> Re: [RFC] mmap(MAP_CONTIG)</font>
<div>&nbsp;</div>
</div>
</div>
<font size=3D"2"><span style=3D"font-size:10pt;">
<div class=3D"PlainText">On 10/04/2017 01:56 AM, Mike Kravetz wrote:<br>
<br>
Hi,<br>
<br>
&gt; At Plumbers this year, Guy Shattah and Christoph Lameter gave a presen=
tation<br>
&gt; titled 'User space contiguous memory allocation for DMA' [1].&nbsp; Th=
e slides<br>
<br>
Hm I didn't find slides on that link, are they available?<br>
<br>
&gt; point out the performance benefits of devices that can take advantage =
of<br>
&gt; larger physically contiguous areas.<br>
&gt; <br>
&gt; When such physically contiguous allocations are done today, they are d=
one<br>
&gt; within drivers themselves in an ad-hoc manner.<br>
<br>
As Michal N. noted, the drivers might have different requirements. Is<br>
contiguity (without extra requirements) so common that it would benefit<br>
from a userspace API change?<br>
Also how are the driver-specific allocations done today? mmap() on the<br>
driver's device? Maybe we could provide some in-kernel API/library to<br>
make them less &quot;ad-hoc&quot;. Conversion to MAP_ANONYMOUS would at fir=
st seem<br>
like an improvement in that userspace would be able to use a generic<br>
allocation API and all the generic treatment of anonymous pages (LRU<br>
aging, reclaim, migration etc), but the restrictions you listed below<br>
eliminate most of that?<br>
(It's likely that I just don't have enough info about how it works today<br=
>
so it's difficult to judge)<br>
<br>
&gt; In addition to allocations<br>
&gt; for DMA, allocations of this type are also performed for buffers used =
by<br>
&gt; coprocessors and other acceleration engines.<br>
&gt; <br>
&gt; As mentioned in the presentation, posix specifies an interface to obta=
in<br>
&gt; physically contiguous memory.&nbsp; This is via typed memory objects a=
s described<br>
&gt; in the posix_typed_mem_open() man page.&nbsp; Since Linux today does n=
ot follow<br>
&gt; the posix typed memory object model, adding infrastructure for contigu=
ous<br>
&gt; memory allocations seems to be overkill.&nbsp; Instead, a proposal was=
 suggested<br>
&gt; to add support via a mmap flag: MAP_CONTIG.<br>
&gt; <br>
&gt; mmap(MAP_CONTIG) would have the following semantics:<br>
&gt; - The entire mapping (length size) would be backed by physically conti=
guous<br>
&gt;&nbsp;&nbsp; pages.<br>
&gt; - If 'length' physically contiguous pages can not be allocated, then m=
map<br>
&gt;&nbsp;&nbsp; will fail.<br>
&gt; - MAP_CONTIG only works with MAP_ANONYMOUS mappings.<br>
&gt; - MAP_CONTIG will lock the associated pages in memory.&nbsp; As such, =
the same<br>
&gt;&nbsp;&nbsp; privileges and limits that apply to mlock will also apply =
to MAP_CONTIG.<br>
&gt; - A MAP_CONTIG mapping can not be expanded.<br>
&gt; - At fork time, private MAP_CONTIG mappings will be converted to regul=
ar<br>
&gt;&nbsp;&nbsp; (non-MAP_CONTIG) mapping in the child.&nbsp; As such a COW=
 fault in the child<br>
&gt;&nbsp;&nbsp; will not require a contiguous allocation.<br>
&gt; <br>
&gt; Some implementation considerations:<br>
&gt; - alloc_contig_range() or similar will be used for allocations larger<=
br>
&gt;&nbsp;&nbsp; than MAX_ORDER.<br>
&gt; - MAP_CONTIG should imply MAP_POPULATE.&nbsp; At mmap time, all pages =
for the<br>
&gt;&nbsp;&nbsp; mapping must be 'pre-allocated', and they can only be used=
 for the mapping,<br>
&gt;&nbsp;&nbsp; so it makes sense to 'fault in' all pages.<br>
&gt; - Using 'pre-allocated' pages in the fault paths may be intrusive.<br>
&gt; - We need to keep keep track of those pre-allocated pages until the vm=
a is<br>
&gt;&nbsp;&nbsp; tore down, especially if free_contig_range() must be calle=
d.<br>
&gt; <br>
&gt; Thoughts?<br>
&gt; - Is such an interface useful?<br>
&gt; - Any other ideas on how to achieve the same functionality?<br>
&gt; - Any thoughts on implementation?<br>
&gt; <br>
&gt; I have started down the path of pre-allocating contiguous pages at mma=
p<br>
&gt; time and hanging those off the vma(vm_private_data) with some kludges =
to<br>
&gt; use the pages at fault time.&nbsp; It is really ugly, which is why I a=
m not<br>
&gt; sharing the code.&nbsp; Hoping for some comments/suggestions.<br>
&gt; <br>
&gt; [1] <a href=3D"https://emea01.safelinks.protection.outlook.com/?url=3D=
https%3A%2F%2Fwww.linuxplumbersconf.org%2F2017%2Focw%2Fproposals%2F4669&amp=
;data=3D02%7C01%7Csguy%40mellanox.com%7Ca0ee0fe4f0f74074b69b08d50bbfa7d5%7C=
a652971c7d2e4d9ba6a4d149256f461b%7C0%7C0%7C636427840155156528&amp;sdata=3DG=
YlJ926fwQKSUIKbP7AVI01dasvK%2F0JEWLS%2FoNwJbyU%3D&amp;reserved=3D0">
https://emea01.safelinks.protection.outlook.com/?url=3Dhttps%3A%2F%2Fwww.li=
nuxplumbersconf.org%2F2017%2Focw%2Fproposals%2F4669&amp;data=3D02%7C01%7Csg=
uy%40mellanox.com%7Ca0ee0fe4f0f74074b69b08d50bbfa7d5%7Ca652971c7d2e4d9ba6a4=
d149256f461b%7C0%7C0%7C636427840155156528&amp;sdata=3DGYlJ926fwQKSUIKbP7AVI=
01dasvK%2F0JEWLS%2FoNwJbyU%3D&amp;reserved=3D0</a><br>
&gt; <br>
<br>
</div>
</span></font>
</body>
</html>

--_000_AM6PR0502MB3783E60F560E6FDE4CD13239BD700AM6PR0502MB3783_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
