Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0BE6B01BA
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 03:45:35 -0400 (EDT)
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through
 waiting for flusher thread
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100621231416.904c50c7.akpm@linux-foundation.org>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
	 <20100618060901.GA6590@dastard> <20100621233628.GL3828@quack.suse.cz>
	 <20100622054409.GP7869@dastard>
	 <20100621231416.904c50c7.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 22 Jun 2010 09:45:22 +0200
Message-ID: <1277192722.1875.526.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Mon, 2010-06-21 at 23:14 -0700, Andrew Morton wrote:
> +/*
> + * Compare counter against given value.
> + * Return 1 if greater, 0 if equal and -1 if less
> + */
> +int percpu_counter_compare(struct percpu_counter *fbc, s64 rhs)
> +{
> +       s64     count;
> +
> +       count =3D percpu_counter_read(fbc);
> +       /* Check to see if rough count will be sufficient for comparison =
*/
> +       if (abs(count - rhs) > (percpu_counter_batch*num_online_cpus())) =
{
> +               if (count > rhs)
> +                       return 1;
> +               else
> +                       return -1;
> +       }
> +       /* Need to use precise count */
> +       count =3D percpu_counter_sum(fbc);
> +       if (count > rhs)
> +               return 1;
> +       else if (count < rhs)
> +               return -1;
> +       else
> +               return 0;
> +}
> +EXPORT_SYMBOL(percpu_counter_compare);=20

That won't quite work as advertised for the bdi stuff since we use a
custom batch size.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
