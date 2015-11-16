Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4ED506B0253
	for <linux-mm@kvack.org>; Sun, 15 Nov 2015 22:15:03 -0500 (EST)
Received: by pacej9 with SMTP id ej9so53086537pac.2
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 19:15:03 -0800 (PST)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id ps9si47027677pac.87.2015.11.15.19.15.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Nov 2015 19:15:02 -0800 (PST)
Received: by pacfl14 with SMTP id fl14so22351266pac.1
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 19:15:02 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [PATCH v3 01/17] mm: support madvise(MADV_FREE)
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <20151116021320.GB7973@bbox>
Date: Mon, 16 Nov 2015 11:14:52 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <4D94809E-5E33-49EB-83B4-4CE3812B3CF5@gmail.com>
References: <1447302793-5376-2-git-send-email-minchan@kernel.org> <CALCETrWA6aZC_3LPM3niN+2HFjGEm_65m9hiEdpBtEZMn0JhwQ@mail.gmail.com> <564421DA.9060809@gmail.com> <20151113061511.GB5235@bbox> <56458056.8020105@gmail.com> <20151113063802.GF5235@bbox> <56458720.4010400@gmail.com> <20151113070356.GG5235@bbox> <56459B9A.7080501@gmail.com> <CALCETrVx0JFchtJrrKVqEYvTwWvC+DwSLxzhD_A7EdNu2PiG7w@mail.gmail.com> <20151116021320.GB7973@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Daniel Micay <danielmicay@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>


> On Nov 16, 2015, at 10:13, Minchan Kim <minchan@kernel.org> wrote:
>=20
> On Fri, Nov 13, 2015 at 11:46:07AM -0800, Andy Lutomirski wrote:
>> On Fri, Nov 13, 2015 at 12:13 AM, Daniel Micay =
<danielmicay@gmail.com> wrote:
>>> On 13/11/15 02:03 AM, Minchan Kim wrote:
>>>> On Fri, Nov 13, 2015 at 01:45:52AM -0500, Daniel Micay wrote:
>>>>>> And now I am thinking if we use access bit, we could implment =
MADV_FREE_UNDO
>>>>>> easily when we need it. Maybe, that's what you want. Right?
>>>>>=20
>>>>> Yes, but why the access bit instead of the dirty bit for that? It =
could
>>>>> always be made more strict (i.e. access bit) in the future, while =
going
>>>>> the other way won't be possible. So I think the dirty bit is =
really the
>>>>> more conservative choice since if it turns out to be a mistake it =
can be
>>>>> fixed without a backwards incompatible change.
>>>>=20
>>>> Absolutely true. That's why I insist on dirty bit until now =
although
>>>> I didn't tell the reason. But I thought you wanted to change for =
using
>>>> access bit for the future, too. It seems MADV_FREE start to bloat
>>>> over and over again before knowing real problems and usecases.
>>>> It's almost same situation with volatile ranges so I really want to
>>>> stop at proper point which maintainer should decide, I hope.
>>>> Without it, we will make the feature a lot heavy by just brain =
storming
>>>> and then causes lots of churn in MM code without real bebenfit
>>>> It would be very painful for us.
>>>=20
>>> Well, I don't think you need more than a good API and an =
implementation
>>> with no known bugs, kernel security concerns or backwards =
compatibility
>>> issues. Configuration and API extensions are something for later =
(i.e.
>>> land a baseline, then submit stuff like sysctl tunables). Just my =
take
>>> on it though...
>>>=20
>>=20
>> As long as it's anonymous MAP_PRIVATE only, then the security aspects
>> should be okay.  MADV_DONTNEED seems to work on pretty much any VMA,
>> and there's been long history of interesting bugs there.
>>=20
>> As for dirty vs accessed, an argument in favor of going straight to
>> accessed is that it means that users can write code like this without
>> worrying about whether they have a kernel that uses the dirty bit:
>>=20
>> x =3D mmap(...);
>> *x =3D 1;  /* mark it present */
>>=20
>> /* i'm done with it */
>> *x =3D 1;
>> madvise(MADV_FREE, x, ...);
>>=20
>> wait a while;
>>=20
>> /* is it still there? */
>> if (*x =3D=3D 1) {
>>  /* use whatever was cached there */
>> } else {
>> /* reinitialize it */
>> *x =3D 1;
>> }
>>=20
>> With the dirty bit, this will look like it works, but on occasion
>> users will lose the race where they probe *x to see if the data was
>> lost and then the data gets lost before the next write comes in.
>>=20
>> Sure, that load from *x could be changed to RMW or users could do a
>> dummy write (e.g. x[1] =3D 1; if (*x =3D=3D 1) ...), but people might =
forget
>> to do that, and the caching implications are a little bit worse.
>=20
> I think your example is the case what people abuse MADV_FREE.
> What happens if the object(ie, x) spans multiple pages?
> User should know object's memory align and investigate all of pages
> which span the object. Hmm, I don't think it's good for API.
>=20
>>=20
>> Note that switching to RMW is really really dangerous.  Doing:
>>=20
>> *x &=3D 1;
>> if (*x =3D=3D 1) ...;
>>=20
>> is safe on x86 if the compiler generates:
>>=20
>> andl $1, (%[x]);
>> cmpl $1, (%[x]);
>>=20
>> but is unsafe if the compiler generates:
>>=20
>> movl (%[x]), %eax;
>> andl $1, %eax;
>> movl %eax, (%[x]);
>> cmpl $1, %eax;
>>=20
>> and even worse if the write is omitted when "provably" unnecessary.
>>=20
>> OTOH, if switching to the accessed bit is too much of a mess, then
>> using the dirty bit at first isn't so bad.
>=20
> Thanks! I want to use dirty bit first.
>=20
> About access bit, I don't want to say it to mess but I guess it would
> change a lot subtle thing for all architectures. Because we have used
> access bit as just *hint* for aging while dirty bit is really
> *critical marker* for system integrity. A example in x86, we don't
> keep accuracy of access bit for reducing TLB flush IPI. I don't know
> what technique other arches have used but they might have.
>=20
> Thanks.
>=20
i think use access bit is not easy to implement for ANON page in kernel.
we are sure the Anon page is always PageDirty()  if it is =
!PageSwapCache() ,
unless it is MADV_FREE page ,
but use access bit , how to distinguish Normal ANON page and  MADV_FREE =
page?
it can be implemented by Access bit , but not easy, need more code =
change .

Thanks



=20




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
