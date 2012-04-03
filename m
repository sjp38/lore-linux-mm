Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 6DA8A6B0044
	for <linux-mm@kvack.org>; Tue,  3 Apr 2012 11:17:56 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Tue, 3 Apr 2012 11:15:30 -0400
Subject: RE: [RFC][PATCH] avoid swapping out with swappiness==0
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9C014536F9A3@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB9455FE2@USINDEVS02.corp.hds.com>
 <20120305215602.GA1693@redhat.com> <4F5798B1.5070005@jp.fujitsu.com>
 <65795E11DBF1E645A09CEC7EAEE94B9CB951A45F@USINDEVS02.corp.hds.com>
 <65795E11DBF1E645A09CEC7EAEE94B9C01454D13A6@USINDEVS02.corp.hds.com>
 <CAHGf_=p9OgVC9J-Nh78CTbuMbc9CVt-+-G+CNbYUsgz70Uc8Qg@mail.gmail.com>,<4F7ADE1A.2050004@redhat.com>
In-Reply-To: <4F7ADE1A.2050004@redhat.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "jweiner@redhat.com" <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "riel@redhat.com" <riel@redhat.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>

On 04/03/2012 07:25 AM, Jerome Marchand wrote:
> On 04/02/2012 07:10 PM, KOSAKI Motohiro wrote:
>> 2012/3/30 Satoru Moriya <satoru.moriya@hds.com>:
>>> Hello Kosaki-san,
>>>
>>> On 03/07/2012 01:18 PM, Satoru Moriya wrote:
>>>> On 03/07/2012 12:19 PM, KOSAKI Motohiro wrote:
>>>>> Thank you. I brought back to memory it. Unfortunately DB folks are
>>>>> still mainly using RHEL5 generation distros. At that time,
>>>>> swapiness=3D0 doesn't mean disabling swap.
>>>>>
>>>>> They want, "don't swap as far as kernel has any file cache page". but
>>>>> linux don't have such feature. then they used swappiness for emulate
>>>>> it. So, I think this patch clearly make userland harm. Because of, we
>>>>> don't have an alternative way.
>>>
>>> As I wrote in the previous mail(see below), with this patch
>>> the kernel begins to swap out when the sum of free pages and
>>> filebacked pages reduces less than watermark_high.
>
> Actually, this is true only for global reclaims. Reclaims in cgroup can f=
ail
> in this case.

Right.
As long as we consider RHEL5 users above, I believe they don't care
about cgroup case.

>>>
>>> So the kernel reclaims pages like following.
>>>
>>> nr_free + nr_filebacked >=3D watermark_high: reclaim only filebacked pa=
ges
>>> nr_free + nr_filebacked <  watermark_high: reclaim only anonymous pages

I made a tiny mistake.
Correct one is following ;p

nr_free + nr_filebacked >  watermark_high: reclaim only filebacked pages
nr_free + nr_filebacked <=3D watermark_high: reclaim only anonymous pages

>> How?
>
> get_scan_count() checks that case explicitly:
>
>        if (global_reclaim(sc)) {
>                free  =3D zone_page_state(mz->zone, NR_FREE_PAGES);
>                /* If we have very few page cache pages,
>                   force-scan anon pages. */
>                if (unlikely(file + free <=3D high_wmark_pages(mz->zone)))=
 {
>                        fraction[0] =3D 1;
>                        fraction[1] =3D 0;
>                        denominator =3D 1;
>                        goto out;
>                }
>        }

Regards,
Satoru=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
