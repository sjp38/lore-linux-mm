Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1894E6B0005
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 04:37:13 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id x67so195677616oix.2
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 01:37:13 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0075.outbound.protection.outlook.com. [104.47.0.75])
        by mx.google.com with ESMTPS id x5si6551809otx.134.2016.04.29.01.37.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 29 Apr 2016 01:37:12 -0700 (PDT)
From: Xiaowen Liu <xiaowen.liu@nxp.com>
Subject: CMA reservations have different result compared to linux 3.14 kernel.
Date: Fri, 29 Apr 2016 08:37:09 +0000
Message-ID: <VI1PR0401MB17926D311243A471B92BD72DEE660@VI1PR0401MB1792.eurprd04.prod.outlook.com>
Content-Language: zh-CN
Content-Type: multipart/mixed;
	boundary="_004_VI1PR0401MB17926D311243A471B92BD72DEE660VI1PR0401MB1792_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "laurent.pinchart+renesas@ideasonboard.com" <laurent.pinchart+renesas@ideasonboard.com>
Cc: "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

--_004_VI1PR0401MB17926D311243A471B92BD72DEE660VI1PR0401MB1792_
Content-Type: multipart/alternative;
	boundary="_000_VI1PR0401MB17926D311243A471B92BD72DEE660VI1PR0401MB1792_"

--_000_VI1PR0401MB17926D311243A471B92BD72DEE660VI1PR0401MB1792_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi laurent.pinchart,

I found there is a commit to reserve CMA from high memory first and then fa=
lls back to low memory.

commit 16195ddd4ebcc10c30b2f232f8e400df8d464380
Author: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Date:   Fri Oct 24 13:18:41 2014 +0300

    mm: cma: Ensure that reservations never cross the low/high mem boundary

    Commit 95b0e655f914 ("ARM: mm: don't limit default CMA region only to
    low memory") extended CMA memory reservation to allow usage of high
    memory. It relied on commit f7426b983a6a ("mm: cma: adjust address limi=
t
    to avoid hitting low/high memory boundary") to ensure that the reserved
    block never crossed the low/high memory boundary. While the
    implementation correctly lowered the limit, it failed to consider the
    case where the base..limit range crossed the low/high memory boundary
    with enough space on each side to reserve the requested size on either
    low or high memory.

    Rework the base and limit adjustment to fix the problem. The function
    now starts by rejecting the reservation altogether for fixed
    reservations that cross the boundary, tries to reserve from high memory
    first and then falls back to low memory.

The CMA configuration has two paths. One is in DTS and the other in bootarg=
s.
In order to make convenient to adjust CMA size, we use bootargs to set CMA =
size in linux 3.14 kernel.
When the kernel is upgraded from 3.14 to 4.1, there is an strange issue.
The CMA reserved base address is changed from low memory to high memory.
Of course it introduces a lot of issues on our imx6 platform when CMA reser=
ved base address is at high memory.
So, I find your commit listed above that change the CMA reserved base addre=
ss.
Of course this change itself doesn't have any problem.
But it has different result compared to configuring CMA in DTS.
The CMA reserved base address is at low memory when configure CMA in DTS.

My questions are:
1. the two CMA configuration methods reside in different memory zone which =
may introduce confusion.
2. This commit breaks the kernel backward compatibility that the same CMA c=
onfiguration in old kernel version should reside in the same memory zone wh=
en kernel upgrade.

There is one patch attached to make CMA reserved memory allocating from low=
 memory firstly and fall back to high memory to be backward compatible.
If the CMA is required to be reserved at high memory, the CMA base should b=
e set to configure CMA memory.

Best Regards,
Ivan.liu



--_000_VI1PR0401MB17926D311243A471B92BD72DEE660VI1PR0401MB1792_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:v=3D"urn:schemas-microsoft-com:vml" xmlns:o=3D"urn:schemas-micr=
osoft-com:office:office" xmlns:w=3D"urn:schemas-microsoft-com:office:word" =
xmlns:m=3D"http://schemas.microsoft.com/office/2004/12/omml" xmlns=3D"http:=
//www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<meta name=3D"Generator" content=3D"Microsoft Word 15 (filtered medium)">
<style><!--
/* Font Definitions */
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:Calibri;
	panose-1:2 15 5 2 2 2 4 3 2 4;}
@font-face
	{font-family:DengXian;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:DengXian;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
a:link, span.MsoHyperlink
	{mso-style-priority:99;
	color:#0563C1;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-priority:99;
	color:#954F72;
	text-decoration:underline;}
p.MsoListParagraph, li.MsoListParagraph, div.MsoListParagraph
	{mso-style-priority:34;
	margin-top:0in;
	margin-right:0in;
	margin-bottom:0in;
	margin-left:.5in;
	margin-bottom:.0001pt;
	font-size:11.0pt;
	font-family:"Calibri",sans-serif;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:"Calibri",sans-serif;
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-family:"Calibri",sans-serif;}
@page WordSection1
	{size:8.5in 11.0in;
	margin:1.0in 1.25in 1.0in 1.25in;}
div.WordSection1
	{page:WordSection1;}
--></style><!--[if gte mso 9]><xml>
<o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
</xml><![endif]--><!--[if gte mso 9]><xml>
<o:shapelayout v:ext=3D"edit">
<o:idmap v:ext=3D"edit" data=3D"1" />
</o:shapelayout></xml><![endif]-->
</head>
<body lang=3D"EN-US" link=3D"#0563C1" vlink=3D"#954F72">
<div class=3D"WordSection1">
<p class=3D"MsoNormal">Hi laurent.pinchart,<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">I found there is a commit to reserve CMA from high m=
emory first and then falls back to low memory.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">commit 16195ddd4ebcc10c30b2f232f8e400df8d464380<o:p>=
</o:p></p>
<p class=3D"MsoNormal">Author: Laurent Pinchart &lt;laurent.pinchart&#43;re=
nesas@ideasonboard.com&gt;<o:p></o:p></p>
<p class=3D"MsoNormal">Date:&nbsp;&nbsp; Fri Oct 24 13:18:41 2014 &#43;0300=
<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp; mm: cma: Ensure that reservations=
 never cross the low/high mem boundary<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp; Commit 95b0e655f914 (&quot;ARM: m=
m: don't limit default CMA region only to<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp; low memory&quot;) extended CMA me=
mory reservation to allow usage of high<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp; memory. It relied on commit f7426=
b983a6a (&quot;mm: cma: adjust address limit<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp; to avoid hitting low/high memory =
boundary&quot;) to ensure that the reserved<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp; block never crossed the low/high =
memory boundary. While the<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp; implementation correctly lowered =
the limit, it failed to consider the<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp; case where the base..limit range =
crossed the low/high memory boundary<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp; with enough space on each side to=
 reserve the requested size on either<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp; low or high memory.<o:p></o:p></p=
>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp; Rework the base and limit adjustm=
ent to fix the problem. The function<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp; now starts by rejecting the reser=
vation altogether for fixed<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp; reservations that cross the bound=
ary, tries to reserve from high memory<o:p></o:p></p>
<p class=3D"MsoNormal">&nbsp;&nbsp;&nbsp; first and then falls back to low =
memory.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">The CMA configuration has two paths. One is in DTS a=
nd the other in bootargs.<o:p></o:p></p>
<p class=3D"MsoNormal">In order to make convenient to adjust CMA size, we u=
se bootargs to set CMA size in linux 3.14 kernel.<o:p></o:p></p>
<p class=3D"MsoNormal">When the kernel is upgraded from 3.14 to 4.1, there =
is an strange issue.<o:p></o:p></p>
<p class=3D"MsoNormal">The CMA reserved base address is changed from low me=
mory to high memory.<o:p></o:p></p>
<p class=3D"MsoNormal">Of course it introduces a lot of issues on our imx6 =
platform when CMA reserved base address is at high memory.<o:p></o:p></p>
<p class=3D"MsoNormal">So, I find your commit listed above that change the =
CMA reserved base address.<o:p></o:p></p>
<p class=3D"MsoNormal">Of course this change itself doesn't have any proble=
m.<o:p></o:p></p>
<p class=3D"MsoNormal">But it has different result compared to configuring =
CMA in DTS.<o:p></o:p></p>
<p class=3D"MsoNormal">The CMA reserved base address is at low memory when =
configure CMA in DTS.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">My questions are:<o:p></o:p></p>
<p class=3D"MsoNormal">1. the two CMA configuration methods reside in diffe=
rent memory zone which may introduce confusion.<o:p></o:p></p>
<p class=3D"MsoNormal">2. This commit breaks the kernel backward compatibil=
ity that the same CMA configuration in old kernel version should reside in =
the same memory zone when kernel upgrade.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">There is one patch attached to make CMA reserved mem=
ory allocating from low memory firstly and fall back to high memory to be b=
ackward compatible.<o:p></o:p></p>
<p class=3D"MsoNormal">If the CMA is required to be reserved at high memory=
, the CMA base should be set to configure CMA memory.<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal">Best Regards,<o:p></o:p></p>
<p class=3D"MsoNormal">Ivan.liu<o:p></o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
<p class=3D"MsoNormal"><o:p>&nbsp;</o:p></p>
</div>
</body>
</html>

--_000_VI1PR0401MB17926D311243A471B92BD72DEE660VI1PR0401MB1792_--

--_004_VI1PR0401MB17926D311243A471B92BD72DEE660VI1PR0401MB1792_
Content-Type: application/octet-stream;
	name="mm_cma_correct_allocation_backward_compatibility.patch"
Content-Description: mm_cma_correct_allocation_backward_compatibility.patch
Content-Disposition: attachment;
	filename="mm_cma_correct_allocation_backward_compatibility.patch"; size=1102;
	creation-date="Fri, 29 Apr 2016 08:29:34 GMT";
	modification-date="Fri, 29 Apr 2016 21:27:18 GMT"
Content-Transfer-Encoding: base64

ZGlmZiAtLWdpdCBhL21tL2NtYS5jIGIvbW0vY21hLmMKaW5kZXggM2E3YTY3Yi4uZmQyMzg3ZSAx
MDA2NDQKLS0tIGEvbW0vY21hLmMKKysrIGIvbW0vY21hLmMKQEAgLTMxMSwxOCArMzExLDE5IEBA
IGludCBfX2luaXQgY21hX2RlY2xhcmVfY29udGlndW91cyhwaHlzX2FkZHJfdCBiYXNlLAogCQkv
KgogCQkgKiBBbGwgcGFnZXMgaW4gdGhlIHJlc2VydmVkIGFyZWEgbXVzdCBjb21lIGZyb20gdGhl
IHNhbWUgem9uZS4KIAkJICogSWYgdGhlIHJlcXVlc3RlZCByZWdpb24gY3Jvc3NlcyB0aGUgbG93
L2hpZ2ggbWVtb3J5IGJvdW5kYXJ5LAotCQkgKiB0cnkgYWxsb2NhdGluZyBmcm9tIGhpZ2ggbWVt
b3J5IGZpcnN0IGFuZCBmYWxsIGJhY2sgdG8gbG93Ci0JCSAqIG1lbW9yeSBpbiBjYXNlIG9mIGZh
aWx1cmUuCisJCSAqIHRyeSBhbGxvY2F0aW5nIGZyb20gbG93IG1lbW9yeSBmaXJzdCBhbmQgZmFs
bCBiYWNrIHRvIGhpZ2gKKwkJICogbWVtb3J5IGluIGNhc2Ugb2YgZmFpbHVyZSB0byBiZSBiYWNr
d2FyZCBjb21wYXRpYmxlLgogCQkgKi8KLQkJaWYgKGJhc2UgPCBoaWdobWVtX3N0YXJ0ICYmIGxp
bWl0ID4gaGlnaG1lbV9zdGFydCkgewotCQkJYWRkciA9IG1lbWJsb2NrX2FsbG9jX3JhbmdlKHNp
emUsIGFsaWdubWVudCwKLQkJCQkJCSAgICBoaWdobWVtX3N0YXJ0LCBsaW1pdCk7Ci0JCQlsaW1p
dCA9IGhpZ2htZW1fc3RhcnQ7Ci0JCX0KKwkJYWRkciA9IG1lbWJsb2NrX2FsbG9jX3JhbmdlKHNp
emUsIGFsaWdubWVudCwgYmFzZSwKKwkJCQkJICAgIGxpbWl0KTsKIAogCQlpZiAoIWFkZHIpIHsK
LQkJCWFkZHIgPSBtZW1ibG9ja19hbGxvY19yYW5nZShzaXplLCBhbGlnbm1lbnQsIGJhc2UsCi0J
CQkJCQkgICAgbGltaXQpOworCQkJaWYgKGJhc2UgPCBoaWdobWVtX3N0YXJ0ICYmIGxpbWl0ID4g
aGlnaG1lbV9zdGFydCkgeworCQkJCWFkZHIgPSBtZW1ibG9ja19hbGxvY19yYW5nZShzaXplLCBh
bGlnbm1lbnQsCisJCQkJCQkJICAgIGhpZ2htZW1fc3RhcnQsIGxpbWl0KTsKKwkJCQlsaW1pdCA9
IGhpZ2htZW1fc3RhcnQ7CisJCQl9CisKIAkJCWlmICghYWRkcikgewogCQkJCXJldCA9IC1FTk9N
RU07CiAJCQkJZ290byBlcnI7Cg==

--_004_VI1PR0401MB17926D311243A471B92BD72DEE660VI1PR0401MB1792_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
