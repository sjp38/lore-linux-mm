Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f71.google.com (mail-qg0-f71.google.com [209.85.192.71])
	by kanga.kvack.org (Postfix) with ESMTP id 63BD36B007E
	for <linux-mm@kvack.org>; Sat, 16 Apr 2016 18:05:45 -0400 (EDT)
Received: by mail-qg0-f71.google.com with SMTP id t38so184320118qge.3
        for <linux-mm@kvack.org>; Sat, 16 Apr 2016 15:05:45 -0700 (PDT)
Received: from nm41-vm4.bullet.mail.bf1.yahoo.com (nm41-vm4.bullet.mail.bf1.yahoo.com. [216.109.114.159])
        by mx.google.com with ESMTPS id b74si41639972qhb.115.2016.04.16.15.05.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Apr 2016 15:05:44 -0700 (PDT)
Date: Sat, 16 Apr 2016 22:05:09 +0000 (UTC)
From: Paul Sturm <paul_a_sturm@yahoo.com>
Reply-To: Paul Sturm <paul_a_sturm@yahoo.com>
Message-ID: <217592687.1822970.1460844309150.JavaMail.yahoo@mail.yahoo.com>
Subject: pmd_set_huge failure and ACPI warning
MIME-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_1822969_1769754276.1460844309139"
References: <217592687.1822970.1460844309150.JavaMail.yahoo.ref@mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

------=_Part_1822969_1769754276.1460844309139
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Not sure if this is the right place to post. If it is not please direct me =
to where I should go.

I am running x86_64 kernel 4.4.6 on an Intel Xeon D system. This is an SOC =
system that includes dual 10G ethernet using the ixgbe driver.=C2=A0
I have also tested this on kernels 4.2 through 4.6rc3 with the same result.

When the ixgbe driver loads, I get the following two warnings:

[ 5453.184701] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - vers=
ion 4.2.1-k=C2=A0
[ 5453.184704] ixgbe: Copyright (c) 1999-2015 Intel Corporation.=C2=A0
[ 5453.184767] ACPI Warning: \_SB_.PCI0.BR2C._PRT: Return Package has no el=
ements (empty) (20150930/nsprepkg-126)=C2=A0
[ 5453.184891] pmd_set_huge: Cannot satisfy [mem 0x383fffa00000-0x383fffc00=
000] with a huge-page mapping due to MTRR override.=C2=A0

BIOS is set to enable 64-bit DMA above 4GB.=C2=A0
cat proc/mtrr looks like this:=C2=A0
reg00: base=3D0x080000000 ( 2048MB ), size=3D 2048MB, count=3D1: uncachable=
=C2=A0
reg01: base=3D0x380000000000 (58720256MB ), size=3D262144MB, count=3D1: unc=
achable=C2=A0
reg02: base=3D0x383fff800000 (58982392MB ), size=3D 8MB, count=3D1: write-t=
hrough=C2=A0
reg03: base=3D0x383ffff00000 (58982399MB ), size=3D 1MB, count=3D1: uncacha=
ble=C2=A0

When I change the BIOS setting to disable DMA above 4GB (no other BIOS chan=
ges I tried had any effect on the MTRR ranges)=C2=A0
cat /proc/mtrr looks like this:=C2=A0
reg00: base=3D0x080000000 ( 2048MB ), size=3D 2048MB, count=3D1: uncachable=
=C2=A0
reg01: base=3D0x380000000000 (58720256MB ), size=3D262144MB, count=3D1: unc=
achable=C2=A0
reg02: base=3D0x0f9800000 ( 3992MB ), size=3D 8MB, count=3D1: write-through=
=C2=A0
reg03: base=3D0x0f9f00000 ( 3999MB ), size=3D 1MB, count=3D1: uncachable=C2=
=A0

and the pmd_set_huge warning indicates a memory range in the 0x0fxxxx uncac=
heable range.=C2=A0

So the result is that ixgbe seems to always try to get it's hugepage from t=
he uncacheable range.=C2=A0

I can post the full dmesg if requested, but in the meantime, here are the T=
LB-related entries:=C2=A0
[ 0.027925] Last level iTLB entries: 4KB 64, 2MB 8, 4MB 8=C2=A0
[ 0.027931] Last level dTLB entries: 4KB 64, 2MB 0, 4MB 0, 1GB 4=C2=A0

[ 0.325307] HugeTLB registered 1 GB page size, pre-allocated 0 pages=C2=A0
[ 0.325315] HugeTLB registered 2 MB page size, pre-allocated 0 pages=C2=A0
I tried to pre-allocate both 1GB and 2MB pages via the kernel command line =
and it had no effect.=C2=A0

I have tried both compiling the driver in the kernel and loading it as a mo=
dule. Same results.=C2=A0

I first reported this on the e1000 sourceforge list and they directed me he=
re.=C2=A0

In addition to the pmd_set_huge warning, there is also that ACPI warning. I=
 am not sure if it is related or not, but I can say it only appears when th=
e IXGBE driver is loaded and it always loads right before the pmd_set_huge =
warning.=C2=A0

Please advise.

------=_Part_1822969_1769754276.1460844309139
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<html><head></head><body><div style=3D"color:#000; background-color:#fff; f=
ont-family:HelveticaNeue, Helvetica Neue, Helvetica, Arial, Lucida Grande, =
sans-serif;font-size:16px"><div id=3D"yui_3_16_0_ym19_1_1460842411323_18387=
" dir=3D"ltr"><span style=3D"color: rgb(51, 51, 51); font-family: monospace=
; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18619">Not sur=
e if this is the right place to post. If it is not please direct me to wher=
e I should go.</span><br style=3D"color: rgb(51, 51, 51); font-family: mono=
space; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18620"><b=
r style=3D"color: rgb(51, 51, 51); font-family: monospace; font-size: 14.16=
px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18621"><span style=3D"color: rgb=
(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0=
_ym19_1_1460842411323_18622">I am running x86_64 kernel 4.4.6 on an Intel X=
eon D system. This is an SOC system that includes dual 10G ethernet using t=
he ixgbe driver.</span><span style=3D"color: rgb(51, 51, 51); font-family: =
monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18623=
">&nbsp;</span><br style=3D"color: rgb(51, 51, 51); font-family: monospace;=
 font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18624"><span st=
yle=3D"color: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;"=
 id=3D"yui_3_16_0_ym19_1_1460842411323_18625">I have also tested this on ke=
rnels 4.2 through 4.6rc3 with the same result.</span><br style=3D"color: rg=
b(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_=
0_ym19_1_1460842411323_18626"><br style=3D"color: rgb(51, 51, 51); font-fam=
ily: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_=
18627"><span style=3D"color: rgb(51, 51, 51); font-family: monospace; font-=
size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18628">When the ixgbe=
 driver loads, I get the following two warnings:</span><br style=3D"color: =
rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_1=
6_0_ym19_1_1460842411323_18629"><br style=3D"color: rgb(51, 51, 51); font-f=
amily: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_146084241132=
3_18630"><span style=3D"color: rgb(51, 51, 51); font-family: monospace; fon=
t-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18631">[ 5453.18470=
1] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 4.2.1-k<=
/span><span style=3D"color: rgb(51, 51, 51); font-family: monospace; font-s=
ize: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18632">&nbsp;</span><b=
r style=3D"color: rgb(51, 51, 51); font-family: monospace; font-size: 14.16=
px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18633"><span style=3D"color: rgb=
(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0=
_ym19_1_1460842411323_18634">[ 5453.184704] ixgbe: Copyright (c) 1999-2015 =
Intel Corporation.</span><span style=3D"color: rgb(51, 51, 51); font-family=
: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_186=
35">&nbsp;</span><br style=3D"color: rgb(51, 51, 51); font-family: monospac=
e; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18636"><span =
style=3D"color: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px=
;" id=3D"yui_3_16_0_ym19_1_1460842411323_18637">[ 5453.184767] ACPI Warning=
: \_SB_.PCI0.BR2C._PRT: Return Package has no elements (empty) (20150930/ns=
prepkg-126)</span><span style=3D"color: rgb(51, 51, 51); font-family: monos=
pace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18638">&nb=
sp;</span><br style=3D"color: rgb(51, 51, 51); font-family: monospace; font=
-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18639"><span style=
=3D"color: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=
=3D"yui_3_16_0_ym19_1_1460842411323_18640">[ 5453.184891] pmd_set_huge: Can=
not satisfy [mem 0x383fffa00000-0x383fffc00000] with a huge-page mapping du=
e to MTRR override.</span><span style=3D"color: rgb(51, 51, 51); font-famil=
y: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18=
641">&nbsp;</span><br style=3D"color: rgb(51, 51, 51); font-family: monospa=
ce; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18642"><br s=
tyle=3D"color: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;=
" id=3D"yui_3_16_0_ym19_1_1460842411323_18643"><span style=3D"color: rgb(51=
, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym=
19_1_1460842411323_18644">BIOS is set to enable 64-bit DMA above 4GB.</span=
><span style=3D"color: rgb(51, 51, 51); font-family: monospace; font-size: =
14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18645">&nbsp;</span><br sty=
le=3D"color: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;" =
id=3D"yui_3_16_0_ym19_1_1460842411323_18646"><span style=3D"color: rgb(51, =
51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19=
_1_1460842411323_18647">cat proc/mtrr looks like this:</span><span style=3D=
"color: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D=
"yui_3_16_0_ym19_1_1460842411323_18648">&nbsp;</span><br style=3D"color: rg=
b(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_=
0_ym19_1_1460842411323_18649"><span style=3D"color: rgb(51, 51, 51); font-f=
amily: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_146084241132=
3_18650">reg00: base=3D0x080000000 ( 2048MB ), size=3D 2048MB, count=3D1: u=
ncachable</span><span style=3D"color: rgb(51, 51, 51); font-family: monospa=
ce; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18651">&nbsp=
;</span><br style=3D"color: rgb(51, 51, 51); font-family: monospace; font-s=
ize: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18652"><span style=3D"=
color: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"=
yui_3_16_0_ym19_1_1460842411323_18653">reg01: base=3D0x380000000000 (587202=
56MB ), size=3D262144MB, count=3D1: uncachable</span><span style=3D"color: =
rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_1=
6_0_ym19_1_1460842411323_18654">&nbsp;</span><br style=3D"color: rgb(51, 51=
, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1=
_1460842411323_18655"><span style=3D"color: rgb(51, 51, 51); font-family: m=
onospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18656"=
>reg02: base=3D0x383fff800000 (58982392MB ), size=3D 8MB, count=3D1: write-=
through</span><span style=3D"color: rgb(51, 51, 51); font-family: monospace=
; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18657">&nbsp;<=
/span><br style=3D"color: rgb(51, 51, 51); font-family: monospace; font-siz=
e: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18658"><span style=3D"co=
lor: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yu=
i_3_16_0_ym19_1_1460842411323_18659">reg03: base=3D0x383ffff00000 (58982399=
MB ), size=3D 1MB, count=3D1: uncachable</span><span style=3D"color: rgb(51=
, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym=
19_1_1460842411323_18660">&nbsp;</span><br style=3D"color: rgb(51, 51, 51);=
 font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_14608=
42411323_18661"><br style=3D"color: rgb(51, 51, 51); font-family: monospace=
; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18662"><span s=
tyle=3D"color: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;=
" id=3D"yui_3_16_0_ym19_1_1460842411323_18663">When I change the BIOS setti=
ng to disable DMA above 4GB (no other BIOS changes I tried had any effect o=
n the MTRR ranges)</span><span style=3D"color: rgb(51, 51, 51); font-family=
: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_186=
64">&nbsp;</span><br style=3D"color: rgb(51, 51, 51); font-family: monospac=
e; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18665"><span =
style=3D"color: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px=
;" id=3D"yui_3_16_0_ym19_1_1460842411323_18666">cat /proc/mtrr looks like t=
his:</span><span style=3D"color: rgb(51, 51, 51); font-family: monospace; f=
ont-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18667">&nbsp;</sp=
an><br style=3D"color: rgb(51, 51, 51); font-family: monospace; font-size: =
14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18668"><span style=3D"color=
: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui_3=
_16_0_ym19_1_1460842411323_18669">reg00: base=3D0x080000000 ( 2048MB ), siz=
e=3D 2048MB, count=3D1: uncachable</span><span style=3D"color: rgb(51, 51, =
51); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1=
460842411323_18670">&nbsp;</span><br style=3D"color: rgb(51, 51, 51); font-=
family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_14608424113=
23_18671"><span style=3D"color: rgb(51, 51, 51); font-family: monospace; fo=
nt-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18672">reg01: base=
=3D0x380000000000 (58720256MB ), size=3D262144MB, count=3D1: uncachable</sp=
an><span style=3D"color: rgb(51, 51, 51); font-family: monospace; font-size=
: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18673">&nbsp;</span><br s=
tyle=3D"color: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;=
" id=3D"yui_3_16_0_ym19_1_1460842411323_18674"><span style=3D"color: rgb(51=
, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym=
19_1_1460842411323_18675">reg02: base=3D0x0f9800000 ( 3992MB ), size=3D 8MB=
, count=3D1: write-through</span><span style=3D"color: rgb(51, 51, 51); fon=
t-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_146084241=
1323_18676">&nbsp;</span><br style=3D"color: rgb(51, 51, 51); font-family: =
monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18677=
"><span style=3D"color: rgb(51, 51, 51); font-family: monospace; font-size:=
 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18678">reg03: base=3D0x0f9=
f00000 ( 3999MB ), size=3D 1MB, count=3D1: uncachable</span><span style=3D"=
color: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"=
yui_3_16_0_ym19_1_1460842411323_18679">&nbsp;</span><br style=3D"color: rgb=
(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0=
_ym19_1_1460842411323_18680"><br style=3D"color: rgb(51, 51, 51); font-fami=
ly: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_1=
8681"><span style=3D"color: rgb(51, 51, 51); font-family: monospace; font-s=
ize: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18682">and the pmd_set=
_huge warning indicates a memory range in the 0x0fxxxx uncacheable range.</=
span><span style=3D"color: rgb(51, 51, 51); font-family: monospace; font-si=
ze: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18683">&nbsp;</span><br=
 style=3D"color: rgb(51, 51, 51); font-family: monospace; font-size: 14.16p=
x;" id=3D"yui_3_16_0_ym19_1_1460842411323_18684"><br style=3D"color: rgb(51=
, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym=
19_1_1460842411323_18685"><span style=3D"color: rgb(51, 51, 51); font-famil=
y: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18=
686">So the result is that ixgbe seems to always try to get it's hugepage f=
rom the uncacheable range.</span><span style=3D"color: rgb(51, 51, 51); fon=
t-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_146084241=
1323_18687">&nbsp;</span><br style=3D"color: rgb(51, 51, 51); font-family: =
monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18688=
"><br style=3D"color: rgb(51, 51, 51); font-family: monospace; font-size: 1=
4.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18689"><span style=3D"color:=
 rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_=
16_0_ym19_1_1460842411323_18690">I can post the full dmesg if requested, bu=
t in the meantime, here are the TLB-related entries:</span><span style=3D"c=
olor: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"y=
ui_3_16_0_ym19_1_1460842411323_18691">&nbsp;</span><br style=3D"color: rgb(=
51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_=
ym19_1_1460842411323_18692"><span style=3D"color: rgb(51, 51, 51); font-fam=
ily: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_=
18693">[ 0.027925] Last level iTLB entries: 4KB 64, 2MB 8, 4MB 8</span><spa=
n style=3D"color: rgb(51, 51, 51); font-family: monospace; font-size: 14.16=
px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18694">&nbsp;</span><br style=3D=
"color: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D=
"yui_3_16_0_ym19_1_1460842411323_18695"><span style=3D"color: rgb(51, 51, 5=
1); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_14=
60842411323_18696">[ 0.027931] Last level dTLB entries: 4KB 64, 2MB 0, 4MB =
0, 1GB 4</span><span style=3D"color: rgb(51, 51, 51); font-family: monospac=
e; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18697">&nbsp;=
</span><br style=3D"color: rgb(51, 51, 51); font-family: monospace; font-si=
ze: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18698"><br style=3D"col=
or: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui=
_3_16_0_ym19_1_1460842411323_18699"><span style=3D"color: rgb(51, 51, 51); =
font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_146084=
2411323_18700">[ 0.325307] HugeTLB registered 1 GB page size, pre-allocated=
 0 pages</span><span style=3D"color: rgb(51, 51, 51); font-family: monospac=
e; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18701">&nbsp;=
</span><br style=3D"color: rgb(51, 51, 51); font-family: monospace; font-si=
ze: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18702"><span style=3D"c=
olor: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"y=
ui_3_16_0_ym19_1_1460842411323_18703">[ 0.325315] HugeTLB registered 2 MB p=
age size, pre-allocated 0 pages</span><span style=3D"color: rgb(51, 51, 51)=
; font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460=
842411323_18704">&nbsp;</span><br style=3D"color: rgb(51, 51, 51); font-fam=
ily: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_=
18705"><span style=3D"color: rgb(51, 51, 51); font-family: monospace; font-=
size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18706">I tried to pre=
-allocate both 1GB and 2MB pages via the kernel command line and it had no =
effect.</span><span style=3D"color: rgb(51, 51, 51); font-family: monospace=
; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18707">&nbsp;<=
/span><br style=3D"color: rgb(51, 51, 51); font-family: monospace; font-siz=
e: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18708"><br style=3D"colo=
r: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui_=
3_16_0_ym19_1_1460842411323_18709"><span style=3D"color: rgb(51, 51, 51); f=
ont-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842=
411323_18710">I have tried both compiling the driver in the kernel and load=
ing it as a module. Same results.</span><span style=3D"color: rgb(51, 51, 5=
1); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_14=
60842411323_18711">&nbsp;</span><br style=3D"color: rgb(51, 51, 51); font-f=
amily: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_146084241132=
3_18712"><br style=3D"color: rgb(51, 51, 51); font-family: monospace; font-=
size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18713"><span style=3D=
"color: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D=
"yui_3_16_0_ym19_1_1460842411323_18714">I first reported this on the e1000 =
sourceforge list and they directed me here.</span><span style=3D"color: rgb=
(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0=
_ym19_1_1460842411323_18715">&nbsp;</span><br style=3D"color: rgb(51, 51, 5=
1); font-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_14=
60842411323_18716"><br style=3D"color: rgb(51, 51, 51); font-family: monosp=
ace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18717"><spa=
n style=3D"color: rgb(51, 51, 51); font-family: monospace; font-size: 14.16=
px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18718">In addition to the pmd_se=
t_huge warning, there is also that ACPI warning. I am not sure if it is rel=
ated or not, but I can say it only appears when the IXGBE driver is loaded =
and it always loads right before the pmd_set_huge warning.</span><span styl=
e=3D"color: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;" i=
d=3D"yui_3_16_0_ym19_1_1460842411323_18719">&nbsp;</span><br style=3D"color=
: rgb(51, 51, 51); font-family: monospace; font-size: 14.16px;" id=3D"yui_3=
_16_0_ym19_1_1460842411323_18720"><br style=3D"color: rgb(51, 51, 51); font=
-family: monospace; font-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411=
323_18721"><span style=3D"color: rgb(51, 51, 51); font-family: monospace; f=
ont-size: 14.16px;" id=3D"yui_3_16_0_ym19_1_1460842411323_18722">Please adv=
ise.</span><br></div></div></body></html>
------=_Part_1822969_1769754276.1460844309139--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
