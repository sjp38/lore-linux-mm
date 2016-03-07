Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id DE3C26B0257
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 13:12:20 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id tt10so20586491pab.3
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 10:12:20 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 75si30297641pfs.118.2016.03.07.10.12.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 10:12:20 -0800 (PST)
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
References: <1456951177-23579-1-git-send-email-khalid.aziz@oracle.com>
 <20160305.230702.1325379875282120281.davem@davemloft.net>
 <56DD9949.1000106@oracle.com>
 <20160307.115626.807716799249471744.davem@davemloft.net>
 <56DDC2B6.6020009@oracle.com>
From: Rob Gardner <rob.gardner@oracle.com>
Message-ID: <56DDC3EB.8060909@oracle.com>
Date: Mon, 7 Mar 2016 10:09:47 -0800
MIME-Version: 1.0
In-Reply-To: <56DDC2B6.6020009@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, David Miller <davem@davemloft.net>
Cc: corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On 03/07/2016 10:04 AM, Khalid Aziz wrote:
> On 03/07/2016 09:56 AM, David Miller wrote:
>> From: Khalid Aziz <khalid.aziz@oracle.com>
>> Date: Mon, 7 Mar 2016 08:07:53 -0700
>>
>>> PR_GET_SPARC_ADICAPS
>>
>> Put this into a new ELF auxiliary vector entry via ARCH_DLINFO.
>>
>> So now all that's left is supposedly the TAG stuff, please explain
>> that to me so I can direct you to the correct existing interface to
>> provide that as well.
>>
>> Really, try to avoid prtctl, it's poorly typed and almost worse than
>> ioctl().
>>
>
> The two remaining operations I am looking at are:
>
> 1. Is PSTATE.mcde bit set for the process? PR_SET_SPARC_ADI provides 
> this in its return value in the patch I sent.
>
> 2. Is TTE.mcd set for a given virtual address? PR_GET_SPARC_ADI_STATUS 
> provides this function in the patch I sent.
>
> Setting and clearing version tags can be done entirely from userspace:
>
>         while (addr < end) {
>                 asm volatile(
>                         "stxa %1, [%0]ASI_MCD_PRIMARY\n\t"
>                         :
>                         : "r" (addr), "r" (version));
>                 addr += adicap.blksz;
>         }
> so I do not have to add any kernel code for tags.
>

What about clearing the tags when the user is done with the memory? You 
can't count on the user to do that, so doesn't the kernel have to do it 
someplace?

Rob


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
