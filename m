Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 50B3A828E2
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 15:27:53 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id 63so20620647pfe.3
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 12:27:53 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id qz9si6803260pab.94.2016.03.08.12.27.51
        for <linux-mm@kvack.org>;
        Tue, 08 Mar 2016 12:27:51 -0800 (PST)
Date: Tue, 08 Mar 2016 15:27:46 -0500 (EST)
Message-Id: <20160308.152746.1746115669072714849.davem@davemloft.net>
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
From: David Miller <davem@davemloft.net>
In-Reply-To: <56DF330B.2010600@oracle.com>
References: <56DDED63.8010302@oracle.com>
	<20160308.145748.1648298790157991002.davem@davemloft.net>
	<56DF330B.2010600@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: khalid.aziz@oracle.com
Cc: dave.hansen@linux.intel.com, luto@amacapital.net, rob.gardner@oracle.com, corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

From: Khalid Aziz <khalid.aziz@oracle.com>
Date: Tue, 8 Mar 2016 13:16:11 -0700

> On 03/08/2016 12:57 PM, David Miller wrote:
>> From: Khalid Aziz <khalid.aziz@oracle.com>
>> Date: Mon, 7 Mar 2016 14:06:43 -0700
>>
>>> Good questions. Isn't set of valid VAs already constrained by VA_BITS
>>> (set to 44 in arch/sparc/include/asm/processor_64.h)? As I see it we
>>> are already not using the top 4 bits. Please correct me if I am wrong.
>>
>> Another limiting constraint is the number of address bits coverable by
>> the 4-level page tables we use.  And this is sign extended so we have
>> a top-half and a bottom-half with a "hole" in the center of the VA
>> space.
>>
>> I want some clarification on the top bits during ADI accesses.
>>
>> If ADI is enabled, then the top bits of the virtual address are
>> intepreted as tag bits.  Once "verified" with the ADI settings, what
>> happense to these tag bits?  Are they dropped from the virtual address
>> before being passed down the TLB et al. for translations?
> 
> Bits 63-60 (tag bits) are dropped from the virtual address before
> being passed down the TLB for translation when PSTATE.mcde = 1.

Ok and you said that values 15 and 0 are special.

I'm just wondering if this means you can't really use ADI mappings in
the top half of the 64-bit address space.  If the bits are dropped, they
will be zero, but they need to be all 1's for the top-half of the VA
space since it's sign extended.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
