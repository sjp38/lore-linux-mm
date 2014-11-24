Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5CBBF6B0038
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 17:57:32 -0500 (EST)
Received: by mail-ie0-f173.google.com with SMTP id y20so9875131ier.18
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 14:57:32 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a15si107514icg.87.2014.11.24.14.57.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Nov 2014 14:57:31 -0800 (PST)
Date: Mon, 24 Nov 2014 14:57:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 5/8] stacktrace: introduce snprint_stack_trace for
 buffer output
Message-Id: <20141124145752.ab64fd85.akpm@linux-foundation.org>
In-Reply-To: <1416816926-7756-6-git-send-email-iamjoonsoo.kim@lge.com>
References: <1416816926-7756-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1416816926-7756-6-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 24 Nov 2014 17:15:23 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> Current stacktrace only have the function for console output.
> page_owner that will be introduced in following patch needs to print
> the output of stacktrace into the buffer for our own output format
> so so new function, snprint_stack_trace(), is needed.
> 
> ...
>
> +int snprint_stack_trace(char *buf, size_t size,
> +			struct stack_trace *trace, int spaces)
> +{
> +	int i;
> +	unsigned long ip;
> +	int generated;
> +	int total = 0;
> +
> +	if (WARN_ON(!trace->entries))
> +		return 0;
> +
> +	for (i = 0; i < trace->nr_entries; i++) {
> +		ip = trace->entries[i];
> +		generated = snprintf(buf, size, "%*c[<%p>] %pS\n",
> +				1 + spaces, ' ', (void *) ip, (void *) ip);
> +
> +		total += generated;
> +
> +		/* Assume that generated isn't a negative number */
> +		if (generated >= size) {
> +			buf += size;
> +			size = 0;

Seems strange to keep looping around doing nothing.  Would it be better
to `break' here?

> +		} else {
> +			buf += generated;
> +			size -= generated;
> +		}
> +	}
> +
> +	return total;
> +}
> +EXPORT_SYMBOL_GPL(snprint_stack_trace);
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
