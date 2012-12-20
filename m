Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id C6AC16B006C
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 22:03:00 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CF3653EE081
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 12:02:58 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B52E045DD74
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 12:02:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AF7345DE72
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 12:02:58 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DF461DB803E
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 12:02:58 +0900 (JST)
Received: from g01jpexchyt10.g01.fujitsu.local (g01jpexchyt10.g01.fujitsu.local [10.128.194.49])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 38D221DB803C
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 12:02:58 +0900 (JST)
From: "Hatayama, Daisuke" <d.hatayama@jp.fujitsu.com>
Subject: RE: [PATCH v2] Add the values related to buddy system for filtering
 free pages.
Date: Thu, 20 Dec 2012 03:02:56 +0000
Message-ID: <33710E6CAA200E4583255F4FB666C4E20AB2DEA3@G01JPEXMBYT03>
References: <20121210103913.020858db777e2f48c59713b6@mxc.nes.nec.co.jp>
 <20121219161856.e6aa984f.akpm@linux-foundation.org>
 <20121220112103.d698c09a9d1f27a253a63d37@mxc.nes.nec.co.jp>
In-Reply-To: <20121220112103.d698c09a9d1f27a253a63d37@mxc.nes.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "cpw@sgi.com" <cpw@sgi.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

> From: kexec-bounces@lists.infradead.org
> [mailto:kexec-bounces@lists.infradead.org] On Behalf Of Atsushi Kumagai
> Sent: Thursday, December 20, 2012 11:21 AM

> On Wed, 19 Dec 2012 16:18:56 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
>=20
> > On Mon, 10 Dec 2012 10:39:13 +0900
> > Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp> wrote:
> >

> >
> > We might change the PageBuddy() implementation at any time, and
> > makedumpfile will break.  Or in this case, become less efficient.
> >
> > Is there any way in which we can move some of this logic into the
> > kernel?  In this case, add some kernel code which uses PageBuddy() on
> > behalf of makedumpfile, rather than replicating the PageBuddy() logic
> > in userspace?
>=20
> In last month, Cliff Wickman proposed such idea:
>=20
>   [PATCH v2] makedumpfile: request the kernel do page scans
>   http://lists.infradead.org/pipermail/kexec/2012-November/007318.html
>=20
>   [PATCH] scan page tables for makedumpfile, 3.0.13 kernel
>   http://lists.infradead.org/pipermail/kexec/2012-November/007319.html
>=20
> In his idea, the kernel does page scans to distinguish unnecessary pages
> (free pages and others) and returns the list of PFN's which should be
> excluded for makedumpfile.
> As a result, makedumpfile doesn't need to consider internal kernel
> behavior.
>=20
> I think it's a good idea from the viewpoint of maintainability and
> performance.

I also think wide part of his code can be reused in this work. But the bad
performance is caused by a lot of ioremap, not a lot of copying. See my
profiling result I posted some days ago. Two issues, ioremap one and filter=
ing
maintainability, should be considered separately. Even on ioremap issue,
there is secondary one to consider in memory consumption on the 2nd kernel.

Also, I have one question. Can we always think of 1st and 2nd kernels are s=
ame?
If I understand correctly, kexec/kdump can use the 2nd kernel different
from the 1st's. So, differnet kernels need to do the same thing as makedump=
file
does. If assuming two are same, problem is mush simplified.

Thanks.
HATAYAMA, Daisuke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
