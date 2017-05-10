Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A95002803C7
	for <linux-mm@kvack.org>; Wed, 10 May 2017 02:50:12 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g67so5559241wrd.0
        for <linux-mm@kvack.org>; Tue, 09 May 2017 23:50:12 -0700 (PDT)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id m38si2432684wrm.206.2017.05.09.23.50.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 23:50:11 -0700 (PDT)
Date: Wed, 10 May 2017 14:50:04 +0800 (SGT)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH v2] mm: fix the memory leak after collapsing the huge
 page fails (fwd)
In-Reply-To: <951ad516-b8da-8277-d4ad-141ba3b47bec@suse.cz>
Message-ID: <alpine.DEB.2.20.1705101448580.20213@hadrien>
References: <alpine.DEB.2.20.1705092341330.3502@hadrien> <5912AB58.7020103@huawei.com> <alpine.DEB.2.20.1705101421530.20213@hadrien> <951ad516-b8da-8277-d4ad-141ba3b47bec@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Julia Lawall <julia.lawall@lip6.fr>, zhong jiang <zhongjiang@huawei.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, mgorman@techsingularity.net, linux-mm@kvack.org, kbuild-all@01.org



On Wed, 10 May 2017, Vlastimil Babka wrote:

> On 05/10/2017 08:25 AM, Julia Lawall wrote:
> >
> >
> > On Wed, 10 May 2017, zhong jiang wrote:
> >
> >> On 2017/5/9 23:43, Julia Lawall wrote:
> >>> Hello,
> >>>
> >>> I don't know if there is a bug here, but it could e worth checking on.  If
> >>> the loop on line 1481 is executed, page will not be NULL at the out label
> >>> on line 1560.  Instead it will have a dummy value.  Perhaps the value of
> >>> result keeps the if at the out label from being taken.
> >>>
> >>> julia
> >>   Hi, Julia
> >>
> >>    it has no memory leak.  so my initial thought is not correct. but I do not know you mean.
> >>    The page is local variable.  it aybe a  dummy value. but it should not cause any issue.
> >>    is it right? or I miss something.
> >
> > I had first been thinking that the if branch was referencing page.  In
> > that case, if page were a dummy value, then there could be a problem.  But
> > now I see that the branch does not refer to page.  So the question is
> > just, if the loop on lines 1481-1491 is executed, is it correct to execute
> > the code put_page(new_page)?  Or will result be SCAN_SUCCEEDED in that
> > case?
>
> That loop is under "if (result == SCAN_SUCCEED)", so yeah. It also ends
> with "*hpage = NULL;", so the put_page(hpage) in khugepaged_do_scan()
> won't apply. I see no problem besides the very non-obvious code :/

OK, thanks for the clarification.

julia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
