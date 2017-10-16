Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 974916B0038
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 11:58:40 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id h6so8869112oia.17
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 08:58:40 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 70sor2636596otf.244.2017.10.16.08.58.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Oct 2017 08:58:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171016144753.GB14135@stefanha-x1.localdomain>
References: <20171012155027.3277-1-pagupta@redhat.com> <20171012155027.3277-3-pagupta@redhat.com>
 <20171013094431.GA27308@stefanha-x1.localdomain> <24301306.20068579.1507891695416.JavaMail.zimbra@redhat.com>
 <20171016144753.GB14135@stefanha-x1.localdomain>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 16 Oct 2017 08:58:37 -0700
Message-ID: <CAPcyv4hffSdoONfFohKZzfB2gywGYG9MmDxC0H9+5R53w+ROVQ@mail.gmail.com>
Subject: Re: [RFC 2/2] KVM: add virtio-pmem driver
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Hajnoczi <stefanha@gmail.com>
Cc: Pankaj Gupta <pagupta@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KVM list <kvm@vger.kernel.org>, Qemu Developers <qemu-devel@nongnu.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Stefan Hajnoczi <stefanha@redhat.com>, Rik van Riel <riel@redhat.com>, haozhong zhang <haozhong.zhang@intel.com>, Nitesh Narayan Lal <nilal@redhat.com>, Kevin Wolf <kwolf@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, ross zwisler <ross.zwisler@intel.com>, David Hildenbrand <david@redhat.com>, xiaoguangrong eric <xiaoguangrong.eric@gmail.com>

On Mon, Oct 16, 2017 at 7:47 AM, Stefan Hajnoczi <stefanha@gmail.com> wrote:
> On Fri, Oct 13, 2017 at 06:48:15AM -0400, Pankaj Gupta wrote:
>> > On Thu, Oct 12, 2017 at 09:20:26PM +0530, Pankaj Gupta wrote:
>> > > +static blk_qc_t virtio_pmem_make_request(struct request_queue *q,
>> > > +                 struct bio *bio)
>> > > +{
>> > > + blk_status_t rc = 0;
>> > > + struct bio_vec bvec;
>> > > + struct bvec_iter iter;
>> > > + struct virtio_pmem *pmem = q->queuedata;
>> > > +
>> > > + if (bio->bi_opf & REQ_FLUSH)
>> > > +         //todo host flush command
>> >
>> > This detail is critical to the device design.  What is the plan?
>>
>> yes, this is good point.
>>
>> was thinking of guest sending a flush command to Qemu which
>> will do a fsync on file fd.
>
> Previously there was discussion about fsyncing a specific file range
> instead of the whole file.  This could perform better in cases where
> only a subset of dirty pages need to be flushed.
>
> One possibility is to design the virtio interface to communicate ranges
> but the emulation code simply fsyncs the fd for the time being.  Later
> on, if the necessary kernel and userspace interfaces are added, we can
> make use of the interface.

Range based is not a natural storage cache management mechanism. All
that is it available typically is a full write-cache-flush mechanism
and upper layers would need to customized for range-based flushing.

>> If we do a async flush and move the task to wait queue till we receive
>> flush complete reply from host we can allow other tasks to execute
>> in current cpu.
>>
>> Any suggestions you have or anything I am not foreseeing here?
>
> My main thought about this patch series is whether pmem should be a
> virtio-blk feature bit instead of a whole new device.  There is quite a
> bit of overlap between the two.

I'd be open to that... there's already provisions in the pmem driver
for platforms where cpu caches are flushed on power-loss, a virtio
mode for this shared-memory case seems reasonable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
