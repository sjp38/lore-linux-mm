Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 554686B0038
	for <linux-mm@kvack.org>; Sun, 26 Feb 2017 20:21:06 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id t184so154622362pgt.1
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 17:21:06 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id i6si13747866plk.296.2017.02.26.17.21.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Feb 2017 17:21:05 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: Is MADV_HWPOISON supposed to work only on faulted-in pages?
Date: Mon, 27 Feb 2017 01:20:30 +0000
Message-ID: <20170227012029.GA28934@hori1.linux.bs1.fc.nec.co.jp>
References: <6a445beb-119c-9a9a-0277-07866afe4924@redhat.com>
 <20170220050016.GA15533@hori1.linux.bs1.fc.nec.co.jp>
 <20170223032342.GA18740@hori1.linux.bs1.fc.nec.co.jp>
 <1ba376aa-5e7c-915f-35d1-2d4eef0cad88@huawei.com>
In-Reply-To: <1ba376aa-5e7c-915f-35d1-2d4eef0cad88@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <B8E09B5BFBBD2F43BD5369B1A5F4573B@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: Jan Stancek <jstancek@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "ltp@lists.linux.it" <ltp@lists.linux.it>

On Sat, Feb 25, 2017 at 10:28:15AM +0800, Yisheng Xie wrote:
> hi Naoya,
>=20
> On 2017/2/23 11:23, Naoya Horiguchi wrote:
> > On Mon, Feb 20, 2017 at 05:00:17AM +0000, Horiguchi Naoya(=1B$BKY8}=1B(=
B =1B$BD>Li=1B(B) wrote:
> >> On Tue, Feb 14, 2017 at 04:41:29PM +0100, Jan Stancek wrote:
> >>> Hi,
> >>>
> >>> code below (and LTP madvise07 [1]) doesn't produce SIGBUS,
> >>> unless I touch/prefault page before call to madvise().
> >>>
> >>> Is this expected behavior?
> >>
> >> Thank you for reporting.
> >>
> >> madvise(MADV_HWPOISON) triggers page fault when called on the address
> >> over which no page is faulted-in, so I think that SIGBUS should be
> >> called in such case.
> >>
> >> But it seems that memory error handler considers such a page as "reser=
ved
> >> kernel page" and recovery action fails (see below.)
> >>
> >>   [  383.371372] Injecting memory failure for page 0x1f10 at 0x7efcdc5=
69000
> >>   [  383.375678] Memory failure: 0x1f10: reserved kernel page still re=
ferenced by 1 users
> >>   [  383.377570] Memory failure: 0x1f10: recovery action for reserved =
kernel page: Failed
> >>
> >> I'm not sure how/when this behavior was introduced, so I try to unders=
tand.
> >=20
> > I found that this is a zero page, which is not recoverable for memory
> > error now.
> >=20
> >> IMO, the test code below looks valid to me, so no need to change.
> >=20
> > I think that what the testcase effectively does is to test whether memo=
ry
> > handling on zero pages works or not.
> > And the testcase's failure seems acceptable, because it's simply not-im=
plemented yet.
> > Maybe recovering from error on zero page is possible (because there's n=
o data
> > loss for memory error,) but I'm not sure that code might be simple enou=
gh and/or
> > it's worth doing ...
> I question about it,  if a memory error happened on zero page, it will
> cause all of data read from zero page is error, I mean no-zero, right?

Hi Yisheng,

Yes, the impact is serious (could affect many processes,) but it's possibil=
ity
is very low because there's only one page in a system that is used for zero=
 page.
There are many other pages which are not recoverable for memory error like
slab pages, so I'm not sure how I prioritize it (maybe it's not a
top-priority thing, nor low-hanging fruit.)

> And can we just use re-initial it with zero data maybe by memset ?

Maybe it's not enoguh. Under a real hwpoison, we should isolate the error
page to prevent the access on the broken data.
But zero page is statically defined as an array of global variable, so
it's not trival to replace it with a new zero page at runtime.

Anyway, it's in my todo list, so hopefully revisited in the future.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
