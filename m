Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 72CCF6B00F8
	for <linux-mm@kvack.org>; Tue,  8 May 2012 03:36:32 -0400 (EDT)
Received: by yenm8 with SMTP id m8so7163479yen.14
        for <linux-mm@kvack.org>; Tue, 08 May 2012 00:36:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com>
References: <20120501132409.GA22894@lizard>
	<20120501132620.GC24226@lizard>
	<4FA35A85.4070804@kernel.org>
	<20120504073810.GA25175@lizard>
	<CAOJsxLH_7mMMe+2DvUxBW1i5nbUfkbfRE3iEhLQV9F_MM7=eiw@mail.gmail.com>
	<CAHGf_=qcGfuG1g15SdE0SDxiuhCyVN025pQB+sQNuNba4Q4jcA@mail.gmail.com>
	<20120507121527.GA19526@lizard>
	<4FA82056.2070706@gmail.com>
	<CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com>
	<CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com>
	<CAOJsxLFAavdDbiLnYRwe+QiuEHSD62+Sz6LJTk+c3J9gnLVQ_w@mail.gmail.com>
	<CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com>
Date: Tue, 8 May 2012 10:36:31 +0300
Message-ID: <CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com>
Subject: Re: [PATCH 3/3] vmevent: Implement special low-memory attribute
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Minchan Kim <minchan@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Tue, May 8, 2012 at 10:11 AM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
> Ok, sane. Then I take my time a little and review current vmevent code br=
iefly.
> (I read vmevent/core branch in pekka's tree. please let me know if
> there is newer repositry)

It's the latest one.

On Tue, May 8, 2012 at 10:11 AM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
> 1) sample_period is brain damaged idea. If people ONLY need to
> sampling stastics, they
> =A0only need to read /proc/vmstat periodically. just remove it and
> implement push notification.
> =A0_IF_ someone need unfrequent level trigger, just use
> "usleep(timeout); read(vmevent_fd)"
> =A0on userland code.

That comes from a real-world requirement. See Leonid's email on the topic:

https://lkml.org/lkml/2012/5/2/42

> 2) VMEVENT_ATTR_STATE_ONE_SHOT is misleading name. That is effect as
> edge trigger shot. not only once.

Would VMEVENT_ATTR_STATE_EDGE_TRIGGER be a better name?

> 3) vmevent_fd() seems sane interface. but it has name space unaware.
> maybe we discuss how to harmonize name space feature. =A0No hurry. but we=
 have
> to think that issue since at beginning.

You mean VFS namespaces? Yeah, we need to take care of that.

> 4) Currently, vmstat have per-cpu batch and vmstat updating makes 3
> second delay at maximum.
> =A0This is fine for usual case because almost userland watcher only
> read /proc/vmstat per second.
> =A0But, for vmevent_fd() case, 3 seconds may be unacceptable delay. At
> worst, 128 batch x 4096
> =A0x 4k pagesize =3D 2G bytes inaccurate is there.

That's pretty awful. Anton, Leonid, comments?

> 5) __VMEVENT_ATTR_STATE_VALUE_WAS_LT should be removed from userland
> exporting files.
> =A0When exporing kenrel internal, always silly gus used them and made unh=
appy.

Agreed. Anton, care to cook up a patch to do that?

> 6) Also vmevent_event must hide from userland.

Why? That's part of the ABI.

> 7) vmevent_config::size must be removed. In 20th century, M$ API
> prefer to use this technique. But
> =A0They dropped the way because a lot of application don't initialize
> size member and they can't use it for keeping upper compitibility.

It's there to support forward/backward ABI compatibility like perf
does. I'm going to keep it for now but I'm open to dropping it when
the ABI is more mature.

> 8) memcg unaware
> 9) numa unaware
> 10) zone unaware

Yup.

> And, we may need vm internal change if we really need lowmem
> notification. current kernel don't have such info. _And_ there is one mor=
e
> big problem. Currently the kernel maintain memory per
> zone. But almost all userland application aren't aware zone nor node.
> Thus raw notification aren't useful for userland. In the other hands, tot=
al
> memory and total free memory is useful? Definitely No!
> Even though total free memory are lots, system may start swap out and
> oom invokation. If we can't oom invocation, this feature has serious rais=
on
> d'etre issue. (i.e. (4), (8), (9) and (19) are not ignorable issue. I thi=
nk)

I'm guessing most of the existing solutions get away with
approximations and soft limits because they're mostly used on UMA
embedded machines.

But yes, we need to do better here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
