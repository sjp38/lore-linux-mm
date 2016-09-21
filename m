From: Philipp Hahn <pmhahn@pmhahn.de>
Subject: Re: RFH: virnet: page allocation failure: order:0
Date: Wed, 21 Sep 2016 08:44:37 +0200
Message-ID: <bb36fe18-2087-502d-0ebd-f1e1b7a5b508@pmhahn.de>
References: <8838f4e4-cb93-9c78-f446-7b1e2cb639fa@pmhahn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8838f4e4-cb93-9c78-f446-7b1e2cb639fa@pmhahn.de>
Sender: linux-kernel-owner@vger.kernel.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Hello,

Am 15.08.2016 um 15:26 schrieb Philipp Hahn:
> this Sunday one of our virtual servers running linux-4.1.16 inside
> OpenStack using qemu "crashed" while doing a backup using rsync to a
> slow NFS server.

This happened again last weekend, with the same stack trace:

>> Call Trace:
>>  <IRQ>  [<ffffffff81597807>] ? dump_stack+0x40/0x50
>>  [<ffffffff8116b6e9>] ? warn_alloc_failed+0xf9/0x150
>>  [<ffffffff8116ee7a>] ? __alloc_pages_nodemask+0x65a/0x9d0
>>  [<ffffffff811b3024>] ? alloc_pages_current+0xa4/0x120
>>  [<ffffffff81481d77>] ? skb_page_frag_refill+0xb7/0xe0
>>  [<ffffffffa002d14b>] ? try_fill_recv+0x31b/0x610 [virtio_net]
>>  [<ffffffffa002db10>] ? virtnet_receive+0x580/0x890 [virtio_net]
>>  [<ffffffffa002de46>] ? virtnet_poll+0x26/0x90 [virtio_net]
>>  [<ffffffff81499629>] ? net_rx_action+0x159/0x330
>>  [<ffffffff8107aace>] ? __do_softirq+0xde/0x260
>>  [<ffffffff8107ae95>] ? irq_exit+0x95/0xa0
>>  [<ffffffff815a0b74>] ? do_IRQ+0x64/0x110
>>  [<ffffffff8159e9ee>] ? common_interrupt+0x6e/0x6e
>>  <EOI>  [<ffffffff81020a70>] ? mwait_idle+0x150/0x150
>>  [<ffffffff8105e192>] ? native_safe_halt+0x2/0x10
>>  [<ffffffff81020a8c>] ? default_idle+0x1c/0xb0
>>  [<ffffffff810b67f4>] ? cpu_startup_entry+0x314/0x3e0
>>  [<ffffffff8159db87>] ? _raw_spin_unlock_irqrestore+0x17/0x50
>>  [<ffffffff8104de55>] ? start_secondary+0x185/0x1b0


> What I don't know is if the network problem was the cause or the
> consequence. Because of that I want to understand why the follwoing
> order=0 allocation failed:

What I still don't understand is how an "order=0" allocation can fail?

>> Node 0 DMA: 1*4kB (U) 0*8kB 0*16kB 1*32kB (U) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (EM) = 15908kB
>> Node 0 DMA32: 4701*4kB (UM) 0*8kB 9*16kB (R) 0*32kB 1*64kB (R) 0*128kB 0*256kB 1*512kB (R) 0*1024kB 0*2048kB 0*4096kB = 19524kB
>> Node 0 Normal: 352*4kB (UM) 5*8kB (UM) 2*16kB (R) 0*32kB 1*64kB (R) 1*128kB (R) 0*256kB 0*512kB 1*1024kB (R) 0*2048kB 0*4096kB = 2696kB
>> Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB

In every zone there are plenty of free pages, so why doesn't allocation
4 KiB work?

I looked at the source code, dis-assembly, similar reports, but now I'm
lost. Can someone give me a hint where to look next please?

Thank you in advance.

Philipp Hahn
