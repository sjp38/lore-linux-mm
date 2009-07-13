Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4BDE66B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 16:51:16 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id l33so557518rvb.26
        for <linux-mm@kvack.org>; Mon, 13 Jul 2009 14:17:10 -0700 (PDT)
Message-ID: <4A5BA451.5070604@codemonkey.ws>
Date: Mon, 13 Jul 2009 16:17:05 -0500
From: Anthony Liguori <anthony@codemonkey.ws>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/4] (Take 2): transcendent memory ("tmem") for Linux
References: <a09e4489-a755-46e7-a569-a0751e0fc39f@default> <4A5A1A51.2080301@redhat.com> <4A5A3AC1.5080800@codemonkey.ws> <20090713201745.GA3783@think> <4A5B9B55.6000404@codemonkey.ws> <20090713210112.GC3783@think>
In-Reply-To: <20090713210112.GC3783@think>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>, Avi Kivity <avi@redhat.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, dave.mccracken@oracle.com, Marcelo Tosatti <mtosatti@redhat.com>, sunil.mushran@oracle.com, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Chris Mason wrote:
> On Mon, Jul 13, 2009 at 03:38:45PM -0500, Anthony Liguori wrote:
>   
> I'll definitely grant that caching with writethough adds more caching,
> but it does need trim support before it is similar to tmem.

I think trim is somewhat orthogonal but even if you do need it, the nice 
thing about implementing ATA trim support verses a paravirtualization is 
that it works with a wide variety of guests.

 From the perspective of the VMM, it seems like a good thing.

>   The caching
> is transparent to the guest, but it is also transparent to qemu, and so
> it is harder to manage and size (or even get a stat for how big it
> currently is).
>   

That's certainly a fixable problem though.  We could expose statistics 
to userspace and then further expose those to guests.  I think the first 
question to answer though is what you would use those statistics for.

>> The difference between our "tmem" is that instead of providing an  
>> interface where the guest explicitly says, "I'm throwing away this  
>> memory, I may need it later", and then asking again for it, the guest  
>> throws away the page and then we can later satisfy the disk I/O request  
>> that results from re-requesting the page instantaneously.
>>
>> This transparent approach is far superior too because it enables  
>> transparent sharing across multiple guests.  This works well for CoW  
>> images and would work really well if we had a file system capable of  
>> block-level deduplification... :-)
>>     
>
> Grin, I'm afraid that even if someone were to jump in and write the
> perfect cow based filesystem and then find a willing contributor to code
> up a dedup implementation, each cow image would be a different file
> and so it would have its own address space.
>
> Dedup and COW are an easy way to have hints about which pages are
> supposed to be have the same contents, but they would have to go with
> some other duplicate page sharing scheme.
>   

Yes.  We have the information we need to dedup this memory though.  We 
just need a way to track non-dirty pages that result from DMA, map the 
host page cache directly into the guest, and then CoW when the guest 
tries to dirty that memory.

We don't quite have the right infrastructure in Linux yet to do this 
effectively, but this is entirely an issue with the host.  The guest 
doesn't need any changes here.

Regards,

Anthony Liguori
> -chris
>
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
