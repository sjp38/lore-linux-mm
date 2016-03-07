Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 079686B0254
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 10:08:28 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id ts10so107758276obc.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 07:08:28 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id g7si5140237obf.80.2016.03.07.07.08.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 07:08:27 -0800 (PST)
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
References: <1456951177-23579-1-git-send-email-khalid.aziz@oracle.com>
 <20160305.230702.1325379875282120281.davem@davemloft.net>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <56DD9949.1000106@oracle.com>
Date: Mon, 7 Mar 2016 08:07:53 -0700
MIME-Version: 1.0
In-Reply-To: <20160305.230702.1325379875282120281.davem@davemloft.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, zhenzhang.zhang@huawei.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org, rob.gardner@oracle.com, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On 03/05/2016 09:07 PM, David Miller wrote:
> From: Khalid Aziz <khalid.aziz@oracle.com>
> Date: Wed,  2 Mar 2016 13:39:37 -0700
>
>> 	In this
>> 	first implementation I am enabling ADI for hugepages only
>> 	since these pages are locked in memory and hence avoid the
>> 	issue of saving and restoring tags.
>
> This makes the feature almost entire useless.
>
> Non-hugepages must be in the initial implementation.

Hi David,

Thanks for the feedback. I will get this working for non-hugepages as 
well. ADI state of each VMA region is already stored in the VMA itself 
in my first implementation, so I do not lose it when the page is swapped 
out. The trouble is ADI version tags for each VMA region have to be 
stored on the swapped out pages since the ADI version tags are flushed 
when TLB entry for a page is flushed. When that page is brought back in, 
its version tags have to be set up again. Version tags are set on 
cacheline boundary and hence there can be multiple version tags for a 
single page. Version tags have to be stored in the swap space somehow 
along with the page. I can start out with allowing ADI to be enabled 
only on pages locked in memory.

>
>> +	PR_ENABLE_SPARC_ADI - Enable ADI checking in all pages in the address
>> +		range specified. The pages in the range must be already
>> +		locked. This operation enables the TTE.mcd bit for the
>> +		pages specified. arg2 is the starting address for address
>> +		range and must be page aligned. arg3 is the length of
>> +		memory address range and must be a multiple of page size.
>
> I strongly dislike this interface, and it makes the prtctl cases look
> extremely ugly and hide to the casual reader what the code is actually
> doing.
>
> This is an mprotect() operation, so add a new flag bit and implement
> this via mprotect please.

That is an interesting idea. Adding a PROT_ADI protection to mprotect() 
sounds cleaner. There are three steps to enabling ADI - (1) set 
PSTATE.mcde bit which is not tied to any VMA, (2) set TTE.mcd for each 
VMA, and (3) set the version tag on cacheline using MCD ASI. I can 
combine steps 1 and 2 in one mprotect() call. That will leave 
PR_GET_SPARC_ADICAPS and PR_GET_SPARC_ADI_STATUS prctl commands still to 
be implemented. PR_SET_SPARC_ADI is also used to check if the process 
has PSTATE.mcde bit set. I could use PR_GET_SPARC_ADI_STATUS to do that 
where return values of 0 and 1 mean the same as before and possibly add 
return value of 2 to mean PSTATE.mcde is not set?

>
> Then since you are guarenteed to have a consistent ADI setting for
> every single VMA region, you never "lose" the ADI state when you swap
> out.  It's implicit in the VMA itself, because you'll store in the VMA
> that this is an ADI region.
>
> I also want this enabled unconditionally, without any Kconfig knobs.
>

I can remove CONFIG_SPARC_ADI. It does mean this code will be built into 
32-bit kernels as well but it will be inactive code.

Thanks,
Khalid



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
