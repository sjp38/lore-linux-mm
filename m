Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id CD9E46B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 17:42:04 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id f52so156808060qga.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 14:42:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 138si877586qkg.31.2016.04.11.14.42.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 14:42:04 -0700 (PDT)
Date: Mon, 11 Apr 2016 23:41:57 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle
 facility?
Message-ID: <20160411234157.3fc9c6fe@redhat.com>
In-Reply-To: <570A9F5B.5010600@grimberg.me>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<20160407143854.GA7685@infradead.org>
	<570678B7.7010802@sandisk.com>
	<570A9F5B.5010600@grimberg.me>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sagi Grimberg <sagi@grimberg.me>
Cc: Bart Van Assche <bart.vanassche@sandisk.com>, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, "lsf@lists.linux-foundation.org" <lsf@lists.linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, brouer@redhat.com


On Sun, 10 Apr 2016 21:45:47 +0300 Sagi Grimberg <sagi@grimberg.me> wrote:

> >> This is also very interesting for storage targets, which face the same
> >> issue.  SCST has a mode where it caches some fully constructed SGLs,
> >> which is probably very similar to what NICs want to do.  
> >
> > I think a cached allocator for page sets + the scatterlists that
> > describe these page sets would not only be useful for SCSI target
> > implementations but also for the Linux SCSI initiator. Today the scsi-mq
> > code reserves space in each scsi_cmnd for a scatterlist of
> > SCSI_MAX_SG_SEGMENTS. If scatterlists would be cached together with page
> > sets less memory would be needed per scsi_cmnd.  
> 
> If we go down this road how about also attaching some driver opaques
> to the page sets?

That was the ultimate plan... to leave some opaques bytes left in the
page struct that drivers could use.

In struct page I would need a pointer back to my page_pool struct and a
page flag.  Then, I would need room to store the dma_unmap address.
(And then some of the usual fields are still needed, like the refcnt,
and reusing some of the list constructs).  And a zero-copy cross-domain
id.


For my packet-page idea, I would need a packet length and an offset
where data starts (I can derive the "head-room" for encap from these
two).

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
