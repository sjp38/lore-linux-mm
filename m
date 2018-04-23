Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 79CE76B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 04:17:15 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 203so9945910pfz.19
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 01:17:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b17-v6si10965225plz.469.2018.04.23.01.17.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Apr 2018 01:17:13 -0700 (PDT)
Subject: Re: [Bug 198497] handle_mm_fault / xen_pmd_val /
 radix_tree_lookup_slot Null pointer
References: <bug-198497-200779@https.bugzilla.kernel.org/>
 <bug-198497-200779-43rwxa1kcg@https.bugzilla.kernel.org/>
 <CAKf6xpuYvCMUVHdP71F8OWm=bQGFxeRd7SddH-5DDo-AQjbbQg@mail.gmail.com>
 <20180420133951.GC10788@bombadil.infradead.org>
 <CAKf6xpuVrPwc=AxYruPVfdxx1Yv7NF7NKiGx7vT2WKLogUoqfA@mail.gmail.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <f10cdd77-2fe2-2003-4cac-dfec50f0ee43@suse.com>
Date: Mon, 23 Apr 2018 10:17:08 +0200
MIME-Version: 1.0
In-Reply-To: <CAKf6xpuVrPwc=AxYruPVfdxx1Yv7NF7NKiGx7vT2WKLogUoqfA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Andryuk <jandryuk@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, labbott@redhat.com, xen-devel@lists.xen.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On 20/04/18 17:20, Jason Andryuk wrote:
> Adding xen-devel and the Linux Xen maintainers.
> 
> Summary: Some Xen users (and maybe others) are hitting a BUG in
> __radix_tree_lookup() under do_swap_page() - example backtrace is
> provided at the end.  Matthew Wilcox provided a band-aid patch that
> prints errors like the following instead of triggering the bug.
> 
> Skylake 32bit PAE Dom0:
> Bad swp_entry: 80000000
> mm/swap_state.c:683: bad pte d3a39f1c(8000000400000000)
> 
> Ivy Bridge 32bit PAE Dom0:
> Bad swp_entry: 40000000
> mm/swap_state.c:683: bad pte d3a05f1c(8000000200000000)
> 
> Other 32bit DomU:
> Bad swp_entry: 4000000
> mm/swap_state.c:683: bad pte e2187f30(8000000200000000)
> 
> Other 32bit:
> Bad swp_entry: 2000000
> mm/swap_state.c:683: bad pte ef3a3f38(8000000100000000)
> 
> The Linux bugzilla has more info
> https://bugzilla.kernel.org/show_bug.cgi?id=198497
> 
> This may not be exclusive to Xen Linux, but most of the reports are on
> Xen.  Matthew wonders if Xen might be stepping on the upper bits of a
> pte.
> 
> On Fri, Apr 20, 2018 at 9:39 AM, Matthew Wilcox <willy@infradead.org> wrote:
>> On Fri, Apr 20, 2018 at 09:10:11AM -0400, Jason Andryuk wrote:
>>>> Given that this is happening on Xen, I wonder if Xen is using some of the
>>>> bits in the page table for its own purposes.
>>>
>>> The backtraces include do_swap_page().  While I have a swap partition
>>> configured, I don't think it's being used.  Are we somehow
>>> misidentifying the page as a swap page?  I'm not familiar with the
>>> code, but is there an easy way to query global swap usage?  That way
>>> we can see if the check for a swap page is bogus.
>>>
>>> My system works with the band-aid patch.  When that patch sets page =
>>> NULL, does that mean userspace is just going to get a zero-ed page?
>>> Userspace still works AFAICT, which makes me think it is a
>>> mis-identified page to start with.
>>
>> Here's how this code works.
> 
> Thanks for the description.
> 
>> When we swap out an anonymous page (a page which is not backed by a
>> file; could be from a MAP_PRIVATE mapping, could be brk()), we write it
>> to the swap cache.  In order to be able to find it again, we store a
>> cookie (called a swp_entry_t) in the process' page table (marked with
>> the 'present' bit clear, so the CPU will fault on it).  When we get a
>> fault, we look up the cookie in a radix tree and bring that page back
>> in from swap.
>>
>> If there's no page found in the radix tree, we put a freshly zeroed
>> page into the process's address space.  That's because we won't find
>> a page in the swap cache's radix tree for the first time we fault.
>> It's not an indication of a bug if there's no page to be found.
> 
> Is "no page found" the case for a lazy, un-allocated MAP_ANONYMOUS page?
> 
>> What we're seeing for this bug is page table entries of the format
>> 0x8000'0004'0000'0000.  That would be a zeroed entry, except for the
>> fact that something's stepped on the upper bits.
> 
> Does a totally zero-ed entry correspond to an un-allocated MAP_ANONYMOUS page?
> 
>> What is worrying is that potentially Xen might be stepping on the upper
>> bits of either a present entry (leading to the process loading a page
>> that belongs to someone else) or an entry which has been swapped out,
>> leading to the process getting a zeroed page when it should be getting
>> its page back from swap.
> 
> There was at least one report of non-Xen 32bit being affected.  There
> was no backtrace, so it could be something else.  One report doesn't
> have any swap configured.
> 
>> Defending against this kind of corruption would take adding a parity
>> bit to the page tables.  That's not a project I have time for right now.
> 
> Understood.  Thanks for the response.
> 
> Regards,
> Jason
> 
> 
> [ 2234.939079] BUG: unable to handle kernel NULL pointer dereference at 00000008
> [ 2234.942154] IP: __radix_tree_lookup+0xe/0xa0
> [ 2234.945176] *pdpt = 0000000008cd5027 *pde = 0000000000000000
> [ 2234.948382] Oops: 0000 [#1] SMP
> [ 2234.951410] Modules linked in: hp_wmi sparse_keymap rfkill wmi_bmof
> pcspkr i915 wmi hp_accel lis3lv02d input_polldev drm_kms_helper
> syscopyarea sysfillrect sysimgblt fb_sys_fops drm hp_wireless
> i2c_algo_bit hid_multitouch sha256_generic xen_netfront v4v(O) psmouse
> ecb xts hid_generic xhci_pci xhci_hcd ohci_pci ohci_hcd uhci_hcd
> ehci_pci ehci_hcd usbhid hid tpm_tis tpm_tis_core tpm
> [ 2234.960816] CPU: 1 PID: 2338 Comm: xenvm Tainted: G           O    4.14.18 #1
> [ 2234.963991] Hardware name: Hewlett-Packard HP EliteBook Folio
> 9470m/18DF, BIOS 68IBD Ver. F.40 02/01/2013
> [ 2234.967186] task: d4370980 task.stack: cf8e8000
> [ 2234.970351] EIP: __radix_tree_lookup+0xe/0xa0
> [ 2234.973520] EFLAGS: 00010286 CPU: 1
> [ 2234.976699] EAX: 00000004 EBX: b5900000 ECX: 00000000 EDX: 00000000
> [ 2234.979887] ESI: 00000000 EDI: 00000004 EBP: cf8e9dd0 ESP: cf8e9dc0
> [ 2234.983081]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0069
> [ 2234.986233] CR0: 80050033 CR2: 00000008 CR3: 08f12000 CR4: 00042660
> [ 2234.989340] Call Trace:
> [ 2234.992354]  radix_tree_lookup_slot+0x1d/0x50
> [ 2234.995341]  ? xen_irq_disable_direct+0xc/0xc
> [ 2234.998288]  find_get_entry+0x1d/0x110
> [ 2235.001140]  pagecache_get_page+0x1f/0x240
> [ 2235.003948]  ? xen_flush_tlb_others+0x17b/0x260
> [ 2235.006784]  lookup_swap_cache+0x32/0xe0
> [ 2235.009632]  swap_readahead_detect+0x67/0x2c0
> [ 2235.012447]  do_swap_page+0x10a/0x750
> [ 2235.015270]  ? wp_page_copy+0x2c4/0x590
> [ 2235.018043]  ? xen_pmd_val+0x11/0x20
> [ 2235.020729]  handle_mm_fault+0x3f8/0x970
> [ 2235.023352]  ? xen_smp_send_reschedule+0xa/0x10
> [ 2235.025927]  ? resched_curr+0x68/0xc0
> [ 2235.028444]  __do_page_fault+0x1a7/0x480
> [ 2235.030883]  do_page_fault+0x33/0x110
> [ 2235.033250]  ? do_fast_syscall_32+0xb3/0x200
> [ 2235.035567]  ? vmalloc_sync_all+0x290/0x290
> [ 2235.037828]  common_exception+0x84/0x8a
> [ 2235.040011] EIP: 0xb7c8ddea
> [ 2235.042111] EFLAGS: 00010202 CPU: 1
> [ 2235.044153] EAX: b7dd38d0 EBX: b7dd2780 ECX: b7dd2000 EDX: b5900010
> [ 2235.046176] ESI: 00000000 EDI: b7dd38f0 EBP: b56ff124 ESP: b56ff070
> [ 2235.048152]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
> [ 2235.050053] Code: 42 14 29 c6 89 f0 c1 f8 02 e9 71 ff ff ff e8 aa
> 81 aa ff 8d 76 00 8d bc 27 00 00 00 00 55 89 e5 57 89 c7 56 53 83 ec
> 04 89 4d f0 <8b> 5f 04 89 d8 83 e0 03 83 f8 01 75 67 89 d8 83 e0 fe 0f
> b6 08
> [ 2235.053998] EIP: __radix_tree_lookup+0xe/0xa0 SS:ESP: 0069:cf8e9dc0
> [ 2235.055895] CR2: 0000000000000008
> 

Could it be we just have a race regarding pte_clear()? This will set
the low part of the pte to zero first and then the hight part.

In case pte_clear() is used in interrupt mode especially Xen will be
rather slow as it emulates the two writes to the page table resulting
in a larger window where the race might happen.


Juergen
