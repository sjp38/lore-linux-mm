Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 548836B0038
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 20:27:44 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so54135387pab.3
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 17:27:44 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id fg3si10630568pac.187.2015.06.14.17.27.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 14 Jun 2015 17:27:43 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH 00/12] mm: mirrored memory support for page buddy
 allocations
Date: Mon, 15 Jun 2015 00:25:00 +0000
Message-ID: <20150615002500.GC4214@hori1.linux.bs1.fc.nec.co.jp>
References: <55704A7E.5030507@huawei.com>
 <20150612084233.GB19075@hori1.linux.bs1.fc.nec.co.jp>
 <20150612190335.GA21994@agluck-desk.sc.intel.com>
In-Reply-To: <20150612190335.GA21994@agluck-desk.sc.intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <234EE1977ABE7D439BE52CB8CA79328D@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "nao.horiguchi@gmail.com" <nao.horiguchi@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 12, 2015 at 12:03:35PM -0700, Luck, Tony wrote:
> On Fri, Jun 12, 2015 at 08:42:33AM +0000, Naoya Horiguchi wrote:
> > 4?) I don't have the whole picture of how address ranging mirroring wor=
ks,
> > but I'm curious about what happens when an uncorrected memory error hap=
pens
> > on the a mirror page. If HW/FW do some useful work invisible from kerne=
l,
> > please document it somewhere. And my questions are:
> >  - can the kernel with this patchset really continue its operation with=
out
> >    breaking consistency? More specifically, the corrupted page is repla=
ced with
> >    its mirror page, but can any other pages which have references (like=
 struct
> >    page or pfn) for the corrupted page properly switch these references=
 to the
> >    mirror page? Or no worry about that?  (This is difficult for kernel =
pages
> >    like slab, and that's why currently hwpoison doesn't handle any kern=
el pages.)
>=20
> The mirror is operated by h/w (perhaps with some platform firmware
> intervention when things start breaking badly).
>=20
> In normal operation there are two DIMM addresses backing each
> system physical address in the mirrored range (thus total system
> memory capacity is reduced when mirror is enabled).  Memory writes
> are directed to both locations. Memory reads are interleaved to
> maintain bandwidth, so could come from either address.

I misunderstood that both of mirrored page and mirroring page are visible
to OS, which is incorrect.

> When a read returns with an ECC failure the h/w automatically:
>  1) Re-issues the read to the other DIMM address. If that also fails - th=
en
>     we do the normal machine check processing for an uncorrected error
>  2) But if the other side of the mirror is good, we can send the good
>     data to the reader (cpu, or dma) and, in parallel try to fix the
>     bad side by writing the good data to it.
>  3) A corrected error will be logged, it may indicate whether the
>     attempt to fix succeeded or not.
>  4) If platform firmware wants, it can be notified of the correction
>     and it may keep statistics on the rate of errors, correction status,
>     etc.  If things get very bad it may "break" the mirror and direct
>     all future reads to the remaining "good" side. If does this it will
>     likely tell the OS via some ACPI method.

Thanks, this fully answered my question.=20

> All of this is done at much less than page granularity. Cache coherence
> is maintained ... apart from some small performance glitches and the corr=
ected
> error logs, the OS is unware of all of this.
>=20
> Note that in current implementations the mirror copies are both behind
> the same memory controller ... so this isn't intended to cope with high
> level failure of a memory controller ... just to deal with randomly
> distributed ECC errors.

OK, I looked at "Memory Address Range Mirroring Validation Guide" and Fig 2=
-2
clearly shows that.

> >  - How can we test/confirm that the whole scheme works fine?  Is curren=
t memory
> >    error injection framework enough?
>=20
> Still working on that piece. To validate you need to be able to
> inject errors to just one side of the mirror, and I'm not really
> sure that the ACPI/EINJ interface is up to the task.

OK.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
