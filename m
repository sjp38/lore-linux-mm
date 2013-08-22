Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 3D2CD6B0036
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 07:05:47 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 23 Aug 2013 07:59:00 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 2710C2CE8052
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 21:04:40 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7MAmQfD45744186
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 20:48:32 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7MB4Wlu027533
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 21:04:33 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 12/20] mm, hugetlb: remove vma_has_reserves()
In-Reply-To: <20130822091747.GA22605@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com> <1376040398-11212-13-git-send-email-iamjoonsoo.kim@lge.com> <87siy215e1.fsf@linux.vnet.ibm.com> <20130822091747.GA22605@lge.com>
Date: Thu, 22 Aug 2013 16:34:22 +0530
Message-ID: <87mwoa0yx5.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> On Thu, Aug 22, 2013 at 02:14:38PM +0530, Aneesh Kumar K.V wrote:
>> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
>> 
>> > vma_has_reserves() can be substituted by using return value of
>> > vma_needs_reservation(). If chg returned by vma_needs_reservation()
>> > is 0, it means that vma has reserves. Otherwise, it means that vma don't
>> > have reserves and need a hugepage outside of reserve pool. This definition
>> > is perfectly same as vma_has_reserves(), so remove vma_has_reserves().
>> >
>> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> 
>> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>
> Thanks.
>
>> > @@ -580,8 +547,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>> >  	 * have no page reserves. This check ensures that reservations are
>> >  	 * not "stolen". The child may still get SIGKILLed
>> >  	 */
>> > -	if (!vma_has_reserves(vma, chg) &&
>> > -			h->free_huge_pages - h->resv_huge_pages == 0)
>> > +	if (chg && h->free_huge_pages - h->resv_huge_pages == 0)
>> >  		return NULL;
>> >
>> >  	/* If reserves cannot be used, ensure enough pages are in the pool */
>> > @@ -600,7 +566,7 @@ retry_cpuset:
>> >  			if (page) {
>> >  				if (avoid_reserve)
>> >  					break;
>> > -				if (!vma_has_reserves(vma, chg))
>> > +				if (chg)
>> >  					break;
>> >
>> >  				SetPagePrivate(page);
>> 
>> Can you add a comment above both the place to explain why checking chg
>> is good enough ?
>
> Yes, I can. But it will be changed to use_reserve in patch 13 and it
> represent it's meaning perfectly. So commeting may be useless.

That should be ok, because having a comment in this patch helps in
understanding the patch better, even though you are removing that
later. 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
