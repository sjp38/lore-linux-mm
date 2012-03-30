Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id A3FD46B0044
	for <linux-mm@kvack.org>; Fri, 30 Mar 2012 18:44:38 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Fri, 30 Mar 2012 18:44:27 -0400
Subject: RE: [RFC][PATCH] avoid swapping out with swappiness==0
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9C01454D13A6@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB9455FE2@USINDEVS02.corp.hds.com>
 <20120305215602.GA1693@redhat.com> <4F5798B1.5070005@jp.fujitsu.com>
 <65795E11DBF1E645A09CEC7EAEE94B9CB951A45F@USINDEVS02.corp.hds.com>
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB951A45F@USINDEVS02.corp.hds.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Satoru Moriya <satoru.moriya@hds.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "jweiner@redhat.com" <jweiner@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "riel@redhat.com" <riel@redhat.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "shaohua.li@intel.com" <shaohua.li@intel.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>

Hello Kosaki-san,

On 03/07/2012 01:18 PM, Satoru Moriya wrote:
> On 03/07/2012 12:19 PM, KOSAKI Motohiro wrote:
>> Thank you. I brought back to memory it. Unfortunately DB folks are=20
>> still mainly using RHEL5 generation distros. At that time,=20
>> swapiness=3D0 doesn't mean disabling swap.
>>
>> They want, "don't swap as far as kernel has any file cache page". but=20
>> linux don't have such feature. then they used swappiness for emulate=20
>> it. So, I think this patch clearly make userland harm. Because of, we=20
>> don't have an alternative way.

As I wrote in the previous mail(see below), with this patch
the kernel begins to swap out when the sum of free pages and
filebacked pages reduces less than watermark_high.

So the kernel reclaims pages like following.

nr_free + nr_filebacked >=3D watermark_high: reclaim only filebacked pages
nr_free + nr_filebacked <  watermark_high: reclaim only anonymous pages

Do you think this behavior satisfies DB users' requirement?


> If they expect the behavior that "don't swap as far as kernel has any=20
> file cache page", this patch definitely helps them because if we set=20
> swappiness=3D=3D0, kernel does not swap out
> *until* nr_free + nr_filebacked < high watermark in the zone.
> It means kernel begins to swap out when nr_free + nr_filebacked=20
> becomes less than high watermark.
>=20
> But, yes, this patch actually changes the behavior with swappiness=3D=3D0=
=20
> and so it may make userland harm.
>=20
> How about introducing new value e.g -1 to avoid swap and maintain=20
> compatibility?

Regards,
Satoru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
