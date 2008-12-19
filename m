Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2F0386B0047
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 21:20:20 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBJ2MNpT022385
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Dec 2008 11:22:23 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 639BE45DD81
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 11:22:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D8B245DD78
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 11:22:23 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B1AC31DB8048
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 11:22:22 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 644B31DB8041
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 11:22:22 +0900 (JST)
Date: Fri, 19 Dec 2008 11:21:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Corruption with O_DIRECT and unaligned user buffers
Message-Id: <20081219112125.75bbda2b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081218152952.GW24856@random.random>
References: <491DAF8E.4080506@quantum.com>
	<200811191526.00036.nickpiggin@yahoo.com.au>
	<20081119165819.GE19209@random.random>
	<20081218152952.GW24856@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Tim LaBerge <tim.laberge@quantum.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Dec 2008 16:29:52 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> @@ -484,11 +476,34 @@
>  	if (page) {
>  		get_page(page);
>  		page_dup_rmap(page);
> +		if (is_cow_mapping(vm_flags) && PageAnon(page)) {
> +			if (unlikely(TestSetPageLocked(page)))
> +				forcecow = 1;
> +			else {
> +				if (unlikely(page_count(page) !=
> +					     page_mapcount(page)
> +					     + !!PageSwapCache(page)))
> +					forcecow = 1;
> +				unlock_page(page);
> +			}
> +		}
>  		rss[!!PageAnon(page)]++;
>  	}
 - Why do you check only Anon rather than all MAP_PRIVATE mappings ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
