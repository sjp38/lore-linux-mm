Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 37E5C6B0038
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 16:32:54 -0500 (EST)
Received: by obcwp18 with SMTP id wp18so11943593obc.1
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 13:32:53 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id gg9si6742599obb.30.2015.03.06.13.32.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 06 Mar 2015 13:32:53 -0800 (PST)
Message-ID: <54FA1CFE.1000500@oracle.com>
Date: Fri, 06 Mar 2015 13:32:46 -0800
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/3] hugetlbfs: optionally reserve all fs pages at mount
 time
References: <1425077893-18366-1-git-send-email-mike.kravetz@oracle.com> <20150302151009.2ae58f4430f9f34b81533821@linux-foundation.org> <54F50BD6.1030706@oracle.com> <20150306151045.GA23443@dhcp22.suse.cz> <54F9F8F1.4020203@oracle.com> <alpine.DEB.2.10.1503061312170.10330@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1503061312170.10330@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 03/06/2015 01:14 PM, David Rientjes wrote:
> On Fri, 6 Mar 2015, Mike Kravetz wrote:
>
>> Thanks for the CONFIG_CGROUP_HUGETLB suggestion, however I do not
>> believe this will be a satisfactory solution for my usecase.  As you
>> point out, cgroups could be set up (by a sysadmin) for every hugetlb
>> user/application.  In this case, the sysadmin needs to have knowledge
>> of every huge page user/application and configure appropriately.
>>
>> I was approaching this from the point of view of the application.  The
>> application wants the guarantee of a minimum number of huge pages,
>> independent of other users/applications.  The "reserve" approach allows
>> the application to set aside those pages at initialization time.  If it
>> can not get the pages it needs, it can refuse to start, or configure
>> itself to use less, or take other action.
>>
>
> Would it be too difficult to modify the application to mmap() the
> hugepages at startup so they are no longer free in the global pool but
> rather get marked as reserved so other applications cannot map them?  That
> should return MAP_FAILED if there is an insufficient number of hugepages
> available to be reserved (HugePages_Rsvd in /proc/meminfo).

The application is a database with multiple processes/tasks that will
come and go over time.  I thought about having one task do a big
mmap() at initialization time, but then the issue is how to coordinate
with the other tasks and their requests to allocate/free pages.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
