Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A17676B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 18:21:31 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ot11so148282pab.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 15:21:31 -0700 (PDT)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id 18si5816706pfs.117.2016.04.11.15.21.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 15:21:30 -0700 (PDT)
Received: by mail-pf0-x22e.google.com with SMTP id c20so163970pfc.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 15:21:30 -0700 (PDT)
Date: Mon, 11 Apr 2016 15:21:26 -0700
From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle facility?
Message-ID: <20160411222124.GA80595@ast-mbp.thefacebook.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
 <20160407161715.52635cac@redhat.com>
 <20160407143854.GA7685@infradead.org>
 <570678B7.7010802@sandisk.com>
 <570A9F5B.5010600@grimberg.me>
 <20160411234157.3fc9c6fe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160411234157.3fc9c6fe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Sagi Grimberg <sagi@grimberg.me>, Bart Van Assche <bart.vanassche@sandisk.com>, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, "lsf@lists.linux-foundation.org" <lsf@lists.linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>

On Mon, Apr 11, 2016 at 11:41:57PM +0200, Jesper Dangaard Brouer wrote:
> 
> On Sun, 10 Apr 2016 21:45:47 +0300 Sagi Grimberg <sagi@grimberg.me> wrote:
> 
> > >> This is also very interesting for storage targets, which face the same
> > >> issue.  SCST has a mode where it caches some fully constructed SGLs,
> > >> which is probably very similar to what NICs want to do.  
> > >
> > > I think a cached allocator for page sets + the scatterlists that
> > > describe these page sets would not only be useful for SCSI target
> > > implementations but also for the Linux SCSI initiator. Today the scsi-mq
> > > code reserves space in each scsi_cmnd for a scatterlist of
> > > SCSI_MAX_SG_SEGMENTS. If scatterlists would be cached together with page
> > > sets less memory would be needed per scsi_cmnd.  
> > 
> > If we go down this road how about also attaching some driver opaques
> > to the page sets?
> 
> That was the ultimate plan... to leave some opaques bytes left in the
> page struct that drivers could use.
> 
> In struct page I would need a pointer back to my page_pool struct and a
> page flag.  Then, I would need room to store the dma_unmap address.
> (And then some of the usual fields are still needed, like the refcnt,
> and reusing some of the list constructs).  And a zero-copy cross-domain
> id.

I don't think we need to add anything to struct page.
This is supposed to be small cache of dma_mapped pages with lockless access.
It can be implemented as an array or link list where every element
is dma_addr and pointer to page. If it is full, dma_unmap_page+put_page to
send it to back to page allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
