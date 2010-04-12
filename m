Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E8F5C6B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 07:28:16 -0400 (EDT)
Date: Mon, 12 Apr 2010 14:23:30 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [Bugme-new] [Bug 15709] New: swapper page allocation failure
Message-ID: <20100412112330.GA16908@redhat.com>
References: <bug-15709-10286@https.bugzilla.kernel.org/> <20100408123438.1cadc5b6.akpm@linux-foundation.org> <4BBE30F6.30607@redhat.com> <20100408200449.GA6044@redhat.com> <4BBEFE25.7000807@tauceti.net> <20100411110303.GD8992@redhat.com> <4BC2E706.7010108@tauceti.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BC2E706.7010108@tauceti.net>
Sender: owner-linux-mm@kvack.org
To: Robert Wimmer <kernel@tauceti.net>
Cc: Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 11:25:26AM +0200, Robert Wimmer wrote:
> server10:/usr/src/linux # git bisect start v2.6.31 v2.6.30 --
> drivers/virtio/ drivers/net/virtio_net.c
> Bisecting: 12 revisions left to test after this (roughly 4 steps)
> [e3353853730eb99c56b7b0aed1667d51c0e3699a] virtio: enhance id_matching
> for virtio drivers
> 

Sorry I wasn't clear. the way to use bisect is as follows:
- first start as you did now.
1. now build kernel, install and test
2. if bug is there, type 'git bisect bad'
3. if bug is not there, type 'git bisect good'
4. The above will give you another kernel version to test
   if so go back to step 1
6. this will be repeated about 4 times (number of steps above)
7. in the end you will get the first revision which has the
   problem. Let's assume it is revision ABCDEF.

   Type git bisect log to see your history.

8. Now git reset --hard ABCDEF~1 and try again.

If you see the problem with ABCDEF but not ABCDEF~1
then we will have a good guess at the culprit.

Some more tips here:
http://www.kernel.org/pub/software/scm/git/docs/git-bisect.html


> Today I've upgraded to qemu-kvm-0.12.3-r1 (Gentoo package)
> but doesn't help. Still getting "page allocation failure" with
> 2.6.31-rc5.
> 
> Does it makes sense to use the same 2.6.31-rc5 kernel
> in the host and guest for testing? Currently I'm still using 2.6.32
> in host and testing 2.6.31-rc5 in guest until "crashes".
> Then I start the guest with 2.6.30 again which works
> without trouble with 2.6.32 as host.
> 
> This is really strange. I have hosts with 2.6.32 running
> guests with 2.6.32 which works perfectly. These hosts
> and guests running on HP DL 380 G6 with Intel Xeon X5560.
> The guests which don't work with 2.6.32 (and 2.6.32
> as host) running on HP DL 380 G5 with Intel Xeon L5420.

Hmm. Some subtle race?

> (All guests) and (all hosts) have the same packages
> and the same versions installed and the same kernel
> configs (hosts and guests using different .config but the
> difference is very small e.g. CONFIG_PARAVIRT_SPINLOCKS=y,
> CONFIG_PARAVIRT_GUEST=y in guests but not in hosts
> .config).
> 
> I've had problems with qemu-kvm 0.12.2 with high network
> traffic which was solved by a patch submitted by Tom
> Lendacky:
> 
> "Fix a race condition where qemu finds that there are not enough virtio
> ring buffers available and the guest make more buffers available before
> qemu can enable notifications."
> http://www.mail-archive.com/kvm@vger.kernel.org/msg28667.html
> 
> It was a real lifesaver for the HP DL 380 G6 mentioned
> above but maybe this is now causing the problems with the G5 machines.
> The symptoms are the same. I can still log into the guest
> via VNC but the network is down.
> 
> Thanks!
> Robert
> 

For now the only thing we seem to know for sure is that on
specific hardware there's a regression between 2.6.30 and
2.6.31-rc5. Yes, it is possible that all it does
is expose a qemu bug, but it's hard to say.
Let's find out what change
does that, this should give us a hint.

> On 04/11/10 13:03, Michael S. Tsirkin wrote:
> > On Fri, Apr 09, 2010 at 12:15:01PM +0200, Robert Wimmer wrote:
> >   
> >> I'm not really a git hero so here is what I've done:
> >>
> >> cd /usr/src
> >> git clone
> >> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git linux
> >> cd linux
> >> git checkout -b mykernel 0b4f2928f14c4a9770b0866923fc81beb7f4aa57
> >>     
> > Looks right.
> >
> >   
> >> Then I've checked
> >>
> >> drivers/net/virtio_net.c
> >> drivers/net/smc91x.c
> >>
> >> if the changes commited where not in there.
> >> Next I build my kernel as usual. I used my .config
> >> from 2.6.30 (which is working fine in a several
> >> guests / .config see here:
> >> https://bugzilla.kernel.org/attachment.cgi?id=25925)
> >> and build the kernel
> >>
> >> genkernel --menuconfig --lvm --oldconfig all
> >>
> >> which finally gave me a 2.6.31-rc5.
> >>     
> > That's right.
> >
> >   
> >> I should mention
> >> that 2.6.30 was using SLUB. So here is the output
> >> from the 2.6.31-rc5 kernel running about 20 min.:
> >> https://bugzilla.kernel.org/attachment.cgi?id=25926
> >>     
> > Hmm, so we see the error here as well?
> >
> >   
> >> Seems not very usefull to me. I'm currently compiling
> >> the same kernel with SLAB.
> >>
> >> Please let me know if the git commands above are
> >> right and/or if you need other kernel options enabled.
> >>     
> > Looks right. You don't have to add -b flag if you don't
> > want to.
> >
> >   
> >> Thanks!
> >> Robert
> >>     
> > Hmm, I do not see anything else that seems related.
> > Could you please try to bisect?
> >
> > git bisect start v2.6.31 v2.6.30 -- drivers/virtio/ drivers/net/virtio_net.c
> >
> > should help assuming the change that triggers this is in virtio.
> >
> >
> >   
> >> On 04/08/10 22:04, Michael S. Tsirkin wrote:
> >>     
> >>> On Thu, Apr 08, 2010 at 10:39:34PM +0300, Avi Kivity wrote:
> >>>   
> >>>       
> >>>> cc: mst
> >>>>
> >>>> On 04/08/2010 10:34 PM, Andrew Morton wrote:
> >>>>     
> >>>>         
> >>>>> (switched to email.  Please respond via emailed reply-to-all, not via the
> >>>>> bugzilla web interface).
> >>>>>
> >>>>> On Wed, 7 Apr 2010 10:29:20 GMT
> >>>>> bugzilla-daemon@bugzilla.kernel.org wrote:
> >>>>>
> >>>>>    
> >>>>>       
> >>>>>           
> >>>>>> https://bugzilla.kernel.org/show_bug.cgi?id=15709
> >>>>>>
> >>>>>>             Summary: swapper page allocation failure
> >>>>>>             Product: Memory Management
> >>>>>>             Version: 2.5
> >>>>>>      Kernel Version: 2.6.32 and 2.6.33
> >>>>>>            Platform: All
> >>>>>>          OS/Version: Linux
> >>>>>>                Tree: Mainline
> >>>>>>              Status: NEW
> >>>>>>            Severity: normal
> >>>>>>            Priority: P1
> >>>>>>           Component: Slab Allocator
> >>>>>>          AssignedTo: akpm@linux-foundation.org
> >>>>>>          ReportedBy: kernel@tauceti.net
> >>>>>>          Regression: No
> >>>>>>
> >>>>>>
> >>>>>> Created an attachment (id=25903)
> >>>>>>   -->  (https://bugzilla.kernel.org/attachment.cgi?id=25903)
> >>>>>> dmesg output
> >>>>>>
> >>>>>> I'm having problems with "swapper page allocation failure's" since upgrading
> >>>>>> from kernel 2.6.30 to 2.6.32/2.6.33. The problems occur inside a kernel virtual
> >>>>>> maschine (KVM). Running Gentoo with kernel 2.6.32 as host which works fine. As
> >>>>>> long as kernel 2.6.30 is used as guest kernel the guest runs fine. But after
> >>>>>> upgrading to 2.6.32 and 2.6.33 I get "swapper page allocation failure's" (see
> >>>>>> attachment of dmesg output). The guest is only running a Apache webserver and
> >>>>>> serves files from a NFS share. It has 1 GB RAM and 2 virtual CPUs. I've tried
> >>>>>> different kernel configurations (e.g. a unmodified version from Sabayon Linux
> >>>>>> Distribution) but doesn't help. Load of the guest (and host) is very low.
> >>>>>> Network traffic is about 20-50 MBit/s.
> >>>>>>
> >>>>>>      
> >>>>>>         
> >>>>>>             
> >>>>> hm, this is a regression.
> >>>>>
> >>>>> : [  454.006706] users: page allocation failure. order:0, mode:0x20
> >>>>> : [  454.006712] Pid: 7992, comm: users Not tainted 2.6.34-rc3-git6 #2
> >>>>> : [  454.006714] Call Trace:
> >>>>> : [  454.006717]<IRQ>   [<ffffffff8109dff7>] __alloc_pages_nodemask+0x5c8/0x615
> >>>>> : [  454.006796]  [<ffffffff817860ce>] ? ip_local_deliver+0x65/0x6d
> >>>>> : [  454.006820]  [<ffffffff810c39c4>] alloc_pages_current+0x96/0x9f
> >>>>> : [  454.006842]  [<ffffffff8167f2c7>] try_fill_recv+0x5e/0x20f
> >>>>> : [  454.006846]  [<ffffffff8167fe13>] virtnet_poll+0x52a/0x5c7
> >>>>> : [  454.006858]  [<ffffffff8104fe74>] ? run_timer_softirq+0x1dc/0x1f4
> >>>>> : [  454.006873]  [<ffffffff8176035d>] net_rx_action+0xad/0x1a5
> >>>>> : [  454.006882]  [<ffffffff8104b6cd>] __do_softirq+0x9c/0x127
> >>>>> : [  454.006897]  [<ffffffff81008ffc>] call_softirq+0x1c/0x30
> >>>>> : [  454.006901]  [<ffffffff8100af01>] do_softirq+0x41/0x7e
> >>>>> : [  454.006904]  [<ffffffff8104b3e3>] irq_exit+0x36/0x75
> >>>>> : [  454.006907]  [<ffffffff8100a5ee>] do_IRQ+0xaa/0xc1
> >>>>> : [  454.006926]  [<ffffffff8183bc13>] ret_from_intr+0x0/0x11
> >>>>> : [  454.006928]<EOI>   [<ffffffff81026b25>] ? kvm_deferred_mmu_op+0x5e/0xe7
> >>>>> : [  454.006942]  [<ffffffff81026b19>] ? kvm_deferred_mmu_op+0x52/0xe7
> >>>>> : [  454.006946]  [<ffffffff81026c03>] kvm_mmu_write+0x2e/0x35
> >>>>> : [  454.006949]  [<ffffffff81026c7d>] kvm_set_pte_at+0x19/0x1b
> >>>>> : [  454.006953]  [<ffffffff810aba67>] __do_fault+0x3c4/0x492
> >>>>> : [  454.006957]  [<ffffffff810adcf4>] handle_mm_fault+0x478/0x9d8
> >>>>> : [  454.006966]  [<ffffffff810deb59>] ? path_put+0x2c/0x30
> >>>>> : [  454.006975]  [<ffffffff8102f162>] do_page_fault+0x2f6/0x31a
> >>>>> : [  454.006979]  [<ffffffff8183b81e>] ? _raw_spin_lock+0x9/0xd
> >>>>> : [  454.006982]  [<ffffffff8183bef5>] page_fault+0x25/0x30
> >>>>> : [  454.006985] Mem-Info:
> >>>>> : [  454.006987] Node 0 DMA per-cpu:
> >>>>> : [  454.006990] CPU    0: hi:    0, btch:   1 usd:   0
> >>>>> : [  454.006992] CPU    1: hi:    0, btch:   1 usd:   0
> >>>>> : [  454.006993] Node 0 DMA32 per-cpu:
> >>>>> : [  454.006996] CPU    0: hi:  186, btch:  31 usd: 185
> >>>>> : [  454.006998] CPU    1: hi:  186, btch:  31 usd: 112
> >>>>> : [  454.007003] active_anon:8308 inactive_anon:8544 isolated_anon:0
> >>>>> : [  454.007005]  active_file:4882 inactive_file:205902 isolated_file:0
> >>>>> : [  454.007006]  unevictable:0 dirty:11 writeback:0 unstable:0
> >>>>> : [  454.007007]  free:1385 slab_reclaimable:2445 slab_unreclaimable:4466
> >>>>> : [  454.007008]  mapped:1895 shmem:113 pagetables:1370 bounce:0
> >>>>> : [  454.007010] Node 0 DMA free:4000kB min:60kB low:72kB high:88kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:11844kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15768kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:64kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> >>>>> : [  454.007021] lowmem_reserve[]: 0 994 994 994
> >>>>> : [  454.007025] Node 0 DMA32 free:1540kB min:4000kB low:5000kB high:6000kB active_anon:33232kB inactive_anon:34176kB active_file:19528kB inactive_file:811764kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1018068kB mlocked:0kB dirty:44kB writeback:0kB mapped:7580kB shmem:452kB slab_reclaimable:9716kB slab_unreclaimable:17832kB kernel_stack:1144kB pagetables:5480kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> >>>>> : [  454.007036] lowmem_reserve[]: 0 0 0 0
> >>>>> : [  454.007040] Node 0 DMA: 0*4kB 4*8kB 6*16kB 5*32kB 6*64kB 4*128kB 1*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 4000kB
> >>>>> : [  454.007050] Node 0 DMA32: 13*4kB 2*8kB 3*16kB 1*32kB 2*64kB 0*128kB 1*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 1556kB
> >>>>> : [  454.007059] 210914 total pagecache pages
> >>>>> : [  454.007061] 0 pages in swap cache
> >>>>> : [  454.007063] Swap cache stats: add 0, delete 0, find 0/0
> >>>>> : [  454.007065] Free swap  = 1959924kB
> >>>>> : [  454.007067] Total swap = 1959924kB
> >>>>> : [  454.014238] 262140 pages RAM
> >>>>> : [  454.014241] 7489 pages reserved
> >>>>> : [  454.014242] 21430 pages shared
> >>>>> : [  454.014244] 247174 pages non-shared
> >>>>>
> >>>>> Either page reclaim got worse or kvm/virtio-net got more aggressive.
> >>>>>
> >>>>> Avi, Rusty: can you think of any changes in the KVM/virtio area in the
> >>>>> 2.6.30 ->  2.6.32 timeframe which may have increased the GFP_ATOMIC
> >>>>> demands upon the page allocator?
> >>>>>
> >>>>> Thanks.
> >>>>>    
> >>>>>       
> >>>>>           
> >>> On the contrary, with commit
> >>> 3161e453e496eb5643faad30fff5a5ab183da0fe
> >>> we should be using GFP_ATOMIC less.
> >>> But maybe there's a bug and it has the reverse effect somehow ...
> >>>
> >>> Robert, could you pls try 3161e453e496eb5643faad30fff5a5ab183da0fe
> >>> and if that *does* have the problem,
> >>> 0b4f2928f14c4a9770b0866923fc81beb7f4aa57?
> >>>
> >>>   
> >>>       

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
