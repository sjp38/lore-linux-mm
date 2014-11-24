Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 627B06B0038
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 18:43:53 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so10577592pad.1
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 15:43:53 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id sm6si23725087pac.165.2014.11.24.15.43.50
        for <linux-mm@kvack.org>;
        Mon, 24 Nov 2014 15:43:52 -0800 (PST)
Date: Tue, 25 Nov 2014 08:46:44 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 5/8] stacktrace: introduce snprint_stack_trace for
 buffer output
Message-ID: <20141124234644.GB7824@js1304-P5Q-DELUXE>
References: <1416816926-7756-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1416816926-7756-6-git-send-email-iamjoonsoo.kim@lge.com>
 <20141124145752.ab64fd85.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141124145752.ab64fd85.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 24, 2014 at 02:57:52PM -0800, Andrew Morton wrote:
> On Mon, 24 Nov 2014 17:15:23 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > Current stacktrace only have the function for console output.
> > page_owner that will be introduced in following patch needs to print
> > the output of stacktrace into the buffer for our own output format
> > so so new function, snprint_stack_trace(), is needed.
> > 
> > ...
> >
> > +int snprint_stack_trace(char *buf, size_t size,
> > +			struct stack_trace *trace, int spaces)
> > +{
> > +	int i;
> > +	unsigned long ip;
> > +	int generated;
> > +	int total = 0;
> > +
> > +	if (WARN_ON(!trace->entries))
> > +		return 0;
> > +
> > +	for (i = 0; i < trace->nr_entries; i++) {
> > +		ip = trace->entries[i];
> > +		generated = snprintf(buf, size, "%*c[<%p>] %pS\n",
> > +				1 + spaces, ' ', (void *) ip, (void *) ip);
> > +
> > +		total += generated;
> > +
> > +		/* Assume that generated isn't a negative number */
> > +		if (generated >= size) {
> > +			buf += size;
> > +			size = 0;
> 
> Seems strange to keep looping around doing nothing.  Would it be better
> to `break' here?

generated will be added to total in each iteration even if size is 0.
snprint_stack_trace() could return accurate generated string length
by this looping.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
