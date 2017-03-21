Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DF3BC6B038A
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 05:23:51 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 21so166819304pgg.4
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 02:23:51 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0138.outbound.protection.outlook.com. [104.47.0.138])
        by mx.google.com with ESMTPS id 16si14644538pfc.284.2017.03.21.02.23.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 21 Mar 2017 02:23:50 -0700 (PDT)
Subject: Re: [PATCH 2/3] asm-generic, x86: wrap atomic operations
References: <cover.1489519233.git.dvyukov@google.com>
 <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
 <20170320171718.GL31213@leverpostej>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <956a8e10-e03f-a21c-99d9-8a75c2616e0a@virtuozzo.com>
Date: Tue, 21 Mar 2017 12:25:06 +0300
MIME-Version: 1.0
In-Reply-To: <20170320171718.GL31213@leverpostej>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com, akpm@linux-foundation.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On 03/20/2017 08:17 PM, Mark Rutland wrote:
> Hi,
> 
> On Tue, Mar 14, 2017 at 08:24:13PM +0100, Dmitry Vyukov wrote:
>>  /**
>> - * atomic_read - read atomic variable
>> + * arch_atomic_read - read atomic variable
>>   * @v: pointer of type atomic_t
>>   *
>>   * Atomically reads the value of @v.
>>   */
>> -static __always_inline int atomic_read(const atomic_t *v)
>> +static __always_inline int arch_atomic_read(const atomic_t *v)
>>  {
>> -	return READ_ONCE((v)->counter);
>> +	/*
>> +	 * We use READ_ONCE_NOCHECK() because atomic_read() contains KASAN
>> +	 * instrumentation. Double instrumentation is unnecessary.
>> +	 */
>> +	return READ_ONCE_NOCHECK((v)->counter);
>>  }
> 
> Just to check, we do this to avoid duplicate reports, right?
> 
> If so, double instrumentation isn't solely "unnecessary"; it has a
> functional difference, and we should explicitly describe that in the
> comment.
> 
> ... or are duplicate reports supressed somehow?
> 

They are not suppressed yet. But I think we should just switch kasan to single shot mode,
i.e. report only the first error. Single bug quite often has multiple invalid memory accesses
causing storm in dmesg. Also write OOB might corrupt metadata so the next report will print
bogus alloc/free stacktraces.
In most cases we need to look only at the first report, so reporting anything after the first
is just counterproductive.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
