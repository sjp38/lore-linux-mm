Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 740906B016A
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 16:08:14 -0400 (EDT)
Message-ID: <4E52B71A.9030108@cray.com>
Date: Mon, 22 Aug 2011 15:07:54 -0500
From: Andrew Barry <abarry@cray.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/1] hugepages: Fix race between hugetlbfs umount and
 quota update.
References: <4E4EB603.8090305@cray.com> <20110819145109.dcd5dac6.akpm@linux-foundation.org>
In-Reply-To: <20110819145109.dcd5dac6.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, David Gibson <david@gibson.dropbear.id.au>, Hugh Dickins <hughd@google.com>, Andrew Hastings <abh@cray.com>

On 08/19/2011 04:51 PM, Andrew Morton wrote:
> What's different about hugetlbfs?  Why don't other filesystems hit this?
> 
> <investigates further>
> 
> OK so the incorrect interaction happened in free_huge_page(), which is
> called via the compound page destructor (this dtor is "what's different
> about hugetlbfs").   What is incorrect about this is
> 
> a) that we're doing fs operations in response to a
>    get_user_pages()/put_page() operation which has *nothing* to do with
>    filesystems!
> 
> b) that we continue to try to do that fs operation against an fs
>    which was unmounted and freed three days ago. duh.

Yes.

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
> 
> 
> Regular filesystems don't need to diddle quota counts within
> page_cache_release().  Why should hugetlbfs need to?

Is there anyone, more expert in hugetlbfs code than I, who can/should/will take
that on?


>> +#define HPAGE_INACTIVE  0
>> +#define HPAGE_ACTIVE    1
> 
> The above need documenting, please.  That documentation would perhaps
> help me understand why we need both an "active" flag *and* a refcount.

It doesn't need both. Now that you mention it, it would be simpler to put it all
in the refcount. I'd send an updated patch, but it sounds like things will be
going in a different direction.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
