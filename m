Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 963BF6B006C
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 03:30:28 -0500 (EST)
Message-ID: <50AC911A.3070501@parallels.com>
Date: Wed, 21 Nov 2012 12:30:18 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Revert "mm: remove __GFP_NO_KSWAPD"
References: <20121012135726.GY29125@suse.de> <507BDD45.1070705@suse.cz> <20121015110937.GE29125@suse.de> <5093A3F4.8090108@redhat.com> <5093A631.5020209@suse.cz> <509422C3.1000803@suse.cz> <509C84ED.8090605@linux.vnet.ibm.com> <509CB9D1.6060704@redhat.com> <20121109090635.GG8218@suse.de> <509F6C2A.9060502@redhat.com> <20121112113731.GS8218@suse.de> <50AB4ADB.6090506@parallels.com> <20121120121817.cf80b8ad.akpm@linux-foundation.org>
In-Reply-To: <20121120121817.cf80b8ad.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Zdenek Kabelac <zkabelac@redhat.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jiri Slaby <jslaby@suse.cz>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Robert Jennings <rcj@linux.vnet.ibm.com>

On 11/21/2012 12:18 AM, Andrew Morton wrote:
> On Tue, 20 Nov 2012 13:18:19 +0400
> Glauber Costa <glommer@parallels.com> wrote:
> 
>> On 11/12/2012 03:37 PM, Mel Gorman wrote:
>>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>>> index 02c1c971..d0a7967 100644
>>> --- a/include/linux/gfp.h
>>> +++ b/include/linux/gfp.h
>>> @@ -31,6 +31,7 @@ struct vm_area_struct;
>>>  #define ___GFP_THISNODE		0x40000u
>>>  #define ___GFP_RECLAIMABLE	0x80000u
>>>  #define ___GFP_NOTRACK		0x200000u
>>> +#define ___GFP_NO_KSWAPD	0x400000u
>>>  #define ___GFP_OTHER_NODE	0x800000u
>>>  #define ___GFP_WRITE		0x1000000u
>>
>> Keep in mind that this bit has been reused in -mm.
>> If this patch needs to be reverted, we'll need to first change
>> the definition of __GFP_KMEMCG (and __GFP_BITS_SHIFT as a result), or it
>> would break things.
> 
> I presently have
> 
> /* Plain integer GFP bitmasks. Do not use this directly. */
> #define ___GFP_DMA		0x01u
> #define ___GFP_HIGHMEM		0x02u
> #define ___GFP_DMA32		0x04u
> #define ___GFP_MOVABLE		0x08u
> #define ___GFP_WAIT		0x10u
> #define ___GFP_HIGH		0x20u
> #define ___GFP_IO		0x40u
> #define ___GFP_FS		0x80u
> #define ___GFP_COLD		0x100u
> #define ___GFP_NOWARN		0x200u
> #define ___GFP_REPEAT		0x400u
> #define ___GFP_NOFAIL		0x800u
> #define ___GFP_NORETRY		0x1000u
> #define ___GFP_MEMALLOC		0x2000u
> #define ___GFP_COMP		0x4000u
> #define ___GFP_ZERO		0x8000u
> #define ___GFP_NOMEMALLOC	0x10000u
> #define ___GFP_HARDWALL		0x20000u
> #define ___GFP_THISNODE		0x40000u
> #define ___GFP_RECLAIMABLE	0x80000u
> #define ___GFP_KMEMCG		0x100000u
> #define ___GFP_NOTRACK		0x200000u
> #define ___GFP_NO_KSWAPD	0x400000u
> #define ___GFP_OTHER_NODE	0x800000u
> #define ___GFP_WRITE		0x1000000u
> 
> and
> 

Humm, I didn't realize there were also another free space at 0x100000u.
This seems fine.

> #define __GFP_BITS_SHIFT 25	/* Room for N __GFP_FOO bits */
> #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
> 
> Which I think is OK?
Yes, if we haven't increased the size of the flag-space, no need to
change it.

> 
> I'd forgotten about __GFP_BITS_SHIFT.  Should we do this?
> 
> --- a/include/linux/gfp.h~a
> +++ a/include/linux/gfp.h
> @@ -35,6 +35,7 @@ struct vm_area_struct;
>  #define ___GFP_NO_KSWAPD	0x400000u
>  #define ___GFP_OTHER_NODE	0x800000u
>  #define ___GFP_WRITE		0x1000000u
> +/* If the above are modified, __GFP_BITS_SHIFT may need updating */
>  
This is a very helpful comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
