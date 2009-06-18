Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id ECB336B005C
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 10:45:39 -0400 (EDT)
Message-ID: <4A3A53C9.4030609@kernel.org>
Date: Thu, 18 Jun 2009 23:48:41 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [this_cpu_xx V2 10/19] this_cpu: X86 optimized this_cpu operations
References: <20090617203337.399182817@gentwo.org> <20090617203444.731295080@gentwo.org> <4A39ADBF.1000505@kernel.org> <alpine.DEB.1.10.0906181001420.15556@gentwo.org>
In-Reply-To: <alpine.DEB.1.10.0906181001420.15556@gentwo.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Hello,

Christoph Lameter wrote:
>>  DEFINE_PER_CPU(int, my_pcpu_cnt);
>>  void my_func(void)
>>  {
>> 	 int *ptr = &per_cpu__my_pcpu_cnt;
>>
>> 	 *(int *)this_cpu_ptr(ptr) = 0;
>> 	 this_cpu_add(ptr, 1);
> 
> Needs to be this_cpu_add(*ptr, 1). this_cpu_add does not take a pointer
> to an int but a lvalue. The typical use case is with a struct. I.e.
> 
> struct {
> 	int x;
> } * ptr = &per_cpu_var(m_cpu_pnt);
> 
> then do
> 
> this_cpu_add(ptr->x, 1)
> 
> 
>> 	 percpu_add(my_pcpu_cnt, 1);
>>  }
>>
>> So, this_cpu_add(ptr, 1) ends up accessing the wrong address.  Also,
>> please note the use of 'addq' instead of 'addl' as the pointer
>> variable is being modified.
> 
> You incremented the pointer instead of the value pointed to. Look at the
> patches that use this_cpu_add(). You pass the object to be incremented not
> a pointer. If the convention would be different then the address would
> have to be taken of these objects everywhere.

Ah... okay, so it's supposed to take a lvalue.  I think it would be
better to make it take pointer.  lvalue parameter is just weird when
dynamic percpu variables are involved.  The old percpu accessors
taking lvalue has more to do with the way percpu variables were
defined in the beginning than anything else and are inconsistent with
other similar accessors in the kernel.  As the new accessors are gonna
replace the old ones eventually and maybe leave only the most often
used ones as wrapper around pointer based ones, I think it would be
better to make the transition while introducing new accessors.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
