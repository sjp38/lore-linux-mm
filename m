Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 087936B0240
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 12:16:55 -0400 (EDT)
Message-ID: <4BDB026E.1030605@redhat.com>
Date: Fri, 30 Apr 2010 19:16:46 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <4BD16D09.2030803@redhat.com>> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>> <4BD1A74A.2050003@redhat.com>> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>> <4BD1B427.9010905@redhat.com> <4BD1B626.7020702@redhat.com>> <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default>> <4BD3377E.6010303@redhat.com>> <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com>> <ce808441-fae6-4a33-8335-f7702740097a@default>> <20100428055538.GA1730@ucw.cz> <1272591924.23895.807.camel@nimitz 4BDA8324.7090409@redhat.com> <084f72bf-21fd-4721-8844-9d10cccef316@default>
In-Reply-To: <084f72bf-21fd-4721-8844-9d10cccef316@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/30/2010 06:59 PM, Dan Magenheimer wrote:
>>
>>> experiencing a load spike, you increase load even more by making the
>>> guests swap.  If you can just take some of their memory away, you can
>>> smooth that spike out.  CMM2 and frontswap do that.  The guests
>>> explicitly give up page contents that the hypervisor does not have to
>>> first consult with the guest before discarding.
>>>        
>> Frontswap does not do this.  Once a page has been frontswapped, the
>> host
>> is committed to retaining it until the guest releases it.
>>      
> Dave or others can correct me if I am wrong, but I think CMM2 also
> handles dirty pages that must be retained by the hypervisor.

But those are the guest's pages in the first place, that's not a new 
commitment.  CMM2 provides the hypervisor alternatives to swapping a 
page out.  Frontswap provides the guest alternatives to swapping a page out.

>    The
> difference between CMM2 (for dirty pages) and frontswap is that
> CMM2 sets hints that can be handled asynchronously while frontswap
> provides explicit hooks that synchronously succeed/fail.
>    

They are not directly comparable.  In fact for dirty pages CMM2 is 
mostly a no-op - the host is forced to swap them out if it wants them.  
CMM2 brings value for demand zero or clean pages which can be restored 
by the guest without requiring swapin.

I think for dirty pages what CMM2 brings is the ability to discard them 
if the host has swapped them out but the guest doesn't need them,

> In fact, Avi, CMM2 is probably a fairly good approximation of what
> the asynchronous interface you are suggesting might look like.
> In other words,

CMM2 is more directly comparably to ballooning rather than to 
frontswap.  Frontswap (and cleancache) work with storage that is 
external to the guest, and say nothing about the guest's page itself.

> feasible but much much more complex than frontswap.
>    

The swap API (e.g. the block layer) itself is an asynchronous batched 
version of frontswap.  The complexity in CMM2 comes from the fact that 
it is communicating information about guest pages to the host, and from 
the fact that communication is two-way and asynchronous in both directions.


>    
>> [frontswap is] really
>> not very different from a synchronous swap device.
>>      
> Not to beat a dead horse, but there is a very key difference:
> The size and availability of frontswap is entirely dynamic;
> any page-to-be-swapped can be rejected at any time even if
> a page was previously successfully swapped to the same index.
> Every other swap device is much more static so the swap code
> assumes a static device.  Existing swap code can account for
> "bad blocks" on a static device, but this is far from sufficient
> to handle the dynamicity needed by frontswap.
>    

Given that whenever frontswap fails you need to swap anyway, it is 
better for the host to never fail a frontswap request and instead back 
it with disk storage if needed.  This way you avoid a pointless vmexit 
when you're out of memory.  Since it's disk backed it needs to be 
asynchronous and batched.

At this point we're back with the ordinary swap API.  Simply have your 
host expose a device which is write cached by host memory, you'll have 
all the benefits of frontswap with none of the disadvantages, and with 
no changes to guest code.


-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
