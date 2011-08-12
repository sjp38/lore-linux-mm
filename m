Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5F3306B016B
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 18:50:39 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p7CMoYV8028458
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 15:50:35 -0700
Received: from yib18 (yib18.prod.google.com [10.243.65.82])
	by wpaz37.hot.corp.google.com with ESMTP id p7CMoCMY032740
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 15:50:34 -0700
Received: by yib18 with SMTP id 18so2938318yib.23
        for <linux-mm@kvack.org>; Fri, 12 Aug 2011 15:50:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110812153616.GH7959@redhat.com>
References: <1312492042-13184-1-git-send-email-walken@google.com>
	<CANN689HpuQ3bAW946c4OeoLLAUXHd6nzp+NVxkrFgZo7k3k0Kg@mail.gmail.com>
	<20110807142532.GC1823@barrios-desktop>
	<CANN689Edai1k4nmyTHZ_2EwWuTXdfmah-JiyibEBvSudcWhv+g@mail.gmail.com>
	<20110812153616.GH7959@redhat.com>
Date: Fri, 12 Aug 2011 15:50:33 -0700
Message-ID: <CANN689HrJPx233U3Z2oYRS9Gj3AQeFsyzkutGUFkOQCWrQ0NRw@mail.gmail.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Fri, Aug 12, 2011 at 8:36 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> On Tue, Aug 09, 2011 at 04:04:21AM -0700, Michel Lespinasse wrote:
>> - Use my proposed page count lock in order to avoid the race. One
>> would have to convert all get_page_unless_zero() sites to use it. I
>> expect the cost would be low but still measurable.
>
> I didn't yet focus at your problem after we talked about it at MM
> summit, but I seem to recall I suggested there to just get to the head
> page and always take the lock on it. split_huge_page only works at 2M
> aligned pages, the rest you don't care about. Getting to the head page
> compound_lock should be always safe. And that will still scale
> incredibly better than taking the lru_lock for the whole zone (which
> would also work). And it seems the best way to stop split_huge_page
> without having to alter the put_page fast path when it works on head
> pages (the only thing that gets into put_page complex slow path is the
> release of tail pages after get_user_pages* so it'd be nice if
> put_page fast path still didn't need to take locks).

We did talk about it. At some point I thought it might work :)

The problem case there is this. Say the page I want to
get_page_unless_zero is a single page, and the page at the prior 2M
aligned boundary is currently free. I can't rely on the desired page
not getting reallocated, because I don't have a reference on it yet.
But I can't make things safe by taking a reference and/or the compound
lock on the aligned page either, because its refcount currently is
zero.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
