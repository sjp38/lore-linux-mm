Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 557C96B00A7
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 10:25:35 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so6175264oag.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 07:25:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121015094907.GE29069@dhcp22.suse.cz>
References: <20121010141142.GG23011@dhcp22.suse.cz> <507BD33C.4030209@jp.fujitsu.com>
 <20121015094907.GE29069@dhcp22.suse.cz>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 15 Oct 2012 10:25:14 -0400
Message-ID: <CAHGf_=p4d33t7i5++YHTkc0PbAUckca1oBxR5dZ48EzybKYHgw@mail.gmail.com>
Subject: Re: [RFC PATCH] memcg: oom: fix totalpages calculation for swappiness==0
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 078701f..308fd77 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -640,6 +640,9 @@ swappiness
>  This control is used to define how aggressive the kernel will swap
>  memory pages.  Higher values will increase agressiveness, lower values
>  decrease the amount of swap.
> +The value can be used from the [0, 100] range, where 0 means no swapping
> +at all (even if there is a swap storage enabled) while 100 means that
> +anonymous pages are reclaimed in the same rate as file pages.

I think this only correct when memcg. Even if swappiness==0, global reclaim swap
out anon pages before oom.

see below.

get_scan_count()
(snip)
	if (global_reclaim(sc)) {
		free  = zone_page_state(zone, NR_FREE_PAGES);
		/* If we have very few page cache pages,
		   force-scan anon pages. */
		if (unlikely(file + free <= high_wmark_pages(zone))) {
			fraction[0] = 1;
			fraction[1] = 0;
			denominator = 1;
			goto out;
		}
	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
