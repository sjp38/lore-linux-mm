Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 728896B0005
	for <linux-mm@kvack.org>; Fri,  1 Mar 2013 21:42:55 -0500 (EST)
Received: by mail-ie0-f180.google.com with SMTP id bn7so4265684ieb.25
        for <linux-mm@kvack.org>; Fri, 01 Mar 2013 18:42:54 -0800 (PST)
Message-ID: <51316727.1040806@gmail.com>
Date: Sat, 02 Mar 2013 10:42:47 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] add extra free kbytes tunable
References: <alpine.DEB.2.02.1302111734090.13090@dflat> <A5ED84D3BB3A384992CBB9C77DEDA4D414A98EBF@USINDEM103.corp.hds.com> <511EB5CB.2060602@redhat.com> <alpine.DEB.2.02.1302171546120.10836@dflat> <20130219152936.f079c971.akpm@linux-foundation.org> <alpine.DEB.2.02.1302192100100.23162@dflat> <20130222175634.GA4824@cmpxchg.org> <51307354.5000401@gmail.com> <51307583.2020006@gmail.com> <alpine.LNX.2.00.1303011431290.9961@eggly.anvils> <5131438B.4090507@gmail.com> <alpine.LNX.2.00.1303011648330.16381@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1303011648330.16381@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Seiji Aguchi <seiji.aguchi@hds.com>, Satoru Moriya <satoru.moriya@hds.com>, Randy Dunlap <rdunlap@xenotime.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Mel Gorman <mel@csn.ul.ie>

On 03/02/2013 09:42 AM, Hugh Dickins wrote:
> On Sat, 2 Mar 2013, Simon Jeons wrote:
>> In function __add_to_swap_cache if add to radix tree successfully will result
>> in increase NR_FILE_PAGES, why? This is anonymous page instead of file backed
>> page.
> Right, that's hard to understand without historical background.
>
> I think the quick answer would be that we used to (and still do) think
> of file-cache and swap-cache as two halves of page-cache.  And then when

shmem page should be treated as file-cache or swap-cache? It is strange 
since it is consist of anonymous pages and these pages establish files.

> someone changed the way stats were gathered, they couldn't very well
> name the stat for page-cache pages NR_PAGE_PAGES, so they called it
> NR_FILE_PAGES - but it still included swap.
>
> We have tried down the years to keep the info shown in /proc/meminfo
> (for example, but it is the prime example) consistent across releases,
> while adding new lines and new distinctions.
>
> But it has often been hard to find good enough short enough names for
> those new distinctions: when 2.6.28 split the LRUs between file-backed
> and swap-backed, it used "anon" for swap-backed in /proc/meminfo.
>
> So you'll find that shmem and swap are counted as file in some places
> and anon in others, and it's hard to grasp which is where and why,
> without remembering the history.
>
> I notice that fs/proc/meminfo.c:meminfo_proc_show() subtracts
> total_swapcache_pages from the NR_FILE_PAGES count for /proc/meminfo:
> so it's undoing what you observe __add_to_swap_cache() to be doing.
>
> It's quite possible that if you went through all the users of
> NR_FILE_PAGES, you'd find it makes much more sense to leave out
> the swap-cache pages, and just add those on where needed.
>
> But you might find a few places where it's hard to decide whether
> the swap-cache pages were ever intended to be included or not, and
> hard to decide if it's safe to change those numbers now or not.
>
> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
