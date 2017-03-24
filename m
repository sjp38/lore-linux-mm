Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 83ED36B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 05:14:25 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n11so15596664pfg.7
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 02:14:25 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s3si1943820pgn.344.2017.03.24.02.14.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 02:14:22 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2O992S5054043
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 05:14:22 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29cm3u02h9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 05:14:21 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 24 Mar 2017 03:14:21 -0600
Subject: Re: [PATCH 26/26] x86/mm: allow to have userspace mappings above
 47-bits
References: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
 <20170313055020.69655-27-kirill.shutemov@linux.intel.com>
 <8760j4sfcz.fsf@skywalker.in.ibm.com>
 <20170324090408.xsj7othssj547w5k@node.shutemov.name>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Fri, 24 Mar 2017 14:44:10 +0530
MIME-Version: 1.0
In-Reply-To: <20170324090408.xsj7othssj547w5k@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Message-Id: <d1007940-5066-4fcf-9744-0bb0514b33d4@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On Friday 24 March 2017 02:34 PM, Kirill A. Shutemov wrote:
> On Mon, Mar 20, 2017 at 10:40:20AM +0530, Aneesh Kumar K.V wrote:
>> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
>>  @@ -168,6 +182,10 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>>>  	unsigned long addr = addr0;
>>>  	struct vm_unmapped_area_info info;
>>>
>>> +	addr = mpx_unmapped_area_check(addr, len, flags);
>>> +	if (IS_ERR_VALUE(addr))
>>> +		return addr;
>>> +
>>>  	/* requested length too big for entire address space */
>>>  	if (len > TASK_SIZE)
>>>  		return -ENOMEM;
>>> @@ -192,6 +210,14 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>>>  	info.length = len;
>>>  	info.low_limit = PAGE_SIZE;
>>>  	info.high_limit = mm->mmap_base;
>>> +
>>> +	/*
>>> +	 * If hint address is above DEFAULT_MAP_WINDOW, look for unmapped area
>>> +	 * in the full address space.
>>> +	 */
>>> +	if (addr > DEFAULT_MAP_WINDOW)
>>> +		info.high_limit += TASK_SIZE - DEFAULT_MAP_WINDOW;
>>> +
>>
>> Is this ok for 32 bit application ?
>
> DEFAULT_MAP_WINDOW is equal to TASK_SIZE on 32-bit, so it's nop and will
> be compile out.
>

That is not about CONFIG_X86_32 but about 32 bit application on a 64 bit 
kernel. I guess we will never find addr > DEFAULT_MAP_WINDOW with
a 32 bit app ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
