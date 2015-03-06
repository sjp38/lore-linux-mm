Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 964E96B0038
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 13:59:04 -0500 (EST)
Received: by obcvb8 with SMTP id vb8so18505915obc.0
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 10:59:04 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id ix8si6484775obc.59.2015.03.06.10.59.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 06 Mar 2015 10:59:03 -0800 (PST)
Message-ID: <54F9F8F1.4020203@oracle.com>
Date: Fri, 06 Mar 2015 10:58:57 -0800
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/3] hugetlbfs: optionally reserve all fs pages at mount
 time
References: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com> <20150302151009.2ae58f4430f9f34b81533821@linux-foundation.org> <54F50BD6.1030706@oracle.com> <20150306151045.GA23443@dhcp22.suse.cz>
In-Reply-To: <20150306151045.GA23443@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>

On 03/06/2015 07:10 AM, Michal Hocko wrote:
> On Mon 02-03-15 17:18:14, Mike Kravetz wrote:
>> On 03/02/2015 03:10 PM, Andrew Morton wrote:
>>> On Fri, 27 Feb 2015 14:58:08 -0800 Mike Kravetz <mike.kravetz@oracle.com> wrote:
>>>
>>>> hugetlbfs allocates huge pages from the global pool as needed.  Even if
>>>> the global pool contains a sufficient number pages for the filesystem
>>>> size at mount time, those global pages could be grabbed for some other
>>>> use.  As a result, filesystem huge page allocations may fail due to lack
>>>> of pages.
>>>
>>> Well OK, but why is this a sufficiently serious problem to justify
>>> kernel changes?  Please provide enough info for others to be able
>>> to understand the value of the change.
>>>
>>
>> Thanks for taking a look.
>>
>> Applications such as a database want to use huge pages for performance
>> reasons.  hugetlbfs filesystem semantics with ownership and modes work
>> well to manage access to a pool of huge pages.  However, the application
>> would like some reasonable assurance that allocations will not fail due
>> to a lack of huge pages.  Before starting, the application will ensure
>> that enough huge pages exist on the system in the global pools.  What
>> the application wants is exclusive use of a pool of huge pages.
>>
>> One could argue that this is a system administration issue.  The global
>> huge page pools are only available to users with root privilege.
>> Therefore,  exclusive use of a pool of huge pages can be obtained by
>> limiting access.  However, many applications are installed to run with
>> elevated privilege to take advantage of resources like huge pages.  It
>> is quite possible for one application to interfere another, especially
>> in the case of something like huge pages where the pool size is mostly
>> fixed.
>>
>> Suggestions for other ways to approach this situation are appreciated.
>> I saw the existing support for "reservations" within hugetlbfs and
>> thought of extending this to cover the size of the filesystem.
>
> Maybe I do not understand your usecase properly but wouldn't hugetlb
> cgroup (CONFIG_CGROUP_HUGETLB) help to guarantee the same? Just
> configure limits for different users/applications (inside different
> groups) so that they never overcommit the existing pool. Would that work
> for you?

Thanks for the CONFIG_CGROUP_HUGETLB suggestion, however I do not
believe this will be a satisfactory solution for my usecase.  As you
point out, cgroups could be set up (by a sysadmin) for every hugetlb
user/application.  In this case, the sysadmin needs to have knowledge
of every huge page user/application and configure appropriately.

I was approaching this from the point of view of the application.  The
application wants the guarantee of a minimum number of huge pages,
independent of other users/applications.  The "reserve" approach allows
the application to set aside those pages at initialization time.  If it
can not get the pages it needs, it can refuse to start, or configure
itself to use less, or take other action.

As you point out, the cgroup approach could also provide guarantees to
the application if set up properly.  I was trying for an approach that
would provide more control to the application independent of the
sysadmin and other users/applications.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
