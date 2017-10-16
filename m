Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2096B0038
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 13:04:41 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id x82so16009420qkb.11
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 10:04:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f7si444951qte.316.2017.10.16.10.04.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 10:04:40 -0700 (PDT)
Date: Mon, 16 Oct 2017 13:04:34 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <1080174355.20804941.1508173474622.JavaMail.zimbra@redhat.com>
In-Reply-To: <20171016144753.GB14135@stefanha-x1.localdomain>
References: <20171012155027.3277-1-pagupta@redhat.com> <20171012155027.3277-3-pagupta@redhat.com> <20171013094431.GA27308@stefanha-x1.localdomain> <24301306.20068579.1507891695416.JavaMail.zimbra@redhat.com> <20171016144753.GB14135@stefanha-x1.localdomain>
Subject: Re: [RFC 2/2] KVM: add virtio-pmem driver
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Hajnoczi <stefanha@gmail.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org, jack@suse.cz, stefanha@redhat.com, dan j williams <dan.j.williams@intel.com>, riel@redhat.com, haozhong zhang <haozhong.zhang@intel.com>, nilal@redhat.com, kwolf@redhat.com, pbonzini@redhat.com, ross zwisler <ross.zwisler@intel.com>, david@redhat.com, xiaoguangrong eric <xiaoguangrong.eric@gmail.com>


> 
> On Fri, Oct 13, 2017 at 06:48:15AM -0400, Pankaj Gupta wrote:
> > > On Thu, Oct 12, 2017 at 09:20:26PM +0530, Pankaj Gupta wrote:
> > > > +static blk_qc_t virtio_pmem_make_request(struct request_queue *q,
> > > > +			struct bio *bio)
> > > > +{
> > > > +	blk_status_t rc = 0;
> > > > +	struct bio_vec bvec;
> > > > +	struct bvec_iter iter;
> > > > +	struct virtio_pmem *pmem = q->queuedata;
> > > > +
> > > > +	if (bio->bi_opf & REQ_FLUSH)
> > > > +		//todo host flush command
> > > 
> > > This detail is critical to the device design.  What is the plan?
> > 
> > yes, this is good point.
> > 
> > was thinking of guest sending a flush command to Qemu which
> > will do a fsync on file fd.
> 
> Previously there was discussion about fsyncing a specific file range
> instead of the whole file.  This could perform better in cases where
> only a subset of dirty pages need to be flushed.

yes, We had discussion about this and decided to do entire block flush
then to range level flush.

> 
> One possibility is to design the virtio interface to communicate ranges
> but the emulation code simply fsyncs the fd for the time being.  Later
> on, if the necessary kernel and userspace interfaces are added, we can
> make use of the interface.
> 
> > If we do a async flush and move the task to wait queue till we receive
> > flush complete reply from host we can allow other tasks to execute
> > in current cpu.
> > 
> > Any suggestions you have or anything I am not foreseeing here?
> 
> My main thought about this patch series is whether pmem should be a
> virtio-blk feature bit instead of a whole new device.  There is quite a
> bit of overlap between the two.

Exposing options with existing virtio-blk device to be used as persistent memory
range at high level would require additional below features:

- Use a persistent memory range with an option to allocate memmap array in the device
  itself for .

- Block operations for DAX and persistent memory range.

- Bifurcation at filesystem level based on type of virtio-blk device selected.

- Bifurcation of flushing interface and communication channel between guest & host.

But yes these features can be dynamically configured based on type of device
added? What if we have virtio-blk:virtio-pmem (m:n) devices ratio?And scale involved? 

If i understand correctly virtio-blk is high performance interface with multiqueue support 
and additional features at host side like data-plane mode etc. If we bloat it with additional
stuff(even when we need them) and provide locking with additional features both at guest as 
well as host side we will get a hit in performance? Also as requirement of both the interfaces
would grow it will be more difficult to maintain? I would prefer more simpler interfaces with
defined functionality but yes common code can be shared and used using well defined wrappers. 

> 
> Stefan
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
