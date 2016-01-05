Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id E96F46B000A
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 19:27:33 -0500 (EST)
Received: by mail-io0-f178.google.com with SMTP id o67so451229637iof.3
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 16:27:33 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id b67si44214235ioj.123.2016.01.04.16.27.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Jan 2016 16:27:33 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: pagewalk API
Date: Tue, 5 Jan 2016 00:26:10 +0000
Message-ID: <20160105002609.GA13579@hori1.linux.bs1.fc.nec.co.jp>
References: <20160104182939.GA27351@linux.intel.com>
 <20160104204727.GE13515@node.shutemov.name>
In-Reply-To: <20160104204727.GE13515@node.shutemov.name>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <94CFB41504CF2A4388588FCD31DDA833@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Matthew Wilcox <willy@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Kirill, Matthew,

On Mon, Jan 04, 2016 at 10:47:27PM +0200, Kirill A. Shutemov wrote:
> On Mon, Jan 04, 2016 at 01:29:39PM -0500, Matthew Wilcox wrote:
> >=20
> > I find myself in the position of needing to expand the pagewalk API to
> > allow PUDs to be passed to pagewalk handlers.
> >=20
> > The problem with the current pagewalk API is that it requires the calle=
rs
> > to implement a lot of boilerplate, and the further up the hierarchy we
> > intercept the pagewalk, the more boilerplate has to be implemented in e=
ach
> > caller, to the point where it's not worth using the pagewalk API any mo=
re.
> >
> > Compare and contrast mincore's pud_entry that only has to handle PUDs
> > which are guaranteed to be (1) present, (2) huge, (3) locked versus the
> > PMD code which has to take care of checking all three things itself.
> >=20
> > (http://marc.info/?l=3Dlinux-mm&m=3D145097405229181&w=3D2)

In the current pagewalk API, each walk can choose whether to enter lower
levels with return values of callbacks, so I think that using ->pud_entry
along with ->pmd_entry or ->pte_entry is a valid usage.

The confusion seems to be in the current code (not in your patch.) Currentl=
y
many of current ->pmd_entry()s handle both PMD stuff and PTE stuff, but ide=
ally,
each level of callback should deal with only the relevant level of entry to
minimize duplicate code.
I tried it a few years ago, but that's unfinished at that time because ther=
e
was a difference in ptl pattern among pagewalk callers.

> > Kirill's point is that it's confusing to have the PMD and PUD handling
> > be different, and I agree.  But it certainly saves a lot of code in the
> > callers.  So should we convert the PMD code to be similar?  Or put a
> > subptimal API in for the PUD case?

.. so I like "converting PMD code" option.

> Naoya, if I remember correctly, we had something like this on early stage
> of you pagewalk rework. Is it correct? If yes, why it was changed to what
> we have now?

Yes, maybe I mentioned the suboptimality in current code. My pagewalk work
didn't solve it because main focus was on fixing problems around ->hugetlb_=
entry.
So this might be a good time to revisit the issue.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
