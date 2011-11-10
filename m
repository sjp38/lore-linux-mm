Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 150836B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 03:03:30 -0500 (EST)
Received: by ggnh4 with SMTP id h4so3428338ggn.14
        for <linux-mm@kvack.org>; Thu, 10 Nov 2011 00:03:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1111020352210.23788@router.home>
References: <1319385413-29665-1-git-send-email-gilad@benyossef.com>
	<1319385413-29665-5-git-send-email-gilad@benyossef.com>
	<4EAAD351.70805@redhat.com>
	<CAOtvUMd8Z_jbs__+cVG2+ZkPZLqGkJGym402RMRYGDDjT73bkg@mail.gmail.com>
	<alpine.DEB.2.00.1111020352210.23788@router.home>
Date: Thu, 10 Nov 2011 10:03:27 +0200
Message-ID: <CAOtvUMd7asdth2nhWdO_ZriFSOcM75F0YmgwtGmtXgp1XrMGzg@mail.gmail.com>
Subject: Re: [PATCH v2 4/6] mm: Only IPI CPUs to drain local pages if they exist
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>

On Wed, Nov 2, 2011 at 10:53 AM, Christoph Lameter <cl@gentwo.org> wrote:
> On Sat, 29 Oct 2011, Gilad Ben-Yossef wrote:
>
>> >> +/* Which CPUs have per cpu pages =A0*/
>> >> +cpumask_var_t cpus_with_pcp;
>> >> +static DEFINE_PER_CPU(unsigned long, total_cpu_pcp_count);
>> >
>> > Does the flushing happen so frequently that it is worth keeping this
>> > state on a per-cpu basis, or would it be better to check each CPU's
>> > pcp info and assemble a cpumask at flush time like done in patch 5?
>> >
>>
>> No, I don't =A0believe it is frequent at all. I will try to re-work the
>> patch as suggested.
>
> The draining of the pcp pages is done from the vmstat callback which
> occurs every second. Only if there is something to clean in the caches
> will the flush happen.
>

Right,  I wasn't accurate with my answer - I meant to say that the code to =
IPI
all CPUs asking to flush their pcp pages is infrequent, so doing more
work in that
code path is not unthinkable. Thanks for pointing it out.

As Christoph pointed out flushing on each CPU is also done by the  vmstat
workqueue every second, in addition to the IPI path.

Since the changes I need wish to do involve the code that sends the IPI and=
 not
the flush code itself, I believe it is correct to say it is not a
frequent activity.

Having said that, trying to come up with a way with avoiding waking up each=
 CPU
once per second to do the vmstat work is also on my todo list, but
this is another
patch and another story altogether... :-)

Thanks!
Gilad

--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"Unfortunately, cache misses are an equal opportunity pain provider."
-- Mike Galbraith, LKML

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
