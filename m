Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DFC0B6B005C
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 19:45:26 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so2439932qwf.44
        for <linux-mm@kvack.org>; Wed, 08 Jul 2009 16:57:41 -0700 (PDT)
Message-ID: <4A553272.5050909@codemonkey.ws>
Date: Wed, 08 Jul 2009 18:57:38 -0500
From: Anthony Liguori <anthony@codemonkey.ws>
MIME-Version: 1.0
Subject: Re: [Xen-devel] Re: [RFC PATCH 0/4] (Take 2): transcendent memory
 ("tmem") for Linux
References: <ac5dec0d-e593-4a82-8c9d-8aa374e8c6ed@default>
In-Reply-To: <ac5dec0d-e593-4a82-8c9d-8aa374e8c6ed@default>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org, dave.mccracken@oracle.com, linux-mm@kvack.org, chris.mason@oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, alan@lxorguk.ukuu.org.uk, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Dan Magenheimer wrote:
> Hi Anthony --
>
> Thanks for the comments.
>
>   
>> I have trouble mapping this to a VMM capable of overcommit 
>> without just coming back to CMM2.
>>
>> In CMM2 parlance, ephemeral tmem pools is just normal kernel memory 
>> marked in the volatile state, no?
>>     
>
> They are similar in concept, but a volatile-marked kernel page
> is still a kernel page, can be changed by a kernel (or user)
> store instruction, and counts as part of the memory used
> by the VM.  An ephemeral tmem page cannot be directly written
> by a kernel (or user) store,

Why does tmem require a special store?

A VMM can trap write operations pages can be stored on disk 
transparently by the VMM if necessary.  I guess that's the bit I'm missing.

>> It seems to me that an architecture built around hinting 
>> would be more 
>> robust than having to use separate memory pools for this type 
>> of memory 
>> (especially since you are requiring a copy to/from the pool).
>>     
>
> Depends on what you mean by robust, I suppose.  Once you
> understand the basics of tmem, it is very simple and this
> is borne out in the low invasiveness of the Linux patch.
> Simplicity is another form of robustness.
>   

The main disadvantage I see is that you need to explicitly convert 
portions of the kernel to use a data copying API.  That seems like an 
invasive change to me.  Hinting on the other hand can be done in a 
less-invasive way.

I'm not really arguing against tmem, just the need to have explicit 
get/put mechanisms for the transcendent memory areas.

> The copy may be expensive on an older machine, but on newer
> machines copying a page is relatively inexpensive.

I don't think that's a true statement at all :-)  If you had a workload 
where data never came into the CPU cache (zero-copy) and now you 
introduce a copy, even with new system, you're going to see a 
significant performance hit.

>   On a reasonable
> multi-VM-kernbench-like benchmark I'll be presenting at Linux
> Symposium next week, the overhead is on the order of 0.01%
> for a fairly significant savings in IOs.
>   
But how would something like specweb do where you should be doing 
zero-copy IO from the disk to the network?  This is the area where I 
would be concerned.  For something like kernbench, you're already 
bringing the disk data into the CPU cache anyway so I can appreciate 
that the copy could get lost in the noise.

Regards,

Anthony Liguori

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
