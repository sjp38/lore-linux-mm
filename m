Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id BAFDD6B0044
	for <linux-mm@kvack.org>; Tue,  3 Apr 2012 07:25:28 -0400 (EDT)
Message-ID: <4F7ADE1A.2050004@redhat.com>
Date: Tue, 03 Apr 2012 13:25:14 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] avoid swapping out with swappiness==0
References: <65795E11DBF1E645A09CEC7EAEE94B9CB9455FE2@USINDEVS02.corp.hds.com> <20120305215602.GA1693@redhat.com> <4F5798B1.5070005@jp.fujitsu.com> <65795E11DBF1E645A09CEC7EAEE94B9CB951A45F@USINDEVS02.corp.hds.com> <65795E11DBF1E645A09CEC7EAEE94B9C01454D13A6@USINDEVS02.corp.hds.com> <CAHGf_=p9OgVC9J-Nh78CTbuMbc9CVt-+-G+CNbYUsgz70Uc8Qg@mail.gmail.com>
In-Reply-To: <CAHGf_=p9OgVC9J-Nh78CTbuMbc9CVt-+-G+CNbYUsgz70Uc8Qg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Satoru Moriya <satoru.moriya@hds.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "riel@redhat.com" <riel@redhat.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "shaohua.li@intel.com" <shaohua.li@intel.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>

On 04/02/2012 07:10 PM, KOSAKI Motohiro wrote:
> 2012/3/30 Satoru Moriya <satoru.moriya@hds.com>:
>> Hello Kosaki-san,
>>
>> On 03/07/2012 01:18 PM, Satoru Moriya wrote:
>>> On 03/07/2012 12:19 PM, KOSAKI Motohiro wrote:
>>>> Thank you. I brought back to memory it. Unfortunately DB folks are
>>>> still mainly using RHEL5 generation distros. At that time,
>>>> swapiness=0 doesn't mean disabling swap.
>>>>
>>>> They want, "don't swap as far as kernel has any file cache page". but
>>>> linux don't have such feature. then they used swappiness for emulate
>>>> it. So, I think this patch clearly make userland harm. Because of, we
>>>> don't have an alternative way.
>>
>> As I wrote in the previous mail(see below), with this patch
>> the kernel begins to swap out when the sum of free pages and
>> filebacked pages reduces less than watermark_high.

Actually, this is true only for global reclaims. Reclaims in cgroup can fail
in this case.

>>
>> So the kernel reclaims pages like following.
>>
>> nr_free + nr_filebacked >= watermark_high: reclaim only filebacked pages
>> nr_free + nr_filebacked <  watermark_high: reclaim only anonymous pages
> 
> How?

get_scan_count() checks that case explicitly:

	if (global_reclaim(sc)) {
		free  = zone_page_state(mz->zone, NR_FREE_PAGES);
		/* If we have very few page cache pages,
		   force-scan anon pages. */
		if (unlikely(file + free <= high_wmark_pages(mz->zone))) {
			fraction[0] = 1;
			fraction[1] = 0;
			denominator = 1;
			goto out;
		}
	}

Regards,
Jerome

> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
