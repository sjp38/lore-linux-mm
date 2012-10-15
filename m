Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 47EB66B002B
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 18:33:33 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so6716924obc.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 15:33:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121015144736.GI29069@dhcp22.suse.cz>
References: <20121010141142.GG23011@dhcp22.suse.cz> <507BD33C.4030209@jp.fujitsu.com>
 <20121015094907.GE29069@dhcp22.suse.cz> <CAHGf_=p4d33t7i5++YHTkc0PbAUckca1oBxR5dZ48EzybKYHgw@mail.gmail.com>
 <20121015144736.GI29069@dhcp22.suse.cz>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 15 Oct 2012 18:33:12 -0400
Message-ID: <CAHGf_=qniFPXUMoQ6Ayi6iAQ9h4_AUr4_aaJUJcYHmW57L4gKQ@mail.gmail.com>
Subject: Re: [RFC PATCH] memcg: oom: fix totalpages calculation for swappiness==0
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

>> I think this only correct when memcg. Even if swappiness==0, global reclaim swap
>> out anon pages before oom.
>
> Right you are (we really do swap when the file pages are really
> low)! Sorry about the confusion. I kind of became if(global_reclaim)
> block blind...
>
> Then this really needs a memcg specific documentation fix. What about
> the following?
> ---
> From 59a60705abd2faf9e266a4270bbf302001845588 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Mon, 15 Oct 2012 11:43:56 +0200
> Subject: [PATCH] doc: describe memcg swappiness more precisely
>
> since fe35004f (mm: avoid swapping out with swappiness==0) memcg reclaim
> stopped swapping out anon pages completely when 0 value is used.
> Although this is somehow expected it hasn't been done for a really long
> time this way and so it is probably better to be explicit about the
> effect. Moreover global reclaim swapps out even when swappiness is 0
> to prevent from OOM killer.
>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  Documentation/cgroups/memory.txt |    4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index c07f7b4..71c4da4 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -466,6 +466,10 @@ Note:
>  5.3 swappiness
>
>  Similar to /proc/sys/vm/swappiness, but affecting a hierarchy of groups only.
> +Please note that unlike the global swappiness, memcg knob set to 0
> +really prevents from any swapping even if there is a swap storage
> +available. This might lead to memcg OOM killer if there are no file
> +pages to reclaim.

Pretty good to me. Thank you!

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
