Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AC6786B0082
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 20:15:21 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so2444338qwf.44
        for <linux-mm@kvack.org>; Wed, 08 Jul 2009 17:27:46 -0700 (PDT)
Message-ID: <4A55397F.8050207@codemonkey.ws>
Date: Wed, 08 Jul 2009 19:27:43 -0500
From: Anthony Liguori <anthony@codemonkey.ws>
MIME-Version: 1.0
Subject: Re: [Xen-devel] Re: [RFC PATCH 0/4] (Take 2): transcendent memory
 ("tmem") for Linux
References: <ac5dec0d-e593-4a82-8c9d-8aa374e8c6ed@default> <4A553272.5050909@codemonkey.ws> <4A553707.5060107@goop.org>
In-Reply-To: <4A553707.5060107@goop.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, npiggin@suse.de, akpm@osdl.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org, dave.mccracken@oracle.com, linux-mm@kvack.org, chris.mason@oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, alan@lxorguk.ukuu.org.uk, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Jeremy Fitzhardinge wrote:
> On 07/08/09 16:57, Anthony Liguori wrote:
>   
>> Why does tmem require a special store?
>>
>> A VMM can trap write operations pages can be stored on disk
>> transparently by the VMM if necessary.  I guess that's the bit I'm
>> missing.
>>     
>
> tmem doesn't store anything to disk.  It's more about making sure that
> free host memory can be quickly and efficiently be handed out to guests
> as they need it; to increase "memory liquidity" as it were.  Guests need
> to explicitly ask to use tmem, rather than having the host/hypervisor
> try to intuit what to do based on access patterns and hints; typically
> they'll use tmem as the first line storage for memory which they were
> about to swap out anyway.

If the primary use of tmem is to avoid swapping when measure pressure 
would have forced it, how is this different using ballooning along with 
a shrinker callback?

With virtio-balloon, a guest can touch any of the memory it's ballooned 
to immediately reclaim that memory.  I think the main difference with 
tmem is that you can also mark a page as being volatile.  The hypervisor 
can then reclaim that page without swapping it (it can always reclaim 
memory and swap it) and generate a special fault to the guest if it 
attempts to access it.

You can fail to put with tmem, right?  You can also fail to get?  In 
both cases though, these failures can be handled because Linux is able 
to recreate the page on it's on (by doing disk IO).  So why not just 
generate a special fault instead of having to introduce special accessors?

Regards,

Anthony Liguori

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
