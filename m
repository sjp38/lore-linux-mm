Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 741316B0253
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 15:08:49 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id p66so349887228pga.4
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 12:08:49 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id q2si49216323plh.215.2016.12.13.12.08.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 12:08:48 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id 144so6438171pfv.0
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 12:08:48 -0800 (PST)
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
References: <alpine.DEB.2.20.1612121200280.13607@east.gentwo.org>
 <20161213171028.24dbf519@redhat.com> <5850335F.6090000@gmail.com>
 <20161213.145333.514056260418695987.davem@davemloft.net>
From: John Fastabend <john.fastabend@gmail.com>
Message-ID: <58505535.1080908@gmail.com>
Date: Tue, 13 Dec 2016 12:08:21 -0800
MIME-Version: 1.0
In-Reply-To: <20161213.145333.514056260418695987.davem@davemloft.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: brouer@redhat.com, cl@linux.com, rppt@linux.vnet.ibm.com, netdev@vger.kernel.org, linux-mm@kvack.org, willemdebruijn.kernel@gmail.com, bjorn.topel@intel.com, magnus.karlsson@intel.com, alexander.duyck@gmail.com, mgorman@techsingularity.net, tom@herbertland.com, bblanco@plumgrid.com, tariqt@mellanox.com, saeedm@mellanox.com, jesse.brandeburg@intel.com, METH@il.ibm.com, vyasevich@gmail.com

On 16-12-13 11:53 AM, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Tue, 13 Dec 2016 09:43:59 -0800
> 
>> What does "zero-copy send packet-pages to the application/socket that
>> requested this" mean? At the moment on x86 page-flipping appears to be
>> more expensive than memcpy (I can post some data shortly) and shared
>> memory was proposed and rejected for security reasons when we were
>> working on bifurcated driver.
> 
> The whole idea is that we map all the active RX ring pages into
> userspace from the start.
> 
> And just how Jesper's page pool work will avoid DMA map/unmap,
> it will also avoid changing the userspace mapping of the pages
> as well.
> 
> Thus avoiding the TLB/VM overhead altogether.
> 

I get this but it requires applications to be isolated. The pages from
a queue can not be shared between multiple applications in different
trust domains. And the application has to be cooperative meaning it
can't "look" at data that has not been marked by the stack as OK. In
these schemes we tend to end up with something like virtio/vhost or
af_packet.

Any ACLs/filtering/switching/headers need to be done in hardware or
the application trust boundaries are broken.

If the above can not be met then a copy is needed. What I am trying
to tease out is the above comment along with other statements like
this "can be done with out HW filter features".

.John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
