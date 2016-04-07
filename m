Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id B52426B007E
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 10:17:22 -0400 (EDT)
Received: by mail-qk0-f169.google.com with SMTP id o6so31148356qkc.2
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 07:17:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 81si6055019qhz.5.2016.04.07.07.17.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 07:17:21 -0700 (PDT)
Date: Thu, 7 Apr 2016 16:17:15 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [LSF/MM TOPIC] Generic page-pool recycle facility?
Message-ID: <20160407161715.52635cac@redhat.com>
In-Reply-To: <1460034425.20949.7.camel@HansenPartnership.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>
Cc: brouer@redhat.com, James Bottomley <James.Bottomley@HansenPartnership.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tom Herbert <tom@herbertland.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, Brenden Blanco <bblanco@plumgrid.com>, lsf-pc@lists.linux-foundation.org

(Topic proposal for MM-summit)

Network Interface Cards (NIC) drivers, and increasing speeds stress
the page-allocator (and DMA APIs).  A number of driver specific
open-coded approaches exists that work-around these bottlenecks in the
page allocator and DMA APIs. E.g. open-coded recycle mechanisms, and
allocating larger pages and handing-out page "fragments".

I'm proposing a generic page-pool recycle facility, that can cover the
driver use-cases, increase performance and open up for zero-copy RX.


The basic performance problem is that pages (containing packets at RX)
are cycled through the page allocator (freed at TX DMA completion
time).  While a system in a steady state, could avoid calling the page
allocator, when having a pool of pages equal to the size of the RX
ring plus the number of outstanding frames in the TX ring (waiting for
DMA completion).

The motivation for quick page recycling came primarily for performance
reasons.  But returning pages to the same pool also benefit other
use-cases.  If a NIC HW RX ring is strictly bound (e.g. to a process
or guest/KVM) then pages can be shared/mmap'ed (RX zero-copy) as
information leaking does not occur.  (Obviously for this use-case,
when adding pages into the pool these need to zero'ed out).


The motivation behind implemeting this (extremely fast page-pool) is
because we need it as a building block in the network stack, but
hopefully other areas could also benefit from this.


[Resources/Links]: It is specifically related to:

What Facebook calls XDP (eXpress Data Path)
 * https://github.com/iovisor/bpf-docs/blob/master/Express_Data_Path.pdf
 * RFC patchset thread: http://thread.gmane.org/gmane.linux.network/406288

And what I call the "packet-page" level:
 * BoF on kernel network performance: http://lwn.net/Articles/676806/
 * http://people.netfilter.org/hawk/presentations/NetDev1.1_2016/links.html


See you soon at LFS/MM-summit :-)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
