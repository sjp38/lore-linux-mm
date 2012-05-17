Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 067FC6B0092
	for <linux-mm@kvack.org>; Thu, 17 May 2012 17:56:51 -0400 (EDT)
Message-ID: <1337291805.4281.97.camel@twins>
Subject: Re: [PATCH 1/2] lib: Proportions with flexible period
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 17 May 2012 23:56:45 +0200
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
> +void fprop_fraction_percpu(struct fprop_global *p,
> +                          struct fprop_local_percpu *pl,
> +                          unsigned long *numerator, unsigned long *denom=
inator)
> +{
> +       unsigned int seq;
> +       s64 den;
> +
> +       do {
> +               seq =3D read_seqcount_begin(&p->sequence);
> +               fprop_reflect_period_percpu(p, pl);
> +               *numerator =3D percpu_counter_read_positive(&pl->events);
> +               den =3D percpu_counter_read(&p->events);
> +               if (den <=3D 0)
> +                       den =3D percpu_counter_sum(&p->events);
> +               *denominator =3D den;
> +       } while (read_seqcount_retry(&p->sequence, seq));
> +}=20


why not use percpu_counter_read_positive(&p->events) and ditch
percpu_counter_sum()? That sum can be terribly expensive..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
