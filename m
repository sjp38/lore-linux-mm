Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id l6DL9r3J029350
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 14:09:53 -0700
Received: from an-out-0708.google.com (ancc31.prod.google.com [10.100.29.31])
	by zps38.corp.google.com with ESMTP id l6DL9iiX009070
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 14:09:45 -0700
Received: by an-out-0708.google.com with SMTP id c31so138719anc
        for <linux-mm@kvack.org>; Fri, 13 Jul 2007 14:09:44 -0700 (PDT)
Message-ID: <b040c32a0707131409q26a1c937ka22b7bdd860ea2ff@mail.gmail.com>
Date: Fri, 13 Jul 2007 14:09:44 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [PATCH 5/5] [hugetlb] Try to grow pool for MAP_SHARED mappings
In-Reply-To: <20070713130508.6f5b9bbb.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070713151621.17750.58171.stgit@kernel>
	 <20070713151717.17750.44865.stgit@kernel>
	 <20070713130508.6f5b9bbb.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, mel@skynet.ie, apw@shadowen.org, wli@holomorphy.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On 7/13/07, Paul Jackson <pj@sgi.com> wrote:
> But the cpuset behaviour of this hugetlb stuff looks suspicious to me:
>  1) The code in alloc_fresh_huge_page() seems to round robin over
>     the entire system, spreading the hugetlb pages uniformly on all nodes.
>     If one a task in one small cpuset starts aggressively allocating hugetlb
>     pages, do you think this will work,

alloc_fresh_huge_page() is used to fill up the hugetlb page pool.  It
is called through sysctl path.  The path that dish out page out of the
pool and allocate to task is alloc_huge_page(), which should obey both
mempolicy and cpuset constrain.


>  2) I don't see what keeps us from picking hugetlb pages off -any- node in the
>     system, perhaps way outside the current cpuset.

I think it is checked in dequeue_huge_page():

                if (cpuset_zone_allowed_softwall(*z, GFP_HIGHUSER) &&
                    !list_empty(&hugepage_freelists[nid]))
                        break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
