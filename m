Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 79DB56B004F
	for <linux-mm@kvack.org>; Sun, 12 Jul 2009 12:59:25 -0400 (EDT)
Message-ID: <4A5A1A51.2080301@redhat.com>
Date: Sun, 12 Jul 2009 20:16:01 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/4] (Take 2): transcendent memory ("tmem") for Linux
References: <a09e4489-a755-46e7-a569-a0751e0fc39f@default>
In-Reply-To: <a09e4489-a755-46e7-a569-a0751e0fc39f@default>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Anthony Liguori <anthony@codemonkey.ws>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Schwidefsky <schwidefsky@de.ibm.com>, chris.mason@oracle.com, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On 07/12/2009 07:20 PM, Dan Magenheimer wrote:
>>> that information; but tmem is trying to go a step further by making
>>> the cooperation between the OS and hypervisor more explicit
>>> and directly beneficial to the OS.
>>>        
>> KVM definitely falls into the camp of trying to minimize
>> modification to the guest.
>>      
>
> No argument there.  Well, maybe one :-) Yes, but KVM
> also heavily encourages unmodified guests.  Tmem is
> philosophically in favor of finding a balance between
> things that work well with no changes to any OS (and
> thus work just fine regardless of whether the OS is
> running in a virtual environment or not), and things
> that could work better if the OS is knowledgable that
> it is running in a virtual environment.
>    


CMM2 and tmem are not any different in this regard; both require OS 
modification, and both make information available to the hypervisor.  In 
fact CMM2 is much more intrusive (but on the other hand provides much 
more information).

> For those that believe virtualization is a flash-in-
> the-pan, no modifications to the OS is the right answer.
> For those that believe it will be pervasive in the
> future, finding the right balance is a critical step
> in operating system evolution.
>    

You're arguing for CMM2 here IMO.

> Is it the tmem API or the precache/preswap API layered on
> top of it that is problematic?  Both currently assume copying
> but perhaps the precache/preswap API could, with minor
> modifications, meet KVM's needs better?
>
>    

My take on this is that precache (predecache?) / preswap can be 
implemented even without tmem by using write-through backing for the 
virtual disk.  For swap this is actually slight;y more efficient than 
tmem preswap, for preuncache slightly less efficient (since there will 
be some double caching).  So I'm more interested in other use cases of 
tmem/CMM2.Well, first, tmem's very name means memory that is "beyond the
> range of normal perception".  This is certainly not the first class
> of memory in use in data centers that can't be accounted at
> process granularity.  I'm thinking disk array caches as the
> primary example.  Also lots of tools that work great in a
> non-virtualized OS are worthless or misleading in a virtual
> environment.
>
>    

Right, the transient uses of tmem when applied to disk objects 
(swap/pagecache) are very similar to disk caches.  Which is why you can 
get a very similar effect when caching your virtual disks; this can be 
done without any guest modification.


-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
