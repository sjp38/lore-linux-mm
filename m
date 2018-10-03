Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA6A96B0010
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 10:39:15 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id n186-v6so3812891oig.13
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 07:39:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t184-v6sor730997oie.171.2018.10.03.07.39.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Oct 2018 07:39:14 -0700 (PDT)
MIME-Version: 1.0
References: <20181002100531.GC4135@quack2.suse.cz> <20181002121039.GA3274@linux-x5ow.site>
 <20181002142959.GD9127@quack2.suse.cz> <20181002143713.GA19845@infradead.org>
 <20181002144412.GC4963@linux-x5ow.site> <20181002145206.GA10903@infradead.org>
 <20181002153100.GG9127@quack2.suse.cz> <CAPcyv4j0tTD+rENqFExA68aw=-MmtCBaOe1qJovyrmJC=yBg-Q@mail.gmail.com>
 <20181003125056.GA21043@quack2.suse.cz>
In-Reply-To: <20181003125056.GA21043@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 3 Oct 2018 07:38:50 -0700
Message-ID: <CAPcyv4jfV10yuTiPg6ijsPRRL2-c_48ovfpU5TK1Zu7BWnfk3g@mail.gmail.com>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, Johannes Thumshirn <jthumshirn@suse.de>, Dave Jiang <dave.jiang@intel.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Oct 3, 2018 at 5:51 AM Jan Kara <jack@suse.cz> wrote:
>
> On Tue 02-10-18 13:18:54, Dan Williams wrote:
> > On Tue, Oct 2, 2018 at 8:32 AM Jan Kara <jack@suse.cz> wrote:
> > >
> > > On Tue 02-10-18 07:52:06, Christoph Hellwig wrote:
> > > > On Tue, Oct 02, 2018 at 04:44:13PM +0200, Johannes Thumshirn wrote:
> > > > > On Tue, Oct 02, 2018 at 07:37:13AM -0700, Christoph Hellwig wrote:
> > > > > > No, it should not.  DAX is an implementation detail thay may change
> > > > > > or go away at any time.
> > > > >
> > > > > Well we had an issue with an application checking for dax, this is how
> > > > > we landed here in the first place.
> > > >
> > > > So what exacty is that "DAX" they are querying about (and no, I'm not
> > > > joking, nor being philosophical).
> > >
> > > I believe the application we are speaking about is mostly concerned about
> > > the memory overhead of the page cache. Think of a machine that has ~ 1TB of
> > > DRAM, the database running on it is about that size as well and they want
> > > database state stored somewhere persistently - which they may want to do by
> > > modifying mmaped database files if they do small updates... So they really
> > > want to be able to use close to all DRAM for the DB and not leave slack
> > > space for the kernel page cache to cache 1TB of database files.
> >
> > VM_MIXEDMAP was never a reliable indication of DAX because it could be
> > set for random other device-drivers that use vm_insert_mixed(). The
> > MAP_SYNC flag positively indicates that page cache is disabled for a
> > given mapping, although whether that property is due to "dax" or some
> > other kernel mechanics is purely an internal detail.
> >
> > I'm not opposed to faking out VM_MIXEDMAP if this broken check has
> > made it into production, but again, it's unreliable.
>
> So luckily this particular application wasn't widely deployed yet so we
> will likely get away with the vendor asking customers to update to a
> version not looking into smaps and parsing /proc/mounts instead.
>
> But I don't find parsing /proc/mounts that beautiful either and I'd prefer
> if we had a better interface for applications to query whether they can
> avoid page cache for mmaps or not.

Yeah, the mount flag is not a good indicator either. I think we need
to follow through on the per-inode property of DAX. Darrick and I
discussed just allowing the property to be inherited from the parent
directory at file creation time. That avoids the dynamic set-up /
teardown races that seem intractable at this point.

What's wrong with MAP_SYNC as a page-cache detector in the meantime?
