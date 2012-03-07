Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id DAE246B007E
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 13:21:10 -0500 (EST)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Wed, 7 Mar 2012 13:18:56 -0500
Subject: RE: [RFC][PATCH] avoid swapping out with swappiness==0
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB951A45F@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB9455FE2@USINDEVS02.corp.hds.com>
 <20120305215602.GA1693@redhat.com> <4F5798B1.5070005@jp.fujitsu.com>
In-Reply-To: <4F5798B1.5070005@jp.fujitsu.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "jweiner@redhat.com" <jweiner@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "riel@redhat.com" <riel@redhat.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "shaohua.li@intel.com" <shaohua.li@intel.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>

On 03/07/2012 12:19 PM, KOSAKI Motohiro wrote:
> On 3/5/2012 4:56 PM, Johannes Weiner wrote:
>> On Fri, Mar 02, 2012 at 12:36:40PM -0500, Satoru Moriya wrote:
>>>
>>> This patch changes the behavior with swappiness=3D=3D0. If we set=20
>>> swappiness=3D=3D0, the kernel does not swap out completely (for global=
=20
>>> reclaim until the amount of free pages and filebacked pages in a=20
>>> zone has been reduced to something very very small (nr_free +=20
>>> nr_filebacked < high watermark)).
>>>
>>> Any comments are welcome.
>>
>> Last time I tried that (getting rid of sc->may_swap, using=20
>> !swappiness), it was rejected it as there were users who relied on=20
>> swapping very slowly with this setting.
>>
>> KOSAKI-san, do I remember correctly?  Do you still think it's an=20
>> issue?
>>
>> Personally, I still think it's illogical that !swappiness allows=20
>> swapping and would love to see this patch go in.
>=20
> Thank you. I brought back to memory it. Unfortunately DB folks are=20
> still mainly using RHEL5 generation distros. At that time, swapiness=3D0=
=20
> doesn't mean disabling swap.
>=20
> They want, "don't swap as far as kernel has any file cache page". but=20
> linux don't have such feature. then they used swappiness for emulate=20
> it. So, I think this patch clearly make userland harm. Because of, we=20
> don't have an alternative way.

If they expect the behavior that "don't swap as far as kernel
has any file cache page", this patch definitely helps them
because if we set swappiness=3D=3D0, kernel does not swap out
*until* nr_free + nr_filebacked < high watermark in the zone.
It means kernel begins to swap out when nr_free + nr_filebacked
becomes less than high watermark.

But, yes, this patch actually changes the behavior with
swappiness=3D=3D0 and so it may make userland harm.=20

How about introducing new value e.g -1 to avoid swap and
maintain compatibility?

Regards,
Satoru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
