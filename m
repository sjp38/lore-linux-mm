Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id 877CB6B006C
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 10:58:08 -0400 (EDT)
Received: by ykel193 with SMTP id l193so9928570yke.2
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 07:58:08 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id hv1si5254021qcb.11.2015.03.26.07.58.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 07:58:07 -0700 (PDT)
Message-ID: <55141E75.4090403@oracle.com>
Date: Thu, 26 Mar 2015 09:57:57 -0500
From: Dave Kleikamp <dave.kleikamp@oracle.com>
MIME-Version: 1.0
Subject: Re: [patch 1/4] fs, jfs: remove slab object constructor
References: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com> <alpine.LRH.2.02.1503252157330.6657@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.10.1503251935180.16714@chino.kir.corp.google.com> <20150326072800.GA26163@lst.de>
In-Reply-To: <20150326072800.GA26163@lst.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, David Rientjes <rientjes@google.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Kleikamp <shaggy@kernel.org>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net

On 03/26/2015 02:28 AM, Christoph Hellwig wrote:
> On Wed, Mar 25, 2015 at 07:37:40PM -0700, David Rientjes wrote:
>> That would be true only for
>>
>> 	ptr = mempool_alloc(gfp, pool);
>> 	mempool_free(ptr, pool);
>>
>> and nothing in between, and that's pretty pointless.  Typically, callers 
>> allocate memory, modify it, and then free it.  When that happens with 
>> mempools, and we can't allocate slab because of the gfp context, mempools 
>> will return elements in the state in which they were freed (modified, not 
>> as constructed).
> 
> The historic slab allocator (Solaris and early Linux) expects objects
> to be returned in the same / similar enough form as the constructor
> returned it, and the constructor is only called when allocating pages
> from the page pool.

I'm pretty sure that this was the intention of the jfs code. Returned
objects should have these fields returned to their initial values. It
does seem error-prone, though. If jfs is in fact the last user of the
constructor, it's probably time for it to die.

> 
> I have to admit that I haven't used this feature forever, and I have no idea if
> people changed how the allocator works in the meantime.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
