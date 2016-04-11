Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1AF6B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 18:02:52 -0400 (EDT)
Received: by mail-io0-f177.google.com with SMTP id u185so4312401iod.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 15:02:52 -0700 (PDT)
Received: from mail-io0-x233.google.com (mail-io0-x233.google.com. [2607:f8b0:4001:c06::233])
        by mx.google.com with ESMTPS id p1si18015362ign.77.2016.04.11.15.02.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 15:02:51 -0700 (PDT)
Received: by mail-io0-x233.google.com with SMTP id g185so4387816ioa.2
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 15:02:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160411234157.3fc9c6fe@redhat.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<20160407143854.GA7685@infradead.org>
	<570678B7.7010802@sandisk.com>
	<570A9F5B.5010600@grimberg.me>
	<20160411234157.3fc9c6fe@redhat.com>
Date: Mon, 11 Apr 2016 15:02:51 -0700
Message-ID: <CAKgT0UdbO00-Pe3xdrCC2T8L=XVZasWSQQVzTTs9r521RDes+Q@mail.gmail.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle facility?
From: Alexander Duyck <alexander.duyck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Sagi Grimberg <sagi@grimberg.me>, Bart Van Assche <bart.vanassche@sandisk.com>, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, "lsf@lists.linux-foundation.org" <lsf@lists.linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, Alexei Starovoitov <alexei.starovoitov@gmail.com>

On Mon, Apr 11, 2016 at 2:41 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
> On Sun, 10 Apr 2016 21:45:47 +0300 Sagi Grimberg <sagi@grimberg.me> wrote:
>
>> >> This is also very interesting for storage targets, which face the same
>> >> issue.  SCST has a mode where it caches some fully constructed SGLs,
>> >> which is probably very similar to what NICs want to do.
>> >
>> > I think a cached allocator for page sets + the scatterlists that
>> > describe these page sets would not only be useful for SCSI target
>> > implementations but also for the Linux SCSI initiator. Today the scsi-mq
>> > code reserves space in each scsi_cmnd for a scatterlist of
>> > SCSI_MAX_SG_SEGMENTS. If scatterlists would be cached together with page
>> > sets less memory would be needed per scsi_cmnd.
>>
>> If we go down this road how about also attaching some driver opaques
>> to the page sets?
>
> That was the ultimate plan... to leave some opaques bytes left in the
> page struct that drivers could use.
>
> In struct page I would need a pointer back to my page_pool struct and a
> page flag.  Then, I would need room to store the dma_unmap address.
> (And then some of the usual fields are still needed, like the refcnt,
> and reusing some of the list constructs).  And a zero-copy cross-domain
> id.
>
>
> For my packet-page idea, I would need a packet length and an offset
> where data starts (I can derive the "head-room" for encap from these
> two).

Have you taken a look at possibly trying to optimize the DMA pool API
to work with pages?  It sounds like it is supposed to do something
similar to what you are wanting to do.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
