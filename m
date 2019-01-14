Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0CCDB8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 10:52:03 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id w4so8603433wrt.21
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 07:52:03 -0800 (PST)
Received: from mail-40130.protonmail.ch (mail-40130.protonmail.ch. [185.70.40.130])
        by mx.google.com with ESMTPS id b127si18677004wme.116.2019.01.14.07.52.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 07:52:01 -0800 (PST)
Date: Mon, 14 Jan 2019 15:51:54 +0000
From: Esme <esploit@protonmail.ch>
Reply-To: Esme <esploit@protonmail.ch>
Subject: Re: [PATCH v2] rbtree: fix the red root
Message-ID: <xeAUGwo5bQoLOJ9aXeSLY9G0hlKWJzjeZ4f4M1Hr8-1ryRwQ3Y-PgQ_eAtFAjpNZnn0zQGk6yHMkoEjjoM99vdhumv4Dey9KP5y6PvSRroo=@protonmail.ch>
In-Reply-To: <5298bfcc-0cbc-01e8-85b2-087a380fd3fe@lca.pw>
References: <20190111181600.GJ6310@bombadil.infradead.org>
 <864d6b85-3336-4040-7c95-7d9615873777@lechnology.com>
 <b1033d96-ebdd-e791-650a-c6564f030ce1@lca.pw>
 <8v11ZOLyufY7NLAHDFApGwXOO_wGjVHtsbw1eiZ__YvI9EZCDe_4FNmlp0E-39lnzGQHhHAczQ6Q6lQPzVU2V6krtkblM8IFwIXPHZCuqGE=@protonmail.ch>
 <c6265fc0-4089-9d1a-ba7c-b267b847747e@interlog.com>
 <UKsodHRZU8smIdO2MHHL4Yzde_YB4iWX43TaHI1uY2tMo4nii4ucbaw4XC31XIY-Pe4oEovjF62qbkeMsIMTrvT1TdCCP4Fs_fxciAzXYVc=@protonmail.ch>
 <ad591828-76e8-324b-6ab8-dc87e4390f64@interlog.com>
 <GBn2paWQ0Uy0COgTeJsgmC18Faw0x_yNIog8gpuC5TJ4kCn_IUH1EnHJW0mQeo3Qy5MMcpMzyw9Yer3lxyWYgtk5TJx8I3sJK4oVlIJh38s=@protonmail.ch>
 <5298bfcc-0cbc-01e8-85b2-087a380fd3fe@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: "dgilbert@interlog.com" <dgilbert@interlog.com>, David Lechner <david@lechnology.com>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, "jejb@linux.ibm.com" <jejb@linux.ibm.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "joeypabalinas@gmail.com" <joeypabalinas@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Disabled kmemleak options. On mobile, pardon brevity.


Sent with ProtonMail Secure Email.

=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90 Original Me=
ssage =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90
On Monday, January 14, 2019 10:45 AM, Qian Cai <cai@lca.pw> wrote:

> On 1/14/19 1:23 AM, Esme wrote:
>
> > I did not yet verify the previous branches but did tune out kmemleak (C=
ONFIG_DEBUG_MEMLEAK no longer set) as it seemed a bit obtrusive in this mat=
ter, this is what I see now (note redzone?).
> > /Esme
> > 114.826116] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> > [ 114.828121] BUG kmalloc-64 (Tainted: G W ): Padding overwritten. 0x00=
0000006913c65d-0x000000006e410492
> > [ 114.830551] ---------------------------------------------------------=
--------------------
> > [ 114.830551]
> > [ 114.832755] INFO: Slab 0x0000000054f47c55 objects=3D19 used=3D19 fp=
=3D0x (null) flags=3D0x1fffc0000010200
> > [ 114.835063] CPU: 0 PID: 6310 Comm: x Tainted: G B W 5.0.0-rc2 #15
> > [ 114.836829] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BI=
OS 1.11.1-1ubuntu1 04/01/2014
> > [ 114.838847] Call Trace:
> > [ 114.839497] dump_stack+0x1d8/0x2c6
> > [ 114.840274] ? dump_stack_print_info.cold.1+0x20/0x20
> > [ 114.841402] slab_err+0xab/0xcf
> > [ 114.842103] ? __asan_report_load1_noabort+0x14/0x20
> > [ 114.843244] ? memchr_inv+0x2c1/0x330
> > [ 114.844059] slab_pad_check.part.50.cold.87+0x27/0x81
>
> Confused again. Those slab_pad_check() looks like only with SLUB, but you=
 said
> you used SLAB. What else did you change?
