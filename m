Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id D96AE6B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 18:36:22 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id ey11so1644169pad.32
        for <linux-mm@kvack.org>; Thu, 15 May 2014 15:36:22 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tk2si6746316pac.24.2014.05.15.15.36.21
        for <linux-mm@kvack.org>;
        Thu, 15 May 2014 15:36:22 -0700 (PDT)
Date: Thu, 15 May 2014 15:36:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, hugetlb: move the error handle logic out of normal
 code path
Message-Id: <20140515153620.344fe054b6b8d054a28fbf82@linux-foundation.org>
In-Reply-To: <20140515090142.GB3938@dhcp22.suse.cz>
References: <1400051459-20578-1-git-send-email-nasa4836@gmail.com>
	<20140515090142.GB3938@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Jianyu Zhan <nasa4836@gmail.com>, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, steve.capper@linaro.org, davidlohr@hp.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 15 May 2014 11:01:42 +0200 Michal Hocko <mhocko@suse.cz> wrote:

> On Wed 14-05-14 15:10:59, Jianyu Zhan wrote:
> > alloc_huge_page() now mixes normal code path with error handle logic.
> > This patches move out the error handle logic, to make normal code
> > path more clean and redue code duplicate.
> 
> I don't know. Part of the function returns and cleans up on its own and
> other part relies on clean up labels. This is not so much nicer than the
> previous state.

That's actually a common pattern:

foo()
{
	if (check which doesn't change any state)
		return -Efoo;
	if (another check which doesn't change any state)
		return -Ebar;

	do_something_which_changes_state()
	
	if (another check)
		goto undo_that_state_chage;
	...

undo_that_state_change:
	...
}


This ties into the main reason why we use all these gotos: to support
evolution of the code.  With multiple return points we risk later
adding resource leaks and locking errors.  Plus the code becomes more
and more duplicative and spaghettified.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
