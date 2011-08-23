Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5FFFE6B016A
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 00:10:37 -0400 (EDT)
Date: Tue, 23 Aug 2011 14:10:20 +1000
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH v2 1/1] hugepages: Fix race between hugetlbfs umount and
 quota update.
Message-ID: <20110823041020.GQ30097@yookeroo.fritz.box>
References: <4E4EB603.8090305@cray.com>
 <20110819145109.dcd5dac6.akpm@linux-foundation.org>
 <4E52B71A.9030108@cray.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E52B71A.9030108@cray.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Barry <abarry@cray.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Andrew Hastings <abh@cray.com>

On Mon, Aug 22, 2011 at 03:07:54PM -0500, Andrew Barry wrote:
> On 08/19/2011 04:51 PM, Andrew Morton wrote:
> > What's different about hugetlbfs?  Why don't other filesystems hit this?
> > 
> > <investigates further>
> > 
> > OK so the incorrect interaction happened in free_huge_page(), which is
> > called via the compound page destructor (this dtor is "what's different
> > about hugetlbfs").   What is incorrect about this is
> > 
> > a) that we're doing fs operations in response to a
> >    get_user_pages()/put_page() operation which has *nothing* to do with
> >    filesystems!
> > 
> > b) that we continue to try to do that fs operation against an fs
> >    which was unmounted and freed three days ago. duh.
> 
> Yes.
> 
> > So I hereby pronounce that
> > 
> > a) It was wrong to manipulate hugetlbfs quotas within
> >    free_huge_page().  Because free_huge_page() is a low-level
> >    page-management function which shouldn't know about one of its
> >    specific clients (in this case, hugetlbfs).
> > 
> >    In fact it's wrong for there to be *any* mention of hugetlbfs
> >    within hugetlb.c.
> > 
> > b) I shouldn't have merged that hugetlbfs quota code.  whodidthat. 
> >    Mel, Adam, Dave, at least...
> > 
> > c) The proper fix here is to get that hugetlbfs quota code out of
> >    free_huge_page() and do it all where it belongs: within hugetlbfs
> >    code.
> > 
> > 
> > Regular filesystems don't need to diddle quota counts within
> > page_cache_release().  Why should hugetlbfs need to?
> 
> Is there anyone, more expert in hugetlbfs code than I, who can/should/will take
> that on?

As far as I can tell the hugetlbfs "quota" counts that are updated
here don't share much with the normal quota mechanisms.  The way they
operate, they logically divide the pool of free huge pages between
different hugetlbfs instances.  This means that you can give different
hugepage mounts to different applications and they won't be able to
exhaust each others resources.

I can't see how that can be done without updating the count somewhere
at free_huge_page() time.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
