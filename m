Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C08A56B02BF
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 14:11:48 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id q45so13615544qtq.21
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 11:11:48 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id m22si11199941qtc.44.2017.11.22.11.11.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 11:11:47 -0800 (PST)
Subject: Re: hugetlb page migration vs. overcommit
References: <20171122152832.iayefrlxbugphorp@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <91969714-5256-e96f-a48b-43af756a2686@oracle.com>
Date: Wed, 22 Nov 2017 11:11:38 -0800
MIME-Version: 1.0
In-Reply-To: <20171122152832.iayefrlxbugphorp@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

On 11/22/2017 07:28 AM, Michal Hocko wrote:
> Hi,
> is there any reason why we enforce the overcommit limit during hugetlb
> pages migration? It's in alloc_huge_page_node->__alloc_buddy_huge_page
> path. I am wondering whether this is really an intentional behavior.

I do not think it was intentional.  But, I was not around when that
code was added.

> The page migration allocates a page just temporarily so we should be
> able to go over the overcommit limit for the migration duration. The
> reason I am asking is that hugetlb pages tend to be utilized usually
> (otherwise the memory would be just wasted and pool shrunk) but then
> the migration simply fails which breaks memory hotplug and other
> migration dependent functionality which is quite suboptimal. You can
> workaround that by increasing the overcommit limit.

Yes.  In an environment making optimal use of huge pages, you are unlikely
to have 'spare pages' set aside for a potential migration operation.  So
I agree that it would make sense to try and allocate overcommit pages for
this purpose.

> Why don't we simply migrate as long as we are able to allocate the
> target hugetlb page? I have a half baked patch to remove this
> restriction, would there be an opposition to do something like that?

I would not be opposed and would help with this effort.  My concern would
be any subtle hugetlb accounting issues once you start messing with
additional overcommit pages.

Since Naoya was originally involved in huge page migration, I would welcome
his comments.
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
