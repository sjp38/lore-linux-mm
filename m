Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5B20E6B000E
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 17:14:12 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id o6-v6so4785657oib.9
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 14:14:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m22-v6sor1278476oic.162.2018.10.03.14.14.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Oct 2018 14:14:11 -0700 (PDT)
MIME-Version: 1.0
References: <20181002142959.GD9127@quack2.suse.cz> <20181002143713.GA19845@infradead.org>
 <20181002144412.GC4963@linux-x5ow.site> <20181002145206.GA10903@infradead.org>
 <20181002153100.GG9127@quack2.suse.cz> <CAPcyv4j0tTD+rENqFExA68aw=-MmtCBaOe1qJovyrmJC=yBg-Q@mail.gmail.com>
 <20181003125056.GA21043@quack2.suse.cz> <CAPcyv4jfV10yuTiPg6ijsPRRL2-c_48ovfpU5TK1Zu7BWnfk3g@mail.gmail.com>
 <20181003150658.GC24030@quack2.suse.cz> <CAPcyv4iJvN6_Cf6tw=5a=Uh99LfMFKU7n8QkGcz1ZaxL0Oi-3w@mail.gmail.com>
 <20181003164407.GK24030@quack2.suse.cz>
In-Reply-To: <20181003164407.GK24030@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 3 Oct 2018 14:13:59 -0700
Message-ID: <CAPcyv4iCXNYTSzwU5OoZc_b+xxbqKwjyQV74CRxEfvDjaMPDfg@mail.gmail.com>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, Johannes Thumshirn <jthumshirn@suse.de>, Dave Jiang <dave.jiang@intel.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Oct 3, 2018 at 9:46 AM Jan Kara <jack@suse.cz> wrote:
>
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

The only problem is that you can't use it purely as a query. If we
ever did plumb it to be a hint you could not read the state without
writing the state.

mincore(2) seems to be close the intent of discovering whether RAM is
being consumed for a given address range, but it currently is
implemented to only indicate if *any* mapping is established, not
whether RAM is consumed. I can see an argument that a dax mapped file
should always report an empty mincore vector.
