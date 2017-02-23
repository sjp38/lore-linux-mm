Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 42DAE6B0038
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 22:25:24 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id b2so31099221pgc.6
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 19:25:24 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id q21si2978423pgi.412.2017.02.22.19.25.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 19:25:23 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: Is MADV_HWPOISON supposed to work only on faulted-in pages?
Date: Thu, 23 Feb 2017 03:23:49 +0000
Message-ID: <20170223032342.GA18740@hori1.linux.bs1.fc.nec.co.jp>
References: <6a445beb-119c-9a9a-0277-07866afe4924@redhat.com>
 <20170220050016.GA15533@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20170220050016.GA15533@hori1.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <A628664CADC03043A6588BB4C56BA8CB@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "ltp@lists.linux.it" <ltp@lists.linux.it>

On Mon, Feb 20, 2017 at 05:00:17AM +0000, Horiguchi Naoya(=1B$BKY8}=1B(B =
=1B$BD>Li=1B(B) wrote:
> On Tue, Feb 14, 2017 at 04:41:29PM +0100, Jan Stancek wrote:
> > Hi,
> >
> > code below (and LTP madvise07 [1]) doesn't produce SIGBUS,
> > unless I touch/prefault page before call to madvise().
> >
> > Is this expected behavior?
>=20
> Thank you for reporting.
>=20
> madvise(MADV_HWPOISON) triggers page fault when called on the address
> over which no page is faulted-in, so I think that SIGBUS should be
> called in such case.
>=20
> But it seems that memory error handler considers such a page as "reserved
> kernel page" and recovery action fails (see below.)
>=20
>   [  383.371372] Injecting memory failure for page 0x1f10 at 0x7efcdc5690=
00
>   [  383.375678] Memory failure: 0x1f10: reserved kernel page still refer=
enced by 1 users
>   [  383.377570] Memory failure: 0x1f10: recovery action for reserved ker=
nel page: Failed
>=20
> I'm not sure how/when this behavior was introduced, so I try to understan=
d.

I found that this is a zero page, which is not recoverable for memory
error now.

> IMO, the test code below looks valid to me, so no need to change.

I think that what the testcase effectively does is to test whether memory
handling on zero pages works or not.
And the testcase's failure seems acceptable, because it's simply not-implem=
ented yet.
Maybe recovering from error on zero page is possible (because there's no da=
ta
loss for memory error,) but I'm not sure that code might be simple enough a=
nd/or
it's worth doing ...

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
