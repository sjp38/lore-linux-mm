Message-ID: <49051C71.9040404@sgi.com>
Date: Mon, 27 Oct 2008 12:42:09 +1100
From: Lachlan McIlroy <lachlan@sgi.com>
Reply-To: lachlan@sgi.com
MIME-Version: 1.0
Subject: Re: deadlock with latest xfs
References: <4900412A.2050802@sgi.com> <20081023205727.GA28490@infradead.org> <49013C47.4090601@sgi.com> <20081024052418.GO25906@disturbed> <20081024064804.GQ25906@disturbed> <20081026005351.GK18495@disturbed> <20081026025013.GL18495@disturbed>
In-Reply-To: <20081026025013.GL18495@disturbed>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lachlan McIlroy <lachlan@sgi.com>, Christoph Hellwig <hch@infradead.org>, xfs-oss <xfs@oss.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Chinner wrote:
> On Sun, Oct 26, 2008 at 11:53:51AM +1100, Dave Chinner wrote:
>> On Fri, Oct 24, 2008 at 05:48:04PM +1100, Dave Chinner wrote:
>>> OK, I just hung a single-threaded rm -rf after this completed:
>>>
>>> # fsstress -p 1024 -n 100 -d /mnt/xfs2/fsstress
>>>
>>> It has hung with this trace:
>>>
>>> # echo w > /proc/sysrq-trigger
>> ....
>>> [42954211.590000] 794877f8:  [<6002e40a>] update_curr+0x3a/0x50
>>> [42954211.590000] 79487818:  [<60014f0d>] _switch_to+0x6d/0xe0
>>> [42954211.590000] 79487858:  [<60324b21>] schedule+0x171/0x2c0
>>> [42954211.590000] 794878a8:  [<60324e6d>] schedule_timeout+0xad/0xf0
>>> [42954211.590000] 794878c8:  [<60326e98>] _spin_unlock_irqrestore+0x18/0x20
>>> [42954211.590000] 79487908:  [<60195455>] xlog_grant_log_space+0x245/0x470
>>> [42954211.590000] 79487920:  [<60030ba0>] default_wake_function+0x0/0x10
>>> [42954211.590000] 79487978:  [<601957a2>] xfs_log_reserve+0x122/0x140
>>> [42954211.590000] 794879c8:  [<601a36e7>] xfs_trans_reserve+0x147/0x2e0
>>> [42954211.590000] 794879f8:  [<60087374>] kmem_cache_alloc+0x84/0x100
>>> [42954211.590000] 79487a38:  [<601ab01f>] xfs_inactive_symlink_rmt+0x9f/0x450
>>> [42954211.590000] 79487a88:  [<601ada94>] kmem_zone_zalloc+0x34/0x50
>>> [42954211.590000] 79487aa8:  [<601a3a6d>] _xfs_trans_alloc+0x2d/0x70
>> ....
>>
>> I came back to the system, and found that the hang had gone away - the
>> rm -rf had finished sometime in the ~36 hours between triggering the
>> problem and coming back to look at the corpse....
>>
>> So nothing to report yet.
> 
> Got it now. I can reproduce this in a couple of minutes now that both
> the test fs and the fs hosting the UML fs images are using lazy-count=1
> (and the frequent 10s long host system freezes have gone away, too).
> 
> Looks like *another* new memory allocation problem [1]:
> 
> [42950422.270000] xfsdatad/0    D 000000000043bf7a     0    51      2
> [42950422.270000] 804add98 804ad8f8 60498c40 80474000 804776a0 60014f0d 80442780 1000111a8
> [42950422.270000]        80474000 7ff1ac08 804ad8c0 80442780 804776f0 60324b21 80474000 80477700
> [42950422.270000]        80474000 1000111a8 80477700 0000000a 804777e0 80477950 80477750 60324e39 <6>Call Trace:
> [42950422.270000] 80477668:  [<60014f0d>] _switch_to+0x6d/0xe0
> [42950422.270000] 804776a8:  [<60324b21>] schedule+0x171/0x2c0
> [42950422.270000] 804776f8:  [<60324e39>] schedule_timeout+0x79/0xf0
> [42950422.270000] 80477718:  [<60040360>] process_timeout+0x0/0x10
> [42950422.270000] 80477758:  [<60324619>] io_schedule_timeout+0x19/0x30
> [42950422.270000] 80477778:  [<6006eb74>] congestion_wait+0x74/0xa0
> [42950422.270000] 80477790:  [<6004c5b0>] autoremove_wake_function+0x0/0x40
> [42950422.270000] 804777d8:  [<600692a0>] throttle_vm_writeout+0x80/0xa0
> [42950422.270000] 80477818:  [<6006cdf4>] shrink_zone+0xac4/0xb10
> [42950422.270000] 80477828:  [<601adb5b>] kmem_alloc+0x5b/0x140
> [42950422.270000] 804778c8:  [<60186d48>] xfs_iext_inline_to_direct+0x68/0x80
> [42950422.270000] 804778f8:  [<60187e38>] xfs_iext_realloc_direct+0x128/0x1c0
> [42950422.270000] 80477928:  [<60188594>] xfs_iext_add+0xc4/0x290
> [42950422.270000] 80477978:  [<60166388>] xfs_bmbt_set_all+0x18/0x20
> [42950422.270000] 80477988:  [<601887c4>] xfs_iext_insert+0x64/0x80
> [42950422.270000] 804779c8:  [<6006d75a>] try_to_free_pages+0x1ea/0x330
> [42950422.270000] 80477a40:  [<6006ba40>] isolate_pages_global+0x0/0x40
> [42950422.270000] 80477a98:  [<60067887>] __alloc_pages_internal+0x267/0x540
> [42950422.270000] 80477b68:  [<60086b61>] cache_alloc_refill+0x4c1/0x970
> [42950422.270000] 80477b88:  [<60326ea9>] _spin_unlock+0x9/0x10
> [42950422.270000] 80477bd8:  [<6002ffc5>] __might_sleep+0x55/0x120
> [42950422.270000] 80477c08:  [<601ad9cd>] kmem_zone_alloc+0x7d/0x110
> [42950422.270000] 80477c18:  [<600873c3>] kmem_cache_alloc+0xd3/0x100
> [42950422.270000] 80477c58:  [<601ad9cd>] kmem_zone_alloc+0x7d/0x110
> [42950422.270000] 80477ca8:  [<601ada78>] kmem_zone_zalloc+0x18/0x50
> [42950422.270000] 80477cc8:  [<601a3a6d>] _xfs_trans_alloc+0x2d/0x70
> [42950422.270000] 80477ce8:  [<601a3b52>] xfs_trans_alloc+0xa2/0xb0
> [42950422.270000] 80477d18:  [<60027655>] set_signals+0x35/0x40
> [42950422.270000] 80477d48:  [<6018f93a>] xfs_iomap_write_unwritten+0x5a/0x260
> [42950422.270000] 80477d50:  [<60063d12>] mempool_free_slab+0x12/0x20
> [42950422.270000] 80477d68:  [<60027655>] set_signals+0x35/0x40
> [42950422.270000] 80477db8:  [<60063d12>] mempool_free_slab+0x12/0x20
> [42950422.270000] 80477dc8:  [<60063dbf>] mempool_free+0x4f/0x90
> [42950422.270000] 80477e18:  [<601af5e5>] xfs_end_bio_unwritten+0x65/0x80
> [42950422.270000] 80477e38:  [<60048574>] run_workqueue+0xa4/0x180
> [42950422.270000] 80477e50:  [<601af580>] xfs_end_bio_unwritten+0x0/0x80
> [42950422.270000] 80477e58:  [<6004c791>] prepare_to_wait+0x51/0x80
> [42950422.270000] 80477e98:  [<600488e0>] worker_thread+0x70/0xd0
> 
> We've entered memory reclaim inside the xfsdatad while trying to do
> unwritten extent completion during I/O completion, and that memory
> reclaim is now blocked waiting for I/o completion that cannot make
> progress.
> 
> Nasty.
> 
> My initial though is to make _xfs_trans_alloc() able to take a KM_NOFS argument
> so we don't re-enter the FS here. If we get an ENOMEM in this case, we should
> then re-queue the I/O completion at the back of the workqueue and let other
> I/o completions progress before retrying this one. That way the I/O that
> is simply cleaning memory will make progress, hence allowing memory
> allocation to occur successfully when we retry this I/O completion...
It could work - unless it's a synchronous I/O in which case the I/O is not
complete until the extent conversion takes place.

Could we allocate the memory up front before the I/O is issued?

> 
> XFS-folk - thoughts?
> 
> [1] I don't see how any of the XFS changes we made make this easier to hit.
> What I suspect is a VM regression w.r.t. memory reclaim because this is
> the second problem since 2.6.26 that appears to be a result of memory
> allocation failures in places that we've never, ever seen failures before.
> 
> The other new failure is this one:
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=11805
> 
> which is an alloc_pages(GFP_KERNEL) failure....
> 
> mm-folk - care to weight in?
> 
> Cheers,
> 
> Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
