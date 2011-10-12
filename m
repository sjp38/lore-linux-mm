Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 48A336B0033
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 00:43:40 -0400 (EDT)
Date: Wed, 12 Oct 2011 15:43:17 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH v2 1/1] hugepages: Fix race between hugetlbfs umount and
 quota update.
Message-ID: <20111012044317.GA31436@drongo>
References: <4E4EB603.8090305@cray.com>
 <20110819145109.dcd5dac6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110819145109.dcd5dac6.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrew Barry <abarry@cray.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, David Gibson <david@gibson.dropbear.id.au>, Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Hastings <abh@cray.com>

On Fri, Aug 19, 2011 at 02:51:09PM -0700, Andrew Morton wrote:
> 
> OK.  This sounds screwed up.  If a device driver is currently using a
> page from a hugetlbfs file then the unmount shouldn't have succeeded in
> the first place!
> 
> Or is it the case that the device driver got a reference to the page by
> other means, bypassing hugetlbfs?  And there's undesirable/incorrect
> interaction between the non-hugetlbfs operation and hugetlbfs?
> 
> Or something else?
> 
> <starts reading the mailing list>
> 
> OK, important missing information from the above is that the driver got
> at this page via get_user_pages() and happened to stumble across a
> hugetlbfs page.  So it's indeed an incorrect interaction between a
> non-hugetlbfs operation and hugetlbfs.
> 
> What's different about hugetlbfs?  Why don't other filesystems hit this?

What's different about hugetlbfs, as I understand it, is that the
"quota" mechanism is there to restrict memory usage, rather than disk
usage.

> <investigates further>
> 
> OK so the incorrect interaction happened in free_huge_page(), which is
> called via the compound page destructor (this dtor is "what's different
> about hugetlbfs").   What is incorrect about this is
> 
> a) that we're doing fs operations in response to a
>    get_user_pages()/put_page() operation which has *nothing* to do with
>    filesystems!

The hugetlbfs quota thing is more like an RSS limit than a disk
quota.  Perhaps the "quota" name is misleading.

I assume we update RSS counts for ordinary pages when allocating and
freeing pages?

> b) that we continue to try to do that fs operation against an fs
>    which was unmounted and freed three days ago. duh.
> 
> 
> So I hereby pronounce that
> 
> a) It was wrong to manipulate hugetlbfs quotas within
>    free_huge_page().  Because free_huge_page() is a low-level
>    page-management function which shouldn't know about one of its
>    specific clients (in this case, hugetlbfs).
> 
>    In fact it's wrong for there to be *any* mention of hugetlbfs
>    within hugetlb.c.
> 
> b) I shouldn't have merged that hugetlbfs quota code.  whodidthat. 
>    Mel, Adam, Dave, at least...
> 
> c) The proper fix here is to get that hugetlbfs quota code out of
>    free_huge_page() and do it all where it belongs: within hugetlbfs
>    code.

That doesn't sound right to me, if we need to limit usage of huge
memory pages in memory, rather than back out on the "filesystem".
An ordinary filesystem doesn't worry about memory consumption, it
worries about how its blocks of backing store are allocated.
Hugetlbfs is unusual here in that the "backing store" and the memory
pages that get mapped into userspace are one and the same thing.

> Regular filesystems don't need to diddle quota counts within
> page_cache_release().  Why should hugetlbfs need to?

In a regular filesystem you can reclaim a block of backing store, and
thus decrement a quota count, while there might still be a page of
memory in use that contains its old contents.  That's problematic with
hugetlbfs.

In the meantime we have a user-triggerable kernel crash.  As far as I
can see, if we did what you suggest, we would end up with a situation
where we could run out of huge pages even though everyone was within
quota.  Which is arguably better than a kernel crash, but still less
than ideal.  What do you suggest?

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
