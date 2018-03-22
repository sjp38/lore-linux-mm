Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 53E356B0029
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:29:04 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t123so4193187wmt.2
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 09:29:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l34si6223454ede.316.2018.03.22.09.29.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 09:29:02 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2MGPJrj065196
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:29:01 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gvf89amcp-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:29:01 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 22 Mar 2018 16:28:58 -0000
Subject: Re: [RFC PATCH 1/8] mm: mmap: unmap large mapping by section
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
 <1521581486-99134-2-git-send-email-yang.shi@linux.alibaba.com>
 <20180321131449.GN23100@dhcp22.suse.cz>
 <8e0ded7b-4be4-fa25-f40c-d3116a6db4db@linux.alibaba.com>
 <cf87ade4-5a5c-3919-0fc6-acc40e12659b@linux.alibaba.com>
 <20180321212355.GR23100@dhcp22.suse.cz>
 <952dcae2-a73e-0726-3cc5-9b6a63b417b7@linux.alibaba.com>
 <20180322091008.GZ23100@dhcp22.suse.cz>
 <8b4407dd-78f6-2f6f-3f45-ddb8a2d805c8@linux.alibaba.com>
 <20180322161316.GD28468@bombadil.infradead.org>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 22 Mar 2018 17:28:54 +0100
MIME-Version: 1.0
In-Reply-To: <20180322161316.GD28468@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <e36daca9-8bf0-5fad-d68b-a3116cc1a75e@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 22/03/2018 17:13, Matthew Wilcox wrote:
> On Thu, Mar 22, 2018 at 09:06:14AM -0700, Yang Shi wrote:
>> On 3/22/18 2:10 AM, Michal Hocko wrote:
>>> On Wed 21-03-18 15:36:12, Yang Shi wrote:
>>>> On 3/21/18 2:23 PM, Michal Hocko wrote:
>>>>> On Wed 21-03-18 10:16:41, Yang Shi wrote:
>>>>>> proc_pid_cmdline_read(), it calls access_remote_vm() which need acquire
>>>>>> mmap_sem too, so the mmap_sem scalability issue will be hit sooner or later.
>>>>> Ohh, absolutely. mmap_sem is unfortunatelly abused and it would be great
>>>>> to remove that. munmap should perform much better. How to do that safely
>>> The full vma will have to be range locked. So there is nothing small or large.
>>
>> It sounds not helpful to a single large vma case since just one range lock
>> for the vma, it sounds equal to mmap_sem.
> 
> But splitting mmap_sem into pieces is beneficial for this case.  Imagine
> we have a spinlock / rwlock to protect the rbtree 

Which is more or less what I'm proposing in the speculative page fault series:
https://lkml.org/lkml/2018/3/13/1158

This being said, having a per VMA lock could lead to tricky dead lock case,
when merging multiple VMA happens in parallel since multiple VMA will have to
be locked at the same time, grabbing those lock in a fine order will be required.

> ... / arg_start / arg_end
> / ...  and then each VMA has a rwsem (or equivalent).  access_remote_vm()
> would walk the tree and grab the VMA's rwsem for read while reading
> out the arguments.  The munmap code would have a completely different
> VMA write-locked.
> 
