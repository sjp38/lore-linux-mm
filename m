Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C6AFE6B0260
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 10:59:11 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id f63so31280554oig.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:59:11 -0700 (PDT)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id z131si1952148oiz.239.2016.04.26.07.59.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 07:59:11 -0700 (PDT)
Received: by mail-oi0-x234.google.com with SMTP id r78so17694322oie.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:59:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160426082711.GC26977@dastard>
References: <20160420205923.GA24797@infradead.org>
	<1461434916.3695.7.camel@intel.com>
	<20160425083114.GA27556@infradead.org>
	<1461604476.3106.12.camel@intel.com>
	<20160425232552.GD18496@dastard>
	<CAPcyv4i6iwm1iY2mQ5yRbYfRexQroUX_R0B-db4ROU837fratw@mail.gmail.com>
	<20160426001157.GE18496@dastard>
	<CAPcyv4i0qnCrzsTQT-v84OhnhjmVBFJ8gKoyu6XkuUwH0babfQ@mail.gmail.com>
	<20160426025645.GG18496@dastard>
	<CAPcyv4hg6O3nvD7aXuFm_GAB-1GJxqfNn=RZswj47COa9bVygA@mail.gmail.com>
	<20160426082711.GC26977@dastard>
Date: Tue, 26 Apr 2016 07:59:10 -0700
Message-ID: <CAPcyv4h19Cp93f+vQXapnmXLEXHE2RZGyQVo7dCnAqcmnW1GEg@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "Verma, Vishal L" <vishal.l.verma@intel.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "jack@suse.cz" <jack@suse.cz>, "axboe@fb.com" <axboe@fb.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "hch@infradead.org" <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>

On Tue, Apr 26, 2016 at 1:27 AM, Dave Chinner <david@fromorbit.com> wrote:
> On Mon, Apr 25, 2016 at 09:18:42PM -0700, Dan Williams wrote:
[..]
> It seems to me you are focussing on code/technologies that exist
> today instead of trying to define an architecture that is more
> optimal for pmem storage systems. Yes, working code is great, but if
> you can't tell people how things like robust error handling and
> redundancy are going to work in future then it's going to take
> forever for everyone else to handle such errors robustly through the
> storage stack...

Precisely because higher order redundancy is built on top this baseline.

MD-RAID can't do it's error recovery if we don't have -EIO and
clear-error-on-write.  On the other hand, you're absolutely right that
we have a gaping hole on top of the SIGBUS recovery model, and don't
have a kernel layer we can interpose on top of DAX to provide some
semblance of redundancy.

In the meantime, a handful of applications with a team of full-time
site-reliability-engineers may be able to plug in external redundancy
infrastructure on top of what is defined in these patches.  For
everyone else, the hard problem, we need to do a lot more thinking
about a trap and recover solution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
