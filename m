Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 363486B0253
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 10:45:49 -0500 (EST)
Received: by mail-oi0-f54.google.com with SMTP id c203so81858509oia.2
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 07:45:49 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id h67si12315918oia.123.2016.03.07.07.45.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 07:45:48 -0800 (PST)
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
References: <1456951177-23579-1-git-send-email-khalid.aziz@oracle.com>
 <20160305.230702.1325379875282120281.davem@davemloft.net>
 <56DD9949.1000106@oracle.com> <56DD9E94.70201@oracle.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <56DDA211.20807@oracle.com>
Date: Mon, 7 Mar 2016 08:45:21 -0700
MIME-Version: 1.0
In-Reply-To: <56DD9E94.70201@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Gardner <rob.gardner@oracle.com>, David Miller <davem@davemloft.net>
Cc: corbet@lwn.net, akpm@linux-foundation.org, dingel@linux.vnet.ibm.com, bob.picco@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, arnd@arndb.de, sparclinux@vger.kernel.org, mhocko@suse.cz, chris.hyser@oracle.com, richard@nod.at, vbabka@suse.cz, koct9i@gmail.com, oleg@redhat.com, gthelen@google.com, jack@suse.cz, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, luto@kernel.org, ebiederm@xmission.com, bsegall@google.com, geert@linux-m68k.org, dave@stgolabs.net, adobriyan@gmail.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On 03/07/2016 08:30 AM, Rob Gardner wrote:
> On 03/07/2016 07:07 AM, Khalid Aziz wrote:
>> On 03/05/2016 09:07 PM, David Miller wrote:
>>> From: Khalid Aziz <khalid.aziz@oracle.com>
>>> Date: Wed,  2 Mar 2016 13:39:37 -0700
>>>
>>>>     In this
>>>>     first implementation I am enabling ADI for hugepages only
>>>>     since these pages are locked in memory and hence avoid the
>>>>     issue of saving and restoring tags.
>>>
>>> This makes the feature almost entire useless.
>>>
>>> Non-hugepages must be in the initial implementation.
>>
>> Hi David,
>>
>> Thanks for the feedback. I will get this working for non-hugepages as
>> well. ADI state of each VMA region is already stored in the VMA itself
>> in my first implementation, so I do not lose it when the page is
>> swapped out. The trouble is ADI version tags for each VMA region have
>> to be stored on the swapped out pages since the ADI version tags are
>> flushed when TLB entry for a page is flushed.
>
>
> Khalid,
>
> Are you sure about that last statement? My understanding is that the
> tags are stored in physical memory, and remain there until explicitly
> changed or removed, and so flushing a TLB entry has no effect on the ADI
> tags. If it worked the way you think, then somebody would have to
> potentially reload a long list of ADI tags on every TLB miss.
>
> Rob
>

Hi Rob,

I am fairly sure that is the case. This is what I found from the 
processor guys and others working on ADI. I tested it out by setting up 
ADI on normal malloc'd pages that got swapped out and I got MCD 
exceptions when those pages were swapped back in on access.

I mis-spoke when I said "....ADI version tags are flushed when TLB entry 
for a page is flushed". I meant ADI version tags are flushed when 
mapping for a virtual address is removed from TSB, not when TLB entry is 
flushed. Yes, ADI tags are stored in physical memory and removed when 
mapping is removed.

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
