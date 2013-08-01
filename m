Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id A354A6B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 12:17:42 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 1 Aug 2013 21:42:12 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id BAFA1E0055
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 21:47:45 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r71GIciI28966960
	for <linux-mm@kvack.org>; Thu, 1 Aug 2013 21:48:39 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r71GHW0d004628
	for <linux-mm@kvack.org>; Thu, 1 Aug 2013 16:17:33 GMT
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 01/18] mm, hugetlb: protect reserved pages when softofflining requests the pages
In-Reply-To: <CAJd=RBCj_wAHjv10FhhX+Fzx8p4ybeGykEfvqF=jZaok3s+j9w@mail.gmail.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com> <1375075929-6119-2-git-send-email-iamjoonsoo.kim@lge.com> <CAJd=RBCUJg5GJEQ2_heCt8S9LZzedGLbvYvivFkmvfMChPqaCg@mail.gmail.com> <20130731022751.GA2548@lge.com> <CAJd=RBD=SNm9TG-kxKcd-BiMduOhLUubq=JpRwCy_MmiDtO9Tw@mail.gmail.com> <20130731044101.GE2548@lge.com> <CAJd=RBDr72T+O+aNdb-HyB3U+k5JiVWMoXfPNA0y-Hxw-wDD-g@mail.gmail.com> <20130731063740.GA4212@lge.com> <CAJd=RBCj_wAHjv10FhhX+Fzx8p4ybeGykEfvqF=jZaok3s+j9w@mail.gmail.com>
Date: Thu, 01 Aug 2013 21:47:31 +0530
Message-ID: <87siytwfl0.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Hillf Danton <dhillf@gmail.com> writes:

> On Wed, Jul 31, 2013 at 2:37 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>> On Wed, Jul 31, 2013 at 02:21:38PM +0800, Hillf Danton wrote:
>>> On Wed, Jul 31, 2013 at 12:41 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>>> > On Wed, Jul 31, 2013 at 10:49:24AM +0800, Hillf Danton wrote:
>>> >> On Wed, Jul 31, 2013 at 10:27 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>>> >> > On Mon, Jul 29, 2013 at 03:24:46PM +0800, Hillf Danton wrote:
>>> >> >> On Mon, Jul 29, 2013 at 1:31 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>>> >> >> > alloc_huge_page_node() use dequeue_huge_page_node() without
>>> >> >> > any validation check, so it can steal reserved page unconditionally.
>>> >> >>
>>> >> >> Well, why is it illegal to use reserved page here?
>>> >> >
>>> >> > If we use reserved page here, other processes which are promised to use
>>> >> > enough hugepages cannot get enough hugepages and can die. This is
>>> >> > unexpected result to them.
>>> >> >
>>> >> But, how do you determine that a huge page is requested by a process
>>> >> that is not allowed to use reserved pages?
>>> >
>>> > Reserved page is just one for each address or file offset. If we need to
>>> > move this page, this means that it already use it's own reserved page, this
>>> > page is it. So we should not use other reserved page for moving this page.
>>> >
>>> Hm, how do you determine "this page" is not buddy?
>>
>> If this page comes from the buddy, it doesn't matter. It imply that
>> this mapping cannot use reserved page pool, because we always allocate
>> a page from reserved page pool first.
>>
> A buddy page also implies, if the mapping can use reserved pages, that no
> reserved page was available when requested. Now we can try reserved
> page again.

I didn't quiet get that. My understanding is, the new page we are
allocating here for soft offline should not be allocated from the
reserve pool. If we do that we may possibly have allocation failure
later for a request that had done page reservation. Now to
avoid that we make sure we have enough free pages outside reserve pool
so that we can dequeue the huge page. If not we use buddy to allocate
the hugepage.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
