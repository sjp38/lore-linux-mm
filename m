Message-ID: <4919E62F.1020104@redhat.com>
Date: Tue, 11 Nov 2008 22:08:15 +0200
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>	<20081111103051.979aea57.akpm@linux-foundation.org>	<4919D370.7080301@redhat.com>	<20081111111110.decc0f06.akpm@linux-foundation.org>	<4919DA7F.5090106@redhat.com> <20081111113247.c2b0f1ac.akpm@linux-foundation.org> <4919E293.6040600@redhat.com>
In-Reply-To: <4919E293.6040600@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: avi@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com
List-ID: <linux-mm.kvack.org>

Izik Eidus wrote:
> Andrew Morton wrote:
>> On Tue, 11 Nov 2008 21:18:23 +0200
>> Izik Eidus <ieidus@redhat.com> wrote:
>>
>>  
>>>> hm.
>>>>
>>>> There has been the occasional discussion about idenfifying all-zeroes
>>>> pages and scavenging them, repointing them at the zero page.  Could
>>>> this infrastructure be used for that?  (And how much would we gain 
>>>> from
>>>> it?)
>>>>
>>>> [I'm looking for reasons why this is more than a 
>>>> muck-up-the-vm-for-kvm
>>>> thing here ;) ]
>>>>       
>>
>> ^^ this?
>>
>>  
>>> KSM is separate driver , it doesn't change anything in the VM but 
>>> adding two helper functions.
>>>     
>>
>> What, you mean I should actually read the code?   Oh well, OK.
>>   
> Andrea i think what is happening here is my fault
Sorry, meant to write here Andrew :-)
> i will try to give here much more information about KSM:
> first the bad things:
> KSM shared pages are right now (we have patch that can change it but 
> we want to wait with it) unswappable
> this mean that the entire memory of the guest is swappable but the 
> pages that are shared are not.
> (when the pages are splited back by COW they become anonymous again 
> with the help of do_wp_page()
> the reason that the pages are not swappable is beacuse the way the 
> Linux Rmap is working, this not allow us to create nonlinear anonymous 
> pages
> (we dont want to use nonlinear vma for kvm, as it will make swapping 
> for kvm very slow)
> the reason that ksm pages need to have nonlinear reverse mapping is 
> that for one guest identical page can be found in whole diffrent 
> offset than other guest have it
> (this is from the userspace VM point of view)
>
> the rest is quite simple:
> it is walking over the entire guest memory (or only some of it) and 
> scan for identical pages using hash table
> it merge the pages into one single write protected page
>
> numbers for ksm is something that i have just for desktops and just 
> the numbers i gave you
> what is do know is:
> big overcommit like 300% is possible just when you take into account 
> that some of the guest memory will be free
> we are sharing mostly the DLLs/ KERNEL / ZERO pages, for the DLLS and 
> KERNEL PAGEs this pages likely will never break
> but ZERO pages will be break when windows will allocate them and will 
> come back when windows will free the memory.
> (i wouldnt suggest 300% overcommit for servers workload, beacuse you 
> can end up swapping in that case,
> but for desktops after runing in production and passed some seiroes qa 
> tress tests it seems like 300% is a real number that can be use)
>
> i just ran test on two fedora 8 guests and got that results (using 
> GNOME in both of them)
> 9959 root      15   0  730m 537m 281m S    8  3.4   0:44.28 
> kvm                                                                            
>
> 9956 root      15   0  730m 537m 246m S    4  3.4   0:41.43 kvm
> as you can see the physical sharing was 281mb and 246mb (kernel pages 
> are counted as shared)
> there is small lie in this numbers beacuse pages that was shared 
> across two guests and was splited by writing from guest number 1 will 
> still have 1 refernce count to it
> and will still be kernel page (untill the other guest (num 2) will 
> write to it as well)
>
>
> anyway i am willing to make much better testing or everything that 
> needed for this patchs to be merged.
> (just tell me what and i will do it)
>
> beside that you should know that patch 4 is not a must, it is just 
> nice optimization...
>
> thanks.
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe 
> linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
