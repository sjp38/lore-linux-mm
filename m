Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 664456B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 15:51:55 -0500 (EST)
Received: by pff63 with SMTP id 63so17235174pff.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 12:51:55 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id g87si19316017pfj.194.2015.12.14.12.51.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 12:51:54 -0800 (PST)
Received: by pacwq6 with SMTP id wq6so109440605pac.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 12:51:54 -0800 (PST)
Subject: Re: [PATCH v6 4/4] x86: mm: support ARCH_MMAP_RND_BITS.
References: <1449856338-30984-1-git-send-email-dcashman@android.com>
 <1449856338-30984-2-git-send-email-dcashman@android.com>
 <1449856338-30984-3-git-send-email-dcashman@android.com>
 <1449856338-30984-4-git-send-email-dcashman@android.com>
 <1449856338-30984-5-git-send-email-dcashman@android.com>
 <566F1154.7030703@zytor.com>
From: Daniel Cashman <dcashman@android.com>
Message-ID: <566F2BE7.4090904@android.com>
Date: Mon, 14 Dec 2015 12:51:51 -0800
MIME-Version: 1.0
In-Reply-To: <566F1154.7030703@zytor.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, linux-kernel@vger.kernel.org
Cc: linux@arm.linux.org.uk, akpm@linux-foundation.org, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, ebiederm@xmission.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, catalin.marinas@arm.com, will.deacon@arm.com, x86@kernel.org, hecmargi@upv.es, bp@suse.de, dcashman@google.com, arnd@arndb.de, jonathanh@nvidia.com

On 12/14/2015 10:58 AM, H. Peter Anvin wrote:
> On 12/11/15 09:52, Daniel Cashman wrote:
>> diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
>> index 844b06d..647fecf 100644
>> --- a/arch/x86/mm/mmap.c
>> +++ b/arch/x86/mm/mmap.c
>> @@ -69,14 +69,14 @@ unsigned long arch_mmap_rnd(void)
>>  {
>>  	unsigned long rnd;
>>  
>> -	/*
>> -	 *  8 bits of randomness in 32bit mmaps, 20 address space bits
>> -	 * 28 bits of randomness in 64bit mmaps, 40 address space bits
>> -	 */
>>  	if (mmap_is_ia32())
>> -		rnd = (unsigned long)get_random_int() % (1<<8);
>> +#ifdef CONFIG_COMPAT
>> +		rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_compat_bits);
>> +#else
>> +		rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_bits);
>> +#endif
>>  	else
>> -		rnd = (unsigned long)get_random_int() % (1<<28);
>> +		rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_bits);
>>  
>>  	return rnd << PAGE_SHIFT;
>>  }
>>
> 
> Now, you and I know that both variants can be implemented with a simple
> AND, but I have a strong suspicion that once this is turned into a
> variable, this will in fact be changed from an AND to a divide.
> 
> So I'd prefer to use the
> "get_random_int() & ((1UL << mmap_rnd_bits) - 1)" construct instead.

Good point.  Will change in v7 across patch-set.

Thank You,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
