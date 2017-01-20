Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2EBC86B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 05:02:50 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c73so91339602pfb.7
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 02:02:50 -0800 (PST)
Received: from mail-pg0-x22d.google.com (mail-pg0-x22d.google.com. [2607:f8b0:400e:c05::22d])
        by mx.google.com with ESMTPS id q12si6370498plk.245.2017.01.20.02.02.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jan 2017 02:02:49 -0800 (PST)
Received: by mail-pg0-x22d.google.com with SMTP id 194so22587678pgd.2
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 02:02:49 -0800 (PST)
Date: Fri, 20 Jan 2017 02:02:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, oom: header nodemask is NULL when cpusets are
 disabled
In-Reply-To: <e32b48f0-e345-2a44-9f95-0403eeb6a4fd@suse.cz>
Message-ID: <alpine.DEB.2.10.1701200202001.88633@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1701181347320.142399@chino.kir.corp.google.com> <279f10c2-3eaa-c641-094f-3070db67d84f@suse.cz> <alpine.DEB.2.10.1701191454470.2381@chino.kir.corp.google.com> <e32b48f0-e345-2a44-9f95-0403eeb6a4fd@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

On Fri, 20 Jan 2017, Vlastimil Babka wrote:

> Could we simplify both patches with something like this?
> Although the sizeof("null") is not the nicest thing, because it relies on knowledge
> that pointer() in lib/vsprintf.c uses this string. Maybe Rasmus has some better idea?
> 
> Thanks,
> Vlastimil
> 
> diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
> index f746e44d4046..4add88ef63f0 100644
> --- a/include/linux/nodemask.h
> +++ b/include/linux/nodemask.h
> @@ -103,7 +103,7 @@ extern nodemask_t _unused_nodemask_arg_;
>   *
>   * Can be used to provide arguments for '%*pb[l]' when printing a nodemask.
>   */
> -#define nodemask_pr_args(maskp)		MAX_NUMNODES, (maskp)->bits
> +#define nodemask_pr_args(maskp)		((maskp) ? MAX_NUMNODES : (int) sizeof("null")), ((maskp) ? (maskp)->bits : NULL)
>  
>  /*
>   * The inline keyword gives the compiler room to decide to inline, or
> 

That's creative.  I'm not sure if it's worth it considering 
nodemask_pr_args() is usually used in a context where we know we have a 
nodemask :)  These would be the only two exceptions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
