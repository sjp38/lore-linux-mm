Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id EA4196B003C
	for <linux-mm@kvack.org>; Fri, 16 May 2014 03:57:35 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c41so1251778eek.17
        for <linux-mm@kvack.org>; Fri, 16 May 2014 00:57:35 -0700 (PDT)
Received: from mail-ee0-x22b.google.com (mail-ee0-x22b.google.com [2a00:1450:4013:c00::22b])
        by mx.google.com with ESMTPS id n46si6035365eeo.97.2014.05.16.00.57.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 16 May 2014 00:57:34 -0700 (PDT)
Received: by mail-ee0-f43.google.com with SMTP id d17so1268931eek.2
        for <linux-mm@kvack.org>; Fri, 16 May 2014 00:57:33 -0700 (PDT)
Date: Fri, 16 May 2014 09:57:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm, hugetlb: move the error handle logic out of normal
 code path
Message-ID: <20140516075730.GA22818@dhcp22.suse.cz>
References: <1400051459-20578-1-git-send-email-nasa4836@gmail.com>
 <20140515090142.GB3938@dhcp22.suse.cz>
 <20140515153620.344fe054b6b8d054a28fbf82@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140515153620.344fe054b6b8d054a28fbf82@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jianyu Zhan <nasa4836@gmail.com>, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, steve.capper@linaro.org, davidlohr@hp.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 15-05-14 15:36:20, Andrew Morton wrote:
> On Thu, 15 May 2014 11:01:42 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Wed 14-05-14 15:10:59, Jianyu Zhan wrote:
> > > alloc_huge_page() now mixes normal code path with error handle logic.
> > > This patches move out the error handle logic, to make normal code
> > > path more clean and redue code duplicate.
> > 
> > I don't know. Part of the function returns and cleans up on its own and
> > other part relies on clean up labels. This is not so much nicer than the
> > previous state.
> 
> That's actually a common pattern:
> 
> foo()
> {
> 	if (check which doesn't change any state)
> 		return -Efoo;
> 	if (another check which doesn't change any state)
> 		return -Ebar;
> 
> 	do_something_which_changes_state()
> 	
> 	if (another check)
> 		goto undo_that_state_chage;
> 	...
> 
> undo_that_state_change:
> 	...
> }

Right. I have misread the previous vma_needs_reservation and
hugepage_subpool_get_pages error path and already considered it as a
changing state one. Sorry about the confusion.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
