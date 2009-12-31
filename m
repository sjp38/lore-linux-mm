Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 010BE60021B
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 21:41:32 -0500 (EST)
Received: by pxi2 with SMTP id 2so8749024pxi.11
        for <linux-mm@kvack.org>; Wed, 30 Dec 2009 18:41:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.0912301619500.3369@sister.anvils>
References: <ceeec51bdc2be64416e05ca16da52a126b598e17.1258773030.git.minchan.kim@gmail.com>
	 <ae2928fe7bb3d94a7ca18d3b3274fdfeb009803a.1258773030.git.minchan.kim@gmail.com>
	 <4B38876F.6010204@gmail.com>
	 <alpine.LSU.2.00.0912301619500.3369@sister.anvils>
Date: Thu, 31 Dec 2009 11:41:31 +0900
Message-ID: <28c262360912301841r3ed43d31yc677fbc3a01fe5bb@mail.gmail.com>
Subject: Re: [PATCH 2/3 -mmotm-2009-12-10-17-19] Count zero page as file_rss
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 31, 2009 at 1:49 AM, Hugh Dickins
<hugh.dickins@tiscali.co.uk> wrote:
> On Mon, 28 Dec 2009, Minchan Kim wrote:
>> I missed Hugh.
>
> Thank you: it is sweet of you to say so :)
>
>>
>> Minchan Kim wrote:
>> > Long time ago, we counted zero page as file_rss.
>> > But after reinstanted zero page, we don't do it.
>> > It means rss of process would be smaller than old.
>> >
>> > It could chage OOM victim selection.
>
> Eh? =C2=A0We don't use rss for OOM victim selection, we use total_vm.
>
> I know that's under discussion, and there are good arguments on
> both sides (I incline to the rss side, but see David's point about
> predictability); but here you seem to be making an argument for
> back-compatibility, yet there is no such issue in OOM victim selection.

Sorry, I totally confused that.

>
> And if we do decide that rss is appropriate for OOM victim selection,
> then we would prefer to keep the ZERO_PAGE out of rss, wouldn't we?

If we start to use RSS, it's good that keep zero page out of rss in OOM asp=
ect.
But I am not sure it's good in smap aspect.
Some smap user might want to know max memory usage in process.
Zero page has a possibility to change real rss.

>
>> >
>> > Kame reported following as
>> > "Before starting zero-page works, I checked "questions" in lkml and
>> > found some reports that some applications start to go OOM after zero-p=
age
>> > removal.
>> >
>> > For me, I know one of my customer's application depends on behavior of
>> > zero page (on RHEL5). So, I tried to add again it before RHEL6 because
>> > I think removal of zero-page corrupts compatibility."
>> >
>> > So how about adding zero page as file_rss again for compatibility?
>
> I think not.

At least,  we had accounted zero page as file_rss until remove zero page.
That was my concern.
I think we have to fix this for above compatibility regardless of OOM issue=
.

>
> KAMEZAWA-san can correct me (when he returns in the New Year) if I'm
> wrong, but I don't think his customer's OOMs had anything to do with
> whether the ZERO_PAGE was counted in file_rss or not: the OOMs came
> from the fact that many pages were being used up where just the one
> ZERO_PAGE had been good before. =C2=A0Wouldn't he have complained if the
> zero_pfn patches hadn't solved that problem?
>
> You are right that I completely overlooked the issue of whether to
> include the ZERO_PAGE in rss counts (now being a !vm_normal_page,
> it was just natural to leave it out); and I overlooked the fact that
> it used to be counted into file_rss in the old days (being !PageAnon).
>
> So I'm certainly at fault for that, and thank you for bringing the
> issue to attention; but once considered, I can't actually see a good
> reason why we should add code to count ZERO_PAGEs into file_rss now.
> And if this patch falls, then 1/3 and 3/3 would fall also.
>
> And the patch below would be incomplete anyway, wouldn't it?
> There would need to be a matching change to zap_pte_range(),
> but I don't see that.

Thanks.
If we think this patch is need, I will repost path with fix it.

What do you think?

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
