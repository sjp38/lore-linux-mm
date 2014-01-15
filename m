Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8A0876B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 11:07:14 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id t10so985302eei.12
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 08:07:10 -0800 (PST)
Received: from www62.your-server.de (www62.your-server.de. [213.133.104.62])
        by mx.google.com with ESMTPS id y48si8500215eew.247.2014.01.15.08.07.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 08:07:03 -0800 (PST)
Message-ID: <52D6B213.4020602@iogearbox.net>
Date: Wed, 15 Jan 2014 17:06:43 +0100
From: Daniel Borkmann <borkmann@iogearbox.net>
MIME-Version: 1.0
Subject: Re: [BUG] at include/linux/page-flags.h:415 (PageTransHuge)
References: <52D03A9E.2030309@iogearbox.net> <20140110222248.4e8419ca.akpm@linux-foundation.org> <52D147F1.3040803@iogearbox.net> <52D3BCE9.4020405@suse.cz> <52D3D060.1010301@iogearbox.net> <52D69AB4.6000309@suse.cz>
In-Reply-To: <52D69AB4.6000309@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Michel Lespinasse <walken@google.com>, linux-mm <linux-mm@kvack.org>, Jared Hulbert <jaredeh@gmail.com>, netdev <netdev@vger.kernel.org>

[keeping netdev in loop as well]

On 01/15/2014 03:27 PM, Vlastimil Babka wrote:
> On 01/13/2014 12:39 PM, Daniel Borkmann wrote:
>> On 01/13/2014 11:16 AM, Vlastimil Babka wrote:
>>> On 01/11/2014 02:32 PM, Daniel Borkmann wrote:
>>>> On 01/11/2014 07:22 AM, Andrew Morton wrote:
>>>>> On Fri, 10 Jan 2014 19:23:26 +0100 Daniel Borkmann <borkmann@iogearbox.net> wrote:
>>>>>
>>>>>> This is being reliably triggered for each mmaped() packet(7)
>>>>>> socket from user space, basically during unmapping resp.
>>>>>> closing the TX socket.
>>>>>>
>>>>>> I believe due to some change in transparent hugepages code ?
>>>>>>
>>>>>> When I disable transparent hugepages, everything works fine,
>>>>>> no BUG triggered.
>>>>>>
>>>>>> I'd be happy to test patches.
>>>>>
>>>>> Did the inclusion of c424be1cbbf852e46acc8 ("mm: munlock: fix a bug
>>>>> where THP tail page is encountered") in current mainline fix this?
>>>>
>>>> Thanks for your answer Andrew!
>>>>
>>>> Hm, I just cherry-picked that onto current net-next as I have some work
>>>> there, and this time I got ...
>>>>
>>>> (User space uses packet mmap() and mlockall(MCL_CURRENT | MCL_FUTURE)
>>>>       and on shutdown munlockall() ...)
>>>>
>>>> [   63.863672] ------------[ cut here ]------------
>>>> [   63.863702] kernel BUG at mm/mlock.c:507!
>>>> [   63.863721] invalid opcode: 0000 [#1] SMP
>>>> [   63.863743] Modules linked in: fuse ebtable_nat xt_CHECKSUM nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_nat nf_nat_ipv6 ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack bridge ebtable_filter ebtables stp llc ip6table_filter ip6_tables rfcomm bnep snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec iwlwifi cfg80211 snd_hwdep btusb snd_seq bluetooth sdhci_pci snd_seq_device e1000e tpm_tis snd_pcm thinkpad_acpi sdhci ptp tpm uvcvideo pps_core snd_page_alloc snd_timer snd rfkill mmc_core iTCO_wdt iTCO_vendor_support lpc_ich mfd_core soundcore joydev wmi videobuf2_vmalloc videobuf2_memops videobuf2_core i2c_i801 pcspkr videodev media uinput i915
>>>> [   63.864152]  i2c_algo_bit drm_kms_helper drm i2c_core video
>>>> [   63.864181] CPU: 1 PID: 1617 Comm: trafgen Not tainted 3.13.0-rc6+ #15
>>>> [   63.864209] Hardware name: LENOVO 2429BP3/2429BP3, BIOS G4ET37WW (1.12 ) 05/29/2012
>>>> [   63.864242] task: ffff8801ee060000 ti: ffff8800b5954000 task.ti: ffff8800b5954000
>>>> [   63.864274] RIP: 0010:[<ffffffff8116fa9a>]  [<ffffffff8116fa9a>] munlock_vma_pages_range+0x2ea/0x2f0
>>>> [   63.864318] RSP: 0018:ffff8800b5955e08  EFLAGS: 00010202
>>>> [   63.864341] RAX: 00000000000001ff RBX: ffff8800b58f7508 RCX: 0000000000000034
>>>> [   63.864372] RDX: 00000007f0708992 RSI: ffffea0002c3e700 RDI: ffffea0002c3e700
>>>> [   63.864402] RBP: ffff8800b5955ee0 R08: 3800000000000000 R09: a8000b0f9c000000
>>>> [   63.864432] R10: 57ffdef066c3e700 R11: ffffff5cfb00c14a R12: ffffea0002c3e700
>>>> [   63.864462] R13: ffff8800b5955f48 R14: 00007f0708992000 R15: 00007f0708992000
>>>> [   63.864492] FS:  00007f0708b92740(0000) GS:ffff88021e240000(0000) knlGS:0000000000000000
>>>> [   63.864526] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>>> [   63.864551] CR2: 00007f33bb373000 CR3: 00000000b2a2c000 CR4: 00000000001407e0
>>>> [   63.864581] Stack:
>>>> [   63.864593]  ffff8800b5955ed0 00007f0708b91fff 00007f0708b92000 ffff8800b5955e48
>>>> [   63.864632]  000001ff810c864b ffff8801ee060000 0000000000000000 0000000000000000
>>>> [   63.864669]  ffff8800b5955e58 ffff8801ee060000 0000000700000086 ffff8801ee060000
>>>> [   63.864708] Call Trace:
>>>> [   63.864724]  [<ffffffff816956bc>] ? _raw_spin_unlock_irq+0x2c/0x30
>>>> [   63.864754]  [<ffffffff81171b52>] ? vma_merge+0xc2/0x330
>>>> [   63.864786]  [<ffffffff8116fb9c>] mlock_fixup+0xfc/0x190
>>>> [   63.864812]  [<ffffffff8116fde7>] do_mlockall+0x87/0xc0
>>>> [   63.864836]  [<ffffffff811702df>] sys_munlockall+0x2f/0x50
>>>> [   63.864873]  [<ffffffff8169e192>] system_call_fastpath+0x16/0x1b
>>>> [   63.864898] Code: d7 48 89 95 28 ff ff ff e8 a4 04 fe ff 84 c0 48 8b 95 28 ff ff ff 0f 85 5a ff ff ff e9 46 ff ff ff e8 3f ac 51 00 e8 34 ac 51 00 <0f> 0b 0f 1f 40 00 0f 1f 44 00 00 55 48 89 e5 41 57 41 56 41 55
>>>> [   63.865114] RIP  [<ffffffff8116fa9a>] munlock_vma_pages_range+0x2ea/0x2f0
>>>> [   63.865148]  RSP <ffff8800b5955e08>
>>>> [   63.874968] ------------[ cut here ]------------
>>>>
>>>> ... when I find some time, I'll try with normal torvalds' tree, maybe some
>>>> other patches are missing as well, not sure right now.
>>>
>>> Uh so the triggered assertion is the one added by this very patch, and there are no more changes wrt this in mainline.
>>>
>>> If you can still try debug patches, please try this. Thanks.
>>
>> Yes, thanks, I'll come back to you some time by today.
>
> Daniel sent me (off-list) instructions to reproduce:
>
>> Then in the kernel source tree, you'll find:
>>
>>     tools/testing/selftests/net/
>>
>> There, just do a 'make' and run ./psock_tpacket
>
> It reproduces deterministically in mainline since 3.12, i.e. my munlock
> performance series. Based on the initial debug output, I've expanded the
> debug patch below a bit:
>
>>> From: Vlastimil Babka <vbabka@suse.cz>
>>> Date: Mon, 13 Jan 2014 11:13:53 +0100
>>> Subject: [PATCH] debug munlock_vma_pages_range
>>>
>>> ---
>>>     mm/mlock.c | 22 ++++++++++++++++++++--
>>>     1 file changed, 20 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/mm/mlock.c b/mm/mlock.c
>>> index c59c420..7d0e29a 100644
>>> --- a/mm/mlock.c
>>> +++ b/mm/mlock.c
>>> @@ -448,12 +448,14 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
>>>     void munlock_vma_pages_range(struct vm_area_struct *vma,
>>>     			     unsigned long start, unsigned long end)
>>>     {
>>> +	unsigned long orig_start = start;
>>> +	unsigned long page_increm = 0;
>>> +
>>>     	vma->vm_flags &= ~VM_LOCKED;
>>>
>>>     	while (start < end) {
>>>     		struct page *page = NULL;
>>>     		unsigned int page_mask;
>>> -		unsigned long page_increm;
>>>     		struct pagevec pvec;
>>>     		struct zone *zone;
>>>     		int zoneid;
>>> @@ -504,7 +506,23 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
>>>     			}
>>>     		}
>>>     		/* It's a bug to munlock in the middle of a THP page */
>>> -		VM_BUG_ON((start >> PAGE_SHIFT) & page_mask);
>>> +		if ((start >> PAGE_SHIFT) & page_mask) {
>>> +			dump_page(page);
>>> +			printk("start=%lu pfn=%lu orig_start=%lu "
>>> +			       "prev_page_increm=%lu page_mask=%u "
>>> +			       "vm_start=%lu vm_end=%lu vm_flags=%lu\n",
>>> +				start, page_to_pfn(page), orig_start,
>>> +				page_increm, page_mask,
>>> +				vma->vm_start, vma->vm_end,
>>> +				vma->vm_flags);
> +                        printk("vm_ops=%pF, open=%pF, fault=%pF, remap_pages=%pF\n", vma->vm_ops,
> +                                vma->vm_ops->open, vma->vm_ops->fault, vma->vm_ops->remap_pages);
> +                        if (PageCompound(page)) {
> +                                printk("page is compound with order=%d\n", compound_order(page));
> +                        }
>>> +			if (PageTail(page)) {
>>> +				struct page *first_page = page->first_page;
>>> +				printk("first_page pfn=%lu\n",
>>> +						page_to_pfn(first_page));
>>> +				dump_page(first_page);
>>> +			}
>>> +			VM_BUG_ON(true);
>>> +		}
>>>     		page_increm = 1 + page_mask;
>>>     		start += page_increm * PAGE_SIZE;
>>>     next:
>>>
>
> And got output like this:
>
> page:ffffea0002474a40 count:5 mapcount:1 mapping:          (null) index:0x0
> page flags: 0x100000000004004(referenced|head)
> start=140242647736320 pfn=682616 orig_start=140242647736320 prev_page_increm=0 page_mask=511 vm_start=140242647736320 vm_end=140242651930624 vm_flags=268435707
> vm_ops=packet_mmap_ops+0x0/0xfffffffffffff8e0 [af_packet], open=packet_mm_open+0x0/0x30 [af_packet], fault=          (null), remap_pages=          (null)
> page is compound with order=2
>
> Observations:
> - address 140242647736320 is where the vma starts, and is not aligned to 512 pages
>    (so it cannot be a THP head which the munlock expects). Yet there is a head page
>    that triggers the PageTransHuge() and consequently hpage_nr_pages() in munlock_vma_page()
>    That's why page_mask is determined to be 511 and the code thinks it's in the
>    middle of a THP page.
> - in fact, the page is a compound page with order=2
> - the VM flags (except (may)read/write) are VM_SHARED and VM_MIXEDMAP
> - the vma was mmapped by packet_mmap() (net/packet/af_packet.c) which uses
>    vm_insert_page(), which adds the VM_MIXEDMAP flag
> - the buffers that are mapped were allocated by alloc_one_pg_vec_page()
>    where flags indeed include __GFP_COMP
>
> So clearly there is a way to have mlock/munlock operate on a vma that contains
> compound pages and confuse the checks for PageTransHuge().
>
> The checks for THP in munlock came with commit ff6a6da60b89 ("mm: accelerate munlock()
> treatment of THP pages"), i.e. since 3.9, but did not trigger a bug. It however
> makes munlock_vma_pages_range() skip pages until the next 512-pages-aligned page,
> when it encounters a head page. If the head page is of smaller order and is followed
> by normal LRU pages (theoretically, I'm not sure if that's possible, or done anywhere),
> they wouldn't get munlocked.
>
> My commit 7225522bb429 ("mm: munlock: batch non-THP page isolation and
> munlock+putback using pagevec") (since 3.12) has added a new PageTransHuge() check
> that can trigger on tail pages of the compound page here. Commit c424be1cbbf852e46acc8
> ("mm: munlock: fix a bug where THP tail page is encountered") in current rc's removes
> one class of bugs here, but still non-THP compound pages are not expected in mlock/munlock,
> which leads to this assertion failing.
>
> The question is what is the correct fix, and I'm not that familiar with VM_MIXEDMAP
> to decide.
>
> Option 1: mlocking VM_MIXEDMAP vma's has no sense. They should be treated like VM_PFNMAP
>            and added to VM_SPECIAL, which makes m(un)lock skip them completely.
>
> Option 2: if indeed VM_MIXEDMAP can contain PageLRU pages for which mlocking is useful,
>            VM_NO_THP should be checked in munlock before attempting PageTransHuge() and
>            friends. VM_NO_THP already contains VM_MIXEDMAP, so knowing that there can be
>            no THP means we don't try optimize for it and no unexpected head pages trip us.
>
> Thoughts?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
