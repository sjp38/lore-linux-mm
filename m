Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id A4EFA6B0258
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 10:14:53 -0500 (EST)
Received: by wmec201 with SMTP id c201so86064573wme.0
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 07:14:53 -0800 (PST)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id gd4si26407511wjb.2.2015.11.13.07.14.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Nov 2015 07:14:52 -0800 (PST)
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <andreas.krebbel@de.ibm.com>;
	Fri, 13 Nov 2015 15:14:51 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 97F6B219005C
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 15:14:45 +0000 (GMT)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tADFEoAI1769976
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 15:14:50 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tADFEonW013744
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 08:14:50 -0700
Received: from d50lp02.ny.us.ibm.com ([146.89.104.208])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVin) with ESMTP id tADFEn37011076
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 08:14:49 -0700
Message-Id: <201511131514.tADFEn37011076@d06av09.portsmouth.uk.ibm.com>
Received: from /spool/local
	by d50lp02.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <andreas.krebbel@de.ibm.com>;
	Fri, 13 Nov 2015 10:13:59 -0500
Received: from /spool/local
	by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
	for <linux-mm@kvack.org> from <andreas.krebbel@de.ibm.com>;
	Fri, 13 Nov 2015 15:13:56 -0000
In-Reply-To: <20151113125200.319a3101@mschwide>
Subject: Re: [linux-next:master 12891/13017] mm/slub.c:2396:1: warning:
 '___slab_alloc' uses dynamic stack allocation
From: "Andreas Krebbel1" <Andreas.Krebbel@de.ibm.com>
Date: Fri, 13 Nov 2015 16:13:46 +0100
References: <201511111413.65wysS6A%fengguang.wu@intel.com><20151111124108.53df1f48218c1366f9e763f0@linux-foundation.org>
 <20151113125200.319a3101@mschwide>
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="=_alternative 0053A859C1257EFC_="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mschwid2@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>, heicars2@linux.vnet.ibm.com, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>


--=_alternative 0053A859C1257EFC_=
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="US-ASCII"

mschwid2@linux.vnet.ibm.com wrote on 11/13/2015 12:52:00 PM:
> > This patch doesn't add any dynamic stack allocations.  The fact that
> > slub.c already had a bunch of these warnings makes me suspect that=20
it's
> > happening in one of the s390 headers?
>=20
> That looks like a false positive to me. I can not find any function that =

does
> a dynamic allocation and the generated code creates a stack frame with a
> constant size. A bit odd is the fact that the stack frame is create in=20
two
> steps, e.g. deactivate=5Fslab:
>=20
>     a632:       b9 04 00 ef             lgr     %r14,%r15
>     a636:       a7 fb ff 50             aghi    %r15,-176   # first 176=20
bytes
>     a63a:       b9 04 00 bf             lgr     %r11,%r15
>     a63e:       e3 e0 f0 98 00 24       stg     %r14,152(%r15)
>     a644:       e3 10 f0 98 00 04       lg      %r1,152(%r15)
>     a64a:       a7 fb ff 30             aghi    %r15,-208   #=20
> another 208 bytes
>     a64e:       e3 30 b0 e8 00 24       stg     %r3,232(%r11)
>     a654:       e3 40 b0 d8 00 24       stg     %r4,216(%r11)
>=20
> Strange. Andreas can you make something of this?

Hi Martin,

this appears to be the result of aligning struct page to more than 8 bytes =

and putting it onto the stack - wich is only 8 bytes aligned.  The=20
compiler has to perform runtime alignment to achieve that. It allocates=20
memory using *alloca* and does the math with the returned pointer. Our=20
dynamic stack allocation option basically only checks if there is an=20
alloca user.

We have added that -mwarn-dynamicstack option because our runtime check=20
(-mstack-guard) is only able to deal with the static stack allocations. So =

with dynamic stack allocations you might still overwrite stuff without the =

runtime stack guard being able to catch it. So in one regard the warning=20
is correct since there in fact is a stack allocation which will not be=20
covered by the stack guard. One the other hand the additional stack=20
allocation is done with a constant value so it is not really dynamic and=20
the warning message is not really helpful. Perhaps we should emit warnings =

whenever there are stack allocations present which aren't covered by the=20
stack guard? Or should we silently ignore such a case?

-Andreas-


--=_alternative 0053A859C1257EFC_=
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html; charset="US-ASCII"

<tt><font size=3D2>mschwid2@linux.vnet.ibm.com wrote on 11/13/2015 12:52:00
PM:<br>&gt; &gt; This patch doesn't add any dynamic stack allocations. &nbs=
p;The
fact that<br>&gt; &gt; slub.c already had a bunch of these warnings makes m=
e suspect
that it's<br>&gt; &gt; happening in one of the s390 headers?<br>&gt; &nbsp;=
<br>&gt; That looks like a false positive to me. I can not find any function
that does<br>&gt; a dynamic allocation and the generated code creates a sta=
ck frame
with a<br>&gt; constant size. A bit odd is the fact that the stack frame is=
 create
in two<br>&gt; steps, e.g. deactivate=5Fslab:<br>&gt; <br>&gt; &nbsp; &nbsp=
; a632: &nbsp; &nbsp; &nbsp; b9 04 00 ef &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; lgr &nbsp; &nbsp; %r14,%r15<br>&gt; &nbsp; &nbs=
p; a636: &nbsp; &nbsp; &nbsp; a7 fb ff 50 &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; aghi &nbsp; &nbsp;%r15,-176 &nbsp; # first
176 bytes<br>&gt; &nbsp; &nbsp; a63a: &nbsp; &nbsp; &nbsp; b9 04 00 bf &nbs=
p; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; lgr &nbsp; &nbsp; %r11,%r15<br>&gt; &nbsp; &nbs=
p; a63e: &nbsp; &nbsp; &nbsp; e3 e0 f0 98 00 24 &nbsp;
&nbsp; &nbsp; stg &nbsp; &nbsp; %r14,152(%r15)<br>&gt; &nbsp; &nbsp; a644: =
&nbsp; &nbsp; &nbsp; e3 10 f0 98 00 04 &nbsp;
&nbsp; &nbsp; lg &nbsp; &nbsp; &nbsp;%r1,152(%r15)<br>&gt; &nbsp; &nbsp; a6=
4a: &nbsp; &nbsp; &nbsp; a7 fb ff 30 &nbsp; &nbsp;
&nbsp; &nbsp; &nbsp; &nbsp; aghi &nbsp; &nbsp;%r15,-208 &nbsp; # <br>&gt; a=
nother 208 bytes<br>&gt; &nbsp; &nbsp; a64e: &nbsp; &nbsp; &nbsp; e3 30 b0 =
e8 00 24 &nbsp;
&nbsp; &nbsp; stg &nbsp; &nbsp; %r3,232(%r11)<br>&gt; &nbsp; &nbsp; a654: &=
nbsp; &nbsp; &nbsp; e3 40 b0 d8 00 24 &nbsp;
&nbsp; &nbsp; stg &nbsp; &nbsp; %r4,216(%r11)<br>&gt; <br>&gt; Strange. And=
reas can you make something of this?<br></font></tt><br><tt><font size=3D2>=
Hi Martin,</font></tt><br><br><tt><font size=3D2>this appears to be the res=
ult of aligning struct page
to more than 8 bytes and putting it onto the stack - wich is only 8 bytes
aligned. &nbsp;The compiler has to perform runtime alignment to achieve
that. It allocates memory using *alloca* and does the math with the returned
pointer. Our dynamic stack allocation option basically only checks if there
is an alloca user.</font></tt><br><br><tt><font size=3D2>We have added that=
 -mwarn-dynamicstack option because
our runtime check (-mstack-guard) is only able to deal with the static
stack allocations. So with dynamic stack allocations you might still overwr=
ite
stuff without the runtime stack guard being able to catch it. So in one
regard the warning is correct since there in fact is a stack allocation
which will not be covered by the stack guard. One the other hand the additi=
onal
stack allocation is done with a constant value so it is not really dynamic
and the warning message is not really helpful. Perhaps we should emit warni=
ngs
whenever there are stack allocations present which aren't covered by the
stack guard? Or should we silently ignore such a case?</font></tt><br><br><=
tt><font size=3D2>-Andreas-</font></tt><BR>
--=_alternative 0053A859C1257EFC_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
