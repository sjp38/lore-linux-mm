Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1DE5B6B00DE
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:51:48 -0400 (EDT)
Date: Wed, 3 Jun 2009 23:51:33 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler
	in the VM v3
Message-ID: <20090603155133.GA7529@localhost>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528095934.GA10678@localhost> <20090528122357.GM6920@wotan.suse.de> <20090528135428.GB16528@localhost> <20090601115046.GE5018@wotan.suse.de> <20090601183225.GS1065@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090601183225.GS1065@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <npiggin@suse.de>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 02:32:25AM +0800, Andi Kleen wrote:
[snip]
> > > > > Clean swap cache pages can be directly isolated. A later page fault will bring
> > > > > in the known good data from disk.
> > > > 
> > > > OK, but why do you ClearPageUptodate if it is just to be deleted from
> > > > swapcache anyway?
> > > 
> > > The ClearPageUptodate() is kind of a careless addition, in the hope
> > > that it will stop some random readers. Need more investigations.
> > 
> > OK. But it just muddies the waters in the meantime, so maybe take
> > such things out until there is a case for them.
> 
> It's gone

Andi, I'd recommend to re-add ClearPageUptodate() for dirty swap cache
pages. It will then make shmem_getpage() return EIO for
- shmem_fault()        => kill app with VM_FAULT_SIGBUS
- shmem_readpage()     => fail splice()/sendfile() etc.
- shmem_write_begin()  => fail splice()/sendfile() etc.
which is exactly what we wanted. Note that the EIO here is permanent.

I'll continue to do some experiments on its normal read/write behaviors.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
