Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 1C00B6B007E
	for <linux-mm@kvack.org>; Sun,  1 Apr 2012 12:51:52 -0400 (EDT)
Message-ID: <4F7887A5.3060700@tilera.com>
Date: Sun, 1 Apr 2012 12:51:49 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] hugetlb: fix race condition in hugetlb_fault()
References: <201203302018.q2UKIFH5020745@farm-0012.internal.tilera.com> <CAJd=RBCoLNB+iRX1shKGAwSbE8PsZXyk9e3inPTREcm2kk3nXA@mail.gmail.com> <201203311339.q2VDdJMD006254@farm-0012.internal.tilera.com> <CAJd=RBBWx7uZcw=_oA06RVunPAGeFcJ7LY=RwFCyB_BreJb_kg@mail.gmail.com>
In-Reply-To: <CAJd=RBBWx7uZcw=_oA06RVunPAGeFcJ7LY=RwFCyB_BreJb_kg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>

On 4/1/2012 8:10 AM, Hillf Danton wrote:
> On Sat, Mar 31, 2012 at 4:07 AM, Chris Metcalf <cmetcalf@tilera.com> wrote:
>> The race is as follows.  Suppose a multi-threaded task forks a new
>> process, thus bumping up the ref count on all the pages.  While the fork
>> is occurring (and thus we have marked all the PTEs as read-only), another
>> thread in the original process tries to write to a huge page, taking an
>> access violation from the write-protect and calling hugetlb_cow().  Now,
>> suppose the fork() fails.  It will undo the COW and decrement the ref
>> count on the pages, so the ref count on the huge page drops back to 1.
>> Meanwhile hugetlb_cow() also decrements the ref count by one on the
>> original page, since the original address space doesn't need it any more,
>> having copied a new page to replace the original page.  This leaves the
>> ref count at zero, and when we call unlock_page(), we panic.
>>
>> The solution is to take an extra reference to the page while we are
>> holding the lock on it.
>>
> If the following chart matches the above description,
>
> [...]
>
> would you please spin with description refreshed?

Done, and thanks!  I added your timeline chart to my description; I figure
no harm in having it both ways.

>> Cc: stable@kernel.org
> Let Andrew do the stable work, ok?

Fair point.  I'm used to adding the Cc myself for things I push through the
arch/tile tree.  This of course does make more sense to go through Andrew,
so I'll remove it.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
