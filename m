Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id F18096B0033
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 09:01:48 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 26 Aug 2013 18:25:09 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id F1E491258059
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 18:31:28 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7QD1ZYQ20709536
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 18:31:36 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7QD1b05011266
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 18:31:38 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 03/20] mm, hugetlb: fix subpool accounting handling
In-Reply-To: <20130822074752.GH13415@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com> <1376040398-11212-4-git-send-email-iamjoonsoo.kim@lge.com> <87vc2zgzpn.fsf@linux.vnet.ibm.com> <20130822065038.GA13415@lge.com> <87y57u19ur.fsf@linux.vnet.ibm.com> <20130822074752.GH13415@lge.com>
Date: Mon, 26 Aug 2013 18:31:35 +0530
Message-ID: <871u5gehcg.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> On Thu, Aug 22, 2013 at 12:38:12PM +0530, Aneesh Kumar K.V wrote:
>> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
>> 
>> > Hello, Aneesh.
>> >
>> > First of all, thank you for review!
>> >
>> > On Wed, Aug 21, 2013 at 02:58:20PM +0530, Aneesh Kumar K.V wrote:
>> >> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
>> >> 
>> >> > If we alloc hugepage with avoid_reserve, we don't dequeue reserved one.
>> >> > So, we should check subpool counter when avoid_reserve.
>> >> > This patch implement it.
>> >> 
>> >> Can you explain this better ? ie, if we don't have a reservation in the
>> >> area chg != 0. So why look at avoid_reserve. 
>> >
>> > We don't consider avoid_reserve when chg != 0.
>> > Look at following code.
>> >
>> > +       if (chg || avoid_reserve)
>> > +               if (hugepage_subpool_get_pages(spool, 1))
>> >
>> > It means that if chg != 0, we skip to check avoid_reserve.
>> 
>> when whould be avoid_reserve == 1 and chg == 0 ?
>
> In this case, we should do hugepage_subpool_get_pages(), since we don't
> get a reserved page due to avoid_reserve.

As per off-list discussion we had around this, please add additional
information in commit message explaining when we have
avoid_reserve == 1 and chg == 0

Something like the below copied from call site.

	 /* If the process that created a MAP_PRIVATE mapping is about to
	  * perform a COW due to a shared page count, attempt to satisfy
	  * the allocation without using the existing reserves
          */

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
