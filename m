Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 521BC90001C
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 10:23:12 -0400 (EDT)
Received: by mail-vc0-f175.google.com with SMTP id id10so6658953vcb.6
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 07:23:12 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id s62si439594yho.16.2014.10.08.07.23.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Oct 2014 07:23:11 -0700 (PDT)
Message-ID: <543548C3.7030003@oracle.com>
Date: Wed, 08 Oct 2014 10:22:59 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] mm: poison page struct
References: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com> <1412041639-23617-6-git-send-email-sasha.levin@oracle.com> <5434630C.3070006@intel.com>
In-Reply-To: <5434630C.3070006@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@suse.de, Christoph Lameter <cl@linux.com>

On 10/07/2014 06:02 PM, Dave Hansen wrote:
> On 09/29/2014 06:47 PM, Sasha Levin wrote:
>>  struct page {
>> +#ifdef CONFIG_DEBUG_VM_POISON
>> +	u32 poison_start;
>> +#endif
>>  	/* First double word block */
>>  	unsigned long flags;		/* Atomic flags, some possibly
>>  					 * updated asynchronously */
>> @@ -196,6 +199,9 @@ struct page {
>>  #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
>>  	int _last_cpupid;
>>  #endif
>> +#ifdef CONFIG_DEBUG_VM_POISON
>> +	u32 poison_end;
>> +#endif
>>  }
> 
> Does this break slub's __cmpxchg_double_slab trick?  I thought it
> required page->freelist and page->counters to be doubleword-aligned.

I'll probably have to switch it to 8 bytes anyways to make it work with
kasan. This should take care of the slub optimization as well.

> It's not like we really require this optimization when we're debugging,
> but trying to use it will unnecessarily slow things down.
> 
> FWIW, if you're looking to trim down the number of lines of code, you
> could certainly play some macro tricks and #ifdef tricks.
> 
> struct vm_poison {
> #ifdef CONFIG_DEBUG_VM_POISON
> 	u32 val;
> #endif	
> };
> 
> Then, instead of #ifdefs in each structure, you do:
> 
> struct page {
> 	struct vm_poison poison_start;
> 	... other gunk
> 	struct vm_poison poison_end;
> };

Agreed, I'll reword that in the next version.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
