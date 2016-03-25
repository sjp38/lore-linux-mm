Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 840816B007E
	for <linux-mm@kvack.org>; Fri, 25 Mar 2016 17:42:38 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id kf9so59778652obc.1
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 14:42:38 -0700 (PDT)
Received: from mail-ob0-x232.google.com (mail-ob0-x232.google.com. [2607:f8b0:4003:c01::232])
        by mx.google.com with ESMTPS id kr2si5824955oeb.52.2016.03.25.14.42.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Mar 2016 14:42:37 -0700 (PDT)
Received: by mail-ob0-x232.google.com with SMTP id xj3so65535619obb.0
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 14:42:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1458939566.5501.5.camel@intel.com>
References: <1458861450-17705-1-git-send-email-vishal.l.verma@intel.com>
	<1458861450-17705-6-git-send-email-vishal.l.verma@intel.com>
	<20160325104549.GB10525@infradead.org>
	<1458939566.5501.5.camel@intel.com>
Date: Fri, 25 Mar 2016 14:42:37 -0700
Message-ID: <CAPcyv4jFPYYP=eL72V6MmW2fcXFP3PfQfcO+zYV4NN7rdu1ksg@mail.gmail.com>
Subject: Re: [PATCH 5/5] dax: handle media errors in dax_do_io
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Verma, Vishal L" <vishal.l.verma@intel.com>
Cc: "hch@infradead.org" <hch@infradead.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

On Fri, Mar 25, 2016 at 1:59 PM, Verma, Vishal L
<vishal.l.verma@intel.com> wrote:
> On Fri, 2016-03-25 at 03:45 -0700, Christoph Hellwig wrote:
>> On Thu, Mar 24, 2016 at 05:17:30PM -0600, Vishal Verma wrote:
>> >
>> > dax_do_io (called for read() or write() for a dax file system) may
>> > fail
>> > in the presence of bad blocks or media errors. Since we expect that
>> > a
>> > write should clear media errors on nvdimms, make dax_do_io fall
>> > back to
>> > the direct_IO path, which will send down a bio to the driver, which
>> > can
>> > then attempt to clear the error.
>> Leave the fallback on -EIO to the callers please.  They generally
>> call
>> __blockdev_direct_IO anyway, so it should actually become simpler
>> that
>> way.
>
> I thought of this, but made the retrying happen in the wrapper so that
> it can be centralized. If the callers were to become responsible for
> the retry, then any new callers of dax_do_io might not realize they are
> responsible for retrying, and hit problems.

That's their prerogative otherwise you are precluding an alternate
handling of a dax_do_io() failure.  Maybe a fs or upper layer can
recover in a different manner than re-submit the I/O to the
__blockdev_direct_IO path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
