Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2BABF6B025F
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 11:27:28 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o42so794462wrb.2
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 08:27:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s19si4049699wrc.141.2017.09.29.08.27.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Sep 2017 08:27:26 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8TFObkI111462
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 11:27:25 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2d9mqyr7aw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 11:27:25 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 29 Sep 2017 16:27:21 +0100
Subject: Re: [PATCH v3 00/20] Speculative page faults
References: <CAADnVQLmSbLHwj9m33kpzAidJPvq3cbdnXjaew6oTLqHWrBbZQ@mail.gmail.com>
 <20170925163443.260d6092160ec704e2b04653@linux-foundation.org>
 <924a79af-6d7a-316a-1eee-3aebbfd4addf@linux.vnet.ibm.com>
 <20170928133850.90c5bf2aac0f1a63e29c01a3@linux-foundation.org>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Fri, 29 Sep 2017 17:27:09 +0200
MIME-Version: 1.0
In-Reply-To: <20170928133850.90c5bf2aac0f1a63e29c01a3@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <64e9759b-a4fb-63d3-a811-3e35ae5a1028@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, kirill@shutemov.name, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, dave@stgolabs.net, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, haren@linux.vnet.ibm.com, Anshuman Khandual <khandual@linux.vnet.ibm.com>, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, "x86@kernel.org" <x86@kernel.org>

Hi Andrew,

On 28/09/2017 22:38, Andrew Morton wrote:
> On Thu, 28 Sep 2017 14:29:02 +0200 Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:
> 
>>> Laurent's [0/n] provides some nice-looking performance benefits for
>>> workloads which are chosen to show performance benefits(!) but, alas,
>>> no quantitative testing results for workloads which we may suspect will
>>> be harmed by the changes(?).  Even things as simple as impact upon
>>> single-threaded pagefault-intensive workloads and its effect upon
>>> CONFIG_SMP=n .text size?
>>
>> I forgot to mention in my previous email the impact on the .text section.
>>
>> Here are the metrics I got :
>>
>> .text size	UP		SMP		Delta
>> 4.13-mmotm	8444201		8964137		6.16%
>> '' +spf		8452041		8971929		6.15%
>> 	Delta	0.09%		0.09%	
>>
>> No major impact as you could see.
> 
> 8k text increase seems rather a lot actually.  That's a lot more
> userspace cacheclines that get evicted during a fault...
> 
> Is the feature actually beneficial on uniprocessor?

This is useless on uniprocessor, and I will disable it on x86 when !SMP 
by not defining __HAVE_ARCH_CALL_SPF.
So the speculative page fault handler will not be built but the vm 
sequence counter and the SCRU stuff will still be there. I may also make 
it disabled through macro when __HAVE_ARCH_CALL_SPF is not defined, but 
this may obfuscated the code a bit...

On ppc64, as this feature requires book3s, it can't be built without SMP 
support.

I rebuild the code on my x86 guest with the following patch applied:
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -260,7 +260,7 @@ enum page_cache_mode {
  /*
   * Advertise that we call the Speculative Page Fault handler.
   */
-#ifdef CONFIG_X86_64
+#if defined(CONFIG_X86_64) && defined(CONFIG_SMP)
  #define __HAVE_ARCH_CALL_SPF
  #endif

And this time I got the following size on UP :
		UP
4.13-mmotm	8444201
'' +spf		8447945 (previously 8452041)
		  +3744

If I disable all the vm_sequence operations and the SRCU stuff this 
would lead to 0.

Thanks,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
