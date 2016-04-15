Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id AA2D56B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 15:10:24 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id th5so42948472obc.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 12:10:24 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id jx3si17038386oeb.82.2016.04.15.12.10.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 12:10:24 -0700 (PDT)
Message-ID: <1460746909.4597.7.camel@hpe.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
From: Toshi Kani <toshi.kani@hpe.com>
Date: Fri, 15 Apr 2016 13:01:49 -0600
In-Reply-To: <CAPcyv4hRQj2ZsFj7Xa_=OwcHrzP9_5yUpt3LQ+bPH4PcLe7UCQ@mail.gmail.com>
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
	 <1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
	 <x49twj26edj.fsf@segfault.boston.devel.redhat.com>
	 <1460739288.3012.3.camel@intel.com>
	 <x49potq6bm2.fsf@segfault.boston.devel.redhat.com>
	 <1460741821.3012.11.camel@intel.com>
	 <CAPcyv4hemNM4uQYCPBXyH+DWTOLvyBNBeMYstKbPdad_Cw48HQ@mail.gmail.com>
	 <x49lh4e6928.fsf@segfault.boston.devel.redhat.com>
	 <CAPcyv4hRQj2ZsFj7Xa_=OwcHrzP9_5yUpt3LQ+bPH4PcLe7UCQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Jeff Moyer <jmoyer@redhat.com>
Cc: "axboe@fb.com" <axboe@fb.com>, "jack@suse.cz" <jack@suse.cz>, "david@fromorbit.com" <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "hch@infradead.org" <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>

On Fri, 2016-04-15 at 11:17 -0700, Dan Williams wrote:
> On Fri, Apr 15, 2016 at 11:06 AM, Jeff Moyer <jmoyer@redhat.com> wrote:
> > 
> > Dan Williams <dan.j.williams@intel.com> writes:
> >A 
> > > > > There's a lot of special casing here, so you might consider
> > > > > adding comments.
> > > > Correct - maybe we should reconsider wrapper-izing this? :)
> > > Another option is just to skip dax_do_io() and this special casing
> > > fallback entirely if errors are present.A A I.e. only attempt dax_do_io
> > > when: IS_DAX() && gendisk->bb && bb->count == 0.
> >
> > So, if there's an error anywhere on the device, penalize all I/O (not
> > just writes, and not just on sectors that are bad)?A A I'm not sure
> > that's a great plan, either.
> > 
> If errors are rare how much are we actually losing in practice?
> Moreover, we're going to do the full badblocks lookup anyway when we
> call ->direct_access().A A If we had that information earlier we can
> avoid this fallback dance.

A system running with DAX may have active data set in NVDIMM lager than RAM
size. A In this case, falling back to non-DAX will allocate page cache for
the data, which will saturate the system with memory pressure.

Thanks,
-Toshi A 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
