Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 912506B0038
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 10:10:51 -0500 (EST)
Received: by wghk14 with SMTP id k14so9959864wgh.3
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 07:10:50 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dc6si20836832wib.78.2015.03.06.07.10.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Mar 2015 07:10:48 -0800 (PST)
Date: Fri, 6 Mar 2015 16:10:45 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/3] hugetlbfs: optionally reserve all fs pages at mount
 time
Message-ID: <20150306151045.GA23443@dhcp22.suse.cz>
References: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com>
 <20150302151009.2ae58f4430f9f34b81533821@linux-foundation.org>
 <54F50BD6.1030706@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F50BD6.1030706@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon 02-03-15 17:18:14, Mike Kravetz wrote:
> On 03/02/2015 03:10 PM, Andrew Morton wrote:
> >On Fri, 27 Feb 2015 14:58:08 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> >
> >>hugetlbfs allocates huge pages from the global pool as needed.  Even if
> >>the global pool contains a sufficient number pages for the filesystem
> >>size at mount time, those global pages could be grabbed for some other
> >>use.  As a result, filesystem huge page allocations may fail due to lack
> >>of pages.
> >
> >Well OK, but why is this a sufficiently serious problem to justify
> >kernel changes?  Please provide enough info for others to be able
> >to understand the value of the change.
> >
> 
> Thanks for taking a look.
> 
> Applications such as a database want to use huge pages for performance
> reasons.  hugetlbfs filesystem semantics with ownership and modes work
> well to manage access to a pool of huge pages.  However, the application
> would like some reasonable assurance that allocations will not fail due
> to a lack of huge pages.  Before starting, the application will ensure
> that enough huge pages exist on the system in the global pools.  What
> the application wants is exclusive use of a pool of huge pages.
> 
> One could argue that this is a system administration issue.  The global
> huge page pools are only available to users with root privilege.
> Therefore,  exclusive use of a pool of huge pages can be obtained by
> limiting access.  However, many applications are installed to run with
> elevated privilege to take advantage of resources like huge pages.  It
> is quite possible for one application to interfere another, especially
> in the case of something like huge pages where the pool size is mostly
> fixed.
> 
> Suggestions for other ways to approach this situation are appreciated.
> I saw the existing support for "reservations" within hugetlbfs and
> thought of extending this to cover the size of the filesystem.

Maybe I do not understand your usecase properly but wouldn't hugetlb
cgroup (CONFIG_CGROUP_HUGETLB) help to guarantee the same? Just
configure limits for different users/applications (inside different
groups) so that they never overcommit the existing pool. Would that work
for you?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
