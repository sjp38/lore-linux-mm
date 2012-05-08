Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 6F8066B0100
	for <linux-mm@kvack.org>; Tue,  8 May 2012 04:03:06 -0400 (EDT)
Received: by yhr47 with SMTP id 47so7231684yhr.14
        for <linux-mm@kvack.org>; Tue, 08 May 2012 01:03:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FA8D046.7000808@gmail.com>
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
	<CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com>
	<4FA8D046.7000808@gmail.com>
Date: Tue, 8 May 2012 11:03:05 +0300
Message-ID: <CAOJsxLGWtJy7q6ij_-tN8nVTr-OXpgdWVkXsOda8S9mJzo7n2w@mail.gmail.com>
Subject: Re: [PATCH 3/3] vmevent: Implement special low-memory attribute
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Minchan Kim <minchan@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Tue, May 8, 2012 at 10:50 AM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
>>> 1) sample_period is brain damaged idea. If people ONLY need to
>>> sampling stastics, they
>>> =A0only need to read /proc/vmstat periodically. just remove it and
>>> implement push notification.
>>> =A0_IF_ someone need unfrequent level trigger, just use
>>> "usleep(timeout); read(vmevent_fd)"
>>> =A0on userland code.
>>
>> That comes from a real-world requirement. See Leonid's email on the topi=
c:
>>
>> https://lkml.org/lkml/2012/5/2/42
>
> I know, many embedded guys prefer such timer interval. I also have an
> experience
> similar logic when I was TV box developer. but I must disagree. Someone h=
ope
> timer housekeeping complexity into kernel. but I haven't seen any
> justification.

Leonid?

>>> 6) Also vmevent_event must hide from userland.
>>
>> Why? That's part of the ABI.
>
> Ahhh, if so, I missed something. as far as I look, vmevent_fd() only depe=
nd
> on vmevent_config. which syscall depend on vmevent_evennt?

read(2). See tools/testing/vmevent/vmevent-test.c for an example how
the ABI is used.

>>> 7) vmevent_config::size must be removed. In 20th century, M$ API
>>> prefer to use this technique. But
>>> =A0They dropped the way because a lot of application don't initialize
>>> size member and they can't use it for keeping upper compitibility.
>>
>> It's there to support forward/backward ABI compatibility like perf
>> does. I'm going to keep it for now but I'm open to dropping it when
>> the ABI is more mature.
>
> perf api is not intended to use from generic applications. then, I don't
> think it will make abi issue. tool/perf is sane, isn't it? but vmevent_fd=
()
> is generic api and we can't trust all userland guy have sane, unfortunate=
ly.

The perf ABI is being used by other projects as well. We don't
_depend_ on ->size being sane as much as use it to detect new features
in the future.

But anyway, we can consider dropping once the ABI is more stable.

> Hm. If you want vmevent makes depend on CONFIG_EMBEDDED, I have no reason=
 to
> complain this feature. At that world, almost all applications _know_ thei=
r
> system configuration. then I don't think api misuse issue is big matter.

No, I don't want to do that. I was just commeting on why existing
solutions are the way they are.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
