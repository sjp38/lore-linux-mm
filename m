Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id F379D6B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 04:34:57 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so131636pac.1
        for <linux-mm@kvack.org>; Tue, 12 May 2015 01:34:57 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id b1si15395767pat.100.2015.05.12.01.34.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 01:34:56 -0700 (PDT)
Date: Tue, 12 May 2015 11:34:38 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [RFC] rmap: fix "race" between do_wp_page and shrink_active_list
Message-ID: <20150512083438.GB17628@esperanza>
References: <1431330677-24476-1-git-send-email-vdavydov@parallels.com>
 <CAFP4FLoPfisZib3SQeeW57U6NPxnpd=rNRgiv9OOsYDrFWd=6A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAFP4FLoPfisZib3SQeeW57U6NPxnpd=rNRgiv9OOsYDrFWd=6A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 11, 2015 at 04:59:27PM +0800, yalin wang wrote:
> i am confused about your analysis ,
> for the race stack:
> 
> CPU0                          CPU1
> 
>    ----                          ----
> 
>    do_wp_page                    shrink_active_list
> 
>     lock_page                     page_referenced
> 
>                                    PageAnon->yes, so skip trylock_page
> 
>     page_move_anon_rmap
> 
>      page->mapping = anon_vma
> 
>                                    rmap_walk
> 
>                                     PageAnon->no
> 
>                                     rmap_walk_file
> 
>                                      BUG
> 
>      page->mapping += PAGE_MAPPING_ANON
> 
> the page should must change from PageAnon() to !PageAnon() when crash happened.
> but page_move_anon_rmap() is doing change a page from !PageAnon()
> (swapcache page) to PageAnon() ,

A swapcache page is not necessarily !PageAnon. In do_wp_page() old_page
*is* PageAnon. It may or may not be on the swapcache though, which does
not really matter.

> how does this race condition crash happened ?

It never happened. It might theoretically happen due to a compiler
"optimization" I described above.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
