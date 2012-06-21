Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id ABF3E6B005C
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 21:39:28 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so91970ghr.14
        for <linux-mm@kvack.org>; Wed, 20 Jun 2012 18:39:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FE26470.90401@kernel.org>
References: <4FE169B1.7020600@kernel.org> <4FE16E80.9000306@gmail.com>
 <4FE18187.3050103@kernel.org> <4FE23069.5030702@gmail.com> <4FE26470.90401@kernel.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 20 Jun 2012 21:39:07 -0400
Message-ID: <CAHGf_=pjoiHQ9vxXXe-GtbkYRzhxdDhu3pf6pwDsCe5pBQE8Nw@mail.gmail.com>
Subject: Re: Accounting problem of MIGRATE_ISOLATED freed page
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Aaditya Kumar <aaditya.kumar.30@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

>> number of isolate page block is almost always 0. then if we have such counter,
>> we almost always can avoid zone->lock. Just idea.
>
> Yeb. I thought about it but unfortunately we can't have a counter for MIGRATE_ISOLATE.
> Because we have to tweak in page free path for pages which are going to free later after we
> mark pageblock type to MIGRATE_ISOLATE.

I mean,

if (nr_isolate_pageblock != 0)
   free_pages -= nr_isolated_free_pages(); // your counting logic

return __zone_watermark_ok(z, alloc_order, mark,
                              classzone_idx, alloc_flags, free_pages);


I don't think this logic affect your race. zone_watermark_ok() is already
racy. then new little race is no big matter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
