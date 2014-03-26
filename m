Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 092B96B005C
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 20:18:05 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rp16so1166764pbb.31
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 17:18:05 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a3si12551811pay.143.2014.03.25.17.18.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Mar 2014 17:18:05 -0700 (PDT)
Message-ID: <53321CB6.5050706@oracle.com>
Date: Tue, 25 Mar 2014 20:17:58 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: slub: gpf in deactivate_slab
References: <53208A87.2040907@oracle.com> <5331A6C3.2000303@oracle.com> <20140325165247.GA7519@dhcp22.suse.cz> <alpine.DEB.2.10.1403251205140.24534@nuc> <5331B9C8.7080106@oracle.com> <alpine.DEB.2.10.1403251308590.26471@nuc>
In-Reply-To: <alpine.DEB.2.10.1403251308590.26471@nuc>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 03/25/2014 02:10 PM, Christoph Lameter wrote:
> On Tue, 25 Mar 2014, Sasha Levin wrote:
>
>> So here's the full trace. There's obviously something wrong here since we
>> pagefault inside the section that was supposed to be running with irqs
>> disabled
>> and I don't see another cause besides this.
>>
>> The unreliable entries in the stack trace also somewhat suggest that the
>> fault is with the code I've pointed out.
>
> Looks like there was some invalid data fed to the function and the page
> fault with interrupts disabled is the result of following and invalid
> pointer.
>
> Is there more context information available? What are the options set for
> the cache that the operation was performed on?

It seems like it's a regular allocation from the inode_cachep kmem_cache:

	inode = kmem_cache_alloc(inode_cachep, GFP_KERNEL);

I'm not sure if there's anything special about this cache, codewise it's
created as follows:


         inode_cachep = kmem_cache_create("inode_cache",
                                          sizeof(struct inode),
                                          0,
                                          (SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|
                                          SLAB_MEM_SPREAD),
                                          init_once);


I'd be happy to dig up any other info required, I'm just not too sure
what you mean by options for the cache?


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
