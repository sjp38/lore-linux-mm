Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9156B0256
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 04:48:17 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id 128so2570532wmz.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 01:48:17 -0800 (PST)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id v4si3133001wmb.35.2016.01.28.01.48.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Jan 2016 01:48:15 -0800 (PST)
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 28 Jan 2016 09:48:14 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 2AE4E17D805A
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 09:48:13 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0S9m47A64094458
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 09:48:04 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0S9m2Z0012083
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 02:48:03 -0700
Subject: Re: [PATCH v3 2/3] x86: query dynamic DEBUG_PAGEALLOC setting
References: <1453889401-43496-1-git-send-email-borntraeger@de.ibm.com>
 <1453889401-43496-3-git-send-email-borntraeger@de.ibm.com>
 <alpine.DEB.2.10.1601271414180.23510@chino.kir.corp.google.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Message-ID: <56A9E3D1.3090001@de.ibm.com>
Date: Thu, 28 Jan 2016 10:48:01 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1601271414180.23510@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net, Joonsoo Kim <iamjoonsoo.kim@lge.com>, davej@codemonkey.org.uk

On 01/27/2016 11:17 PM, David Rientjes wrote:
> On Wed, 27 Jan 2016, Christian Borntraeger wrote:
> 
>> We can use debug_pagealloc_enabled() to check if we can map
>> the identity mapping with 2MB pages. We can also add the state
>> into the dump_stack output.
>>
>> The patch does not touch the code for the 1GB pages, which ignored
>> CONFIG_DEBUG_PAGEALLOC. Do we need to fence this as well?
>>
>> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
>> Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
>> ---
>>  arch/x86/kernel/dumpstack.c |  5 ++---
>>  arch/x86/mm/init.c          |  7 ++++---
>>  arch/x86/mm/pageattr.c      | 14 ++++----------
>>  3 files changed, 10 insertions(+), 16 deletions(-)
>>
>> diff --git a/arch/x86/kernel/dumpstack.c b/arch/x86/kernel/dumpstack.c
>> index 9c30acf..32e5699 100644
>> --- a/arch/x86/kernel/dumpstack.c
>> +++ b/arch/x86/kernel/dumpstack.c
>> @@ -265,9 +265,8 @@ int __die(const char *str, struct pt_regs *regs, long err)
>>  #ifdef CONFIG_SMP
>>  	printk("SMP ");
>>  #endif
>> -#ifdef CONFIG_DEBUG_PAGEALLOC
>> -	printk("DEBUG_PAGEALLOC ");
>> -#endif
>> +	if (debug_pagealloc_enabled())
>> +		printk("DEBUG_PAGEALLOC ");
>>  #ifdef CONFIG_KASAN
>>  	printk("KASAN");
>>  #endif
>> diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
>> index 493f541..39823fd 100644
>> --- a/arch/x86/mm/init.c
>> +++ b/arch/x86/mm/init.c
>> @@ -150,13 +150,14 @@ static int page_size_mask;
>>  
>>  static void __init probe_page_size_mask(void)
>>  {
>> -#if !defined(CONFIG_DEBUG_PAGEALLOC) && !defined(CONFIG_KMEMCHECK)
>> +#if !defined(CONFIG_KMEMCHECK)
>>  	/*
>> -	 * For CONFIG_DEBUG_PAGEALLOC, identity mapping will use small pages.
>> +	 * For CONFIG_KMEMCHECK or pagealloc debugging, identity mapping will
>> +	 * use small pages.
>>  	 * This will simplify cpa(), which otherwise needs to support splitting
>>  	 * large pages into small in interrupt context, etc.
>>  	 */
>> -	if (cpu_has_pse)
>> +	if (cpu_has_pse && !debug_pagealloc_enabled())
>>  		page_size_mask |= 1 << PG_LEVEL_2M;
>>  #endif
>>  
> 
> I would have thought free_init_pages() would be modified to use 
> debug_pagealloc_enabled() as well?


Indeed, I only touched the identity mapping and dump stack.
The question is do we really want to change free_init_pages as well?
The unmapping during runtime causes significant overhead, but the
unmapping after init imposes almost no runtime overhead. Of course,
things get fishy now as what is enabled and what not.

Kconfig after my patch "mm/debug_pagealloc: Ask users for default setting of debug_pagealloc"
(in mm) now states
----snip----
By default this option will have a small overhead, e.g. by not
allowing the kernel mapping to be backed by large pages on some
architectures. Even bigger overhead comes when the debugging is
enabled by DEBUG_PAGEALLOC_ENABLE_DEFAULT or the debug_pagealloc
command line parameter.
----snip----

So I am tempted to NOT change free_init_pages, but the x86 maintainers
can certainly decide differently. Ingo, Thomas, H. Peter, please advise.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
