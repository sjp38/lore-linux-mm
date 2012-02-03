Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id A4E6B6B13F1
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 09:11:08 -0500 (EST)
Received: by wgbdt12 with SMTP id dt12so3267195wgb.26
        for <linux-mm@kvack.org>; Fri, 03 Feb 2012 06:11:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CADDb1s1sc=69=QsmC+KAqHP=G93JQ95nVdyUPRNRJaVYbwu=HA@mail.gmail.com>
References: <1328275626-5322-1-git-send-email-amit.sahrawat83@gmail.com>
	<1328275948.2662.15.camel@laptop>
	<CADDb1s1sc=69=QsmC+KAqHP=G93JQ95nVdyUPRNRJaVYbwu=HA@mail.gmail.com>
Date: Fri, 3 Feb 2012 19:41:07 +0530
Message-ID: <CADDb1s0jj6gwJpinLcsAE14mhBqLSxQYdf8a0KfJXr8yBnORUw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: make do_writepages() use plugging
From: Amit Sahrawat <amit.sahrawat83@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, Amit Sahrawat <a.sahrawat@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Is there a case for introducing blk_plug in write_one_page() can't
seem to find that support in the code flow
write_one_page()->mpage_writepage()

Regards,
Amit Sahrawat


On Fri, Feb 3, 2012 at 7:31 PM, Amit Sahrawat <amit.sahrawat83@gmail.com> w=
rote:
> Hi Peter,
> Thanks for pointing out.
>
> While checking the plug support in Write code flow, I came across this
> main point from which - we invoke
> writepages(mapping->a_ops->writepages(mapping, wbc)) from almost all
> the the filesystems.
>
> By mistake I checked 2 different kernel versions for this code(and
> missed that the current version already has put plug in
> mpage_writepages) ... so may be this patch is not worth considering.
>
> Regards,
> Amit Sahrawat
>
>
> On Fri, Feb 3, 2012 at 7:02 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> w=
rote:
>> On Fri, 2012-02-03 at 18:57 +0530, Amit Sahrawat wrote:
>>> This will cover all the invocations for writepages to be called with
>>> plugging support.
>>
>> This changelog fails to explain why this is a good thing... I thought
>> the idea of the new plugging stuff was that we now don't need to
>> sprinkle plugs all over the kernel..
>>
>>> Signed-off-by: Amit Sahrawat <a.sahrawat@samsung.com>
>>> ---
>>> =A0mm/page-writeback.c | =A0 =A04 ++++
>>> =A01 files changed, 4 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>>> index 363ba70..2bea32c 100644
>>> --- a/mm/page-writeback.c
>>> +++ b/mm/page-writeback.c
>>> @@ -1866,14 +1866,18 @@ EXPORT_SYMBOL(generic_writepages);
>>>
>>> =A0int do_writepages(struct address_space *mapping, struct writeback_co=
ntrol *wbc)
>>> =A0{
>>> + =A0 =A0 struct blk_plug plug;
>>> =A0 =A0 =A0 int ret;
>>>
>>> =A0 =A0 =A0 if (wbc->nr_to_write <=3D 0)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>>> +
>>> + =A0 =A0 blk_start_plug(&plug);
>>> =A0 =A0 =A0 if (mapping->a_ops->writepages)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mapping->a_ops->writepages(mapping,=
 wbc);
>>> =A0 =A0 =A0 else
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D generic_writepages(mapping, wbc);
>>> + =A0 =A0 blk_finish_plug(&plug);
>>> =A0 =A0 =A0 return ret;
>>> =A0}
>>>
>>
>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
