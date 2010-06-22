Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 394716B01BF
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 04:24:14 -0400 (EDT)
Date: Tue, 22 Jun 2010 01:24:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RFC] mm: Implement balance_dirty_pages() through waiting
 for flusher thread
Message-Id: <20100622012406.1d9aa8fd.akpm@linux-foundation.org>
In-Reply-To: <1277192722.1875.526.camel@laptop>
References: <1276797878-28893-1-git-send-email-jack@suse.cz>
	<20100618060901.GA6590@dastard>
	<20100621233628.GL3828@quack.suse.cz>
	<20100622054409.GP7869@dastard>
	<20100621231416.904c50c7.akpm@linux-foundation.org>
	<1277192722.1875.526.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@infradead.org, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

On Tue, 22 Jun 2010 09:45:22 +0200 Peter Zijlstra <peterz@infradead.org> wrote:

> On Mon, 2010-06-21 at 23:14 -0700, Andrew Morton wrote:
> > +/*
> > + * Compare counter against given value.
> > + * Return 1 if greater, 0 if equal and -1 if less
> > + */
> > +int percpu_counter_compare(struct percpu_counter *fbc, s64 rhs)
> > +{
> > +       s64     count;
> > +
> > +       count = percpu_counter_read(fbc);
> > +       /* Check to see if rough count will be sufficient for comparison */
> > +       if (abs(count - rhs) > (percpu_counter_batch*num_online_cpus())) {
> > +               if (count > rhs)
> > +                       return 1;
> > +               else
> > +                       return -1;
> > +       }
> > +       /* Need to use precise count */
> > +       count = percpu_counter_sum(fbc);
> > +       if (count > rhs)
> > +               return 1;
> > +       else if (count < rhs)
> > +               return -1;
> > +       else
> > +               return 0;
> > +}
> > +EXPORT_SYMBOL(percpu_counter_compare); 
> 
> That won't quite work as advertised for the bdi stuff since we use a
> custom batch size.

Oh come on, of course it will.  It just needs
__percpu_counter_compare() as I mentioned when merging it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
