Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 641F66B0254
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 10:08:50 -0400 (EDT)
Received: by qkdw123 with SMTP id w123so4322466qkd.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 07:08:50 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id n23si8310696qkl.111.2015.09.09.07.08.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 09 Sep 2015 07:08:49 -0700 (PDT)
Date: Wed, 9 Sep 2015 09:08:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 0/3] Network stack, first user of SLAB/kmem_cache
 bulk free API.
In-Reply-To: <20150909145919.4d68ea36@redhat.com>
Message-ID: <alpine.DEB.2.11.1509090907240.18992@east.gentwo.org>
References: <20150824005727.2947.36065.stgit@localhost> <20150904165944.4312.32435.stgit@devil> <55E9DE51.7090109@gmail.com> <alpine.DEB.2.11.1509041354560.993@east.gentwo.org> <55EA0172.2040505@gmail.com> <alpine.DEB.2.11.1509041844190.2499@east.gentwo.org>
 <20150905131825.6c04837d@redhat.com> <alpine.DEB.2.11.1509081228100.26148@east.gentwo.org> <20150909145919.4d68ea36@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, aravinda@linux.vnet.ibm.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, iamjoonsoo.kim@lge.com

On Wed, 9 Sep 2015, Jesper Dangaard Brouer wrote:

> > Hmmm... Guess we need to come up with distinct version of kmalloc() for
> > irq and non irq contexts to take advantage of that . Most at non irq
> > context anyways.
>
> I agree, it would be an easy win.  Do notice this will have the most
> impact for the slAb allocator.
>
> I estimate alloc + free cost would save:
>  * slAb would save approx 60 cycles
>  * slUb would save approx  4 cycles
>
> We might consider keeping the slUb approach as it would be more
> friendly for RT with less IRQ disabling.

IRQ disabling it a mixed bag. Older cpus have higher latencies there and
also virtualized contexts may require the hypervisor tracks the interrupt
state.

For recent intel cpus this is certainly a workable approach.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
