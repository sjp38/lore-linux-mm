Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8E86A6B0062
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 12:47:40 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3DE1482C628
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 12:54:23 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id f9+cjOUHuXx7 for <linux-mm@kvack.org>;
	Thu,  5 Nov 2009 12:54:23 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 20ADF82D5C9
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 10:23:16 -0500 (EST)
Date: Thu, 5 Nov 2009 10:15:36 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC][PATCH] lib: generic percpu counter array
In-Reply-To: <20091105141653.132d4977.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0911051013080.25718@V090114053VZO-1>
References: <20091104152426.eacc894f.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.1.10.0911041414560.7409@V090114053VZO-1> <20091105090659.9a5d17b1.kamezawa.hiroyu@jp.fujitsu.com> <20091105141653.132d4977.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, akpm@linux-foundation.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Nov 2009, KAMEZAWA Hiroyuki wrote:

> +static inline void
> +counter_array_add(struct counter_array *ca, int idx, int val)
> +{
> +	ca->counters[idx] += val;
> +}

This is not a per cpu operation and therefore expensive. The new percpu
this_cpu_inc f.e. generates a single x86 instruction for an increment.

> +void __counter_array_add(struct counter_array *ca, int idx, int val, int batch)
> +{
> +	long count, *pcount;
> +
> +	preempt_disable();
> +
> +	pcount = this_cpu_ptr(ca->v.array);
> +	count = pcount[idx] + val;
> +	if (!ca->v.nosync && ((count > batch) || (count < -batch))) {
> +		atomic_long_add(count, &ca->counters[idx]);
> +		pcount[idx] = 0;
> +	} else
> +		pcount[idx] = count;
> +	preempt_enable();
> +}

Too expensive to use in critical VM paths. The percpu operations generate
a single instruction instead of the code above. No need for preempt etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
