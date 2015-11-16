Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 846636B0038
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 18:42:51 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so193169913pab.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 15:42:51 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id y6si53200920pas.144.2015.11.16.15.42.49
        for <linux-mm@kvack.org>;
        Mon, 16 Nov 2015 15:42:50 -0800 (PST)
Date: Tue, 17 Nov 2015 10:42:46 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 03/11] pmem: enable REQ_FUA/REQ_FLUSH handling
Message-ID: <20151116234246.GZ19199@dastard>
References: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
 <1447459610-14259-4-git-send-email-ross.zwisler@linux.intel.com>
 <CAPcyv4j4arHE+iAALn1WPDzSb_QSCDy8udtXU1FV=kYSZDfv8A@mail.gmail.com>
 <22E0F870-C1FB-431E-BF6C-B395A09A2B0D@dilger.ca>
 <CAPcyv4jwx3VzyRugcpH7KCOKM64kJ4Bq4wgY=iNJMvLTHrBv-Q@mail.gmail.com>
 <20151116133714.GB3443@quack.suse.cz>
 <20151116140526.GA6733@quack.suse.cz>
 <20151116221412.GV19199@dastard>
 <20151116232927.GA5582@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151116232927.GA5582@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Andreas Dilger <adilger@dilger.ca>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, XFS Developers <xfs@oss.sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Mon, Nov 16, 2015 at 04:29:27PM -0700, Ross Zwisler wrote:
> On Tue, Nov 17, 2015 at 09:14:12AM +1100, Dave Chinner wrote:
> > On Mon, Nov 16, 2015 at 03:05:26PM +0100, Jan Kara wrote:
> > > On Mon 16-11-15 14:37:14, Jan Kara wrote:
> > > > On Fri 13-11-15 18:32:40, Dan Williams wrote:
> > > > > On Fri, Nov 13, 2015 at 4:43 PM, Andreas Dilger <adilger@dilger.ca> wrote:
> > > > > > On Nov 13, 2015, at 5:20 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> > > > > >>
> > > > > >> On Fri, Nov 13, 2015 at 4:06 PM, Ross Zwisler
> > > > > >> <ross.zwisler@linux.intel.com> wrote:
> > > > > >>> Currently the PMEM driver doesn't accept REQ_FLUSH or REQ_FUA bios.  These
> > > > > >>> are sent down via blkdev_issue_flush() in response to a fsync() or msync()
> > > > > >>> and are used by filesystems to order their metadata, among other things.
> > > > > >>>
> > > > > >>> When we get an msync() or fsync() it is the responsibility of the DAX code
> > > > > >>> to flush all dirty pages to media.  The PMEM driver then just has issue a
> > > > > >>> wmb_pmem() in response to the REQ_FLUSH to ensure that before we return all
> > > > > >>> the flushed data has been durably stored on the media.
> > > > > >>>
> > > > > >>> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > > > > >>
> > > > > >> Hmm, I'm not seeing why we need this patch.  If the actual flushing of
> > > > > >> the cache is done by the core why does the driver need support
> > > > > >> REQ_FLUSH?  Especially since it's just a couple instructions.  REQ_FUA
> > > > > >> only makes sense if individual writes can bypass the "drive" cache,
> > > > > >> but no I/O submitted to the driver proper is ever cached we always
> > > > > >> flush it through to media.
> > > > > >
> > > > > > If the upper level filesystem gets an error when submitting a flush
> > > > > > request, then it assumes the underlying hardware is broken and cannot
> > > > > > be as aggressive in IO submission, but instead has to wait for in-flight
> > > > > > IO to complete.
> > > > > 
> > > > > Upper level filesystems won't get errors when the driver does not
> > > > > support flush.  Those requests are ended cleanly in
> > > > > generic_make_request_checks().  Yes, the fs still needs to wait for
> > > > > outstanding I/O to complete but in the case of pmem all I/O is
> > > > > synchronous.  There's never anything to await when flushing at the
> > > > > pmem driver level.
> > > > > 
> > > > > > Since FUA/FLUSH is basically a no-op for pmem devices,
> > > > > > it doesn't make sense _not_ to support this functionality.
> > > > > 
> > > > > Seems to be a nop either way.  Given that DAX may lead to dirty data
> > > > > pending to the device in the cpu cache that a REQ_FLUSH request will
> > > > > not touch, its better to leave it all to the mm core to handle.  I.e.
> > > > > it doesn't make sense to call the driver just for two instructions
> > > > > (sfence + pcommit) when the mm core is taking on the cache flushing.
> > > > > Either handle it all in the mm or the driver, not a mixture.
> > > > 
> > > > So I think REQ_FLUSH requests *must* end up doing sfence + pcommit because
> > > > e.g. journal writes going through block layer or writes done through
> > > > dax_do_io() must be on permanent storage once REQ_FLUSH request finishes
> > > > and the way driver does IO doesn't guarantee this, does it?
> > > 
> > > Hum, and looking into how dax_do_io() works and what drivers/nvdimm/pmem.c
> > > does, I'm indeed wrong because they both do wmb_pmem() after each write
> > > which seems to include sfence + pcommit. Sorry for confusion.
> > 
> > Which I want to remove, because it makes DAX IO 3x slower than
> > buffered IO on ramdisk based testing.
> > 
> > > But a question: Won't it be better to do sfence + pcommit only in response
> > > to REQ_FLUSH request and don't do it after each write? I'm not sure how
> > > expensive these instructions are but in theory it could be a performance
> > > win, couldn't it? For filesystems this is enough wrt persistency
> > > guarantees...
> > 
> > I'm pretty sure it would be, because all of the overhead (and
> > therefore latency) I measured is in the cache flushing instructions.
> > But before we can remove the wmb_pmem() from  dax_do_io(), we need
> > the underlying device to support REQ_FLUSH correctly...
> 
> By "support REQ_FLUSH correctly" do you mean call wmb_pmem() as I do in my
> set?  Or do you mean something that also involves cache flushing such as the
> "big hammer" that flushes everything or something like WBINVD?

Either. Both solve the problem of defering the cache flush penalty
to the context that needs it..

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
