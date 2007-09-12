Subject: Kernel Panic - 2.6.23-rc4-mm1 ia64 - was Re: Update:  [Automatic]
	NUMA replicated pagecache ...
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <46E7F2D8.3080003@linux.vnet.ibm.com>
References: <20070727084252.GA9347@wotan.suse.de>
	 <1186604723.5055.47.camel@localhost> <1186780099.5246.6.camel@localhost>
	 <20070813074351.GA15609@wotan.suse.de> <1189543962.5036.97.camel@localhost>
	 <46E74679.9020805@linux.vnet.ibm.com> <1189604927.5004.12.camel@localhost>
	 <46E7F2D8.3080003@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Wed, 12 Sep 2007 11:09:47 -0400
Message-Id: <1189609787.5004.33.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Joachim Deguara <joachim.deguara@amd.com>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Eric Whitney <eric.whitney@hp.com>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-09-12 at 19:38 +0530, Balbir Singh wrote:
> Lee Schermerhorn wrote:
> > On Wed, 2007-09-12 at 07:22 +0530, Balbir Singh wrote:
> >> Lee Schermerhorn wrote:
> >>> [Balbir:  see notes re:  replication and memory controller below]
> >>>
> >>> A quick update:  I have rebased the automatic/lazy page migration and
> >>> replication patches to 23-rc4-mm1.  If interested, you can find the
> >>> entire series that I push in the '070911' tarball at:
> >>>
> >>> 	http://free.linux.hp.com/~lts/Patches/Replication/
> >>>
> >>> I haven't gotten around to some of the things you suggested to address
> >>> the soft lockups. etc.  I just wanted to keep the patches up to date.  
> >>>
> >>> In the process of doing a quick sanity test, I encountered an issue with
> >>> replication and the new memory controller patches.  I had built the
> >>> kernel with the memory controller enabled.  I encountered a panic in
> >>> reclaim, while attempting to "drop caches", because replication was not
> >>> "charging" the replicated pages and reclaim tried to deref a null
> >>> "page_container" pointer.  [!!! new member in page struct !!!]
> >>>
> >>> I added code to try_to_create_replica(), __remove_replicated_page() and
> >>> release_pcache_desc() to charge/uncharge where I thought appropriate
> >>> [replication patch # 02].  That seemed to solve the panic during drop
> >>> caches triggered reclaim.  However, when I tried a more stressful load,
> >>> I hit another panic ["NaT Consumption" == ia64-ese for invalid pointer
> >>> deref, I think] in shrink_active_list() called from direct reclaim.
> >>> Still to be investigated.  I wanted to give you and Balbir a heads up
> >>> about the interaction of memory controllers with page replication.
> >>>
> >> Hi, Lee,
> >>
> >> Thanks for testing the memory controller with page replication. I do
> >> have some questions on the problem you are seeing
> >>
> >> Did you see the problem with direct reclaim or container reclaim?
> >> drop_caches calls remove_mapping(), which should eventually call
> >> the uncharge routine. We have some sanity checks in there.
> > 
> > Sorry.  This one wasn't in reclaim.  It was from the fault path, via
> > activate page.  The bug in reclaim occurred after I "fixed" page
> > replication to charge for replicated pages, thus adding the
> > page_container.  The second panic resulted from bad pointer ref in
> > shrink_active_list() from direct reclaim.
> > 
> > [abbreviated] stack traces attached below.
> > 
> > I took a look at an assembly language objdump and it appears that the
> > bad pointer deref occurred in the "while (!list_empty(&l_inactive))"
> > loop.  I see that there is also a mem_container_move_lists() call there.
> > I will try to rerun the workload on an unpatched 23-rc4-mm1 today to see
> > if it's reproducible there.  I can believe that this is a race between
> > replication [possibly "unreplicate"] and vmscan.  I don't know what type
> > of protection, if any, we have against that.  
> > 
> 
> 
> Thanks, the stack trace makes sense now. So basically, we have a case
> where a page is on the zone LRU, but does not belong to any container,
> which is why we do indeed need your first fix (to charge/uncharge) the
> pages on replication/removal.
> 
> >> We do try to see at several places if the page->page_container is NULL
> >> and check for it. I'll look at your patches to see if there are any
> >> changes to the reclaim logic. I tried looking for the oops you
> >> mentioned, but could not find it in your directory, I saw the soft
> >> lockup logs though. Do you still have the oops saved somewhere?
> >>
> >> I think the fix you have is correct and makes things works, but it
> >> worries me that in direct reclaim we dereference the page_container
> >> pointer without the page belonging to a container? What are the
> >> properties of replicated pages? Are they assumed to be exact
> >> replicas (struct page mappings, page_container expected to be the
> >> same for all replicated pages) of the replicated page?
> > 
> > Before "fix"
> > 
> > Running spol+lpm+repl patches on 23-rc4-mm1.  kernel build test
> > echo 1 >/proc/sys/vm/drop_caches
> > Then [perhaps a coincidence]:
> > 
> > Unable to handle kernel NULL pointer dereference (address 0000000000000008)
> > cc1[23366]: Oops 11003706212352 [1]
> > Modules linked in: sunrpc binfmt_misc fan dock sg thermal processor container button sr_mod scsi_wait_scan ehci_hcd ohci_hcd uhci_hcd usbcore
> > 
> > Pid: 23366, CPU 6, comm:                  cc1
> > <snip>
> >  [<a000000100191a30>] __mem_container_move_lists+0x50/0x100
> >                                 sp=e0000720449a7d60 bsp=e0000720449a1040
> >  [<a000000100192570>] mem_container_move_lists+0x50/0x80
> >                                 sp=e0000720449a7d60 bsp=e0000720449a1010
> >  [<a0000001001382b0>] activate_page+0x1d0/0x220
> >                                 sp=e0000720449a7d60 bsp=e0000720449a0fd0
> >  [<a0000001001389c0>] mark_page_accessed+0xe0/0x160
> >                                 sp=e0000720449a7d60 bsp=e0000720449a0fb0
> >  [<a000000100125f30>] filemap_fault+0x390/0x840
> >                                 sp=e0000720449a7d60 bsp=e0000720449a0f10
> >  [<a000000100146870>] __do_fault+0xd0/0xbc0
> >                                 sp=e0000720449a7d60 bsp=e0000720449a0e90
> >  [<a00000010014b8e0>] handle_mm_fault+0x280/0x1540
> >                                 sp=e0000720449a7d90 bsp=e0000720449a0e00
> >  [<a000000100071940>] ia64_do_page_fault+0x600/0xa80
> >                                 sp=e0000720449a7da0 bsp=e0000720449a0da0
> >  [<a00000010000b5c0>] ia64_leave_kernel+0x0/0x270
> >                                 sp=e0000720449a7e30 bsp=e0000720449a0da0
> > 
> > 
> > After "fix:"
> > 
> > Running "usex" [unix systems exerciser] load, with kernel build, io tests,
> > vm tests, memtoy "lock" tests, ...
> > 
> 
> Wow! thats a real stress, thanks for putting the controller through
> this. How long is it before the system panics? BTW, is NaT NULL Address
> Translation? Does this problem go away with the memory controller
> disabled?

System panics within a few seconds of starting the test.

NaT == Not a Thing.  Kernel reports null pointer deref as such.  I
believe that NaT Consumption errors come from attempting to deref a
non-NULL pointer that points at non-existent memory.

I tried the workload again with an "unpatched kernel" -- i.e., no
automatic page migration nor replication, nor any other of my
experimental patches.  Still happens with memory controller configured
-- same stack trace.

Then I tried an unpatched 23-rc4-mm1 with memory controller NOT
configured, still panic'ed, but with a different symptom:  first a soft
lockup, then a NULL pointer deref--apparently in soft lockup detection
code.  Panics because it OOPses in interrupt handler.

Tried again, same kernel--mem controller unconfig'd:  this time I got
the original stack trace--NaT Consumption in shrink_active_list().
Then, softlockup with NULL pointer deref therein.  It's the null pointer
deref that causes the panic:  "Aiee, killing interrupt handler!"

So, maybe memory controller is "off the hook".

I guess I need to check the lists for 23-rc4-mm1 hot fixes, and try to
bisect rc4-mm1.

> 
> > as[15608]: NaT consumption 2216203124768 [1]
> > Modules linked in: sunrpc binfmt_misc fan dock sg container thermal button processor sr_mod scsi_wait_scan ehci_hcd ohci_hcd uhci_hcd usbcore
> > 
> > Pid: 15608, CPU 8, comm:                   as
> > <snip>
> >  [<a00000010000b5c0>] ia64_leave_kernel+0x0/0x270
> >                                 sp=e00007401f53fab0 bsp=e00007401f539238
> >  [<a00000010013b4a0>] shrink_active_list+0x160/0xe80
> >                                 sp=e00007401f53fc80 bsp=e00007401f539158
> >  [<a00000010013e780>] shrink_zone+0x240/0x280
> >                                 sp=e00007401f53fd40 bsp=e00007401f539100
> >  [<a00000010013fec0>] zone_reclaim+0x3c0/0x580
> >                                 sp=e00007401f53fd40 bsp=e00007401f539098
> >  [<a000000100130950>] get_page_from_freelist+0xb30/0x1360
> >                                 sp=e00007401f53fd80 bsp=e00007401f538f08
> >  [<a000000100131310>] __alloc_pages+0xd0/0x620
> >                                 sp=e00007401f53fd80 bsp=e00007401f538e38
> >  [<a000000100173240>] alloc_page_pol+0x100/0x180
> >                                 sp=e00007401f53fd90 bsp=e00007401f538e08
> >  [<a0000001001733b0>] alloc_page_vma+0xf0/0x120
> >                                 sp=e00007401f53fd90 bsp=e00007401f538dc8
> >  [<a00000010014bda0>] handle_mm_fault+0x740/0x1540
> >                                 sp=e00007401f53fd90 bsp=e00007401f538d38
> >  [<a000000100071940>] ia64_do_page_fault+0x600/0xa80
> >                                 sp=e00007401f53fda0 bsp=e00007401f538ce0
> >  [<a00000010000b5c0>] ia64_leave_kernel+0x0/0x270
> >                                 sp=e00007401f53fe30 bsp=e00007401f538ce0
> > 
> > 
> 
> Interesting, I don't see a memory controller function in the stack
> trace, but I'll double check to see if I can find some silly race
> condition in there.

right.  I noticed that after I sent the mail.  

Also, config available at:
http://free.linux.hp.com/~lts/Temp/config-2.6.23-rc4-mm1-gwydyr-nomemcont



Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
