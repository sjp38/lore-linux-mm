Received: by rv-out-0708.google.com with SMTP id f25so2732367rvb.26
        for <linux-mm@kvack.org>; Thu, 16 Oct 2008 04:14:05 -0700 (PDT)
Date: Thu, 16 Oct 2008 16:43:53 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@gmail.com>
Subject: Re: [PATCH updated] ext4: Fix file fragmentation during large file
	write.
Message-ID: <20081016111353.GB3354@skywalker>
References: <1223661776-20098-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1224103260.6938.45.camel@think.oraclecorp.com> <1224114692.6938.48.camel@think.oraclecorp.com> <20081016091015.GA3354@skywalker>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081016091015.GA3354@skywalker>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, cmm@us.ibm.com, tytso@mit.edu, sandeen@redhat.com, akpm@linux-foundation.org, hch@infradead.org, steve@chygwyn.com, npiggin@suse.de, mpatocka@redhat.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 16, 2008 at 02:40:15PM +0530, Aneesh Kumar K.V wrote:
> On Wed, Oct 15, 2008 at 07:51:32PM -0400, Chris Mason wrote:
> > On Wed, 2008-10-15 at 16:41 -0400, Chris Mason wrote:
> > > On Fri, 2008-10-10 at 23:32 +0530, Aneesh Kumar K.V wrote:
> > > > The range_cyclic writeback mode use the address_space
> > > > writeback_index as the start index for writeback. With
> > > > delayed allocation we were updating writeback_index
> > > > wrongly resulting in highly fragmented file. Number of
> > > > extents reduced from 4000 to 27 for a 3GB file with
> > > > the below patch.
> > > > 
> > > 
> > > I tested the ext4 patch queue from today on top of 2.6.27, and this
> > > includes Aneesh's latest patches.
> > > 
> > > Things are going at disk speed for streaming writes, with the number of
> > > extents generated for a 32GB file down to 27.  So, this is definitely an
> > > improvement for ext4.
> > 
> > Just FYI, I ran this with compilebench -i 20 --makej and my log is full
> > of these:
> > 
> > ext4_da_writepages: jbd2_start: 1024 pages, ino 520417; err -30
> > Pid: 4072, comm: pdflush Not tainted 2.6.27 #2
> > 
> 

compilebench numbers

ext4
==========================================================================
intial create total runs 20 avg 30.25 MB/s (user 0.74s sys 2.40s)
no runs for create
no runs for patch
compile total runs 20 avg 39.79 MB/s (user 0.17s sys 2.55s)
no runs for clean
no runs for read tree
read compiled tree total runs 3 avg 19.83 MB/s (user 0.97s sys 4.08s)
no runs for delete tree
delete compiled tree total runs 20 avg 4.42 seconds (user 0.58s sys 1.79s)
no runs for stat tree

ext3
======================
intial create total runs 20 avg 27.96 MB/s (user 0.73s sys 2.57s)
no runs for create
no runs for patch
compile total runs 20 avg 28.84 MB/s (user 0.17s sys 4.03s)
no runs for clean
no runs for read tree
read compiled tree total runs 3 avg 19.46 MB/s (user 0.97s sys 4.13s)
no runs for delete tree
delete compiled tree total runs 20 avg 18.09 seconds (user 0.58s sys 1.61s)
no runs for stat tree
no runs for stat compiled tree

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
