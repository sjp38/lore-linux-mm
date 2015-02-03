Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id B1E626B0080
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 17:55:24 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id n4so36228012qaq.12
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 14:55:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x10si30667258qal.20.2015.02.03.14.55.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Feb 2015 14:55:23 -0800 (PST)
Date: Tue, 3 Feb 2015 23:55:12 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC 1/3] Slab infrastructure for array operations
Message-ID: <20150203235512.62738c3c@redhat.com>
In-Reply-To: <20150129074443.GA19607@js1304-P5Q-DELUXE>
References: <20150123213727.142554068@linux.com>
	<20150123213735.590610697@linux.com>
	<20150127082132.GE11358@js1304-P5Q-DELUXE>
	<alpine.DEB.2.11.1501271054310.25124@gentwo.org>
	<CAAmzW4MzNfcRucHeTxJtXLks5T-Def=O1sRpQY6fo5ybTzKsBA@mail.gmail.com>
	<alpine.DEB.2.11.1501280923410.31753@gentwo.org>
	<20150129074443.GA19607@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, akpm@linuxfoundation.org, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, brouer@redhat.com

On Thu, 29 Jan 2015 16:44:43 +0900
Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> On Wed, Jan 28, 2015 at 09:30:56AM -0600, Christoph Lameter wrote:
> > On Wed, 28 Jan 2015, Joonsoo Kim wrote:
> > 
[...]
> > 
> > The default when no options are specified is to first exhaust the node
> > partial objects, then allocate new slabs as long as we have more than
> > objects per page left and only then satisfy from cpu local object. I think
> > that is satisfactory for the majority of the cases.
> > 
> > The detailed control options were requested at the meeting in Auckland at
> > the LCA. I am fine with dropping those if they do not make sense. Makes
> > the API and implementation simpler. Jesper, are you ok with this?

Yes, I'm okay with dropping the allocation flags. 

We might want to keep the flag "GFP_SLAB_ARRAY_FULL_COUNT" for allowing
allocator to return less-than the requested elements (but I'm not 100%
sure).  The idea behind this is, if the allocator can "see" that it
needs to perform a (relativly) expensive operation, then I would rather
want it to return current elements (even if it's less than requested).
As this is likely very performance sensitive code using this API.


> IMHO, it'd be better to choose a proper way of allocation by slab
> itself and not to expose options to API user. We could decide the
> best option according to current status of kmem_cache and requested
> object number and internal implementation.
> 
> Is there any obvious example these option are needed for user?

The use-cases were, if the subsystem/user know about their use-case e.g.
1) needing a large allocation which does not need to be cache hot,
2) needing a smaller (e.g 8-16 elems) allocation that should be cache hot.

But, as you argue, I guess it is best to leave this up to the slab
implementation as the status of the kmem_cache is only known to the
allocator itself.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
