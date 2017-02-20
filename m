Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 615BF6B0389
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 04:53:01 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id 65so3087833oig.3
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 01:53:01 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0086.outbound.protection.outlook.com. [104.47.32.86])
        by mx.google.com with ESMTPS id h33si6480541oth.33.2017.02.20.01.53.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 20 Feb 2017 01:53:00 -0800 (PST)
From: "Nair, Vishnu" <Vishnu.Nair@cavium.com>
Subject: Re: [RFC PATCH v1 1/1] mm: zswap - Add crypto acomp/scomp framework
 support
Date: Mon, 20 Feb 2017 09:52:57 +0000
Message-ID: <MWHPR07MB2943F04F607146A954D404E3955E0@MWHPR07MB2943.namprd07.prod.outlook.com>
References: <1487086821-5880-1-git-send-email-Mahipal.Challa@cavium.com>
 <1487086821-5880-2-git-send-email-Mahipal.Challa@cavium.com>
 <CAC8qmcCt8VEX6QSSL35isN-nEvH-AJ2MAJHZy0TigxftsQN2jA@mail.gmail.com>
 <58A45E4A.8080508@caviumnetworks.com>,<20170215221208.GA820@silv-gc1.ir.intel.com>
In-Reply-To: <20170215221208.GA820@silv-gc1.ir.intel.com>
Content-Language: en-US
Content-Type: multipart/alternative;
	boundary="_000_MWHPR07MB2943F04F607146A954D404E3955E0MWHPR07MB2943namp_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Giovanni Cabiddu <giovanni.cabiddu@intel.com>, "Narayana, Prasad Athreya" <Prasad.Athreya@cavium.com>
Cc: Seth Jennings <sjenning@redhat.com>, Mahipal Challa <mahipalreddy2006@gmail.com>, "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>, "davem@davemloft.net" <davem@davemloft.net>, "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "Challa,
 Mahipal" <Mahipal.Challa@cavium.com>

--_000_MWHPR07MB2943F04F607146A954D404E3955E0MWHPR07MB2943namp_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

>This assumption is not correct. An asynchronous implementation, when
>it finishes processing a request, will call acomp_request_complete() which
>in turn calls the callback.
>If the callback is set to NULL, this function will dereference a NULL
>pointer.


This would leave us with the option of waiting in zswap until completion. H=
ere we had a doubt.

If we go ahead with an implementation similar to the one found in crypto/te=
stmgr.c, the private data(result) which is registered via 'acomp_request_se=
t_callback()' is coming from stack. Do you see this as a potential problem =
for an acutal asynchronus algorithm due to the context from which callback =
is called? Do we have to use per-cpu dynamic allocation?


Thanks,
Vishnu


________________________________
From: Giovanni Cabiddu <giovanni.cabiddu@intel.com>
Sent: Thursday, February 16, 2017 3:42 AM
To: Narayana, Prasad Athreya
Cc: Seth Jennings; Mahipal Challa; herbert@gondor.apana.org.au; davem@davem=
loft.net; linux-crypto@vger.kernel.org; LKML; Linux-MM; Narayana, Prasad At=
hreya; Nair, Vishnu; Challa, Mahipal; Nair, Vishnu
Subject: Re: [RFC PATCH v1 1/1] mm: zswap - Add crypto acomp/scomp framewor=
k support

On Wed, Feb 15, 2017 at 07:27:30PM +0530, Narayana Prasad Athreya wrote:
> > I assume all of these crypto_acomp_[compress|decompress] calls are
> > actually synchronous,
> > not asynchronous as the name suggests.  Otherwise, this would blow up
> > quite spectacularly
> > since all the resources we use in the call get derefed/unmapped below.
> >
> > Could an async algorithm be implement/used that would break this assump=
tion?
>
> The callback is set to NULL using acomp_request_set_callback(). This impl=
ies
> synchronous mode of operation. So the underlying implementation must
> complete the operation synchronously.
This assumption is not correct. An asynchronous implementation, when
it finishes processing a request, will call acomp_request_complete() which
in turn calls the callback.
If the callback is set to NULL, this function will dereference a NULL
pointer.

Regards,

--
Giovanni

--_000_MWHPR07MB2943F04F607146A954D404E3955E0MWHPR07MB2943namp_
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
<div id=3D"divtagdefaultwrapper" style=3D"font-size:12pt;color:#000000;font=
-family:Calibri,Arial,Helvetica,sans-serif;" dir=3D"ltr">
<p><font size=3D"2"><span style=3D"font-size:10pt;">&gt;This assumption is =
not correct. An asynchronous implementation, when<br>
&gt;it finishes processing a request, will call acomp_request_complete() wh=
ich<br>
&gt;in turn calls the callback.<br>
&gt;If the callback is set to NULL, this function will dereference a NULL<b=
r>
&gt;pointer.</span></font></p>
<p><font size=3D"2"><span style=3D"font-size:10pt;"><br>
</span></font></p>
<p><font size=3D"2"><span style=3D"font-size:10pt;"></span></font>This woul=
d leave us with the option of waiting in zswap until completion. Here we ha=
d a doubt.
<br>
</p>
<p>If we go ahead with an implementation similar to the one found in crypto=
/testmgr.c, the private data(result) which is registered via '<span>acomp_r=
equest_set_callback</span>()' is coming from stack. Do you see this as a po=
tential problem for an acutal asynchronus
 algorithm due to the context from which callback is called? Do we have to =
use per-cpu dynamic allocation?
<br>
</p>
<p><br>
</p>
<div id=3D"Signature">
<div id=3D"divtagdefaultwrapper" style=3D"font-size:12pt; color:#000000; ba=
ckground-color:#FFFFFF; font-family:Calibri,Arial,Helvetica,sans-serif">
<div name=3D"divtagdefaultwrapper" style=3D"font-family:Calibri,Arial,Helve=
tica,sans-serif; font-size:; margin:0">
Thanks,<br>
Vishnu <br>
</div>
</div>
</div>
<br>
<br>
<div style=3D"color: rgb(0, 0, 0);">
<div>
<hr tabindex=3D"-1" style=3D"display:inline-block; width:98%">
<div id=3D"x_divRplyFwdMsg" dir=3D"ltr"><font style=3D"font-size:11pt" face=
=3D"Calibri, sans-serif" color=3D"#000000"><b>From:</b> Giovanni Cabiddu &l=
t;giovanni.cabiddu@intel.com&gt;<br>
<b>Sent:</b> Thursday, February 16, 2017 3:42 AM<br>
<b>To:</b> Narayana, Prasad Athreya<br>
<b>Cc:</b> Seth Jennings; Mahipal Challa; herbert@gondor.apana.org.au; dave=
m@davemloft.net; linux-crypto@vger.kernel.org; LKML; Linux-MM; Narayana, Pr=
asad Athreya; Nair, Vishnu; Challa, Mahipal; Nair, Vishnu<br>
<b>Subject:</b> Re: [RFC PATCH v1 1/1] mm: zswap - Add crypto acomp/scomp f=
ramework support</font>
<div>&nbsp;</div>
</div>
</div>
<font size=3D"2"><span style=3D"font-size:10pt;">
<div class=3D"PlainText">On Wed, Feb 15, 2017 at 07:27:30PM &#43;0530, Nara=
yana Prasad Athreya wrote:<br>
&gt; &gt; I assume all of these crypto_acomp_[compress|decompress] calls ar=
e<br>
&gt; &gt; actually synchronous,<br>
&gt; &gt; not asynchronous as the name suggests.&nbsp; Otherwise, this woul=
d blow up<br>
&gt; &gt; quite spectacularly<br>
&gt; &gt; since all the resources we use in the call get derefed/unmapped b=
elow.<br>
&gt; &gt; <br>
&gt; &gt; Could an async algorithm be implement/used that would break this =
assumption?<br>
&gt; <br>
&gt; The callback is set to NULL using acomp_request_set_callback(). This i=
mplies<br>
&gt; synchronous mode of operation. So the underlying implementation must<b=
r>
&gt; complete the operation synchronously.<br>
This assumption is not correct. An asynchronous implementation, when<br>
it finishes processing a request, will call acomp_request_complete() which<=
br>
in turn calls the callback.<br>
If the callback is set to NULL, this function will dereference a NULL<br>
pointer.<br>
<br>
Regards,<br>
<br>
-- <br>
Giovanni <br>
</div>
</span></font></div>
</div>
</body>
</html>

--_000_MWHPR07MB2943F04F607146A954D404E3955E0MWHPR07MB2943namp_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
