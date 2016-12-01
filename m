Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 145006B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 08:26:57 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 3so96211241pgd.3
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 05:26:57 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z66si183611pfk.207.2016.12.01.05.26.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 05:26:56 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB1DOrXe062199
	for <linux-mm@kvack.org>; Thu, 1 Dec 2016 08:26:55 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 272jtf7026-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Dec 2016 08:26:55 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 1 Dec 2016 13:26:53 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 42F221B08067
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 13:29:12 +0000 (GMT)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uB1DQn9S36372582
	for <linux-mm@kvack.org>; Thu, 1 Dec 2016 13:26:49 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uB1DQnd5031803
	for <linux-mm@kvack.org>; Thu, 1 Dec 2016 06:26:49 -0700
Subject: Re: [RFC PATCH v2 0/7] Speculative page faults
References: <20161018150243.GZ3117@twins.programming.kicks-ass.net>
 <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
 <871sy8284n.fsf@tassilo.jf.intel.com>
 <885a17ba-fed8-e312-c2d3-e28a996f5424@linux.vnet.ibm.com>
 <CAKTCnz=0QZ55L5=WbLoCQwB8sXZ_2dgqrBCgdtt=jCqejy=wHA@mail.gmail.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 1 Dec 2016 14:26:48 +0100
MIME-Version: 1.0
In-Reply-To: <CAKTCnz=0QZ55L5=WbLoCQwB8sXZ_2dgqrBCgdtt=jCqejy=wHA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <2d934437-fd56-983c-b4a6-dc265be6f0b9@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>

On 01/12/2016 13:50, Balbir Singh wrote:
> On Thu, Dec 1, 2016 at 7:34 PM, Laurent Dufour
> <ldufour@linux.vnet.ibm.com> wrote:
>> On 18/11/2016 15:08, Andi Kleen wrote:
>>> Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:
>>>
>>>> This is a port on kernel 4.8 of the work done by Peter Zijlstra to
>>>> handle page fault without holding the mm semaphore.
>>>
>>> One of the big problems with patches like this today is that it is
>>> unclear what mmap_sem actually protects. It's a big lock covering lots
>>> of code. Parts in the core VM, but also do VM callbacks in file systems
>>> and drivers rely on it too?
>>>
>>> IMHO the first step is a comprehensive audit and then writing clear
>>> documentation on what it is supposed to protect. Then based on that such
>>> changes can be properly evaluated.
>>
>> Hi Andi,
>>
>> Sorry for the late answer...
>>
>> I do agree, this semaphore is massively used and it would be nice to
>> have all its usage documented.
>>
>> I'm currently tracking all the mmap_sem use in 4.8 kernel (about 380
>> hits) and I'm trying to identify which it is protecting.
>>
>> In addition, I think it may be nice to limit its usage to code under mm/
>> so that in the future it may be easier to find its usage.
> 
> Is this possible? All sorts of arch's fault
> handling/virtualization/file system and drivers (IO/DRM/) hold
> mmap_sem.

That's a good question ;)

I may be too optimistic / naive, and I'm not confident in the result of
such a goal but I think it may be good to keep such a direction in mind.
It may be possible to limit its usage as it has been done in the fs part.

Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
