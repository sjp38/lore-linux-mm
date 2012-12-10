Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 2ECC26B006E
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 16:29:16 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id hm9so1389324wib.8
        for <linux-mm@kvack.org>; Mon, 10 Dec 2012 13:29:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50C6477A.4090005@iskon.hr>
References: <20121203194208.GZ24381@cmpxchg.org> <20121204214210.GB20253@cmpxchg.org>
 <20121205030133.GA17438@wolff.to> <20121206173742.GA27297@wolff.to>
 <CA+55aFzZsCUk6snrsopWQJQTXLO__G7=SjrGNyK3ePCEtZo7Sw@mail.gmail.com>
 <50C32D32.6040800@iskon.hr> <50C3AF80.8040700@iskon.hr> <alpine.LFD.2.02.1212081651270.4593@air.linux-foundation.org>
 <20121210110337.GH1009@suse.de> <20121210163904.GA22101@cmpxchg.org>
 <20121210180141.GK1009@suse.de> <50C62AE6.3030000@iskon.hr>
 <CA+55aFwNE2y5t2uP3esCnHsaNo0NTDnGvzN6KF0qTw_y+QbtFA@mail.gmail.com> <50C6477A.4090005@iskon.hr>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 10 Dec 2012 13:28:54 -0800
Message-ID: <CA+55aFx9XSjtMZNuveyKrxL0LUjmZpFvJ7vzkjaKgQZLCs9QCg@mail.gmail.com>
Subject: Re: kswapd craziness in 3.7
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zlatko Calusic <zlatko.calusic@iskon.hr>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

[ Adding High Dickins because of the shmem oops. ]

On Mon, Dec 10, 2012 at 12:35 PM, Zlatko Calusic
<zlatko.calusic@iskon.hr> wrote:
>
> And funny thing that you mention i915, because yesterday my daughter managed to lock up our laptop hard (that was a first), and this is what I found in kern.log after restart:
>
> Dec  9 21:29:42 titan vmunix: general protection fault: 0000 [#1] PREEMPT SMP
> Dec  9 21:29:42 titan vmunix: Modules linked in: vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) [last unloaded: microcode]
> Dec  9 21:29:42 titan vmunix: CPU 2
> Dec  9 21:29:42 titan vmunix: Pid: 2523, comm: Xorg Tainted: G           O 3.7.0-rc8 #1 Hewlett-Packard HP Pavilion dv7 Notebook PC/144B
> Dec  9 21:29:42 titan vmunix: RIP: 0010:[<ffffffff81090b9c>]  [<ffffffff81090b9c>] find_get_page+0x3c/0x90

Ho humm..

I'm not convinced this is related.

> Dec  9 21:29:42 titan vmunix: Call Trace:
> Dec  9 21:29:42 titan vmunix:  [<ffffffff81090e21>] find_lock_page+0x21/0x80
> Dec  9 21:29:42 titan vmunix:  [<ffffffff810a1b60>] shmem_getpage_gfp+0xa0/0x620
> Dec  9 21:29:42 titan vmunix:  [<ffffffff810a224c>] shmem_read_mapping_page_gfp+0x2c/0x50
> Dec  9 21:29:42 titan vmunix:  [<ffffffff812b3611>] i915_gem_object_get_pages_gtt+0xe1/0x270
> Dec  9 21:29:42 titan vmunix:  [<ffffffff812b127f>] i915_gem_object_get_pages+0x4f/0x90
> Dec  9 21:29:42 titan vmunix:  [<ffffffff812b1383>] i915_gem_object_bind_to_gtt+0xc3/0x4c0
> Dec  9 21:29:42 titan vmunix:  [<ffffffff812b4413>] i915_gem_object_pin+0x123/0x190
> Dec  9 21:29:42 titan vmunix:  [<ffffffff812b7d97>] i915_gem_execbuffer_reserve_object.isra.13+0x77/0x190
> Dec  9 21:29:42 titan vmunix:  [<ffffffff812b8171>] i915_gem_execbuffer_reserve.isra.14+0x2c1/0x320
> Dec  9 21:29:42 titan vmunix:  [<ffffffff812b87b2>] i915_gem_do_execbuffer.isra.17+0x5e2/0x11b0
> Dec  9 21:29:42 titan vmunix:  [<ffffffff812b9894>] i915_gem_execbuffer2+0x94/0x280
> Dec  9 21:29:42 titan vmunix:  [<ffffffff81287de3>] drm_ioctl+0x493/0x530
> Dec  9 21:29:42 titan vmunix:  [<ffffffff810d9cbf>] do_vfs_ioctl+0x8f/0x530
> Dec  9 21:29:42 titan vmunix:  [<ffffffff810da1ab>] sys_ioctl+0x4b/0x90
> Dec  9 21:29:42 titan vmunix:  [<ffffffff8154a4d2>] system_call_fastpath+0x16/0x1b
>
> It seems that whenever (if ever?) GFP_NO_KSWAPD removal is attempted again, the i915 driver will need to be taken better care of.

That decodes to

  11: e8 89 b7 15 00       callq  0x15b79f  # radix_tree_lookup_slot
  16: 48 85 c0             test   %rax,%rax
  19: 48 89 c6             mov    %rax,%rsi
  1c: 74 41                 je     0x5f
  1e: 48 8b 18             mov    (%rax),%rbx  #
  21: 48 85 db             test   %rbx,%rbx
  24: 74 1f                 je     0x45
  26: f6 c3 03             test   $0x3,%bl
  29: 75 3c                 jne    0x67
  2b:* 8b 53 1c             mov    0x1c(%rbx),%edx     <-- trapping instruction
  2e: 85 d2                 test   %edx,%edx
  30: 74 d9                 je     0xb

where %rbx is 0x0200000000000000. That looks like it could be a
single-bit error, and should have been zero.

It's the "atomic_read(&page->counter)" which is part of
"page_cache_get_speculative()" as far as I can tell, and it's the
"page" pointer that is that odd (non-pointer) value. The fact that
%ecx contains the value "-6" makes me wonder if there was a -ENXIO
somewhere, though.

None of it looks all that much related to whether the i915 driver uses
GFP_NO_KSWAPD or not, though.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
