Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1B6A96B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 15:42:09 -0400 (EDT)
Message-ID: <49D5141F.40900@redhat.com>
Date: Thu, 02 Apr 2009 22:38:07 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux
References: <1238457560-7613-1-git-send-email-ieidus@redhat.com> <alpine.LNX.2.00.0904022114040.4265@swampdragon.chaosbits.net>
In-Reply-To: <alpine.LNX.2.00.0904022114040.4265@swampdragon.chaosbits.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

Jesper Juhl wrote:
> Hi,
>
> On Tue, 31 Mar 2009, Izik Eidus wrote:
>
>   
>> KSM is a linux driver that allows dynamicly sharing identical memory
>> pages between one or more processes.
>>
>> Unlike tradtional page sharing that is made at the allocation of the
>> memory, ksm do it dynamicly after the memory was created.
>> Memory is periodically scanned; identical pages are identified and
>> merged.
>> The sharing is unnoticeable by the process that use this memory.
>> (the shared pages are marked as readonly, and in case of write
>> do_wp_page() take care to create new copy of the page)
>>
>> To find identical pages ksm use algorithm that is split into three
>> primery levels:
>>
>> 1) Ksm will start scan the memory and will calculate checksum for each
>>    page that is registred to be scanned.
>>    (In the first round of the scanning, ksm would only calculate
>>     this checksum for all the pages)
>>
>>     
>
> One question;
>
> Calcolating a checksum is a fine way to find pages that are "likely to be 
> identical"

I dont use checksum as with hash table, the checksum doesnt use to find 
identical pages by the way that they have similer data...
the checksum is used to let me know that the page was not changed for a 
while and it is worth checking for identical pages to it...
In the future we will want to use the page table dirty bit for it, as 
taking checksum is somewhat expensive

> , but there is no guarantee that two pages with the same 
> checksum really are identical - there *will* be checksum collisions 
> eventually. So, I really hope that your implementation actually checks 
> that two pages that it find that have identical checksums really are 100% 
> identical by comparing them bit by bit before throwing one away.
>   
We do that :-)

> If you rely only on a checksum then eventually a user will get bitten by a 
> checksum collision and, in the best case, something will crash, and in the 
> worst case, data will silently be corrupted.
>
> Do you rely only on the checksum or do you actually compare pages to check 
> they are 100% identical before sharing?
>   

I do 100% compare to the pages before i share them.

> I must admit that I have not read through the patch to find the answer, I 
> just read your description and became concerned.
>
>   
Dont worry, me neither :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
