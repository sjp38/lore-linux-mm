Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D14B26B0007
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 11:07:04 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 71-v6so5654031plb.11
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 08:07:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v10-v6si1040496pfm.162.2018.10.03.08.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 08:07:03 -0700 (PDT)
Date: Wed, 3 Oct 2018 17:06:58 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181003150658.GC24030@quack2.suse.cz>
References: <20181002100531.GC4135@quack2.suse.cz>
 <20181002121039.GA3274@linux-x5ow.site>
 <20181002142959.GD9127@quack2.suse.cz>
 <20181002143713.GA19845@infradead.org>
 <20181002144412.GC4963@linux-x5ow.site>
 <20181002145206.GA10903@infradead.org>
 <20181002153100.GG9127@quack2.suse.cz>
 <CAPcyv4j0tTD+rENqFExA68aw=-MmtCBaOe1qJovyrmJC=yBg-Q@mail.gmail.com>
 <20181003125056.GA21043@quack2.suse.cz>
 <CAPcyv4jfV10yuTiPg6ijsPRRL2-c_48ovfpU5TK1Zu7BWnfk3g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jfV10yuTiPg6ijsPRRL2-c_48ovfpU5TK1Zu7BWnfk3g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Johannes Thumshirn <jthumshirn@suse.de>, Dave Jiang <dave.jiang@intel.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed 03-10-18 07:38:50, Dan Williams wrote:
> On Wed, Oct 3, 2018 at 5:51 AM Jan Kara <jack@suse.cz> wrote:
> >
> > On Tue 02-10-18 13:18:54, Dan Williams wrote:
> > > On Tue, Oct 2, 2018 at 8:32 AM Jan Kara <jack@suse.cz> wrote:
> > > >
> > > > On Tue 02-10-18 07:52:06, Christoph Hellwig wrote:
> > > > > On Tue, Oct 02, 2018 at 04:44:13PM +0200, Johannes Thumshirn wrote:
> > > > > > On Tue, Oct 02, 2018 at 07:37:13AM -0700, Christoph Hellwig wrote:
> > > > > > > No, it should not.  DAX is an implementation detail thay may change
> > > > > > > or go away at any time.
> > > > > >
> > > > > > Well we had an issue with an application checking for dax, this is how
> > > > > > we landed here in the first place.
> > > > >
> > > > > So what exacty is that "DAX" they are querying about (and no, I'm not
> > > > > joking, nor being philosophical).
> > > >
> > > > I believe the application we are speaking about is mostly concerned about
> > > > the memory overhead of the page cache. Think of a machine that has ~ 1TB of
> > > > DRAM, the database running on it is about that size as well and they want
> > > > database state stored somewhere persistently - which they may want to do by
> > > > modifying mmaped database files if they do small updates... So they really
> > > > want to be able to use close to all DRAM for the DB and not leave slack
> > > > space for the kernel page cache to cache 1TB of database files.
> > >
> > > VM_MIXEDMAP was never a reliable indication of DAX because it could be
> > > set for random other device-drivers that use vm_insert_mixed(). The
> > > MAP_SYNC flag positively indicates that page cache is disabled for a
> > > given mapping, although whether that property is due to "dax" or some
> > > other kernel mechanics is purely an internal detail.
> > >
> > > I'm not opposed to faking out VM_MIXEDMAP if this broken check has
> > > made it into production, but again, it's unreliable.
> >
> > So luckily this particular application wasn't widely deployed yet so we
> > will likely get away with the vendor asking customers to update to a
> > version not looking into smaps and parsing /proc/mounts instead.
> >
> > But I don't find parsing /proc/mounts that beautiful either and I'd prefer
> > if we had a better interface for applications to query whether they can
> > avoid page cache for mmaps or not.
> 
> Yeah, the mount flag is not a good indicator either. I think we need
> to follow through on the per-inode property of DAX. Darrick and I
> discussed just allowing the property to be inherited from the parent
> directory at file creation time. That avoids the dynamic set-up /
> teardown races that seem intractable at this point.
> 
> What's wrong with MAP_SYNC as a page-cache detector in the meantime?

So IMHO checking for MAP_SYNC is about as reliable as checking for 'dax'
mount option. It works now but nobody promises it will reliably detect DAX in
future - e.g. there's nothing that prevents MAP_SYNC to work for mappings
using pagecache if we find a sensible usecase for that.

WRT per-inode DAX property, AFAIU that inode flag is just going to be
advisory thing - i.e., use DAX if possible. If you mount a filesystem with
these inode flags set in a configuration which does not allow DAX to be
used, you will still be able to access such inodes but the access will use
page cache instead. And querying these flags should better show real
on-disk status and not just whether DAX is used as that would result in an
even bigger mess. So this feature seems to be somewhat orthogonal to the
API I'm looking for.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
