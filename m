Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id D3F016B0253
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 11:21:44 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id y188so97579484ywf.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 08:21:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f6si2741639qka.311.2016.07.13.08.21.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 08:21:44 -0700 (PDT)
Date: Wed, 13 Jul 2016 11:21:41 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: System freezes after OOM
In-Reply-To: <97c60afe-d922-ce4c-3a5c-5b15bf0fe2da@gmail.com>
Message-ID: <alpine.LRH.2.02.1607131114390.31769@file01.intranet.prod.int.rdu2.redhat.com>
References: <57837CEE.1010609@redhat.com> <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com> <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com> <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com> <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com> <20160713111006.GF28723@dhcp22.suse.cz> <20160713125050.GJ28723@dhcp22.suse.cz> <97c60afe-d922-ce4c-3a5c-5b15bf0fe2da@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Milan Broz <gmazyland@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, device-mapper development <dm-devel@redhat.com>



On Wed, 13 Jul 2016, Milan Broz wrote:

> On 07/13/2016 02:50 PM, Michal Hocko wrote:
> > On Wed 13-07-16 13:10:06, Michal Hocko wrote:
> >> On Tue 12-07-16 19:44:11, Mikulas Patocka wrote:
> > [...]
> >>> As long as swapping is in progress, the free memory is below the limit 
> >>> (because the swapping activity itself consumes any memory over the limit). 
> >>> And that triggered the OOM killer prematurely.
> >>
> >> I am not sure I understand the last part. Are you saing that we trigger
> >> OOM because the initiated swapout will not be able to finish the IO thus
> >> release the page in time?
> >>
> >> The oom detection checks waits for an ongoing writeout if there is no
> >> reclaim progress and at least half of the reclaimable memory is either
> >> dirty or under writeback. Pages under swaout are marked as under
> >> writeback AFAIR. The writeout path (dm-crypt worker in this case) should
> >> be able to allocate a memory from the mempool, hand over to the crypt
> >> layer and finish the IO. Is it possible this might take a lot of time?
> > 
> > I am not familiar with the crypto API but from what I understood from
> > crypt_convert the encryption is done asynchronously. Then I got lost in
> > the indirection. Who is completing the request and from what kind of
> > context? Is it possible it wouldn't be runable for a long time?
> 
> If you mean crypt_convert in dm-crypt, then it can do asynchronous completion
> but usually (with AES-NI ans sw implementations) it run the operation completely
> synchronously.
> Asynchronous processing is quite rare, usually only on some specific hardware
> crypto accelerators.
> 
> Once the encryption is finished, the cloned bio is sent to the block
> layer for processing.
> (There is also some magic with sorting writes but Mikulas knows this better.)

dm-crypt receives requests in crypt_map, then it distributes write 
requests to multiple encryption threads. Encryption is done usually 
synchronously; asynchronous completion is used only when using some PCI 
cards that accelerate encryption. When encryption finishes, the encrypted 
pages are submitted to a thread dmcrypt_write that sorts the requests 
using rbtree and submits them.

The block layer has a deficiency that it cannot merge adjacent requests 
submitted by the different threads.

If we submitted requests directly from encryption threads, lack of merging 
degraded performance seriously.

Mikulas

> Milan
> p.s. I added cc to dm-devel, some dmcrypt people reads only this list.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
