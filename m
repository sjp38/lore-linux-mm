Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C8E16B0010
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 06:04:09 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x10-v6so5229004edx.9
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 03:04:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g5-v6si2661430ejj.262.2018.10.04.03.04.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 03:04:07 -0700 (PDT)
Date: Thu, 4 Oct 2018 12:04:06 +0200
From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181004100406.GE6682@linux-x5ow.site>
References: <20181002143713.GA19845@infradead.org>
 <20181002144412.GC4963@linux-x5ow.site>
 <20181002145206.GA10903@infradead.org>
 <20181002153100.GG9127@quack2.suse.cz>
 <CAPcyv4j0tTD+rENqFExA68aw=-MmtCBaOe1qJovyrmJC=yBg-Q@mail.gmail.com>
 <20181003125056.GA21043@quack2.suse.cz>
 <CAPcyv4jfV10yuTiPg6ijsPRRL2-c_48ovfpU5TK1Zu7BWnfk3g@mail.gmail.com>
 <20181003150658.GC24030@quack2.suse.cz>
 <CAPcyv4iJvN6_Cf6tw=5a=Uh99LfMFKU7n8QkGcz1ZaxL0Oi-3w@mail.gmail.com>
 <20181003164407.GK24030@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181003164407.GK24030@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@infradead.org>, Dave Jiang <dave.jiang@intel.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Oct 03, 2018 at 06:44:07PM +0200, Jan Kara wrote:
> On Wed 03-10-18 08:13:37, Dan Williams wrote:
> > On Wed, Oct 3, 2018 at 8:07 AM Jan Kara <jack@suse.cz> wrote:
> > > WRT per-inode DAX property, AFAIU that inode flag is just going to be
> > > advisory thing - i.e., use DAX if possible. If you mount a filesystem with
> > > these inode flags set in a configuration which does not allow DAX to be
> > > used, you will still be able to access such inodes but the access will use
> > > page cache instead. And querying these flags should better show real
> > > on-disk status and not just whether DAX is used as that would result in an
> > > even bigger mess. So this feature seems to be somewhat orthogonal to the
> > > API I'm looking for.
> > 
> > True, I imagine once we have that flag we will be able to distinguish
> > the "saved" property and the "effective / live" property of DAX...
> > Also it's really not DAX that applications care about as much as "is
> > there page-cache indirection / overhead for this mapping?". That seems
> > to be a narrower guarantee that we can make than what "DAX" might
> > imply.
> 
> Right. So what do people think about my suggestion earlier in the thread to
> use madvise(MADV_DIRECT_ACCESS) for this? Currently it would return success
> when DAX is in use, failure otherwise. Later we could extend it to be also
> used as a hint for caching policy for the inode...

Hmm apart from Dan's objection that it can't really be used for a
query, isn't madvise(2) for mmap(2)?

But AFAIU (from looking at the xfs code, so please correct me if I',
wrong), DAX can be used for the traditional read(2)/write(2) interface
as well.

There is at least:

xfs_file_read_iter()
`-> if (IS_DAX(inode))
    `-> xfs_file_dax_read()
        `->dax_iomap_rw()

So IMHO something on an inode granularity would make more sens to me.

Byte,
	Johannes
-- 
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nurnberg
GF: Felix Imendorffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nurnberg)
Key fingerprint = EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
