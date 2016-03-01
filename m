Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8E6046B0009
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 17:36:09 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id fl4so119927512pad.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 14:36:09 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTP id y8si30278220pas.240.2016.03.01.14.36.08
        for <linux-mm@kvack.org>;
        Tue, 01 Mar 2016 14:36:08 -0800 (PST)
Message-ID: <1456871764.2369.59.camel@HansenPartnership.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Support for 1GB THP
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Tue, 01 Mar 2016 14:36:04 -0800
In-Reply-To: <20160301214403.GJ3730@linux.intel.com>
References: <20160301070911.GD3730@linux.intel.com>
	 <20160301102541.GD27666@quack.suse.cz>
	 <20160301214403.GJ3730@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>, Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Tue, 2016-03-01 at 16:44 -0500, Matthew Wilcox wrote:
> On Tue, Mar 01, 2016 at 11:25:41AM +0100, Jan Kara wrote:
> > On Tue 01-03-16 02:09:11, Matthew Wilcox wrote:
> > > There are a few issues around 1GB THP support that I've come up
> > > against
> > > while working on DAX support that I think may be interesting to
> > > discuss
> > > in person.
> > > 
> > >  - Do we want to add support for 1GB THP for anonymous pages? 
> > >  DAX support
> > >    is driving the initial 1GB THP support, but would anonymous
> > > VMAs also
> > >    benefit from 1GB support?  I'm not volunteering to do this
> > > work, but
> > >    it might make an interesting conversation if we can identify
> > > some users
> > >    who think performance would be better if they had 1GB THP
> > > support.
> > 
> > Some time ago I was thinking about 1GB THP and I was wondering: 
> > What is the motivation for 1GB pages for persistent memory? Is it 
> > the savings in memory used for page tables? Or is it about the cost
> > of fault?
> 
> I think it's both.  I heard from one customer who calculated that 
> with a 6TB server, mapping every page into a process would take ~24MB 
> of page tables.  Multiply that by the 50,000 processes they expect to
> run on a server of that size consumes 1.2TB of DRAM.  Using 1GB pages
> reduces that by a factor of 512, down to 2GB.

This sounds a bit implausible: for the machine not to be thrashing to
death, all the 6TB would have to be in shared memory used by all the
50k processes.  The much more likely scenario is that it's mostly
private memory mixed with a bit of shared, in which case sum(private
working set) + shared must be under 6TB for the machine not to thrash
and you likely only need mappings for the working set. Realistically
that means you only need about 50MB or so of page tables, even with our
current page size, assuming it's mostly file backed.  There might be
some optimisation done for the anonymous memory swap case, which is the
pte profligate one, but probably we shouldn't do anything until we
understand the workload profile.

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
