Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5BB636B0003
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 16:19:07 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id n12-v6so2176418otk.22
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 13:19:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d129-v6sor8641195oif.163.2018.10.02.13.19.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Oct 2018 13:19:05 -0700 (PDT)
MIME-Version: 1.0
References: <20181002100531.GC4135@quack2.suse.cz> <20181002121039.GA3274@linux-x5ow.site>
 <20181002142959.GD9127@quack2.suse.cz> <20181002143713.GA19845@infradead.org>
 <20181002144412.GC4963@linux-x5ow.site> <20181002145206.GA10903@infradead.org>
 <20181002153100.GG9127@quack2.suse.cz>
In-Reply-To: <20181002153100.GG9127@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 2 Oct 2018 13:18:54 -0700
Message-ID: <CAPcyv4j0tTD+rENqFExA68aw=-MmtCBaOe1qJovyrmJC=yBg-Q@mail.gmail.com>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, Johannes Thumshirn <jthumshirn@suse.de>, Dave Jiang <dave.jiang@intel.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue, Oct 2, 2018 at 8:32 AM Jan Kara <jack@suse.cz> wrote:
>
> On Tue 02-10-18 07:52:06, Christoph Hellwig wrote:
> > On Tue, Oct 02, 2018 at 04:44:13PM +0200, Johannes Thumshirn wrote:
> > > On Tue, Oct 02, 2018 at 07:37:13AM -0700, Christoph Hellwig wrote:
> > > > No, it should not.  DAX is an implementation detail thay may change
> > > > or go away at any time.
> > >
> > > Well we had an issue with an application checking for dax, this is how
> > > we landed here in the first place.
> >
> > So what exacty is that "DAX" they are querying about (and no, I'm not
> > joking, nor being philosophical).
>
> I believe the application we are speaking about is mostly concerned about
> the memory overhead of the page cache. Think of a machine that has ~ 1TB of
> DRAM, the database running on it is about that size as well and they want
> database state stored somewhere persistently - which they may want to do by
> modifying mmaped database files if they do small updates... So they really
> want to be able to use close to all DRAM for the DB and not leave slack
> space for the kernel page cache to cache 1TB of database files.

VM_MIXEDMAP was never a reliable indication of DAX because it could be
set for random other device-drivers that use vm_insert_mixed(). The
MAP_SYNC flag positively indicates that page cache is disabled for a
given mapping, although whether that property is due to "dax" or some
other kernel mechanics is purely an internal detail.

I'm not opposed to faking out VM_MIXEDMAP if this broken check has
made it into production, but again, it's unreliable.
