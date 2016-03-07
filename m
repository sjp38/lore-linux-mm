Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id E3F2C6B0254
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 18:16:13 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id fp4so6207836obb.2
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 15:16:13 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id i199si5835866oib.83.2016.03.07.15.16.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 15:16:13 -0800 (PST)
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
References: <56DDC776.3040003@oracle.com>
 <20160307.141600.1873883635480850431.davem@davemloft.net>
 <56DDF3C4.7070701@oracle.com>
 <20160307.163850.1494834587897617780.davem@davemloft.net>
From: Rob Gardner <rob.gardner@oracle.com>
Message-ID: <56DE0B1B.1000000@oracle.com>
Date: Mon, 7 Mar 2016 15:13:31 -0800
MIME-Version: 1.0
In-Reply-To: <20160307.163850.1494834587897617780.davem@davemloft.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, khalid.aziz@oracle.com
Cc: corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On 03/07/2016 01:38 PM, David Miller wrote:
> From: Khalid Aziz <khalid.aziz@oracle.com>
> Date: Mon, 7 Mar 2016 14:33:56 -0700
>
>> On 03/07/2016 12:16 PM, David Miller wrote:
>>> From: Khalid Aziz <khalid.aziz@oracle.com>
>>> Date: Mon, 7 Mar 2016 11:24:54 -0700
>>>
>>>> Tags can be cleared by user by setting tag to 0. Tags are
>>>> automatically cleared by the hardware when the mapping for a virtual
>>>> address is removed from TSB (which is why swappable pages are a
>>>> problem), so kernel does not have to do it as part of clean up.
>>> You might be able to crib some bits for the Tag in the swp_entry_t,
>>> it's
>>> 64-bit and you can therefore steal bits from the offset field.
>>>
>>> That way you'll have the ADI tag in the page tables, ready to
>>> re-install
>>> at swapin time.
>>>
>> That is a possibility but limited in scope. An address range covered
>> by a single TTE can have large number of tags. Version tags are set on
>> cacheline. In extreme case, one could set a tag for each set of
>> 64-bytes in a page. Also tags are set completely in userspace and no
>> transition occurs to kernel space, so kernel has no idea of what tags
>> have been set. I have not found a way to query the MMU on tags.
>>
>> I will think some more about it.
> That would mean that ADI is impossible to use for swappable memory.
>
> ...
>
> If that's true I'm extremely disappointed that they devoted so much
> silicon and engineering to this feature yet didn't take that one
> critical step to make it generally useful. :(

You can easily read ADI tags with a simple ldxa #ASI_MCD_PRIMARY 
instruction.

Rob


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
