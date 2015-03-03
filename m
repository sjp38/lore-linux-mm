Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6DED66B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 20:19:21 -0500 (EST)
Received: by mail-oi0-f45.google.com with SMTP id i138so30488108oig.4
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 17:19:21 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id zv11si1748118obb.39.2015.03.02.17.19.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 17:19:20 -0800 (PST)
Message-ID: <54F50BD6.1030706@oracle.com>
Date: Mon, 02 Mar 2015 17:18:14 -0800
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/3] hugetlbfs: optionally reserve all fs pages at mount
 time
References: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com> <20150302151009.2ae58f4430f9f34b81533821@linux-foundation.org>
In-Reply-To: <20150302151009.2ae58f4430f9f34b81533821@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 03/02/2015 03:10 PM, Andrew Morton wrote:
> On Fri, 27 Feb 2015 14:58:08 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
>
>> hugetlbfs allocates huge pages from the global pool as needed.  Even if
>> the global pool contains a sufficient number pages for the filesystem
>> size at mount time, those global pages could be grabbed for some other
>> use.  As a result, filesystem huge page allocations may fail due to lack
>> of pages.
>
> Well OK, but why is this a sufficiently serious problem to justify
> kernel changes?  Please provide enough info for others to be able
> to understand the value of the change.
>

Thanks for taking a look.

Applications such as a database want to use huge pages for performance
reasons.  hugetlbfs filesystem semantics with ownership and modes work
well to manage access to a pool of huge pages.  However, the application
would like some reasonable assurance that allocations will not fail due
to a lack of huge pages.  Before starting, the application will ensure
that enough huge pages exist on the system in the global pools.  What
the application wants is exclusive use of a pool of huge pages.

One could argue that this is a system administration issue.  The global
huge page pools are only available to users with root privilege.
Therefore,  exclusive use of a pool of huge pages can be obtained by
limiting access.  However, many applications are installed to run with
elevated privilege to take advantage of resources like huge pages.  It
is quite possible for one application to interfere another, especially
in the case of something like huge pages where the pool size is mostly
fixed.

Suggestions for other ways to approach this situation are appreciated.
I saw the existing support for "reservations" within hugetlbfs and
thought of extending this to cover the size of the filesystem.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
