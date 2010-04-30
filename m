Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E44526B024B
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 14:08:42 -0400 (EDT)
Message-ID: <4BDB1CA1.1000006@redhat.com>
Date: Fri, 30 Apr 2010 21:08:33 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <4BD16D09.2030803@redhat.com>> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>> <4BD1A74A.2050003@redhat.com>> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>> <4BD1B427.9010905@redhat.com> <4BD1B626.7020702@redhat.com>> <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default>> <4BD3377E.6010303@redhat.com>> <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com>> <ce808441-fae6-4a33-8335-f7702740097a@default>> <20100428055538.GA1730@ucw.cz> <1272591924.23895.807.camel@nimitz> <4BDA8324.7090409@redhat.com> <084f72bf-21fd-4721-8844-9d10cccef316@default 4BDB026E.1030605@redhat.com> <10e6761a-fb7a-421d-97fc-1f3b6cd94622@default>
In-Reply-To: <10e6761a-fb7a-421d-97fc-1f3b6cd94622@default>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/30/2010 07:43 PM, Dan Magenheimer wrote:
>> Given that whenever frontswap fails you need to swap anyway, it is
>> better for the host to never fail a frontswap request and instead back
>> it with disk storage if needed.  This way you avoid a pointless vmexit
>> when you're out of memory.  Since it's disk backed it needs to be
>> asynchronous and batched.
>>
>> At this point we're back with the ordinary swap API.  Simply have your
>> host expose a device which is write cached by host memory, you'll have
>> all the benefits of frontswap with none of the disadvantages, and with
>> no changes to guest .
>>      
> I think you are making a number of possibly false assumptions here:
> 1) The host [the frontswap backend may not even be a hypervisor]
>    

True.  My remarks only apply to frontswap-to-hypervisor, for internally 
consumed frontswap the situation is different.

> 2) can back it with disk storage [not if it is a bare-metal hypervisor]
>    

So it seems a bare-metal hypervisor has less access to the bare metal 
than a non-bare-metal hypervisor?

Seriously, leave the bare-metal FUD to Simon.  People on this list know 
that kvm and Xen have exactly the same access to the hardware (well 
actually Xen needs to use privileged guests to access some of its hardware).

> 3) avoid a pointless vmexit [no vmexit for a non-VMX (e.g. PV) guest]
>    

There's still an exit.  It's much faster than a vmx/svm vmexit but still 
nontrivial.

But why are we optimizing for 5 year old hardware?

> 4) when you're out of memory [how can this be determined outside of
>     the hypervisor?]
>    

It's determined by the hypervisor, same as with tmem.  The guest swaps 
to a virtual disk, the hypervisor places the data in RAM if it's 
available, or on disk if it isn't.  Write-back caching in all its glory.

> And, importantly, "have your host expose a device which is write
> cached by host memory"... you are implying that all guest swapping
> should be done to a device managed/controlled by the host?  That
> eliminates guest swapping to directIO/SRIOV devices doesn't it?
>    

You can have multiple swap devices.

wrt SR/IOV, you'll see synchronous frontswap reduce throughput.  SR/IOV 
will swap with <1 exit/page and DMA guest pages, while frontswap/tmem 
will carry a 1 exit/page hit (even if no swap actually happens) and the 
copy cost (if it does).

The API really, really wants to be asynchronous.

> Anyway, I think we can see now why frontswap might not be a good
> match for a hosted hypervisor (KVM), but that doesn't make it
> any less useful for a bare-metal hypervisor (or TBD for in-kernel
> compressed swap and TBD for possible future pseudo-RAM technologies).
>    

In-kernel compressed swap does seem to be a good match for a synchronous 
API.  For future memory devices, or even bare-metal buzzword-compliant 
hypervisors, I disagree.  An asynchronous API is required for 
efficiency, and they'll all have swap capability sooner or later (kvm, 
vmware, and I believe xen 4 already do).

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
