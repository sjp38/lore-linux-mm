Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8A90B6B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 08:51:37 -0400 (EDT)
Subject: Re: [PATCH 05/10] writeback: per task dirty rate limit
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 26 Aug 2011 14:51:09 +0200
In-Reply-To: <20110826114619.268843347@intel.com>
References: <20110826113813.895522398@intel.com>
	 <20110826114619.268843347@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1314363069.11049.3.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 2011-08-26 at 19:38 +0800, Wu Fengguang wrote:
> +       preempt_disable();
>         /*
> -        * Check the rate limiting. Also, we do not want to throttle real=
-time
> -        * tasks in balance_dirty_pages(). Period.
> +        * This prevents one CPU to accumulate too many dirtied pages wit=
hout
> +        * calling into balance_dirty_pages(), which can happen when ther=
e are
> +        * 1000+ tasks, all of them start dirtying pages at exactly the s=
ame
> +        * time, hence all honoured too large initial task->nr_dirtied_pa=
use.
>          */
> -       preempt_disable();
>         p =3D  &__get_cpu_var(bdp_ratelimits);

	p =3D &get_cpu_var(bdp_ratelimits);

> -       *p +=3D nr_pages_dirtied;
> -       if (unlikely(*p >=3D ratelimit)) {
> -               ratelimit =3D sync_writeback_pages(*p);
> +       if (unlikely(current->nr_dirtied >=3D ratelimit))
>                 *p =3D 0;
> -               preempt_enable();
> -               balance_dirty_pages(mapping, ratelimit);
> -               return;
> +       else {
> +               *p +=3D nr_pages_dirtied;
> +               if (unlikely(*p >=3D ratelimit_pages)) {
> +                       *p =3D 0;
> +                       ratelimit =3D 0;
> +               }
>         }
>         preempt_enable();=20

	put_cpu_var(bdp_ratelimits);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
