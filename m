Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 43C8F6B0169
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 17:51:28 -0400 (EDT)
Date: Fri, 19 Aug 2011 14:51:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/1] hugepages: Fix race between hugetlbfs umount and
 quota update.
Message-Id: <20110819145109.dcd5dac6.akpm@linux-foundation.org>
In-Reply-To: <4E4EB603.8090305@cray.com>
References: <4E4EB603.8090305@cray.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Barry <abarry@cray.com>
Cc: linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, David Gibson <david@gibson.dropbear.id.au>, Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Hastings <abh@cray.com>

On Fri, 19 Aug 2011 14:14:11 -0500
Andrew Barry <abarry@cray.com> wrote:

> This patch fixes a use-after-free problem in free_huge_page, with a quota update
> happening after hugetlbfs umount. The problem results when a device driver,
> which has mapped a hugepage, does a put_page. Put_page, calls free_huge_page,
> which does a hugetlb_put_quota. As written, hugetlb_put_quota takes an
> address_space struct pointer "mapping" as an argument. If the put_page occurs
> after the hugetlbfs filesystem is unmounted, mapping points to freed memory.

OK.  This sounds screwed up.  If a device driver is currently using a
page from a hugetlbfs file then the unmount shouldn't have succeeded in
the first place!

Or is it the case that the device driver got a reference to the page by
other means, bypassing hugetlbfs?  And there's undesirable/incorrect
interaction between the non-hugetlbfs operation and hugetlbfs?

Or something else?

<starts reading the mailing list>

OK, important missing information from the above is that the driver got
at this page via get_user_pages() and happened to stumble across a
hugetlbfs page.  So it's indeed an incorrect interaction between a
non-hugetlbfs operation and hugetlbfs.

What's different about hugetlbfs?  Why don't other filesystems hit this?

<investigates further>

OK so the incorrect interaction happened in free_huge_page(), which is
called via the compound page destructor (this dtor is "what's different
about hugetlbfs").   What is incorrect about this is

a) that we're doing fs operations in response to a
   get_user_pages()/put_page() operation which has *nothing* to do with
   filesystems!

b) that we continue to try to do that fs operation against an fs
   which was unmounted and freed three days ago. duh.


So I hereby pronounce that

a) It was wrong to manipulate hugetlbfs quotas within
   free_huge_page().  Because free_huge_page() is a low-level
   page-management function which shouldn't know about one of its
   specific clients (in this case, hugetlbfs).

   In fact it's wrong for there to be *any* mention of hugetlbfs
   within hugetlb.c.

b) I shouldn't have merged that hugetlbfs quota code.  whodidthat. 
   Mel, Adam, Dave, at least...

c) The proper fix here is to get that hugetlbfs quota code out of
   free_huge_page() and do it all where it belongs: within hugetlbfs
   code.


Regular filesystems don't need to diddle quota counts within
page_cache_release().  Why should hugetlbfs need to?

>
> ...
>
> +		/*Free only if used quota is zero. */

Missing a space there.

> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -142,11 +142,16 @@ struct hugetlbfs_config {
>  	struct hstate *hstate;
>  };
> 
> +#define HPAGE_INACTIVE  0
> +#define HPAGE_ACTIVE    1

The above need documenting, please.  That documentation would perhaps
help me understand why we need both an "active" flag *and* a refcount.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
