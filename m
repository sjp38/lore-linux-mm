Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id C31FC6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 04:10:48 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so9587683pdb.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 01:10:48 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ka13si7865142pbb.16.2015.06.09.01.10.47
        for <linux-mm@kvack.org>;
        Tue, 09 Jun 2015 01:10:47 -0700 (PDT)
Message-ID: <55769F85.5060909@linux.intel.com>
Date: Tue, 09 Jun 2015 16:10:45 +0800
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slub/slab: fix kmemleak didn't work on some case
References: <99C214DF91337140A8D774E25DF6CD5FC89DA2@shsmsx102.ccr.corp.intel.com> <alpine.DEB.2.11.1506080425350.10651@east.gentwo.org> <20150608101302.GB31349@e104818-lin.cambridge.arm.com>
In-Reply-To: <20150608101302.GB31349@e104818-lin.cambridge.arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux.com>
Cc: "Liu, XinwuX" <xinwux.liu@intel.com>, "penberg@kernel.org" <penberg@kernel.org>, "mpm@selenic.com" <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "He, Bo" <bo.he@intel.com>, "Chen, Lin Z" <lin.z.chen@intel.com>

On 2015/6/8 18:13, Catalin Marinas wrote:
> On Mon, Jun 08, 2015 at 10:38:13AM +0100, Christoph Lameter wrote:
>> On Mon, 8 Jun 2015, Liu, XinwuX wrote:
>>
>>> when kernel uses kmalloc to allocate memory, slub/slab will find
>>> a suitable kmem_cache. Ususally the cache's object size is often
>>> greater than requested size. There is unused space which contains
>>> dirty data. These dirty data might have pointers pointing to a block
>> dirty? In what sense?
> I guess XinwuX meant uninitialised.

Uninitialized or dirty data used before being freed.

>
>>> of leaked memory. Kernel wouldn't consider this memory as leaked when
>>> scanning kmemleak object.
>> This has never been considered leaked memory before to my knowledge and
>> the data is already initialized.
> It's not the object being allocated that is considered leaked. But
> uninitialised data in this object is scanned by kmemleak and it may look
> like valid pointers to real leaked objects. So such data increases the
> number of kmemleak false negatives.

Yes, indeed.

>
> As I replied already, I don't think this is that bad, or at least not
> worse than what kmemleak already does (looking at all data whether it's
> pointer or not).

It depends. As for memleak, developers prefers there are false alarms instead
of missing some leaked memory.

>  It also doesn't solve the kmem_cache_alloc() case where
> the original object size is no longer available.

Such issue around kmem_cache_alloc() case happens only when the
caller doesn't initialize or use the full object, so the object keeps
old dirty data.
This patch is to resolve the redundant unused space (more than object size)
although the full object is used by kernel.

>
>> F.e. The zeroing function in linux/mm/slub.c::slab_alloc_node() zeros the
>> complete object and not only the number of bytes specified in the kmalloc
>> call. Same thing is true for SLAB.
> But that's only when __GFP_ZERO is passed.
>
Thanks for the kind comments. There is a balance between performance (new memset
consumes time) and debug capability. 

Yanmin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
