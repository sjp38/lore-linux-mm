Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BFCED6B00EF
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 17:07:40 -0500 (EST)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Thu, 13 Jan 2011 17:05:07 -0500
Subject: RE: [RFC][PATCH 0/2] Tunable watermark
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9C3B8DF645@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9C3A30A295@USINDEVS02.corp.hds.com>
 <alpine.DEB.2.00.1101071416450.23577@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1101071416450.23577@chino.kir.corp.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Randy Dunlap <rdunlap@xenotime.net>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>
List-ID: <linux-mm.kvack.org>

Hi David,

Thank you for your comments.

On 01/07/2011 05:23 PM, David Rientjes wrote:
> On Fri, 7 Jan 2011, Satoru Moriya wrote:

>>
>> [Problem]
>> The thresholds kswapd/direct reclaim starts(ends) depend on
>> watermark[min,low,high] and currently all watermarks are set
>> based on min_free_kbytes. min_free_kbytes is the amount of
>> free memory that Linux VM should keep at least.
>>
>=20
> Not completely, it also depends on the amount of lowmem (because of the=20
> reserve setup next) and the amount of memory in each zone.

Right. Thanks.

>> [Solution]
>> To avoid the situation above, this patch set introduces new
>> tunables /proc/sys/vm/wmark_min_kbytes, wmark_low_kbytes and
>> wmark_high_kbytes. Each entry controls watermark[min],
>> watermark[low] and watermark[high] separately.
>> By using these parameters one can make the difference between
>> min and low bigger than the amount of memory which applications
>> require.
>>
>=20
> I really dislike this because it adds additional tunables that should=20
> already be handled correctly by the VM and it's very difficult for users=
=20
> to know what to tune these values to; these watermarks (with the exceptio=
n=20
> of min) are supposed to be internal to the VM implementation.

The patchset targeted enterprise system and in that area users expect
that they can tune the system by themselves to fulfill their requirements.

> You didn't mention why it wouldn't be possible to modify=20
> setup_per_zone_wmarks() in some way for your configuration so this happen=
s=20
> automatically.  If you can find a deterministic way to set these=20
> watermarks from userspace, you should be able to do it in the kernel as=20
> well based on the configuration.

Do you mean that we should introduce a mechanism into kernel that changes
watermarks dynamically depending on its loads (such as cpu frequency contro=
l)
or we should change the calculation method in setup_per_zone_wmarks()?

I think it is difficult to control watermarks automatically in kernel becau=
se
required memory varies widely among applications. On the other hand, sysctl
parameters help us fit the kernel to each system's requirement flexibly.

> I think we should invest time in making sure the VM works for any type of=
=20
> workload thrown at it instead of relying on userspace making lots of=20
> adjustments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
