Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5AFDF6B0031
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 14:41:58 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so8632861pad.35
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 11:41:58 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id u6si9653259paa.462.2014.03.31.11.41.57
        for <linux-mm@kvack.org>;
        Mon, 31 Mar 2014 11:41:57 -0700 (PDT)
Message-ID: <5339B6F4.9000809@intel.com>
Date: Mon, 31 Mar 2014 11:41:56 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 00/14] mm, hugetlb: remove a hugetlb_instantiation_mutex
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>	 <5339977F.4070905@intel.com> <1396286773.2507.11.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1396286773.2507.11.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On 03/31/2014 10:26 AM, Davidlohr Bueso wrote:
> On Mon, 2014-03-31 at 09:27 -0700, Dave Hansen wrote:
>> On 12/17/2013 10:53 PM, Joonsoo Kim wrote:
>>> * NOTE for v3
>>> - Updating patchset is so late because of other works, not issue from
>>> this patchset.
>>
>> I've got some folks with a couple TB of RAM seeing long startup times
>> with $LARGE_DATABASE_PRODUCT.  It looks to be contention on
>> hugetlb_instantiation_mutex because everyone is trying to zero hugepages
>> under that lock in parallel.  Just removing the lock sped things up
>> quite a bit.
> 
> Welcome to my world. Regarding the instantiation mutex, it is addressed,
> see commit c999c05ff595 in -next. 

Cool stuff.  That does seem to fix my parallel-fault hugetlbfs
microbenchmark.  I'll recommend that the $DATABASE folks check it as well.

> As for the clear page overhead, I brought this up in lsfmm last week,
> proposing some daemon to clear pages when we have idle cpu... but didn't
> get much positive feedback. Basically (i) not worth the additional
> complexity and (ii) can trigger different application startup times,
> which seems to be something negative. I do have a patch that implements
> huge_clear_page with non-temporal hinting but I didn't see much
> difference on my environment, would you want to give it a try?

I'd just be happy to see it happen outside of the locks.  As it stands
now, I have 1 CPU zeroing a huge page, and 159 sitting there sleeping
waiting for it to release the hugetlb_instantiation_mutex.  That's just
nonsense.  I don't think making them non-temporal will fundamentally
help that.  We need them parallelized.  According to ftrace, a
hugetlb_fault() takes ~700us.  Literally 99% of that is zeroing the page.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
