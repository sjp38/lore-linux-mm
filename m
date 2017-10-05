Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 711D36B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 08:36:40 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p5so36501836pgn.7
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 05:36:40 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10078.outbound.protection.outlook.com. [40.107.1.78])
        by mx.google.com with ESMTPS id j15si9804220pgf.93.2017.10.05.05.36.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Oct 2017 05:36:39 -0700 (PDT)
From: Guy Shattah <sguy@mellanox.com>
Subject: Re: [RFC] mmap(MAP_CONTIG)
Date: Thu, 5 Oct 2017 12:36:35 +0000
Message-ID: <AM6PR0502MB37835D6EE944E671CEF8828FBD700@AM6PR0502MB3783.eurprd05.prod.outlook.com>
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>,<3c28baa4-f8f5-a86e-4830-bf3c7c74ed4f@suse.cz>,<AM6PR0502MB3783E60F560E6FDE4CD13239BD700@AM6PR0502MB3783.eurprd05.prod.outlook.com>
In-Reply-To: <AM6PR0502MB3783E60F560E6FDE4CD13239BD700@AM6PR0502MB3783.eurprd05.prod.outlook.com>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_AM6PR0502MB37835D6EE944E671CEF8828FBD700AM6PR0502MB3783_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>

--_000_AM6PR0502MB37835D6EE944E671CEF8828FBD700AM6PR0502MB3783_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

I'm on vacation and experiencing technical difficulties uploading the slide=
s. I'll upload them next week.
Sorry

Guy


>On 10/04/2017 01:56 AM, Mike Kravetz wrote:
>
>Hi,
>
>> At Plumbers this year, Guy Shattah and Christoph Lameter gave a presenta=
tion
>> titled 'User space contiguous memory allocation for DMA' [1].  The slide=
s
>
>Hm I didn't find slides on that link, are they available?
>
>> point out the performance benefits of devices that can take advantage of
>> larger physically contiguous areas.
>>
>> When such physically contiguous allocations are done today, they are don=
e
>> within drivers themselves in an ad-hoc manner.
>
>As Michal N. noted, the drivers might have different requirements. Is
>contiguity (without extra requirements) so common that it would benefit
>from a userspace API change?
>Also how are the driver-specific allocations done today? mmap() on the
>driver's device? Maybe we could provide some in-kernel API/library to
>make them less "ad-hoc". Conversion to MAP_ANONYMOUS would at first seem
>like an improvement in that userspace would be able to use a generic
>allocation API and all the generic treatment of anonymous pages (LRU
>aging, reclaim, migration etc), but the restrictions you listed below
>eliminate most of that?
>(It's likely that I just don't have enough info about how it works today
>so it's difficult to judge)
>
>> In addition to allocations
>> for DMA, allocations of this type are also performed for buffers used by
>> coprocessors and other acceleration engines.
>>
>> As mentioned in the presentation, posix specifies an interface to obtain
>> physically contiguous memory.  This is via typed memory objects as descr=
ibed
>> in the posix_typed_mem_open() man page.  Since Linux today does not foll=
ow
>> the posix typed memory object model, adding infrastructure for contiguou=
s
>> memory allocations seems to be overkill.  Instead, a proposal was sugges=
ted
>> to add support via a mmap flag: MAP_CONTIG.
>>
>> mmap(MAP_CONTIG) would have the following semantics:
>> - The entire mapping (length size) would be backed by physically contigu=
ous
>>   pages.
>> - If 'length' physically contiguous pages can not be allocated, then mma=
p
>>   will fail.
>> - MAP_CONTIG only works with MAP_ANONYMOUS mappings.
>> - MAP_CONTIG will lock the associated pages in memory.  As such, the sam=
e
>>   privileges and limits that apply to mlock will also apply to MAP_CONTI=
G.
>> - A MAP_CONTIG mapping can not be expanded.
>> - At fork time, private MAP_CONTIG mappings will be converted to regular
>>   (non-MAP_CONTIG) mapping in the child.  As such a COW fault in the chi=
ld
>>   will not require a contiguous allocation.
>>
>> Some implementation considerations:
>> - alloc_contig_range() or similar will be used for allocations larger
>>   than MAX_ORDER.
>> - MAP_CONTIG should imply MAP_POPULATE.  At mmap time, all pages for the
>>   mapping must be 'pre-allocated', and they can only be used for the map=
ping,
>>   so it makes sense to 'fault in' all pages.
>> - Using 'pre-allocated' pages in the fault paths may be intrusive.
>> - We need to keep keep track of those pre-allocated pages until the vma =
is
>>   tore down, especially if free_contig_range() must be called.
>>
>> Thoughts?
>> - Is such an interface useful?
>> - Any other ideas on how to achieve the same functionality?
>> - Any thoughts on implementation?
>>
>> I have started down the path of pre-allocating contiguous pages at mmap
>> time and hanging those off the vma(vm_private_data) with some kludges to
>> use the pages at fault time.  It is really ugly, which is why I am not
>> sharing the code.  Hoping for some comments/suggestions.
>>
>> [1] https://emea01.safelinks.protection.outlook.com/?url=3Dhttps%3A%2F%2=
Fwww.linuxplumbersconf.org%2F2017%2Focw%2Fproposals%2F4669&data=3D02%7C01%7=
Csguy%40mellanox.com%7Ca0ee0fe4f0f74074b69b08d50bbfa7d5%7Ca652971c7d2e4d9ba=
6a4d149256f461b%7C0%7C0%7C636427840155156528&sdata=3DGYlJ926fwQKSUIKbP7AVI0=
1dasvK%2F0JEWLS%2FoNwJbyU%3D&reserved=3D0
>>



--_000_AM6PR0502MB37835D6EE944E671CEF8828FBD700AM6PR0502MB3783_
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=
1">
<style type=3D"text/css" style=3D"display:none;"><!-- P {margin-top:0;margi=
n-bottom:0;} --></style>
</head>
<body dir=3D"ltr">
<div id=3D"divtagdefaultwrapper" style=3D"font-size: 12pt; color: rgb(0, 0,=
 0); font-family: Calibri, Helvetica, sans-serif, EmojiFont, &quot;Apple Co=
lor Emoji&quot;, &quot;Segoe UI Emoji&quot;, NotoColorEmoji, &quot;Segoe UI=
 Symbol&quot;, &quot;Android Emoji&quot;, EmojiSymbols;" dir=3D"ltr">
<p></p>
<div dir=3D"ltr" style=3D"color: rgb(33, 33, 33); font-family: wf_segoe-ui_=
normal, &quot;Segoe UI&quot;, &quot;Segoe WP&quot;, Tahoma, Arial, sans-ser=
if, serif, EmojiFont; font-size: 15px; margin: 0px; padding: 0px;">
<font size=3D"2" color=3D"black" style=3D"font-family: sans-serif, serif, E=
mojiFont;"><span dir=3D"ltr" style=3D"font-size: 11pt;">I'm on vacation and=
 experiencing&nbsp;technical difficulties uploading the slides. I'll upload=
 them next week.<br>
</span></font><span style=3D"font-size: 11pt; font-family: sans-serif, seri=
f, EmojiFont; color: black;">Sorry</span><font size=3D"2" color=3D"black" s=
tyle=3D"font-family: sans-serif, serif, EmojiFont;"><span dir=3D"ltr" style=
=3D"font-size: 11pt;"><br>
</span></font></div>
<div dir=3D"ltr" style=3D"color: rgb(33, 33, 33); font-family: wf_segoe-ui_=
normal, &quot;Segoe UI&quot;, &quot;Segoe WP&quot;, Tahoma, Arial, sans-ser=
if, serif, EmojiFont; font-size: 15px; margin: 0px; padding: 0px;">
<font size=3D"2" color=3D"black" style=3D"font-family: sans-serif, serif, E=
mojiFont;"><span dir=3D"ltr" style=3D"font-size: 11pt;"><br>
</span></font></div>
<div dir=3D"ltr" style=3D"color: rgb(33, 33, 33); font-family: wf_segoe-ui_=
normal, &quot;Segoe UI&quot;, &quot;Segoe WP&quot;, Tahoma, Arial, sans-ser=
if, serif, EmojiFont; font-size: 15px; margin: 0px; padding: 0px;">
<font size=3D"2" color=3D"black" style=3D"font-family: sans-serif, serif, E=
mojiFont;"><span dir=3D"ltr" style=3D"font-size: 11pt;">Guy</span></font></=
div>
<br>
<p></p>
<br>
<div style=3D"color: rgb(0, 0, 0);">
<div>
<div>
<div id=3D"x_divRplyFwdMsg" dir=3D"ltr">
<div>&gt;On 10/04/2017 01:56 AM, Mike Kravetz wrote:</div>
<div>&gt;</div>
<div>&gt;Hi,</div>
<div>&gt;</div>
<div>&gt;&gt; At Plumbers this year, Guy Shattah and Christoph Lameter gave=
 a presentation</div>
<div>&gt;&gt; titled 'User space contiguous memory allocation for DMA' [1].=
&nbsp; The slides</div>
<div>&gt;</div>
<div>&gt;Hm I didn't find slides on that link, are they available?</div>
<div>&gt;</div>
<div>&gt;&gt; point out the performance benefits of devices that can take a=
dvantage of</div>
<div>&gt;&gt; larger physically contiguous areas.</div>
<div>&gt;&gt;&nbsp;</div>
<div>&gt;&gt; When such physically contiguous allocations are done today, t=
hey are done</div>
<div>&gt;&gt; within drivers themselves in an ad-hoc manner.</div>
<div>&gt;</div>
<div>&gt;As Michal N. noted, the drivers might have different requirements.=
 Is</div>
<div>&gt;contiguity (without extra requirements) so common that it would be=
nefit</div>
<div>&gt;from a userspace API change?</div>
<div>&gt;Also how are the driver-specific allocations done today? mmap() on=
 the</div>
<div>&gt;driver's device? Maybe we could provide some in-kernel API/library=
 to</div>
<div>&gt;make them less &quot;ad-hoc&quot;. Conversion to MAP_ANONYMOUS wou=
ld at first seem</div>
<div>&gt;like an improvement in that userspace would be able to use a gener=
ic</div>
<div>&gt;allocation API and all the generic treatment of anonymous pages (L=
RU</div>
<div>&gt;aging, reclaim, migration etc), but the restrictions you listed be=
low</div>
<div>&gt;eliminate most of that?</div>
<div>&gt;(It's likely that I just don't have enough info about how it works=
 today</div>
<div>&gt;so it's difficult to judge)</div>
<div>&gt;</div>
<div>&gt;&gt; In addition to allocations</div>
<div>&gt;&gt; for DMA, allocations of this type are also performed for buff=
ers used by</div>
<div>&gt;&gt; coprocessors and other acceleration engines.</div>
<div>&gt;&gt;&nbsp;</div>
<div>&gt;&gt; As mentioned in the presentation, posix specifies an interfac=
e to obtain</div>
<div>&gt;&gt; physically contiguous memory.&nbsp; This is via typed memory =
objects as described</div>
<div>&gt;&gt; in the posix_typed_mem_open() man page.&nbsp; Since Linux tod=
ay does not follow</div>
<div>&gt;&gt; the posix typed memory object model, adding infrastructure fo=
r contiguous</div>
<div>&gt;&gt; memory allocations seems to be overkill.&nbsp; Instead, a pro=
posal was suggested</div>
<div>&gt;&gt; to add support via a mmap flag: MAP_CONTIG.</div>
<div>&gt;&gt;&nbsp;</div>
<div>&gt;&gt; mmap(MAP_CONTIG) would have the following semantics:</div>
<div>&gt;&gt; - The entire mapping (length size) would be backed by physica=
lly contiguous</div>
<div>&gt;&gt;&nbsp; &nbsp;pages.</div>
<div>&gt;&gt; - If 'length' physically contiguous pages can not be allocate=
d, then mmap</div>
<div>&gt;&gt;&nbsp; &nbsp;will fail.</div>
<div>&gt;&gt; - MAP_CONTIG only works with MAP_ANONYMOUS mappings.</div>
<div>&gt;&gt; - MAP_CONTIG will lock the associated pages in memory.&nbsp; =
As such, the same</div>
<div>&gt;&gt;&nbsp; &nbsp;privileges and limits that apply to mlock will al=
so apply to MAP_CONTIG.</div>
<div>&gt;&gt; - A MAP_CONTIG mapping can not be expanded.</div>
<div>&gt;&gt; - At fork time, private MAP_CONTIG mappings will be converted=
 to regular</div>
<div>&gt;&gt;&nbsp; &nbsp;(non-MAP_CONTIG) mapping in the child.&nbsp; As s=
uch a COW fault in the child</div>
<div>&gt;&gt;&nbsp; &nbsp;will not require a contiguous allocation.</div>
<div>&gt;&gt;&nbsp;</div>
<div>&gt;&gt; Some implementation considerations:</div>
<div>&gt;&gt; - alloc_contig_range() or similar will be used for allocation=
s larger</div>
<div>&gt;&gt;&nbsp; &nbsp;than MAX_ORDER.</div>
<div>&gt;&gt; - MAP_CONTIG should imply MAP_POPULATE.&nbsp; At mmap time, a=
ll pages for the</div>
<div>&gt;&gt;&nbsp; &nbsp;mapping must be 'pre-allocated', and they can onl=
y be used for the mapping,</div>
<div>&gt;&gt;&nbsp; &nbsp;so it makes sense to 'fault in' all pages.</div>
<div>&gt;&gt; - Using 'pre-allocated' pages in the fault paths may be intru=
sive.</div>
<div>&gt;&gt; - We need to keep keep track of those pre-allocated pages unt=
il the vma is</div>
<div>&gt;&gt;&nbsp; &nbsp;tore down, especially if free_contig_range() must=
 be called.</div>
<div>&gt;&gt;&nbsp;</div>
<div>&gt;&gt; Thoughts?</div>
<div>&gt;&gt; - Is such an interface useful?</div>
<div>&gt;&gt; - Any other ideas on how to achieve the same functionality?</=
div>
<div>&gt;&gt; - Any thoughts on implementation?</div>
<div>&gt;&gt;&nbsp;</div>
<div>&gt;&gt; I have started down the path of pre-allocating contiguous pag=
es at mmap</div>
<div>&gt;&gt; time and hanging those off the vma(vm_private_data) with some=
 kludges to</div>
<div>&gt;&gt; use the pages at fault time.&nbsp; It is really ugly, which i=
s why I am not</div>
<div>&gt;&gt; sharing the code.&nbsp; Hoping for some comments/suggestions.=
</div>
<div>&gt;&gt;&nbsp;</div>
<div>&gt;&gt; [1] https://emea01.safelinks.protection.outlook.com/?url=3Dht=
tps%3A%2F%2Fwww.linuxplumbersconf.org%2F2017%2Focw%2Fproposals%2F4669&amp;d=
ata=3D02%7C01%7Csguy%40mellanox.com%7Ca0ee0fe4f0f74074b69b08d50bbfa7d5%7Ca6=
52971c7d2e4d9ba6a4d149256f461b%7C0%7C0%7C636427840155156528&amp;sdata=3DGYl=
J926fwQKSUIKbP7AVI01dasvK%2F0JEWLS%2FoNwJbyU%3D&amp;reserved=3D0</div>
<div>&gt;&gt;&nbsp;</div>
<div><br>
</div>
<br>
</div>
</div>
</div>
</div>
</div>
</body>
</html>

--_000_AM6PR0502MB37835D6EE944E671CEF8828FBD700AM6PR0502MB3783_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
