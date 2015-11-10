Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 790816B0253
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 10:13:43 -0500 (EST)
Received: by wmww144 with SMTP id w144so4917533wmw.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 07:13:43 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id f63si22990672wme.60.2015.11.10.07.13.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 07:13:40 -0800 (PST)
Received: by wmww144 with SMTP id w144so121970118wmw.1
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 07:13:40 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 10 Nov 2015 23:13:39 +0800
Message-ID: <CANudz+s6Y+aC1T4vy5OxqN67RSTAnP7+TD1-TH=Rsq82ZvFwGQ@mail.gmail.com>
Subject: Bad page about page->flag 0xa(error|uptodate) when get_page_from_freelist
From: loody <miloody@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

hi all:
there is a Bad page happen on my platform like below:
(the first line is the message I purposely add in __rmqueue to report
the order and migrtype)

__rmqueue :  order= 0, migratetype = 2
BUG: Bad page state in process TSK_MID_SI  pfn:1a780
page:c0c00000 count:0 mapcount:0 mapping:  (null) index:0x2
page flags: 0xa(error|uptodate)
Modules linked in: mtu_sta(O) mali(O) ump(O) kteeclient(O) ndptsd(O)
ndpci(O) ndpdemod(O) ndptuner(O) ndphdmiswitch(O) ndphdmi(O) ndp_pq(O)
ndpcodec(O) ndpalsa(O)
ndpextin(O) ndpdrm(O) driver(O) fusion(O) PreInit(O)
CPU: 1 PID: 1643 Comm: TSK_MID_SI Tainted: G           O 3.10.0+ #7
Backtrace:
[<c0012ad4>] (dump_backtrace+0x0/0x114) from [<c0012d44>] (show_stack+0x20/0x24)
 r6:c0c00000 r5:c07760c0 r4:c08cbe08 r3:271ae71c
[<c0012d24>] (show_stack+0x0/0x24) from [<c0542508>] (dump_stack+0x24/0x28)
[<c05424e4>] (dump_stack+0x0/0x28) from [<c010e080>] (bad_page+0xc4/0x114)
[<c010dfbc>] (bad_page+0x0/0x114) from [<c010e6b0>]
(get_page_from_freelist+0x458/0x6c0)
 r6:0155f000 r5:c0c00000 r4:c0776640 r3:00000000
[<c010e258>] (get_page_from_freelist+0x0/0x6c0) from [<c010f63c>]
(__alloc_pages_nodemask+0x128/0x9a4)
[<c010f514>] (__alloc_pages_nodemask+0x0/0x9a4) from [<c012b37c>]
(do_wp_page+0xd0/0x74c)
[<c012b2ac>] (do_wp_page+0x0/0x74c) from [<c012cef4>]
(handle_pte_fault+0x41c/0x6b0)
[<c012cad8>] (handle_pte_fault+0x0/0x6b0) from [<c012d214>]
(handle_mm_fault+0x8c/0xbc)
[<c012d188>] (handle_mm_fault+0x0/0xbc) from [<c054858c>]
(do_page_fault+0x310/0x428)
[<c054827c>] (do_page_fault+0x0/0x428) from [<c0008424>]
(do_DataAbort+0x48/0xac)
[<c00083dc>] (do_DataAbort+0x0/0xac) from [<c054691c>] (__dabt_usr+0x3c/0x40)
 Exception stack(0xe4861fb0 to 0xe4861ff8)
 1fa0:                                     a582ac34 00000002 00000000 00000002
 1fc0: a582b4d4 a582b450 000003e8 00000000 00000061 a582af90 a582b450 00000000
 1fe0: 00000000 a582ac30 b41b12ab b41dd184 600d0170 ffffffff 00000000
  r8:00000061
 r7:00000000 r6:ffffffff r5:600d0170 r4:b41dd184

I list my platform paramter like below
1. Arm cortex A9 SMP 2 cores
2. kernel version is 3.10


What makes me curious are
1. evety time Bad page happen, it is always the same page, pfn= 1a780.
2. in my case, the page that is reported as bad page, is allocated
from __rmqueue_fallback.
    Why there will be PG_error put in buddy and marked as free for
later allocation?
3. Why we don't put PG_error in PAGE_FLAGS_CHECK_AT_FREE?
    as far as I know, PG_error means error ever occurs during an I/O
operation involving the page.
    Does that mean even the page gets I/O error, we still can put it
as free one before any proper handling?
4. why we need to check_new_page with PG_error, if we don't care it in
free_pages_check?
5. If I try to add more debug message in __rmqueue_fallback the bad
page report will NOT happen.
from #5,it seems some race condition happen for page management.
Is there other debug methods, suggestions or need I provide more
information to check this kind of problem?

appreciate all your kind help in advance,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
