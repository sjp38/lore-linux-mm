Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DBF0B6B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 09:03:03 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f21so5205615pgi.4
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 06:03:03 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q78si1313180pfj.291.2017.02.22.06.03.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 06:03:02 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1MDx4S0098803
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 09:03:02 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28s5ksgbae-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 09:03:01 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 22 Feb 2017 14:02:58 -0000
Subject: Re: [PATCH] mm/cgroup: avoid panic when init with low memory
References: <1487154969-6704-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170220130123.GI2431@dhcp22.suse.cz>
 <934d40ec-060b-4794-2fdc-35a7ea1dc9e2@linux.vnet.ibm.com>
 <20170220174258.GA31541@dhcp22.suse.cz>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 22 Feb 2017 15:02:54 +0100
MIME-Version: 1.0
In-Reply-To: <20170220174258.GA31541@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <9414873a-6c64-7b96-6251-f0ddba2b256e@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 20/02/2017 18:42, Michal Hocko wrote:
> On Mon 20-02-17 18:09:43, Laurent Dufour wrote:
>> On 20/02/2017 14:01, Michal Hocko wrote:
>>> On Wed 15-02-17 11:36:09, Laurent Dufour wrote:
>>>> The system may panic when initialisation is done when almost all the
>>>> memory is assigned to the huge pages using the kernel command line
>>>> parameter hugepage=xxxx. Panic may occur like this:
>>>
>>> I am pretty sure the system might blow up in many other ways when you
>>> misconfigure it and pull basically all the memory out. Anyway...
>>>
>>> [...]
>>>
>>>> This is a chicken and egg issue where the kernel try to get free
>>>> memory when allocating per node data in mem_cgroup_init(), but in that
>>>> path mem_cgroup_soft_limit_reclaim() is called which assumes that
>>>> these data are allocated.
>>>>
>>>> As mem_cgroup_soft_limit_reclaim() is best effort, it should return
>>>> when these data are not yet allocated.
>>>
>>> ... this makes some sense. Especially when there is no soft limit
>>> configured. So this is a good step. I would just like to ask you to go
>>> one step further. Can we make the whole soft reclaim thing uninitialized
>>> until the soft limit is actually set? Soft limit is not used in cgroup
>>> v2 at all and I would strongly discourage it in v1 as well. We will save
>>> few bytes as a bonus.
>>
>> Hi Michal, and thanks for the review.
>>
>> I'm not familiar with that part of the kernel, so to be sure we are on
>> the same line, are you suggesting to set soft_limit_tree at the first
>> time mem_cgroup_write() is called to set a soft_limit field ?
> 
> yes
> 
>> Obviously, all callers to soft_limit_tree_node() and
>> soft_limit_tree_from_page() will have to check for the return pointer to
>> be NULL.
> 
> All callers that need to access the tree unconditionally, yes. Which is
> the case anyway, right? I haven't checked the check you have added is
> sufficient, but we shouldn't have that many of them because some code
> paths are called only when the soft limit is enabled.

You're right there are not so much callers to fix.
I'll send a new series containing the previous patch fixing the initial
panic and another one delaying the data allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
