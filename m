Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 035286B006C
	for <linux-mm@kvack.org>; Thu,  7 May 2015 06:51:32 -0400 (EDT)
Received: by wief7 with SMTP id f7so10810182wie.0
        for <linux-mm@kvack.org>; Thu, 07 May 2015 03:51:31 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id h2si3206932wiv.100.2015.05.07.03.51.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 07 May 2015 03:51:30 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 7 May 2015 11:51:28 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id B6DC717D8066
	for <linux-mm@kvack.org>; Thu,  7 May 2015 11:52:10 +0100 (BST)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t47ApPUY6291826
	for <linux-mm@kvack.org>; Thu, 7 May 2015 10:51:25 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t47ApNfL031875
	for <linux-mm@kvack.org>; Thu, 7 May 2015 06:51:25 -0400
Message-ID: <554B43AA.1050605@de.ibm.com>
Date: Thu, 07 May 2015 12:51:22 +0200
From: Christian Borntraeger <borntraeger@de.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC 00/15] decouple pagefault_disable() from preempt_disable()
References: <1430934639-2131-1-git-send-email-dahi@linux.vnet.ibm.com> <20150506150158.0a927470007e8ea5f3278956@linux-foundation.org> <20150507094819.GC4734@gmail.com>
In-Reply-To: <20150507094819.GC4734@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Hildenbrand <dahi@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, mingo@redhat.com, peterz@infradead.org, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org

Am 07.05.2015 um 11:48 schrieb Ingo Molnar:
> 
> * Andrew Morton <akpm@linux-foundation.org> wrote:
> 
>> On Wed,  6 May 2015 19:50:24 +0200 David Hildenbrand <dahi@linux.vnet.ibm.com> wrote:
>>
>>> As Peter asked me to also do the decoupling in one shot, this is
>>> the new series.
>>>
>>> I recently discovered that might_fault() doesn't call might_sleep()
>>> anymore. Therefore bugs like:
>>>
>>>   spin_lock(&lock);
>>>   rc = copy_to_user(...);
>>>   spin_unlock(&lock);
>>>
>>> would not be detected with CONFIG_DEBUG_ATOMIC_SLEEP. The code was
>>> changed to disable false positives for code like:
>>>
>>>   pagefault_disable();
>>>   rc = copy_to_user(...);
>>>   pagefault_enable();
>>>
>>> Whereby the caller wants do deal with failures.
>>
>> hm, that was a significant screwup.  I wonder how many bugs we
>> subsequently added.
> 
> So I'm wondering what the motivation was to allow things like:
> 
>    pagefault_disable();
>    rc = copy_to_user(...);
>    pagefault_enable();
> 
> and to declare it a false positive?
> 
> AFAICS most uses are indeed atomic:
> 
>         pagefault_disable();
>         ret = futex_atomic_cmpxchg_inatomic(curval, uaddr, uval, newval);
>         pagefault_enable();
> 
> so why not make it explicitly atomic again?

Hmm, I am probably misreading that, but it sound as you suggest to go back
to Davids first proposal
https://lkml.org/lkml/2014/11/25/436
which makes might_fault to also contain might_sleep. Correct?

Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
