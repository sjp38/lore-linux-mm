Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A49186B01AD
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 00:39:01 -0400 (EDT)
Received: by bwz9 with SMTP id 9so168022bwz.14
        for <linux-mm@kvack.org>; Sat, 26 Jun 2010 21:38:59 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <20100626233029.GA8820@localhost>
References: <20100619132055.GK18946@basil.fritz.box> <AANLkTin-lj5ZgtcvJhWcNiMuWSCQ39N8mqe_2fm8DDVR@mail.gmail.com>
	<20100619133000.GL18946@basil.fritz.box> <AANLkTiloIXtCwBeBvP32hLBBvxCWrZMMwWTZwSj475wi@mail.gmail.com>
	<20100619140933.GM18946@basil.fritz.box> <AANLkTilF6m5YKMiDGaTNuoW6LxiA44oss3HyvkavwrOK@mail.gmail.com>
	<20100619195242.GS18946@basil.fritz.box> <AANLkTikMZu0GXwzs6IeMyoTuhETrnjZ1m5lI9FTauYBA@mail.gmail.com>
	<20100620071446.GA21743@localhost> <AANLkTimv1S4BuyGFyuBld0Wn6ncz7JUnMiPis-HlN3Tb@mail.gmail.com>
	<20100626233029.GA8820@localhost>
From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Sun, 27 Jun 2010 06:38:39 +0200
Message-ID: <AANLkTimN_QBDJU1m_LuhoPREI_SRBSSLC7_-Rc9oa-T5@mail.gmail.com>
Subject: Re: [PATCH] [31/31] HWPOISON: Add a madvise() injector for soft page
	offlining
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jun 27, 2010 at 1:30 AM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> On Sat, Jun 26, 2010 at 09:18:52PM +0800, Michael Kerrisk wrote:
>> Hi Fengguang,
>>
>> On Sun, Jun 20, 2010 at 9:14 AM, Wu Fengguang <fengguang.wu@intel.com> w=
rote:
>> > On Sun, Jun 20, 2010 at 02:19:35PM +0800, Michael Kerrisk wrote:
>> >> Hi Andi,
>> >> On Sat, Jun 19, 2010 at 9:52 PM, Andi Kleen <andi@firstfloor.org> wro=
te:
>> >> >> .TP
>> >> >> .BR MADV_SOFT_OFFLINE " (Since Linux 2.6.33)
>> >> >> Soft offline the pages in the range specified by
>> >> >> .I addr
>> >> >> and
>> >> >> .IR length .
>> >> >> This memory of each page in the specified range is copied to a new=
 page,
>> >> >
>> >> > Actually there are some cases where it's also dropped if it's cache=
d page.
>> >> >
>> >> > Perhaps better would be something more fuzzy like
>> >> >
>> >> > "the contents are preserved"
>> >>
>> >> The problem to me is that this gets so fuzzy that it's hard to
>> >> understand the meaning (I imagine many readers will ask: "What does i=
t
>> >> mean that the contents are preserved"?). Would you be able to come up
>> >> with a wording that is a little miore detailed?
>> >
>> > That is, MADV_SOFT_OFFLINE won't lose data.
>> >
>> > If a process writes "1" to some virtual address and then called
>> > madvice(MADV_SOFT_OFFLINE) on that virtual address, it can continue
>> > to read "1" from that virtual address.
>> >
>> > MADV_SOFT_OFFLINE "transparently" replaces the underlying physical pag=
e
>> > frame with a new one that contains the same data "1". The original pag=
e
>> > frame is offlined, and the new page frame may be installed lazily.
>>
>> Thanks. That helps me come up with a description that is I think a bit c=
learer:
>>
>> =A0 =A0 =A0 =A0MADV_SOFT_OFFLINE (Since Linux 2.6.33)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 Soft offline the pages in the range specifie=
d by
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 addr and length. =A0The memory of each page =
in the
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 specified =A0range =A0is =A0preserved (i.e.,=
 when next
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 accessed, the same content will be visible, =
=A0but
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 in =A0a new physical page frame), and the or=
iginal
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 page is offlined =A0(i.e., =A0no =A0longer =
=A0used, =A0and
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 taken =A0out =A0of =A0normal =A0memory manag=
ement). =A0The
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 effect of =A0the =A0MADV_SOFT_OFFLINE =A0ope=
ration =A0is
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 invisible =A0to =A0(i.e., does not change th=
e seman-
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 tics of) the calling process. ...
>>
>> The actual patch for man-pages-3.26 is below.
>
> Thanks. The change looks good to me.

Thanks for checking it.

> Note that the other perceivable change may be a little access delay.
> The kernel could choose to simply drop the in-memory data when there
> is another copy in disk. When accessed again, the content for the new
> physical page will be populated from disk IO.

Yes, I'd suposed as much, but decided that was a detail that probably
didm\t need to be mentioned in tha man page.

Thanks,

Michael


>>
>> --- a/man2/madvise.2
>> +++ b/man2/madvise.2
>> @@ -163,12 +163,14 @@ Soft offline the pages in the range specified by
>> =A0.I addr
>> =A0and
>> =A0.IR length .
>> -The memory of each page in the specified range is copied to a new page,
>> +The memory of each page in the specified range is preserved
>> +(i.e., when next accessed, the same content will be visible,
>> +but in a new physical page frame),
>> =A0and the original page is offlined
>> =A0(i.e., no longer used, and taken out of normal memory management).
>> =A0The effect of the
>> =A0.B MADV_SOFT_OFFLINE
>> -operation is normally invisible to (i.e., does not change the semantics=
 of)
>> +operation is invisible to (i.e., does not change the semantics of)
>> =A0the calling process.
>> =A0This feature is intended for testing of memory error-handling code;
>> =A0it is only available if the kernel was configured with
>



--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface" http://blog.man7.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
