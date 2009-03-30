Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1F3736B004D
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 17:37:58 -0400 (EDT)
Message-ID: <49D13BB9.3010200@redhat.com>
Date: Tue, 31 Mar 2009 00:38:01 +0300
From: Dor Laor <dlaor@redhat.com>
Reply-To: dlaor@redhat.com
MIME-Version: 1.0
Subject: Re: [patch 0/6] Guest page hinting version 7.
References: <20090327150905.819861420@de.ibm.com>	<1238195024.8286.562.camel@nimitz>	<20090329161253.3faffdeb@skybase>	<1238428495.8286.638.camel@nimitz> <49D11184.3060002@goop.org>	<49D11287.4030307@redhat.com> <49D11674.9040205@goop.org>	<49D12564.40708@redhat.com> <49D12D16.6050407@goop.org>
In-Reply-To: <49D12D16.6050407@goop.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Rik van Riel <riel@redhat.com>, akpm@osdl.org, nickpiggin@yahoo.com.au, frankeh@watson.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, virtualization@lists.osdl.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, hugh@veritas.com, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

Jeremy Fitzhardinge wrote:
> Rik van Riel wrote:
>   
>> Jeremy Fitzhardinge wrote:
>>     
>>> Rik van Riel wrote:
>>>       
>>>> Jeremy Fitzhardinge wrote:
>>>>
>>>>         
>>>>> That said, people have been looking at tracking block IO to work 
>>>>> out when it might be useful to try and share pages between guests 
>>>>> under Xen.
>>>>>           
>>>> Tracking block IO seems like a bass-ackwards way to figure
>>>> out what the contents of a memory page are.
>>>>         
>>> Well, they're research projects, so nobody said that they're 
>>> necessarily useful results ;).  I think the rationale is that, in 
>>> general, there aren't all that many sharable pages, and asize from 
>>> zero-pages, the bulk of them are the result of IO. 
>>>       
>> I'll give you a hint:  Windows zeroes out freed pages.
>>     
>
> Right: "aside from zero-pages".  If you exclude zero-pages from your 
> count of shared pages, the amount of sharing drops a lot.
>
>   
>> It should also be possible to hook up arch_free_page() so
>> freed pages in Linux guests become sharable.
>>
>> Furthermore, every guest with the same OS version will be
>> running the same system daemons, same glibc, etc.  This
>> means sharable pages from not just disk IO (probably from
>> different disks anyway),
>>     
>
> Why?  If you're starting a bunch of cookie-cutter guests, then you're 
> probably starting them from the same template image or COW block 
> devices.  (Also, if you're wearing the cost of physical IO anyway, then 
> additional cost of hashing is relatively small.)
>
>   
>> but also in the BSS and possibly
>> even on the heap.
>>     
>
> Well, maybe.  Modern systems generally randomize memory layouts, so even 
> if they're semantically the same, the pointers will all have different 
> values.
>
> Other research into "sharing" mostly-similar pages is more promising for 
> that kind of case.
>
>   
>> Eventually.  It starts out with hashing the first 128 (IIRC)
>> bytes of page content and comparing the hashes.  If that
>> matches, it will do content comparison.
>>     
The algorithm was changed quite a bit. Izik is planning to resubmit it
any day now.
>> Content comparison is done in the background on the host.
>> I suspect (but have not checked) that it is somehow hooked
>> up to the page reclaim code on the host.
>>     
>
> Yeah, that's the straightforward approach; there's about a research 
> project/year doing a Xen implementation, but they never seem to get very 
> good results aside from very artificial test conditions.
>   
Actually we got really good results by using ksm along with kvm, running 
large
amount of windows virtual machines. We can achieve over commit ratio
of up to 400% of the host ram for VMs doing M$ office load.
-dor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
