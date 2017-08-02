Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 879F06B0631
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 17:17:23 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x64so328045wmg.11
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 14:17:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 91si185953wrg.471.2017.08.02.14.17.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 14:17:22 -0700 (PDT)
Date: Wed, 2 Aug 2017 14:17:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: ratelimit PFNs busy info message
Message-Id: <20170802141720.228502368b534f517e3107ff@linux-foundation.org>
In-Reply-To: <499c0f6cc10d6eb829a67f2a4d75b4228a9b356e.1501695897.git.jtoppins@redhat.com>
References: <499c0f6cc10d6eb829a67f2a4d75b4228a9b356e.1501695897.git.jtoppins@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Toppins <jtoppins@redhat.com>
Cc: linux-mm@kvack.org, linux-rdma@vger.kernel.org, dledford@redhat.com, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Hillf Danton <hillf.zj@alibaba-inc.com>, open list <linux-kernel@vger.kernel.org>

On Wed,  2 Aug 2017 13:44:57 -0400 Jonathan Toppins <jtoppins@redhat.com> wrote:

> The RDMA subsystem can generate several thousand of these messages per
> second eventually leading to a kernel crash. Ratelimit these messages
> to prevent this crash.

Well...  why are all these EBUSY's occurring?  It sounds inefficient (at
least) but if it is expected, normal and unavoidable then perhaps we
should just remove that message altogether?

> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7666,7 +7666,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  
>  	/* Make sure the range is really isolated. */
>  	if (test_pages_isolated(outer_start, end, false)) {
> -		pr_info("%s: [%lx, %lx) PFNs busy\n",
> +		pr_info_ratelimited("%s: [%lx, %lx) PFNs busy\n",
>  			__func__, outer_start, end);
>  		ret = -EBUSY;
>  		goto done;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
