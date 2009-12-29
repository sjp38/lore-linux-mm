Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9A77160021B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 21:09:31 -0500 (EST)
Received: by yxe10 with SMTP id 10so6149635yxe.12
        for <linux-mm@kvack.org>; Mon, 28 Dec 2009 18:09:30 -0800 (PST)
Message-ID: <4B39646A.3080007@vflare.org>
Date: Tue, 29 Dec 2009 07:37:38 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: Tmem [PATCH 0/5] (Take 3): Transcendent memory
References: <f4ab13eb-daaa-40be-82ad-691505b1f169@default>
In-Reply-To: <f4ab13eb-daaa-40be-82ad-691505b1f169@default>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Pavel Machek <pavel@ucw.cz>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, chris.mason@oracle.com, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 12/28/2009 09:27 PM, Dan Magenheimer wrote:
> 
>> From: Pavel Machek [mailto:pavel@ucw.cz]

>>> I'm definitely OK with exploring alternatives.  I just think that
>>> existing kernel mechanisms are very firmly rooted in the notion
>>> that either the kernel owns the memory/cache or an asynchronous
>>> device owns it.  Tmem falls somewhere in between and is very
>>
>> Well... compcache seems to be very similar to preswap: in preswap case
>> you don't know if hypervisor will have space, in ramzswap you don't
>> know if data are compressible.
> 
> Hi Pavel --
> 
> Yes there are definitely similarities too.  In fact, I started
> prototyping preswap (now called frontswap) with Nitin's
> compcache code.  IIRC I ran into some problems with compcache's
> difficulties in dealing with failed "puts" due to dynamic
> changes in size of hypervisor-available-memory.
> 
> Nitin may have addressed this in later versions of ramzswap.
> 

Any kind of swap device that works entirely within guest
(or in native case), will always have problems with any write(put)
failure -- we want to reclaim a page but due to write failure, we can't. Problem!
So, ramzswap also cannot afford to have lot of write failures.

However, the story is different when ramzswap is "virtualization aware".
In this case, we can surely afford to have any numnber of "put" failures
to hypervisor. When this put fails, we will either compress the page and
keep it in guest memory itself or forward it to ramzswap backing swap
device (if present).

Another side point is that we can achieve all this with ramzswap approach
of virtual block devices without any kernel changes as everything is a module.


> One feature of frontswap which is different than ramzswap is
> that frontswap acts as a "fronting store" for all configured
> swap devices, including SAN/NAS swap devices.  It doesn't
> need to be separately configured as a "highest priority" swap
> device.  In many installations and depending on how ramzswap
> is configured, this difference probably doesn't make much
> difference though.
> 

Having a frontswap layer over *every* swap might not be desirable. I think such
things should be completely out of way when not desired. This was one the primary
reasons to have virtual block device approach for ramzswap. You can create any number
of such devices (/dev/ramzswap{0,1,2...}) with each having separate backing device (optional),
memory pools, buffers etc. which adds additional flexibility and helps with scalability.

On a downside however, as you pointed out, managing all this can be a problem for sysadmins.
To ease this, some userspace magic can help which will dynamically manage these virtual disks,
though I have not yet thought much in this direction.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
