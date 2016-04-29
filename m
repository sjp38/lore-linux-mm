Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 25D246B025E
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 05:02:58 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id l137so232294859ywe.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 02:02:58 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0091.outbound.protection.outlook.com. [157.55.234.91])
        by mx.google.com with ESMTPS id 20si6946440qki.178.2016.04.29.02.02.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 29 Apr 2016 02:02:57 -0700 (PDT)
From: Xiaowen Liu <xiaowen.liu@nxp.com>
Subject: CMA reservations have different result in linux 4.1.5 kernel compared
 to linux 3.14 kernel.
Date: Fri, 29 Apr 2016 09:02:55 +0000
Message-ID: <VI1PR0401MB1792A3860CEFE44A750F06E4EE660@VI1PR0401MB1792.eurprd04.prod.outlook.com>
Content-Language: zh-CN
Content-Type: multipart/mixed;
	boundary="_004_VI1PR0401MB1792A3860CEFE44A750F06E4EE660VI1PR0401MB1792_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "laurent.pinchart+renesas@ideasonboard.com" <laurent.pinchart+renesas@ideasonboard.com>
Cc: "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

--_004_VI1PR0401MB1792A3860CEFE44A750F06E4EE660VI1PR0401MB1792_
Content-Type: multipart/alternative;
	boundary="_000_VI1PR0401MB1792A3860CEFE44A750F06E4EE660VI1PR0401MB1792_"

--_000_VI1PR0401MB1792A3860CEFE44A750F06E4EE660VI1PR0401MB1792_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi laurent.pinchart,

I found there is a commit to reserve CMA from high memory first and then fa=
lls back to low memory.

commit 16195ddd4ebcc10c30b2f232f8e400df8d464380
Author: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com<mailto:=
laurent.pinchart+renesas@ideasonboard.com>>
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

The CMA configuration has two paths. One is in DTS and the other in kernel =
command line.
In order to make convenient to adjust CMA size, we use kernel command line =
to set CMA size in linux 3.14 kernel.
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



--_000_VI1PR0401MB1792A3860CEFE44A750F06E4EE660VI1PR0401MB1792_
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
span.EmailStyle18
	{mso-style-type:personal;
	font-family:"Calibri",sans-serif;
	color:windowtext;}
span.EmailStyle19
	{mso-style-type:personal-reply;
	font-family:"Calibri",sans-serif;
	color:#1F497D;}
.MsoChpDefault
	{mso-style-type:export-only;
	font-size:10.0pt;}
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
<p class=3D"MsoNormal">Author: Laurent Pinchart &lt;<a href=3D"mailto:laure=
nt.pinchart&#43;renesas@ideasonboard.com">laurent.pinchart&#43;renesas@idea=
sonboard.com</a>&gt;<o:p></o:p></p>
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
nd the other in kernel command line.<o:p></o:p></p>
<p class=3D"MsoNormal">In order to make convenient to adjust CMA size, we u=
se kernel command line to set CMA size in linux 3.14 kernel.<o:p></o:p></p>
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

--_000_VI1PR0401MB1792A3860CEFE44A750F06E4EE660VI1PR0401MB1792_--

--_004_VI1PR0401MB1792A3860CEFE44A750F06E4EE660VI1PR0401MB1792_
Content-Type: application/octet-stream;
	name="0001-correct-CMA-reserved-memory-allocating-from-low-memo.patch"
Content-Description: 0001-correct-CMA-reserved-memory-allocating-from-low-memo.patch
Content-Disposition: attachment;
	filename="0001-correct-CMA-reserved-memory-allocating-from-low-memo.patch";
	size=1618; creation-date="Fri, 29 Apr 2016 09:02:38 GMT";
	modification-date="Fri, 29 Apr 2016 22:01:18 GMT"
Content-Transfer-Encoding: base64

RnJvbSAyMTg0ODMwOWY4YzQxNmYzZTFmZjIxODc1NzZkMDI1MDdhYTNjYzIzIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBYaWFvd2VuIExpdSA8eGlhb3dlbi5saXVAbnhwLmNvbT4KRGF0
ZTogRnJpLCAyOSBBcHIgMjAxNiAxNzo1Mzo0NCAtMDQwMApTdWJqZWN0OiBbUEFUQ0hdIGNvcnJl
Y3QgQ01BIHJlc2VydmVkIG1lbW9yeSBhbGxvY2F0aW5nIGZyb20gbG93IG1lbW9yeQogZmlyc3Rs
eSBhbmQgZmFsbCBiYWNrIHRvIGhpZ2h0IG1lbW9yeS4KCm1tOiBjbWE6IGNvcnJlY3QgQ01BIHJl
c2VydmVkIG1lbW9yeSBhbGxvY2F0aW5nIGZyb20gbG93IG1lbW9yeSBmaXJzdGx5IGFuZCBmYWxs
IGJhY2sgdG8gaGlnaHQgbWVtb3J5LgoKU2lnbmVkLW9mZi1ieTogWGlhb3dlbiBMaXUgPHhpYW93
ZW4ubGl1QG54cC5jb20+Ci0tLQogbW0vY21hLmMgfCAxOSArKysrKysrKysrLS0tLS0tLS0tCiAx
IGZpbGUgY2hhbmdlZCwgMTAgaW5zZXJ0aW9ucygrKSwgOSBkZWxldGlvbnMoLSkKCmRpZmYgLS1n
aXQgYS9tbS9jbWEuYyBiL21tL2NtYS5jCmluZGV4IDNhN2E2N2IuLmZkMjM4N2UgMTAwNjQ0Ci0t
LSBhL21tL2NtYS5jCisrKyBiL21tL2NtYS5jCkBAIC0zMTEsMTggKzMxMSwxOSBAQCBpbnQgX19p
bml0IGNtYV9kZWNsYXJlX2NvbnRpZ3VvdXMocGh5c19hZGRyX3QgYmFzZSwKIAkJLyoKIAkJICog
QWxsIHBhZ2VzIGluIHRoZSByZXNlcnZlZCBhcmVhIG11c3QgY29tZSBmcm9tIHRoZSBzYW1lIHpv
bmUuCiAJCSAqIElmIHRoZSByZXF1ZXN0ZWQgcmVnaW9uIGNyb3NzZXMgdGhlIGxvdy9oaWdoIG1l
bW9yeSBib3VuZGFyeSwKLQkJICogdHJ5IGFsbG9jYXRpbmcgZnJvbSBoaWdoIG1lbW9yeSBmaXJz
dCBhbmQgZmFsbCBiYWNrIHRvIGxvdwotCQkgKiBtZW1vcnkgaW4gY2FzZSBvZiBmYWlsdXJlLgor
CQkgKiB0cnkgYWxsb2NhdGluZyBmcm9tIGxvdyBtZW1vcnkgZmlyc3QgYW5kIGZhbGwgYmFjayB0
byBoaWdoCisJCSAqIG1lbW9yeSBpbiBjYXNlIG9mIGZhaWx1cmUgdG8gYmUgYmFja3dhcmQgY29t
cGF0aWJsZS4KIAkJICovCi0JCWlmIChiYXNlIDwgaGlnaG1lbV9zdGFydCAmJiBsaW1pdCA+IGhp
Z2htZW1fc3RhcnQpIHsKLQkJCWFkZHIgPSBtZW1ibG9ja19hbGxvY19yYW5nZShzaXplLCBhbGln
bm1lbnQsCi0JCQkJCQkgICAgaGlnaG1lbV9zdGFydCwgbGltaXQpOwotCQkJbGltaXQgPSBoaWdo
bWVtX3N0YXJ0OwotCQl9CisJCWFkZHIgPSBtZW1ibG9ja19hbGxvY19yYW5nZShzaXplLCBhbGln
bm1lbnQsIGJhc2UsCisJCQkJCSAgICBsaW1pdCk7CiAKIAkJaWYgKCFhZGRyKSB7Ci0JCQlhZGRy
ID0gbWVtYmxvY2tfYWxsb2NfcmFuZ2Uoc2l6ZSwgYWxpZ25tZW50LCBiYXNlLAotCQkJCQkJICAg
IGxpbWl0KTsKKwkJCWlmIChiYXNlIDwgaGlnaG1lbV9zdGFydCAmJiBsaW1pdCA+IGhpZ2htZW1f
c3RhcnQpIHsKKwkJCQlhZGRyID0gbWVtYmxvY2tfYWxsb2NfcmFuZ2Uoc2l6ZSwgYWxpZ25tZW50
LAorCQkJCQkJCSAgICBoaWdobWVtX3N0YXJ0LCBsaW1pdCk7CisJCQkJbGltaXQgPSBoaWdobWVt
X3N0YXJ0OworCQkJfQorCiAJCQlpZiAoIWFkZHIpIHsKIAkJCQlyZXQgPSAtRU5PTUVNOwogCQkJ
CWdvdG8gZXJyOwotLSAKMS45LjEKCg==

--_004_VI1PR0401MB1792A3860CEFE44A750F06E4EE660VI1PR0401MB1792_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
