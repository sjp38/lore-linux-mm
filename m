Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B857E440843
	for <linux-mm@kvack.org>; Sun,  9 Jul 2017 03:32:15 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id j186so81095580pge.12
        for <linux-mm@kvack.org>; Sun, 09 Jul 2017 00:32:15 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d34si2784656pld.416.2017.07.09.00.32.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jul 2017 00:32:14 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v697TFMH131208
	for <linux-mm@kvack.org>; Sun, 9 Jul 2017 03:32:14 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bjtpt4ar7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 09 Jul 2017 03:32:14 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Sun, 9 Jul 2017 17:32:11 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v697W9Vm14680250
	for <linux-mm@kvack.org>; Sun, 9 Jul 2017 17:32:09 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v697W8hS012667
	for <linux-mm@kvack.org>; Sun, 9 Jul 2017 17:32:08 +1000
Subject: Re: [RFC PATCH 1/1] mm/mremap: add MREMAP_MIRROR flag for existing
 mirroring functionality
References: <1499357846-7481-1-git-send-email-mike.kravetz@oracle.com>
 <1499357846-7481-2-git-send-email-mike.kravetz@oracle.com>
 <20170707102324.kfihkf72sjcrtn5b@node.shutemov.name>
 <e328ff6a-2c4b-ec26-cc28-e24b7b35a463@oracle.com>
 <20170707174534.wdfbciyfpovi52dy@node.shutemov.name>
 <79eca23d-9f1a-9713-3f6b-8f7598d53190@oracle.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Sun, 9 Jul 2017 13:02:02 +0530
MIME-Version: 1.0
In-Reply-To: <79eca23d-9f1a-9713-3f6b-8f7598d53190@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <662d372a-5737-5f0b-8ac1-c997f3a935eb@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On 07/07/2017 11:39 PM, Mike Kravetz wrote:
> On 07/07/2017 10:45 AM, Kirill A. Shutemov wrote:
>> On Fri, Jul 07, 2017 at 10:29:52AM -0700, Mike Kravetz wrote:
>>> On 07/07/2017 03:23 AM, Kirill A. Shutemov wrote:
>>>> On Thu, Jul 06, 2017 at 09:17:26AM -0700, Mike Kravetz wrote:
>>>>> The mremap system call has the ability to 'mirror' parts of an existing
>>>>> mapping.  To do so, it creates a new mapping that maps the same pages as
>>>>> the original mapping, just at a different virtual address.  This
>>>>> functionality has existed since at least the 2.6 kernel.
>>>>>
>>>>> This patch simply adds a new flag to mremap which will make this
>>>>> functionality part of the API.  It maintains backward compatibility with
>>>>> the existing way of requesting mirroring (old_size == 0).
>>>>>
>>>>> If this new MREMAP_MIRROR flag is specified, then new_size must equal
>>>>> old_size.  In addition, the MREMAP_MAYMOVE flag must be specified.
>>>>
>>>> The patch breaks important invariant that anon page can be mapped into a
>>>> process only once.
>>>
>>> Actually, the patch does not add any new functionality.  It only provides
>>> a new interface to existing functionality.
>>>
>>> Is it not possible to have an anon page mapped twice into the same process
>>> via system V shared memory?  shmget(anon), shmat(), shmat.  
>>> Of course, those are shared rather than private anon pages.
>>
>> By anon pages I mean, private anon or file pages. These are subject to CoW.
>>
>>>> What is going to happen to mirrored after CoW for instance?
>>>>
>>>> In my opinion, it shouldn't be allowed for anon/private mappings at least.
>>>> And with this limitation, I don't see much sense in the new interface --
>>>> just create mirror by mmap()ing the file again.
>>>
>>> The code today works for anon shared mappings.  See simple program below.
>>>
>>> You are correct in that it makes little or no sense for private mappings.
>>> When looking closer at existing code, mremap() creates a new private
>>> mapping in this case.  This is most likely a bug.
>>
>> IIRC, existing code doesn't create mirrors of private pages as it requires
>> old_len to be zero. There's no way to get private pages mapped twice this
>> way.
> 
> Correct.
> As mentioned above, mremap does 'something' for private anon pages when
> old_len == 0.  However, this may be considered a bug.  In this case, mremap
> creates a new private anon mapping of length new_size.  Since old_len == 0,
> it does not unmap any of the old mapping.  So, in this case mremap basically
> creates a new private mapping (unrealted to the original) and does not
> modify the old mapping.
> 

Yeah, in my experiment, after the mremap() exists we have two different VMAs
which can contain two different set of data. No page sharing is happening.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
