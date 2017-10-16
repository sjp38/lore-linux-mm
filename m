Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 574A26B0069
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 10:47:57 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id v127so9603377wma.3
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 07:47:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 202sor1931240wmq.22.2017.10.16.07.47.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Oct 2017 07:47:55 -0700 (PDT)
Date: Mon, 16 Oct 2017 15:47:53 +0100
From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [RFC 2/2] KVM: add virtio-pmem driver
Message-ID: <20171016144753.GB14135@stefanha-x1.localdomain>
References: <20171012155027.3277-1-pagupta@redhat.com>
 <20171012155027.3277-3-pagupta@redhat.com>
 <20171013094431.GA27308@stefanha-x1.localdomain>
 <24301306.20068579.1507891695416.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <24301306.20068579.1507891695416.JavaMail.zimbra@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pankaj Gupta <pagupta@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org, jack@suse.cz, stefanha@redhat.com, dan j williams <dan.j.williams@intel.com>, riel@redhat.com, haozhong zhang <haozhong.zhang@intel.com>, nilal@redhat.com, kwolf@redhat.com, pbonzini@redhat.com, ross zwisler <ross.zwisler@intel.com>, david@redhat.com, xiaoguangrong eric <xiaoguangrong.eric@gmail.com>

On Fri, Oct 13, 2017 at 06:48:15AM -0400, Pankaj Gupta wrote:
> > On Thu, Oct 12, 2017 at 09:20:26PM +0530, Pankaj Gupta wrote:
> > > +static blk_qc_t virtio_pmem_make_request(struct request_queue *q,
> > > +			struct bio *bio)
> > > +{
> > > +	blk_status_t rc = 0;
> > > +	struct bio_vec bvec;
> > > +	struct bvec_iter iter;
> > > +	struct virtio_pmem *pmem = q->queuedata;
> > > +
> > > +	if (bio->bi_opf & REQ_FLUSH)
> > > +		//todo host flush command
> > 
> > This detail is critical to the device design.  What is the plan?
> 
> yes, this is good point.
> 
> was thinking of guest sending a flush command to Qemu which
> will do a fsync on file fd.

Previously there was discussion about fsyncing a specific file range
instead of the whole file.  This could perform better in cases where
only a subset of dirty pages need to be flushed.

One possibility is to design the virtio interface to communicate ranges
but the emulation code simply fsyncs the fd for the time being.  Later
on, if the necessary kernel and userspace interfaces are added, we can
make use of the interface.

> If we do a async flush and move the task to wait queue till we receive 
> flush complete reply from host we can allow other tasks to execute
> in current cpu.
> 
> Any suggestions you have or anything I am not foreseeing here?

My main thought about this patch series is whether pmem should be a
virtio-blk feature bit instead of a whole new device.  There is quite a
bit of overlap between the two.

Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
