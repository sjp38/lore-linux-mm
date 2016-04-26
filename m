Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 212AE6B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 04:33:37 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id vv3so11594041pab.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 01:33:37 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id s63si3315146pfs.86.2016.04.26.01.33.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 01:33:36 -0700 (PDT)
Date: Tue, 26 Apr 2016 01:33:32 -0700
From: "hch@infradead.org" <hch@infradead.org>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
Message-ID: <20160426083332.GB364@infradead.org>
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
 <1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
 <x49twj26edj.fsf@segfault.boston.devel.redhat.com>
 <20160420205923.GA24797@infradead.org>
 <1461434916.3695.7.camel@intel.com>
 <20160425083114.GA27556@infradead.org>
 <1461604476.3106.12.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461604476.3106.12.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Verma, Vishal L" <vishal.l.verma@intel.com>
Cc: "hch@infradead.org" <hch@infradead.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "jmoyer@redhat.com" <jmoyer@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

On Mon, Apr 25, 2016 at 05:14:36PM +0000, Verma, Vishal L wrote:
> - Application hits EIO doing dax_IO or load/store io
> 
> - It checks badblocks and discovers it's files have lost data
> 
> - It write()s those sectors (possibly converted to file offsets using
> fiemap)
> ?? ?? * This triggers the fallback path, but if the application is doing
> this level of recovery, it will know the sector is bad, and write the
> entire sector

This sounds like a mess.

> I think if we want to keep allowing arbitrary alignments for the
> dax_do_io path, we'd need:
> 1. To represent badblocks at a finer granularity (likely cache lines)
> 2. To allow the driver to do IO to a *block device* at sub-sector
> granularity

It's not a block device if it supports DAX.  It's byte addressable
memory masquerading as a block device.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
