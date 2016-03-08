Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id EFDA86B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 15:16:55 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id bj10so19915191pad.2
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 12:16:55 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id xy2si6767693pab.48.2016.03.08.12.16.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 12:16:55 -0800 (PST)
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
References: <56DDA6FD.4040404@oracle.com> <56DDBE68.6080709@linux.intel.com>
 <56DDED63.8010302@oracle.com>
 <20160308.145748.1648298790157991002.davem@davemloft.net>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <56DF330B.2010600@oracle.com>
Date: Tue, 8 Mar 2016 13:16:11 -0700
MIME-Version: 1.0
In-Reply-To: <20160308.145748.1648298790157991002.davem@davemloft.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: dave.hansen@linux.intel.com, luto@amacapital.net, rob.gardner@oracle.com, corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On 03/08/2016 12:57 PM, David Miller wrote:
> From: Khalid Aziz <khalid.aziz@oracle.com>
> Date: Mon, 7 Mar 2016 14:06:43 -0700
>
>> Good questions. Isn't set of valid VAs already constrained by VA_BITS
>> (set to 44 in arch/sparc/include/asm/processor_64.h)? As I see it we
>> are already not using the top 4 bits. Please correct me if I am wrong.
>
> Another limiting constraint is the number of address bits coverable by
> the 4-level page tables we use.  And this is sign extended so we have
> a top-half and a bottom-half with a "hole" in the center of the VA
> space.
>
> I want some clarification on the top bits during ADI accesses.
>
> If ADI is enabled, then the top bits of the virtual address are
> intepreted as tag bits.  Once "verified" with the ADI settings, what
> happense to these tag bits?  Are they dropped from the virtual address
> before being passed down the TLB et al. for translations?

Bits 63-60 (tag bits) are dropped from the virtual address before being 
passed down the TLB for translation when PSTATE.mcde = 1.

--
Khalid

>
> If not, then this means you have to map ADI memory to the correct
> location so that the tags match up.
>
> And if that's the case, if you really wanted to mix tags within a
> single page, you'd have to map that page several times, once for each
> and every cacheline granular tag you'd like to use within that page.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
