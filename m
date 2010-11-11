Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2C7CD6B0085
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 02:17:14 -0500 (EST)
Received: by qyk1 with SMTP id 1so975691qyk.14
        for <linux-mm@kvack.org>; Wed, 10 Nov 2010 23:17:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101111034546.GA20299@localhost>
References: <1289444754-29469-1-git-send-email-lliubbo@gmail.com>
	<20101111032644.GB18483@localhost>
	<AANLkTikCf_bLrLuhxpPmEyheTMgBK-h=B66n1pjJA_WL@mail.gmail.com>
	<20101111034546.GA20299@localhost>
Date: Thu, 11 Nov 2010 15:17:12 +0800
Message-ID: <AANLkTi=e5_SWequhy4RyVy1T+U9D_9WacOogV6JWomXz@mail.gmail.com>
Subject: Re: [PATCH v2] fix __set_page_dirty_no_writeback() return value
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kenchen@google.com" <kenchen@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 11, 2010 at 11:45 AM, Wu Fengguang <fengguang.wu@intel.com> wro=
te:
> On Thu, Nov 11, 2010 at 11:36:48AM +0800, Bob Liu wrote:
>> On Thu, Nov 11, 2010 at 11:26 AM, Wu Fengguang <fengguang.wu@intel.com> =
wrote:
>> > On Thu, Nov 11, 2010 at 11:05:54AM +0800, Bob Liu wrote:
>> >> __set_page_dirty_no_writeback() should return true if it actually tra=
nsitioned
>> >> the page from a clean to dirty state although it seems nobody used it=
s return
>> >> value now.
>> >>
>> >> Change from v1:
>> >> =C2=A0 =C2=A0 =C2=A0 * preserving cacheline optimisation as Andrew po=
inted out
>> >>
>> >> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>> >> ---
>> >> =C2=A0mm/page-writeback.c | =C2=A0 =C2=A04 +++-
>> >> =C2=A01 files changed, 3 insertions(+), 1 deletions(-)
>> >>
>> >> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> >> index bf85062..ac7018a 100644
>> >> --- a/mm/page-writeback.c
>> >> +++ b/mm/page-writeback.c
>> >> @@ -1157,8 +1157,10 @@ EXPORT_SYMBOL(write_one_page);
>> >> =C2=A0 */
>> >> =C2=A0int __set_page_dirty_no_writeback(struct page *page)
>> >> =C2=A0{
>> >> - =C2=A0 =C2=A0 if (!PageDirty(page))
>> >> + =C2=A0 =C2=A0 if (!PageDirty(page)) {
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 SetPageDirty(page);
>> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1;
>> >> + =C2=A0 =C2=A0 }
>> >> =C2=A0 =C2=A0 =C2=A0 return 0;
>> >> =C2=A0}
>> >
>> > It's still racy if not using TestSetPageDirty(). In fact
>> > set_page_dirty() has a default reference implementation:
>>
>> Yes, Andrew had also pointed out that. And I have send v3 fix this.
>> Could you ack it?
>
> Acked-by: Wu Fengguang <fengguang.wu@intel.com>
>

Thanks.

> Thanks!
>
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!PageDirty(page)) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!TestSetPag=
eDirty(page))
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0return 1;
>>
>> return !TestSetPageDirty(page) is more simply?
>
> Yeah that's fine.
>
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>> >
>> > It seems the return value currently is only tested for doing
>> > balance_dirty_pages_ratelimited(). So not a big problem.
>> >
>>
>> yeah, all those are small changes no matter with any problem:-).
>
> It's always good to make it correct :) I looked at the users mainly to
> answer the question: is it a must fix for 2.6.37 or even 2.6.36.x?
>

I have no idea, I think either is okay since it's not related with any bug.

--=20
Thanks,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
