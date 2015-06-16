Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 199076B006E
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 04:05:03 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so4955933qkh.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 01:05:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f92si196084qge.71.2015.06.16.01.05.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 01:05:02 -0700 (PDT)
Date: Tue, 16 Jun 2015 10:04:56 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 7/7] slub: initial bulk free implementation
Message-ID: <20150616100456.624d775e@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1506151133150.20358@east.gentwo.org>
References: <20150615155053.18824.617.stgit@devil>
	<20150615155256.18824.42651.stgit@devil>
	<alpine.DEB.2.11.1506151133150.20358@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, brouer@redhat.com

On Mon, 15 Jun 2015 11:34:44 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Mon, 15 Jun 2015, Jesper Dangaard Brouer wrote:
> 
> > +	for (i = 0; i < size; i++) {
> > +		void *object = p[i];
> > +
> > +		if (unlikely(!object))
> > +			continue; // HOW ABOUT BUG_ON()???
> 
> Sure BUG_ON would be fitting here.

Okay, will do in V2.

> > +
> > +		page = virt_to_head_page(object);
> > +		BUG_ON(s != page->slab_cache); /* Check if valid slab page */
> 
> This is the check if the slab page belongs to the slab cache we are
> interested in.

Is this appropriate to keep on this fastpath? (I copied the check from
one of your earlier patches)

> > +
> > +		if (c->page == page) {
> > +			/* Fastpath: local CPU free */
> > +			set_freepointer(s, object, c->freelist);
> > +			c->freelist = object;
> > +		} else {
> > +			c->tid = next_tid(c->tid);
> 
> tids are only useful for the fastpath. No need to fiddle around with them
> for the slowpath.

Okay, understood.

> > +			local_irq_enable();
> > +			/* Slowpath: overhead locked cmpxchg_double_slab */


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
