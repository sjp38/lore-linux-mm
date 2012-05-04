Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 0D3316B0081
	for <linux-mm@kvack.org>; Fri,  4 May 2012 08:20:16 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so4775119pbb.14
        for <linux-mm@kvack.org>; Fri, 04 May 2012 05:20:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120504120455.GB4413@somewhere.redhat.com>
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com>
	<1336056962-10465-2-git-send-email-gilad@benyossef.com>
	<20120504120455.GB4413@somewhere.redhat.com>
Date: Fri, 4 May 2012 14:20:16 +0200
Message-ID: <CAFTL4hzSPbtTbL8gHy2SEnBv3rqWdk2UQL0uBUedqm2mmpHKiQ@mail.gmail.com>
Subject: Re: [PATCH v1 1/6] timer: make __next_timer_interrupt explicit about
 no future event
From: Frederic Weisbecker <fweisbec@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, linux-mm@kvack.org

2012/5/4 Frederic Weisbecker <fweisbec@gmail.com>:
> On Thu, May 03, 2012 at 05:55:57PM +0300, Gilad Ben-Yossef wrote:
>> @@ -1317,9 +1322,15 @@ unsigned long get_next_timer_interrupt(unsigned l=
ong now)
>> =A0 =A0 =A0 if (cpu_is_offline(smp_processor_id()))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return now + NEXT_TIMER_MAX_DELTA;
>> =A0 =A0 =A0 spin_lock(&base->lock);
>> - =A0 =A0 if (time_before_eq(base->next_timer, base->timer_jiffies))
>> - =A0 =A0 =A0 =A0 =A0 =A0 base->next_timer =3D __next_timer_interrupt(ba=
se);
>> - =A0 =A0 expires =3D base->next_timer;
>> + =A0 =A0 if (time_before_eq(base->next_timer, base->timer_jiffies)) {
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (__next_timer_interrupt(base, &expires))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 base->next_timer =3D expires;
>> + =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 expires =3D now + NEXT_TIMER_M=
AX_DELTA;
>
> I believe you can update base->next_timer to now + NEXT_TIMER_MAX_DELTA,
> so on any further idle interrupt exit that call tick_nohz_stop_sched_tick=
(),
> we won't get again the overhead of __next_timer_interrupt().

Ah forget that, I was confused. If we do that we actually get the useless t=
imer
at now + NEXT_TIMER_MAX_DELTA.

So I think the patch is fine.

Acked-by: Frederic Weisbecker <fweisbec@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
