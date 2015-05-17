Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id B25DF6B0080
	for <linux-mm@kvack.org>; Sun, 17 May 2015 08:48:22 -0400 (EDT)
Received: by pdfh10 with SMTP id h10so105806820pdf.3
        for <linux-mm@kvack.org>; Sun, 17 May 2015 05:48:22 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id oj11si11352547pab.88.2015.05.17.05.48.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 May 2015 05:48:21 -0700 (PDT)
Received: by pablj1 with SMTP id lj1so1240790pab.3
        for <linux-mm@kvack.org>; Sun, 17 May 2015 05:48:21 -0700 (PDT)
Message-ID: <55588D1C.5060900@gmail.com>
Date: Sun, 17 May 2015 20:44:12 +0800
From: yalin <yalin.wang2010@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC] rmap: fix "race" between do_wp_page and shrink_active_list
References: <1431330677-24476-1-git-send-email-vdavydov@parallels.com> <CAFP4FLoPfisZib3SQeeW57U6NPxnpd=rNRgiv9OOsYDrFWd=6A@mail.gmail.com> <20150512083438.GB17628@esperanza>
In-Reply-To: <20150512083438.GB17628@esperanza>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> On Mon, May 11, 2015 at 04:59:27PM +0800, yalin wang wrote:
>> i am confused about your analysis ,
>> for the race stack:
>>
>> CPU0                          CPU1
>>
>>     ----                          ----
>>
>>     do_wp_page                    shrink_active_list
>>
>>      lock_page                     page_referenced
>>
>>                                     PageAnon->yes, so skip trylock_page
>>
>>      page_move_anon_rmap
>>
>>       page->mapping = anon_vma
>>
>>                                     rmap_walk
>>
>>                                      PageAnon->no
>>
>>                                      rmap_walk_file
>>
>>                                       BUG
>>
>>       page->mapping += PAGE_MAPPING_ANON
>>
>> the page should must change from PageAnon() to !PageAnon() when crash happened.
>> but page_move_anon_rmap() is doing change a page from !PageAnon()
>> (swapcache page) to PageAnon() ,
> A swapcache page is not necessarily !PageAnon. In do_wp_page() old_page
> *is* PageAnon. It may or may not be on the swapcache though, which does
> not really matter.
>
>> how does this race condition crash happened ?
> It never happened. It might theoretically happen due to a compiler
> "optimization" I described above.
i see,
Thanks for your explanation!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
