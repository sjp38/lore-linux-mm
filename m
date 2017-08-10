Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2B66B02B4
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 08:11:16 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id k3so5367989pfc.0
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 05:11:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id r7si4390837pli.338.2017.08.10.05.11.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 05:11:15 -0700 (PDT)
Date: Thu, 10 Aug 2017 05:11:10 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v3 20/49] block: introduce bio_for_each_segment_mp()
Message-ID: <20170810121110.GC14607@infradead.org>
References: <20170808084548.18963-1-ming.lei@redhat.com>
 <20170808084548.18963-21-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808084548.18963-21-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

First: as mentioned in the previous patches I really hate the name
scheme with the _sp and _mp postfixes.

To be clear and understandable we should always name the versions
that iterate over segments *segment* and the ones that iterate over
pages *page*.  To make sure we have a clean compile break for code
using the old _segment name I'd suggest to move to pass the bvec_iter
argument by reference, which is the right thing to do anyway.

As far as the implementation goes I don't think we actually need
to pass the mp argument down.  Instead we always call the full-segment
version of  bvec_iter_len / __bvec_iter_advance and then have an
inner loop that moves the fake bvecs forward inside each full-segment
one - that is implement the per-page version on top of the per-segment
one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
