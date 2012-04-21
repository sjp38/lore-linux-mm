Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 25C996B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 20:21:40 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Fri, 20 Apr 2012 20:21:28 -0400
Subject: RE: [RFC][PATCH] avoid swapping out with swappiness==0
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9C014575D8CF@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB9455FE2@USINDEVS02.corp.hds.com>
 <20120305215602.GA1693@redhat.com> <4F5798B1.5070005@jp.fujitsu.com>
 <65795E11DBF1E645A09CEC7EAEE94B9CB951A45F@USINDEVS02.corp.hds.com>
 <65795E11DBF1E645A09CEC7EAEE94B9C01454D13A6@USINDEVS02.corp.hds.com>
 <CAHGf_=p9OgVC9J-Nh78CTbuMbc9CVt-+-G+CNbYUsgz70Uc8Qg@mail.gmail.com>
 <4F7ADE1A.2050004@redhat.com> <4F7C870B.6020807@gmail.com>
In-Reply-To: <4F7C870B.6020807@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Jerome Marchand <jmarchan@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "riel@redhat.com" <riel@redhat.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "shaohua.li@intel.com" <shaohua.li@intel.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>

Hi,

Sorry for my late reply.

On 04/04/2012 01:38 PM, KOSAKI Motohiro wrote:
> (4/3/12 4:25 AM), Jerome Marchand wrote:
>> On 04/02/2012 07:10 PM, KOSAKI Motohiro wrote:
>>> 2012/3/30 Satoru Moriya<satoru.moriya@hds.com>:
>>>> So the kernel reclaims pages like following.
>>>>
>>>> nr_free + nr_filebacked>=3D watermark_high: reclaim only filebacked pa=
ges
>>>> nr_free + nr_filebacked<   watermark_high: reclaim only anonymous page=
s
>>>
>>> How?
>>
>> get_scan_count() checks that case explicitly:
>>
>>     if (global_reclaim(sc)) {
>>         free  =3D zone_page_state(mz->zone, NR_FREE_PAGES);
>>         /* If we have very few page cache pages,
>>            force-scan anon pages. */
>>         if (unlikely(file + free<=3D high_wmark_pages(mz->zone))) {
>>             fraction[0] =3D 1;
>>             fraction[1] =3D 0;
>>             denominator =3D 1;
>>             goto out;
>>         }
>>     }
>=20
> Eek. This is silly. Nowaday many people enabled THP and it increase zone =
watermark.
> so, high watermask is not good threshold anymore.

Ah yes, it is not so small now.
On 4GB server, without THP min_free_kbytes is 8113 but
with THP it is 67584.

How about using low watermark or min watermark?
Are they still big?

...or should we use other value?=20

Regards,
Satoru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
