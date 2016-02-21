Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2EE366B0009
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 17:03:44 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id jq7so150536220obb.0
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 14:03:44 -0800 (PST)
Received: from mail-ob0-x230.google.com (mail-ob0-x230.google.com. [2607:f8b0:4003:c01::230])
        by mx.google.com with ESMTPS id eb7si15319149oeb.35.2016.02.21.14.03.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Feb 2016 14:03:43 -0800 (PST)
Received: by mail-ob0-x230.google.com with SMTP id xk3so152324606obc.2
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 14:03:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56CA2AC9.7030905@plexistor.com>
References: <56C9EDCF.8010007@plexistor.com>
	<CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com>
	<56CA1CE7.6050309@plexistor.com>
	<CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>
	<56CA2AC9.7030905@plexistor.com>
Date: Sun, 21 Feb 2016 14:03:43 -0800
Message-ID: <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Arnd Bergmann <arnd@arndb.de>

On Sun, Feb 21, 2016 at 1:23 PM, Boaz Harrosh <boaz@plexistor.com> wrote:
> On 02/21/2016 10:57 PM, Dan Williams wrote:
>> On Sun, Feb 21, 2016 at 12:24 PM, Boaz Harrosh <boaz@plexistor.com> wrote:
>>> On 02/21/2016 09:51 PM, Dan Williams wrote:
>>> <>
>>>>> Please advise?
>>>>
>>>> When this came up a couple weeks ago [1], the conclusion I came away
>>>> with is
>>>
>>> I think I saw that talk, no this was not suggested. What was suggested
>>> was an FS / mount knob. That would break semantics, this here does not
>>> break anything.
>>
>> No, it was a MAP_DAX mmap flag, similar to this proposal.  The
>> difference being that MAP_DAX was all or nothing (DAX vs page cache)
>> to address MAP_SHARED semantics.
>>
>
> Big difference no? I'm not talking about cached access at all.
>
>>>
>>>> that if an application wants to avoid the overhead of DAX
>>>> semantics it needs to use an alternative to DAX access methods.  Maybe
>>>> a new pmem aware fs like Nova [2], or some other mechanism that
>>>> bypasses the semantics that existing applications on top of ext4 and
>>>> xfs expect.
>>>>
>>>
>>> But my suggestion does not break any "existing applications" and does
>>> not break any semantics of ext4 or xfs. (That I can see)
>>>
>>> As I said above it perfectly co exists with existing applications and
>>> is the best of both worlds. The both applications can write to the
>>> same page and will not break any of application's expectation. Old or
>>> new.
>>>
>>> Please point me to where I'm wrong in the code submitted?
>>>
>>> Besides even an FS like Nova will need a flag per vma like this,
>>> it will need to sort out the different type of application. So
>>> here is how this is communicated, on the mmap call, how else?
>>> And also works for xfs or ext4
>>>
>>> Do you not see how this is entirely different then what was
>>> proposed? or am I totally missing something? Again please show
>>> me how this breaks anything's expectations.
>>>
>>
>> What happens for MAP_SHARED mappings with mixed pmem aware/unaware
>> applications?  Does MAP_PMEM_AWARE also imply awareness of other
>> applications that may be dirtying cachelines without taking
>> responsibility for making them persistent?
>>
>
> Sure. please have a look. What happens is that the legacy app
> will add the page to the radix tree, come the fsync it will be
> flushed. Even though a "new-type" app might fault on the same page
> before or after, which did not add it to the radix tree.
> So yes, all pages faulted by legacy apps will be flushed.
>
> I have manually tested all this and it seems to work. Can you see
> a theoretical scenario where it would not?

I'm worried about the scenario where the pmem aware app assumes that
none of the cachelines in its mapping are dirty when it goes to issue
pcommit.  We'll have two applications with different perceptions of
when writes are durable.  Maybe it's not a problem in practice, at
least current generation x86 cpus flush existing dirty cachelines when
performing non-temporal stores.  However, it bothers me that there are
cpus where a pmem-unaware app could prevent a pmem-aware app from
making writes durable.  It seems if one app has established a
MAP_PMEM_AWARE mapping it needs guarantees that all apps participating
in that shared mapping have the same awareness.

Another potential issue is that MAP_PMEM_AWARE is not enough on its
own.  If the filesystem or inode does not support DAX the application
needs to assume page cache semantics.  At a minimum MAP_PMEM_AWARE
requests would need to fail if DAX is not available.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
