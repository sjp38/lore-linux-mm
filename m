Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 45FF06B0038
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 03:32:31 -0400 (EDT)
Received: by qkap81 with SMTP id p81so78380034qka.2
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 00:32:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f74si17363308qkf.43.2015.09.29.00.32.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 00:32:30 -0700 (PDT)
Date: Tue, 29 Sep 2015 09:32:24 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 5/7] slub: support for bulk free with SLUB freelists
Message-ID: <20150929093224.65bed249@redhat.com>
In-Reply-To: <alpine.DEB.2.20.1509281113400.30876@east.gentwo.org>
References: <20150928122444.15409.10498.stgit@canyon>
	<20150928122629.15409.69466.stgit@canyon>
	<alpine.DEB.2.20.1509281011250.30332@east.gentwo.org>
	<20150928175114.07e85114@redhat.com>
	<alpine.DEB.2.20.1509281113400.30876@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, brouer@redhat.com

On Mon, 28 Sep 2015 11:28:15 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Mon, 28 Sep 2015, Jesper Dangaard Brouer wrote:
> 
> > > Do you really need separate parameters for freelist_head? If you just want
> > > to deal with one object pass it as freelist_head and set cnt = 1?
> >
> > Yes, I need it.  We need to know both the head and tail of the list to
> > splice it.
> 
> Ok so this is to avoid having to scan the list to its end?

True.

> x is the end
> of the list and freelist_head the beginning. That is weird.

Yes, it is a bit weird... the bulk free of freelists comes out as a
second-class citizen.

Okay, I'll try to change the slab_free() and __slab_free() calls to
have a "head" and "tail".  And let tail be NULL on single object free,
to allow compiler to do constant propagation (thus keeping existing
fastpath unaffected).  (The same code should be generated, but we will
have a more intuitive API).

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
