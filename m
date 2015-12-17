Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7214402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 13:43:24 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id n128so16875758pfn.0
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 10:43:24 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id z12si17962451pas.77.2015.12.17.10.43.22
        for <linux-mm@kvack.org>;
        Thu, 17 Dec 2015 10:43:23 -0800 (PST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
Date: Thu, 17 Dec 2015 18:43:20 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F39F882E8@ORSMSX114.amr.corp.intel.com>
References: <1449631109-14756-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1449631177-14863-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <56679FDC.1080800@huawei.com>
 <3908561D78D1C84285E8C5FCA982C28F39F7F4CD@ORSMSX114.amr.corp.intel.com>
 <5668D1FA.4050108@huawei.com>
 <E86EADE93E2D054CBCD4E708C38D364A54299720@G01JPEXMBYT01>
 <56691819.3040105@huawei.com>
 <E86EADE93E2D054CBCD4E708C38D364A54299AA4@G01JPEXMBYT01>
 <566A9AE1.7020001@huawei.com>
 <E86EADE93E2D054CBCD4E708C38D364A5429B2DE@G01JPEXMBYT01>
 <56722258.6030800@huawei.com> <567223A7.9090407@jp.fujitsu.com>
 <56723E8B.8050201@huawei.com> <567241BE.5030806@jp.fujitsu.com>
In-Reply-To: <567241BE.5030806@jp.fujitsu.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>
Cc: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Hansen, Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

>>> As Tony requested, we may need a knob to stop a fallback in "movable->n=
ormal", later.
>>>
>>=20
>> If the mirrored memory is small and the other is large,
>> I think we can both enable "non-mirrored -> normal" and "normal -> non-m=
irrored".
>
> Size of mirrored memory can be configured by software(EFI var).
> So, having both is just overkill and normal->non-mirroed fallback is mean=
ingless considering
> what the feature want to guarantee.

In the original removable usage we wanted to guarantee that Linux did not a=
llocate any
kernel objects in removable memory - because that would prevent later remov=
al of that
memory.

Mirror case is the same - we don't want to allocate kernel structures in no=
n-mirrored memory
because an uncorrectable error in one of them would crash the system.

But I think some users might like some flexibility here.  If the system doe=
sn't have enough
memory for the kernel (non-movable or mirrored), then it seems odd to end u=
p crashing
the system at the point of memory exhaustion (a likely result ... the kerne=
l can try to reclaim
some pages from SLAB, but that might only return a few pages, if the shorta=
ge continues
the system will perform poorly and eventually fail).

The whole point of removable memory or mirrored memory is to provide better=
 availability.

I'd vote for a mode where running out of memory for kernel results in a

   warn_on_once("Ran out of mirrored/non-removable memory for kernel - now =
allocating from all zones\n")

because I think most people would like the system to stay up rather than wo=
rry about some future problem that may never happen.

-Tony



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
