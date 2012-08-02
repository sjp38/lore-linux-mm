Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id BD8F06B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 03:58:14 -0400 (EDT)
Message-ID: <501A3262.6090407@parallels.com>
Date: Thu, 2 Aug 2012 11:55:14 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Any reason to use put_page in slub.c?
References: <1343391586-18837-1-git-send-email-glommer@parallels.com>  <alpine.DEB.2.00.1207271054230.18371@router.home>  <50163D94.5050607@parallels.com>  <alpine.DEB.2.00.1207301421150.27584@router.home>  <5017968C.6050301@parallels.com>  <alpine.DEB.2.00.1207310906350.32295@router.home>  <5017E72D.2060303@parallels.com>  <alpine.DEB.2.00.1207310915150.32295@router.home>  <5017E929.70602@parallels.com>  <alpine.DEB.2.00.1207310927420.32295@router.home> <1343746344.8473.4.camel@dabdike.int.hansenpartnership.com> <50192453.9080706@parallels.com> <alpine.DEB.2.00.1208011307450.4606@router.home>
In-Reply-To: <alpine.DEB.2.00.1208011307450.4606@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On 08/01/2012 10:10 PM, Christoph Lameter wrote:
> On Wed, 1 Aug 2012, Glauber Costa wrote:
> 
>> I've audited all users of get_page() in the drivers/ directory for
>> patterns like this. In general, they kmalloc something like a table of
>> entries, and then get_page() the entries. The entries are either user
>> pages, pages allocated by the page allocator, or physical addresses
>> through their pfn (in 2 cases from the vga ones...)
>>
>> I took a look about some other instances where virt_to_page occurs
>> together with kmalloc as well, and they all seem to fall in the same
>> category.
> 
> The case that was notorious in the past was a scsi control structure
> allocated from slab that was then written to the device via DMA. And it
> was not on x86 but some esoteric platform (powerpc?),
> 
> A reference to the discussion of this issue in 2007:
> 
> http://lkml.indiana.edu/hypermail/linux/kernel/0706.3/0424.html
> 
Thanks.

So again, I've scanned across that thread, and found some very useful
excerpts from it, that can only argue in favor of my patch =)

"There are no kmalloced pages. There is only kmalloced memory. You
allocate pages from the page allocator. Its a layering violation to
expect a page struct operation on a slab object to work."

"So someone played loose ball with the slab, was successful and that
makes it right now?"

Looking at the code again, I see that page_mapping(), that ends up being
called to do the translation in those pathological cases now features a
VM_BUG_ON(), put in place by yourself. This dates back from 2007, giving
me enough reason to believe that whatever issue still existed back then
is already sorted out - or nobody really cares.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
