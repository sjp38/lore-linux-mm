Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id C346D6B0038
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 10:16:49 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so11901975ioi.2
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 07:16:49 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id p140si17354236iop.59.2015.09.29.07.16.42
        for <linux-mm@kvack.org>;
        Tue, 29 Sep 2015 07:16:42 -0700 (PDT)
Subject: Re: [PATCH 21/25] mm: implement new mprotect_key() system call
References: <20150928191817.035A64E2@viggo.jf.intel.com>
 <20150928191826.F1CD5256@viggo.jf.intel.com>
 <1443508783.29119.2.camel@ellerman.id.au>
From: Dave Hansen <dave@sr71.net>
Message-ID: <560A9D46.3070401@sr71.net>
Date: Tue, 29 Sep 2015 07:16:38 -0700
MIME-Version: 1.0
In-Reply-To: <1443508783.29119.2.camel@ellerman.id.au>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com, linux-api@vger.kernel.org

On 09/28/2015 11:39 PM, Michael Ellerman wrote:
> On Mon, 2015-09-28 at 12:18 -0700, Dave Hansen wrote:
>> From: Dave Hansen <dave.hansen@linux.intel.com>
>>
>> mprotect_key() is just like mprotect, except it also takes a
>> protection key as an argument.  On systems that do not support
>> protection keys, it still works, but requires that key=0.
> 
> I'm not sure how userspace is going to use the key=0 feature? ie. userspace
> will still have to detect that keys are not supported and use key 0 everywhere.
> At that point it could just as well skip the mprotect_key() syscalls entirely
> couldn't it?

Yep.

Or, a new architecture could just skip mprotect() itself entirely and
only wire up mprotect_pkey().  I don't see this pkey=0 thing as an
important feature or anything.  I just wanted to call out the behavior.

>> I expect it to get used like this, if you want to guarantee that
>> any mapping you create can *never* be accessed without the right
>> protection keys set up.
>>
>> 	pkey_deny_access(11); // random pkey
>> 	int real_prot = PROT_READ|PROT_WRITE;
>> 	ptr = mmap(NULL, PAGE_SIZE, PROT_NONE, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
>> 	ret = mprotect_key(ptr, PAGE_SIZE, real_prot, 11);
>>
>> This way, there is *no* window where the mapping is accessible
>> since it was always either PROT_NONE or had a protection key set.
>>
>> We settled on 'unsigned long' for the type of the key here.  We
>> only need 4 bits on x86 today, but I figured that other
>> architectures might need some more space.
> 
> If the existing mprotect() syscall had a flags argument you could have just
> used that. So is it worth just adding mprotect2() now and using it for this? ie:
> 
> int mprotect2(unsigned long start, size_t len, unsigned long prot, unsigned long flags) ..
> 
> And then you define bit zero of flags to say you're passing a pkey, and it's in
> bits 1-63?
> 
> That way if other arches need to do something different you at least have the
> flags available?

But what problem does that solve?

mprotect() itself has plenty of space in prot.  Do any of the other
architectures need to pass in more than just an integer key to implement
storage/protection keys?

I'd much rather have a set of (relatively) arch-specific system calls
implementing protection keys rather than a single one with one
arch-specific argument.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
