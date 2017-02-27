Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C73426B038B
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 01:44:12 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id v63so164123154pgv.0
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 22:44:12 -0800 (PST)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id j1si14340431pld.330.2017.02.26.22.44.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Feb 2017 22:44:11 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: Is MADV_HWPOISON supposed to work only on faulted-in pages?
Date: Mon, 27 Feb 2017 06:33:09 +0000
Message-ID: <20170227063308.GA14387@hori1.linux.bs1.fc.nec.co.jp>
References: <6a445beb-119c-9a9a-0277-07866afe4924@redhat.com>
 <20170220050016.GA15533@hori1.linux.bs1.fc.nec.co.jp>
 <20170223032342.GA18740@hori1.linux.bs1.fc.nec.co.jp>
 <1ba376aa-5e7c-915f-35d1-2d4eef0cad88@huawei.com>
 <20170227012029.GA28934@hori1.linux.bs1.fc.nec.co.jp>
 <22763879-C335-41E6-8102-2022EED75DAE@cs.rutgers.edu>
In-Reply-To: <22763879-C335-41E6-8102-2022EED75DAE@cs.rutgers.edu>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <FE54BBF1088CA045825E0244CF1C29A9@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, Jan Stancek <jstancek@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "ltp@lists.linux.it" <ltp@lists.linux.it>

On Sun, Feb 26, 2017 at 10:27:02PM -0600, Zi Yan wrote:
> On 26 Feb 2017, at 19:20, Naoya Horiguchi wrote:
>=20
> > On Sat, Feb 25, 2017 at 10:28:15AM +0800, Yisheng Xie wrote:
> >> hi Naoya,
> >>
> >> On 2017/2/23 11:23, Naoya Horiguchi wrote:
> >>> On Mon, Feb 20, 2017 at 05:00:17AM +0000, Horiguchi Naoya(=1B$BKY8}=
=1B(B =1B$BD>Li=1B(B) wrote:
> >>>> On Tue, Feb 14, 2017 at 04:41:29PM +0100, Jan Stancek wrote:
> >>>>> Hi,
> >>>>>
> >>>>> code below (and LTP madvise07 [1]) doesn't produce SIGBUS,
> >>>>> unless I touch/prefault page before call to madvise().
> >>>>>
> >>>>> Is this expected behavior?
> >>>>
> >>>> Thank you for reporting.
> >>>>
> >>>> madvise(MADV_HWPOISON) triggers page fault when called on the addres=
s
> >>>> over which no page is faulted-in, so I think that SIGBUS should be
> >>>> called in such case.
> >>>>
> >>>> But it seems that memory error handler considers such a page as "res=
erved
> >>>> kernel page" and recovery action fails (see below.)
> >>>>
> >>>>   [  383.371372] Injecting memory failure for page 0x1f10 at 0x7efcd=
c569000
> >>>>   [  383.375678] Memory failure: 0x1f10: reserved kernel page still =
referenced by 1 users
> >>>>   [  383.377570] Memory failure: 0x1f10: recovery action for reserve=
d kernel page: Failed
> >>>>
> >>>> I'm not sure how/when this behavior was introduced, so I try to unde=
rstand.
> >>>
> >>> I found that this is a zero page, which is not recoverable for memory
> >>> error now.
> >>>
> >>>> IMO, the test code below looks valid to me, so no need to change.
> >>>
> >>> I think that what the testcase effectively does is to test whether me=
mory
> >>> handling on zero pages works or not.
> >>> And the testcase's failure seems acceptable, because it's simply not-=
implemented yet.
> >>> Maybe recovering from error on zero page is possible (because there's=
 no data
> >>> loss for memory error,) but I'm not sure that code might be simple en=
ough and/or
> >>> it's worth doing ...
> >> I question about it,  if a memory error happened on zero page, it will
> >> cause all of data read from zero page is error, I mean no-zero, right?
> >
> > Hi Yisheng,
> >
> > Yes, the impact is serious (could affect many processes,) but it's poss=
ibility
> > is very low because there's only one page in a system that is used for =
zero page.
> > There are many other pages which are not recoverable for memory error l=
ike
> > slab pages, so I'm not sure how I prioritize it (maybe it's not a
> > top-priority thing, nor low-hanging fruit.)
> >
> >> And can we just use re-initial it with zero data maybe by memset ?
> >
> > Maybe it's not enoguh. Under a real hwpoison, we should isolate the err=
or
> > page to prevent the access on the broken data.
> > But zero page is statically defined as an array of global variable, so
> > it's not trival to replace it with a new zero page at runtime.
> >
> > Anyway, it's in my todo list, so hopefully revisited in the future.
> >
>=20
> Hi Naoya,
>=20
> The test case tries to HWPOISON a range of virtual addresses that do not
> map to any physical pages.
>=20

Hi Yan,

> I expected either madvise should fail because HWPOISON does not work on
> non-existing physical pages or madvise_hwpoison() should populate
> some physical pages for that virtual address range and poison them.

The latter is the current behavior. It just comes from get_user_pages_fast(=
)
which not only finds the page and takes refcount, but also touch the page.

madvise(MADV_HWPOISON) is a test feature, and calling it for address backed
by no page doesn't simulate anything real. IOW, the behavior is undefined.
So I don't have a strong opinion about how it should behave.

>=20
> As I tested it on kernel v4.10, the test application exited at
> madvise, because madvise returns -1 and error message is
> "Device or resource busy". I think this is a proper behavior.

yes, maybe we see the same thing, you can see in dmesg "recovery action
for reserved kernel page: Failed" message.

>=20
> There might be some confusion in madvise's man page on MADV_HWPOISON.
> If you add some text saying madvise fails if any page is not mapped in
> the given address range, that can eliminate the confusion*

Writing it down to man page makes readers think this behavior is a part of
specification, that might not be good now because the failure in error
handling of zero page is not the eventually fixed behavior.
I mean that if zero page handles hwpoison properly in the future, madvise
will succeed without any confusion.
So I feel that we don't have to update man page for this issue.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
