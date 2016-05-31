Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D8D496B0005
	for <linux-mm@kvack.org>; Mon, 30 May 2016 23:02:51 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id p194so56084211iod.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 20:02:51 -0700 (PDT)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id v186si28530125itb.72.2016.05.30.20.02.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 20:02:51 -0700 (PDT)
Received: by mail-io0-x22b.google.com with SMTP id p64so78386822ioi.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 20:02:51 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 31 May 2016 05:02:50 +0200
Message-ID: <CAPv3WKcVsWBgHHC3UPNcbka2JUmN4CTw1Ym4BR1=1V9=B9av5Q@mail.gmail.com>
Subject: [BUG] Page allocation failures with newest kernels
From: Marcin Wojtas <mw@semihalf.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
Cc: Yehuda Yitschak <yehuday@marvell.com>, nadavh@marvell.com, Lior Amsalem <alior@marvell.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, =?UTF-8?Q?Gregory_Cl=C3=A9ment?= <gregory.clement@free-electrons.com>, Grzegorz Jaszczyk <jaz@semihalf.com>, Tomasz Nowicki <tn@semihalf.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Arnd Bergmann <arnd@arndb.de>

Hi,

After rebasing platform support of two different ARMv8 SoC's from v4.1
baseline to v4.4 it occurred that stressed systems tend to have page
allocation problems, related to creating new slabs:

http://pastebin.com/FhRW5DsF

Steps to reproduce:
- use SATA drive (on-board or over PCIe) with 2 btrfs 50G partitions
- run a couple of loops of following script:
mount /dev/sd${1}1 /mnt
mount /dev/sd${1}2 /mnt2
i=0
while [[ $i -lt ${2} ]]
do
echo -e "i = ${i}\n"
dd if=/dev/zero of=/mnt/3g bs=3M count=1024 &
dd if=/dev/zero of=/mnt/2g bs=2M count=1024 &
dd if=/dev/zero of=/mnt/1g bs=1M count=1024 &
dd if=/dev/zero of=/mnt2/2g bs=2M count=1024 &
dd if=/dev/zero of=/mnt2/1g bs=1M count=1024 &
dd if=/dev/zero of=/mnt2/3g bs=3M count=1024
let "i++"
done

The issue also reproduced on v4.6. Usually problems occur within first
iteration and then the rest is done without errors, also kernel remain
stable. I got an information, that page alloc problem were observed
also on Marvell ARMv7 platfrom (Armada38x).

About the debug itself - after adding simplest possible trace in
trace/events/kmem.h (single argument u64 for counter or whatever kind
of number), it was shown both on v4.1 and v4.4 following condition is
achieved multiple times during test:
In __alloc_pages_nodemask(), during the test kernel jumps huge amount
of times (~250k times in v4.1 and ~570k in v4.4 per one script loop)
into following 'unlikely' condition:
page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
if (unlikely(!page)) {
    [...]
    page = __alloc_pages_slowpath(alloc_mask, order, &ac);
}

The further difference is seen in __alloc_pages_slowpath().
warn_alloc_page() (routine responsible for printing page alloc failure
message) is reached via following condition:
if (!can_direct_reclaim) {
    [...]
    goto nopage;
}
In v4.1 ~5 times and in v4.4 ~40 times per one script loop.

Printing message however can be blocked by following condition in
warn_alloc_fail():
if ((gfp_mask & _GFP_NOWARN) || !_ratelimit(&nopage_rs) ||
    debug_guardpage_minorder() > 0)
        return;
Only first two are relevant. As ratelimit is derived directly from
CONFIG_HZ and this parameter differ between v4.1 and v4.4 (100 vs 250,
also CONFIG_SCHED_HRTICK is enabled only in v4.4) the configs were
swapped, but no change in behavior.

Also within 'faulty' revision there is a difference, depending on
filesystem used - with buildroot the dumps occur, but with same test
under ubuntu - it's impossible see the failure output (and it's not a
question of dmesg level:)). Comparing /proc/sys/vm contents didn't
show anything meaningful.

I tried to analyze changes around mm/ folder between v4.1 and v4.4
that may cause such difference, but wasn't able to find out what may
be causing the issue. Have anyone encountered such problems in recent
revisions? I would be very grateful for any hint or comment. Also if
any other data can be captured, please let know.

Best regards,
Marcin Wojtas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
