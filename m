Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 03EB36B0253
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 17:12:44 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id i15so12753749pfa.15
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 14:12:43 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id t71si11514401pgb.823.2017.11.21.14.12.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 14:12:43 -0800 (PST)
Subject: Re: [PATCH 12/30] x86, kaiser: map GDT into user page tables
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193125.EBF58596@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711202115190.2348@nanos>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <6f13e451-c333-d966-4169-ccda7a02ae06@linux.intel.com>
Date: Tue, 21 Nov 2017 14:12:40 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711202115190.2348@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On 11/20/2017 12:22 PM, Thomas Gleixner wrote:
> On Fri, 10 Nov 2017, Dave Hansen wrote:
>>  	__set_fixmap(get_cpu_gdt_ro_index(cpu), get_cpu_gdt_paddr(cpu), prot);
>> +
>> +	/* CPU 0's mapping is done in kaiser_init() */
>> +	if (cpu) {
>> +		int ret;
>> +
>> +		ret = kaiser_add_mapping((unsigned long) get_cpu_gdt_ro(cpu),
>> +					 PAGE_SIZE, __PAGE_KERNEL_RO);
>> +		/*
>> +		 * We do not have a good way to fail CPU bringup.
>> +		 * Just WARN about it and hope we boot far enough
>> +		 * to get a good log out.
>> +		 */
> 
> The GDT fixmap can be set up before the CPU is started. There is no reason
> to do that in cpu_init().

Do you mean the __set_fixmap(), or my call to kaiser_add_mapping()?

Where would you suggest we move it?  Here seems kinda nice because it's
right next to where the get_cpu_gdt_ro() mapping is created.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
