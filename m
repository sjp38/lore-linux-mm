Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B52786B0047
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 18:17:46 -0400 (EDT)
Message-ID: <49D144D6.9000001@redhat.com>
Date: Tue, 31 Mar 2009 01:16:54 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 0/6] Guest page hinting version 7.
References: <20090327150905.819861420@de.ibm.com>	<1238195024.8286.562.camel@nimitz>	<20090329161253.3faffdeb@skybase>	<1238428495.8286.638.camel@nimitz> <49D11184.3060002@goop.org>	<49D11287.4030307@redhat.com> <49D11674.9040205@goop.org>	<49D12564.40708@redhat.com> <49D12D16.6050407@goop.org> <49D13BB9.3010200@redhat.com>
In-Reply-To: <49D13BB9.3010200@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Rik van Riel <riel@redhat.com>, akpm@osdl.org, nickpiggin@yahoo.com.au, frankeh@watson.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, virtualization@lists.osdl.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, hugh@veritas.com, dlaor@redhat.com
List-ID: <linux-mm.kvack.org>

Jeremy Fitzhardinge wrote:
>> Rik van Riel wrote:
>>  
>>> Jeremy Fitzhardinge wrote:
>>>    
>>>> Rik van Riel wrote:
>>>>      
>>>>> Jeremy Fitzhardinge wrote:
>>>>>
>>>>>        
>>>>>> That said, people have been looking at tracking block IO to work 
>>>>>> out when it might be useful to try and share pages between guests 
>>>>>> under Xen.
>>>>>>           
>>>>> Tracking block IO seems like a bass-ackwards way to figure
>>>>> out what the contents of a memory page are.
>>>>>         
>>>> Well, they're research projects, so nobody said that they're 
>>>> necessarily useful results ;).  I think the rationale is that, in 
>>>> general, there aren't all that many sharable pages, and asize from 
>>>> zero-pages, the bulk of them are the result of IO.       
>>> I'll give you a hint:  Windows zeroes out freed pages.
>>>     
>>
>> Right: "aside from zero-pages".  If you exclude zero-pages from your 
>> count of shared pages, the amount of sharing drops a lot.

20026 root      15   0  707m 526m 246m S  7.0 14.0   0:39.57 
qemu-system-x86                                                                                                       

20010 root      15   0  707m 526m 239m S  6.3 14.0   0:47.16 
qemu-system-x86                                                                                                       

20015 root      15   0  707m 526m 247m S  5.7 14.0   0:46.84 
qemu-system-x86                                                                                                       

20031 root      15   0  707m 526m 242m S  5.7 14.1   0:46.74 
qemu-system-x86                                                                                                       

20005 root      15   0  707m 526m 239m S  0.3 14.0   0:54.16 qemu-system-x86

I just ran 5 debian 5.0 guests with each have 512 mb physical ram,
all i did was just open X, and then open thunderbird and firefox in 
them, check the SHR field...

You cannot ignore the fact that the librarys and the kernel would be 
identical among guests and would be shared...
Other than the library we got the big bonus that is called zero page in 
windows, but that is really not the case for the above example since 
thigs guests are linux.....

>>
>>  
>>> It should also be possible to hook up arch_free_page() so
>>> freed pages in Linux guests become sharable.
>>>
>>> Furthermore, every guest with the same OS version will be
>>> running the same system daemons, same glibc, etc.  This
>>> means sharable pages from not just disk IO (probably from
>>> different disks anyway),
>>>     
>>
>> Why?  If you're starting a bunch of cookie-cutter guests, then you're 
>> probably starting them from the same template image or COW block 
>> devices.  (Also, if you're wearing the cost of physical IO anyway, 
>> then additional cost of hashing is relatively small.)
>>
>>  
>>> but also in the BSS and possibly
>>> even on the heap.
>>>     
>>
>> Well, maybe.  Modern systems generally randomize memory layouts, so 
>> even if they're semantically the same, the pointers will all have 
>> different values.
>>
>> Other research into "sharing" mostly-similar pages is more promising 
>> for that kind of case.
>>
>>  
>>> Eventually.  It starts out with hashing the first 128 (IIRC)
>>> bytes of page content and comparing the hashes.  If that
>>> matches, it will do content comparison.
>>>     
> The algorithm was changed quite a bit. Izik is planning to resubmit it
> any day now.
>>> Content comparison is done in the background on the host.
>>> I suspect (but have not checked) that it is somehow hooked
>>> up to the page reclaim code on the host.
>>>     
>>
>> Yeah, that's the straightforward approach; there's about a research 
>> project/year doing a Xen implementation, but they never seem to get 
>> very good results aside from very artificial test conditions.
I keep hear this argument from Microsoft but even in the hardest test 
condition, how would you make the librarys and the kernel wont be 
identical among the guests?.

Anyway Page sharing is running and installed for our customers and so 
far i only hear from sells guys how surprised and happy the costumers 
are from the overcommit that page sharing is offer...


Anyway i have ready massive-changed (mostly the logical algorithm for 
finding pages) ksm version that i made against the mainline version and 
is ready to be send after i will get some better benchmarks numbers to 
post on the list when together with the patch...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
