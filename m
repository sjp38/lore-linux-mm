Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C58C46B0047
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 15:47:28 -0400 (EDT)
Date: Wed, 29 Sep 2010 12:46:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 19312] New: bad_page crash when writing to OCZ
 Agility2 120G
Message-Id: <20100929124659.469c8f3e.akpm@linux-foundation.org>
In-Reply-To: <bug-19312-10286@https.bugzilla.kernel.org/>
References: <bug-19312-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, b7.10110111@gmail.com
List-ID: <linux-mm.kvack.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 29 Sep 2010 19:03:55 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=19312
> 
>            Summary: bad_page crash when writing to OCZ Agility2 120G
>            Product: Drivers
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: drivers_other@kernel-bugs.osdl.org
>         ReportedBy: b7.10110111@gmail.com
>         Regression: No
> 
> 
> Created an attachment (id=31932)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=31932)
> dmesg output after the Oops
> 
> I recently installed OCZ Agility2 120G SSD. When i tried to make a FS on it, i
> got a crash. After further investigation i found that the crash appears only
> when PAE is enabled. I tried to boot into minimal shell (init=/bin/bash) and
> was able to reproduce the crash. This is how i reproduce the bug:
> 
> dd if=/dev/zero of=/dev/sda bs=256M
> 
> after some gigs of data (up to some tens of gigs) are written, i get an Oops as
> in the attached dmesg log. After some time from the oops, the system locks up
> (no NumLock as well as no Alt+SysRq stuff seems to work).
> 
> I tried to plug the SSD to another SATA port, swap it with HDDs, but the bug
> still persists. I tried to replace my nvidia card with s3virge to no avail. I
> also tried using mem=1024M kernel cmdline to see if it's because of higher
> memory PCI access, but the bug persists, though it appeared later than before.
> Also, the bug sometimes doesn't appear on first write pass, but does on
> second/third.
> Ah, yes, the bug still happened after upgrade to 2.6.35.5 kernel.
> There's no such problem with any of the HDDs. I suspect this may be related to
> high speed of SSD which might create some race condition, but i'm not sure.
> 

A repeatable crash in __block_write_full_page() in 2.6.34 and 2.6.35.

Does anyone have time to take a look?  scripts/decodecode says

All code
========
   0:   89 5c 24 28             mov    %ebx,0x28(%rsp)
   4:   eb 1f                   jmp    0x25
   6:   77 06                   ja     0xe
   8:   3b 74 24 20             cmp    0x20(%rsp),%esi
   c:   76 1d                   jbe    0x2b
   e:   f0 80 23 fd             lock andb $0xfd,(%rbx)
  12:   f0 80 0b 01             lock orb $0x1,(%rbx)
  16:   8b 5b 04                mov    0x4(%rbx),%ebx
  19:   39 5c 24 28             cmp    %ebx,0x28(%rsp)
  1d:   74 70                   je     0x8f
  1f:   83 c6 01                add    $0x1,%esi
  22:   83 d7 00                adc    $0x0,%edi
  25:   3b 7c 24 24             cmp    0x24(%rsp),%edi
  29:   73 db                   jae    0x6
  2b:*  8b 03                   mov    (%rbx),%eax     <-- trapping instruction
  2d:   a8 20                   test   $0x20,%al
  2f:   74 05                   je     0x36
  31:   f6 c4 02                test   $0x2,%ah
  34:   74 e0                   je     0x16
  36:   a8 02                   test   $0x2,%al
  38:   90                      nop    
  39:   74 db                   je     0x16
  3b:   8b 44 24 2c             mov    0x2c(%rsp),%eax
  3f:   3b                      .byte 0x3b

Code starting with the faulting instruction
===========================================
   0:   8b 03                   mov    (%rbx),%eax
   2:   a8 20                   test   $0x20,%al
   4:   74 05                   je     0xb
   6:   f6 c4 02                test   $0x2,%ah
   9:   74 e0                   je     0xffffffffffffffeb
   b:   a8 02                   test   $0x2,%al
   d:   90                      nop    
   e:   74 db                   je     0xffffffffffffffeb
  10:   8b 44 24 2c             mov    0x2c(%rsp),%eax
  14:   3b                      .byte 0x3b

but my attention span ran out.  I _think_ the bh ring got corrupted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
