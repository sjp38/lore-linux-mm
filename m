Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id EA4976B006E
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 01:42:21 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id p10so4663534pdj.39
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 22:42:21 -0800 (PST)
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com. [202.81.31.141])
        by mx.google.com with ESMTPS id ru9si6426064pab.173.2014.11.20.22.42.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 22:42:20 -0800 (PST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 21 Nov 2014 16:42:13 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id E39622BB0065
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 17:42:11 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sAL6hwAm37683264
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 17:44:03 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sAL6g5HZ021260
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 17:42:06 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 06/19] mm: store mapcount for compound page separate
In-Reply-To: <20141118095811.GA21774@node.dhcp.inet.fi>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com> <1415198994-15252-7-git-send-email-kirill.shutemov@linux.intel.com> <20141118084337.GA16714@hori1.linux.bs1.fc.nec.co.jp> <20141118095811.GA21774@node.dhcp.inet.fi>
Date: Fri, 21 Nov 2014 12:11:34 +0530
Message-ID: <87egsx6oo1.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Tue, Nov 18, 2014 at 08:43:00AM +0000, Naoya Horiguchi wrote:
>> > @@ -1837,6 +1839,9 @@ static void __split_huge_page_refcount(struct page *page,
>> >  	atomic_sub(tail_count, &page->_count);
>> >  	BUG_ON(atomic_read(&page->_count) <= 0);
>> >  
>> > +	page->_mapcount = *compound_mapcount_ptr(page);
>> 
>> Is atomic_set() necessary?
>
> Do you mean
> 	atomic_set(&page->_mapcount, atomic_read(compound_mapcount_ptr(page)));
> ?
>
> I don't see why we would need this. Simple assignment should work just
> fine. Or we have archs which will break?

Are you looking at architecture related atomic_set issues, or the fact
that we cannot have parallel _mapcount update and hence the above
assignment should be ok ? If the former, current thp code
use atomic_add instead of even using atomic_set when
updatinge page_tail->_count.  

		 * from under us on the tail_page. If we used
		 * atomic_set() below instead of atomic_add(), we
		 * would then run atomic_set() concurrently with
		 * get_page_unless_zero(), and atomic_set() is
		 * implemented in C not using locked ops. spin_unlock
		 * on x86 sometime uses locked ops because of PPro
		 * errata 66, 92, so unless somebody can guarantee
		 * atomic_set() here would be safe on all archs (and
		 * not only on x86), it's safer to use atomic_add().
		 */
		atomic_add(page_mapcount(page) + page_mapcount(page_tail) + 1,
			   &page_tail->_count);



-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
