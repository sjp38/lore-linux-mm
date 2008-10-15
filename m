Subject: Re: [PATCH updated] ext4: Fix file fragmentation during large file
	write.
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <1224103260.6938.45.camel@think.oraclecorp.com>
References: <1223661776-20098-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <1224103260.6938.45.camel@think.oraclecorp.com>
Content-Type: text/plain
Date: Wed, 15 Oct 2008 19:51:32 -0400
Message-Id: <1224114692.6938.48.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: cmm@us.ibm.com, tytso@mit.edu, sandeen@redhat.com, akpm@linux-foundation.org, hch@infradead.org, steve@chygwyn.com, npiggin@suse.de, mpatocka@redhat.com, linux-mm@kvack.org, inux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2008-10-15 at 16:41 -0400, Chris Mason wrote:
> On Fri, 2008-10-10 at 23:32 +0530, Aneesh Kumar K.V wrote:
> > The range_cyclic writeback mode use the address_space
> > writeback_index as the start index for writeback. With
> > delayed allocation we were updating writeback_index
> > wrongly resulting in highly fragmented file. Number of
> > extents reduced from 4000 to 27 for a 3GB file with
> > the below patch.
> > 
> 
> I tested the ext4 patch queue from today on top of 2.6.27, and this
> includes Aneesh's latest patches.
> 
> Things are going at disk speed for streaming writes, with the number of
> extents generated for a 32GB file down to 27.  So, this is definitely an
> improvement for ext4.

Just FYI, I ran this with compilebench -i 20 --makej and my log is full
of these:

ext4_da_writepages: jbd2_start: 1024 pages, ino 520417; err -30
Pid: 4072, comm: pdflush Not tainted 2.6.27 #2

Call Trace:
 [<ffffffffa0048493>] ext4_da_writepages+0x171/0x2d3 [ext4]
 [<ffffffff802336be>] ? pick_next_task_fair+0x80/0x91
 [<ffffffff80228fa8>] ? source_load+0x2a/0x58
 [<ffffffff8038e499>] ? __next_cpu+0x19/0x26
 [<ffffffff8026748f>] do_writepages+0x28/0x37
 [<ffffffff802a6b39>] __writeback_single_inode+0x14f/0x26d
 [<ffffffff802a6fb7>] generic_sync_sb_inodes+0x1c1/0x2a2
 [<ffffffff802a70a1>] sync_sb_inodes+0x9/0xb
 [<ffffffff802a73dc>] writeback_inodes+0x64/0xad
 [<ffffffff802675db>] wb_kupdate+0x9a/0x10c
 [<ffffffff80267fd1>] ? pdflush+0x0/0x1e9
 [<ffffffff80267fd1>] ? pdflush+0x0/0x1e9
 [<ffffffff8026810e>] pdflush+0x13d/0x1e9
 [<ffffffff80267541>] ? wb_kupdate+0x0/0x10c
 [<ffffffff80248222>] kthread+0x49/0x77
 [<ffffffff8020c5e9>] child_rip+0xa/0x11
 [<ffffffff802481d9>] ? kthread+0x0/0x77
 [<ffffffff8020c5df>] ? child_rip+0x0/0x11


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
