Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id DC2086B0082
	for <linux-mm@kvack.org>; Fri, 18 May 2012 06:43:49 -0400 (EDT)
Message-ID: <1337337824.573.16.camel@twins>
Subject: Re: [PATCH 1/2] lib: Proportions with flexible period
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 18 May 2012 12:43:44 +0200
In-Reply-To: <1337096583-6049-2-git-send-email-jack@suse.cz>
References: <1337096583-6049-1-git-send-email-jack@suse.cz>
	 <1337096583-6049-2-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, 2012-05-15 at 17:43 +0200, Jan Kara wrote:
> +void __fprop_inc_percpu_max(struct fprop_global *p,
> +                           struct fprop_local_percpu *pl, int max_frac)
> +{
> +       if (unlikely(max_frac < 100)) {
> +               unsigned long numerator, denominator;
> +
> +               fprop_fraction_percpu(p, pl, &numerator, &denominator);
> +               if (numerator > ((long long)denominator) * max_frac / 100=
)
> +                       return;

Another thing, your fprop_fraction_percpu() can he horribly expensive
due to using _sum() (and to a lesser degree the retry), remember that
this function is called for _every_ page written out.

Esp. on the mega fast storage (multi-spindle or SSD) they're pushing cpu
limits as it is with iops, we should be very careful not to make it more
expensive than absolutely needed.

> +       } else
> +               fprop_reflect_period_percpu(p, pl);
> +       __percpu_counter_add(&pl->events, 1, PROP_BATCH);
> +       percpu_counter_add(&p->events, 1);
> +}=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
