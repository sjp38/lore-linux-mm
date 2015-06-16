Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id BCC546B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 12:04:46 -0400 (EDT)
Received: by iesa3 with SMTP id a3so16005036ies.2
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 09:04:46 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id k196si1058168ioe.102.2015.06.16.09.04.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 16 Jun 2015 09:04:46 -0700 (PDT)
Date: Tue, 16 Jun 2015 11:04:45 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 7/7] slub: initial bulk free implementation
In-Reply-To: <20150616175231.427499ae@redhat.com>
Message-ID: <alpine.DEB.2.11.1506161104060.5683@east.gentwo.org>
References: <20150615155053.18824.617.stgit@devil> <20150615155256.18824.42651.stgit@devil> <20150616072806.GC13125@js1304-P5Q-DELUXE> <20150616102110.55208fdd@redhat.com> <20150616105732.2bc37714@redhat.com> <CAAmzW4OM-afGBZbWZzcH7O-mivNWvyeKpMVV4Os+i4Xb7GPgmg@mail.gmail.com>
 <alpine.DEB.2.11.1506161008350.3496@east.gentwo.org> <20150616175231.427499ae@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-Netdev <netdev@vger.kernel.org>, Alexander Duyck <alexander.duyck@gmail.com>

On Tue, 16 Jun 2015, Jesper Dangaard Brouer wrote:

> It is very important that everybody realizes that the save+restore
> variant is very expensive, this is key:
>
> CPU: i7-4790K CPU @ 4.00GHz
>  * local_irq_{disable,enable}:  7 cycles(tsc) - 1.821 ns
>  * local_irq_{save,restore}  : 37 cycles(tsc) - 9.443 ns
>
> Even if EVERY object need to call slowpath/__slab_free() it will be
> faster than calling the fallback.  Because I've demonstrated the call
> this_cpu_cmpxchg_double() costs 9 cycles.

But the cmpxchg also stores a value. You need to add the cost of the store
to the cycles.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
