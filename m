Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 32A1B6B003D
	for <linux-mm@kvack.org>; Sun, 13 Dec 2009 23:20:00 -0500 (EST)
Received: by pzk27 with SMTP id 27so1973929pzk.12
        for <linux-mm@kvack.org>; Sun, 13 Dec 2009 20:19:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B25BA6E.5010002@redhat.com>
References: <20091211164651.036f5340@annuminas.surriel.com>
	 <28c262360912131614h62d8e0f7qf6ea9ab882f446d4@mail.gmail.com>
	 <4B25BA6E.5010002@redhat.com>
Date: Mon, 14 Dec 2009 13:19:58 +0900
Message-ID: <28c262360912132019u7c0b8efpf89b11a6cbe512b3@mail.gmail.com>
Subject: Re: [PATCH v2] vmscan: limit concurrent reclaimers in shrink_zone
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: lwoodman@redhat.com, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 14, 2009 at 1:09 PM, Rik van Riel <riel@redhat.com> wrote:
> On 12/13/2009 07:14 PM, Minchan Kim wrote:
>
>> On Sat, Dec 12, 2009 at 6:46 AM, Rik van Riel<riel@redhat.com> =C2=A0wro=
te:
>
>>> If too many processes are active doing page reclaim in one zone,
>>> simply go to sleep in shrink_zone().
>
>> I am worried about one.
>>
>> Now, we can put too many processes reclaim_wait with NR_UNINTERRUBTIBLE
>> state.
>> If OOM happens, OOM will kill many innocent processes since
>> uninterruptible task
>> can't handle kill signal until the processes free from reclaim_wait list=
.
>>
>> I think reclaim_wait list staying time might be long if VM pressure is
>> heavy.
>> Is this a exaggeration?
>>
>> If it is serious problem, how about this?
>>
>> We add new PF_RECLAIM_BLOCK flag and don't pick the process
>> in select_bad_process.
>
> A simpler solution may be to use sleep_on_interruptible, and
> simply have the process continue into shrink_zone() if it
> gets a signal.

I thought it but I was not sure.
Okay. If it is possible, It' more simple.
Could you repost patch with that?


Sorry but I have one requesting.


=3D=3D=3D

        +The default value is 8.
        +
        +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D


    I like this. but why do you select default value as constant 8?
    Do you have any reason?

    I think it would be better to select the number proportional to NR_CPU.
    ex) NR_CPU * 2 or something.

    Otherwise looks good to me.


Pessimistically, I assume that the pageout code spends maybe
10% of its time on locking (we have seen far, far worse than
this with thousands of processes in the pageout code).  That
means if we have more than 10 threads in the pageout code,
we could end up spending more time on locking and less doing
real work - slowing everybody down.

I rounded it down to the closest power of 2 to come up with
an arbitrary number that looked safe :)
=3D=3D=3D

We discussed above.
I want to add your desciption into changelog.
That's because after long time, We don't know why we select '8' as
default value.
Your desciption in changelog will explain it to follow-up people. :)

Sorry for bothering you.


> --
> All rights reversed.
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
