Message-ID: <479716AD.5070708@qumranet.com>
Date: Wed, 23 Jan 2008 12:27:57 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] [PATCH] export notifier #1
References: <20080116124256.44033d48@bree.surriel.com> <478E4356.7030303@qumranet.com> <20080117162302.GI7170@v2.random> <478F9C9C.7070500@qumranet.com> <20080117193252.GC24131@v2.random> <20080121125204.GJ6970@v2.random> <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random> <20080122200858.GB15848@v2.random> <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com> <20080122223139.GD15848@v2.random> <Pine.LNX.4.64.0801221433080.2271@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0801221433080.2271@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Izik Eidus <izike@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, holt@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Ahhh. Good to hear. But we will still end in a situation where only
> the remote ptes point to the page. Maybe the remote instance will dirty
> the page at that point?
>
>   

When the spte is dropped, its dirty bit is transferred to the page.
>   
>> sharing code, and for you missing a single notifier means memory
>> corruption because you don't bump the page count to represent the
>> external reference).
>>     
>
> The approach with the export notifier is page based not based on the 
> mm_struct. We only need a single page count for a page that is exported to 
> a number of remote instances of linux. The page count is dropped when all 
> the remote instances have unmapped the page.
>   

That won't work for kvm.  If we have a hundred virtual machines, that 
means 99 no-op notifications.

Also, our rmap key for finding the spte is keyed on (mm, va).  I imagine 
most RDMA cards are similar.
>  
>   
>>> @@ -966,6 +973,9 @@ int try_to_unmap(struct page *page, int 
>>>  
>>>  	BUG_ON(!PageLocked(page));
>>>  
>>> +	if (unlikely(PageExported(page)))
>>> +		export_notifier(invalidate_page, page);
>>> +
>>>       
>> Passing the page here will complicate things especially for shared
>> pages across different VM that are already working in KVM. For non
>>     
>
> How?
>
>   
>> shared pages we could cache the userland mapping address in
>> page->private but it's a kludge only working for non-shared
>> pages. Walking twice the anon_vma lists when only a single walk is
>>     
>
> There is only the need to walk twice for pages that are marked Exported. 
> And the double walk is only necessary if the exporter does not have its 
> own rmap. The cross partition thing that we are doing has such an rmap and 
> its a matter of walking the exporters rmap to clear out the external 
> references and then we walk the local rmaps. All once.
>   

The problem is that external mmus need a reverse mapping structure to 
locate their ptes.  We can't expand struct page so we need to base it on 
mm + va.

>   
>> Besides the pinned pages ram leak by having the zero locking window
>> above I'm curious how you are going to take care of the finegrined
>> aging that I'm doing with the accessed bit set by hardware in the spte
>>     
>
> I think I explained that above. Remote users effectively are forbidden to 
> establish new references to the page by the clearing of the exported bit.
>
>   

Can they wait on that bit?


-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
