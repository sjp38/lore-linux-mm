Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 532696B0257
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 07:18:14 -0500 (EST)
Received: by wmvv187 with SMTP id v187so78579915wmv.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 04:18:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m139si5238608wma.54.2015.11.13.04.18.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Nov 2015 04:18:13 -0800 (PST)
Subject: Re: [PATCH V6] mm: fix kernel crash in khugepaged thread
References: <1447416477-24881-1-git-send-email-yalin.wang2010@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5645D501.3060202@suse.cz>
Date: Fri, 13 Nov 2015 13:18:09 +0100
MIME-Version: 1.0
In-Reply-To: <1447416477-24881-1-git-send-email-yalin.wang2010@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>, rostedt@goodmis.org, mingo@redhat.com, akpm@linux-foundation.org, riel@redhat.com, ebru.akagunduz@gmail.com, kirill.shutemov@linux.intel.com, jmarchan@redhat.com, mgorman@techsingularity.net, willy@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/13/2015 01:07 PM, yalin wang wrote:
> This crash is caused by NULL pointer deference, in page_to_pfn() marco,
> when page == NULL :
>
> [  182.639154 ] Unable to handle kernel NULL pointer dereference at virtual address 00000000
> [  182.639491 ] pgd = ffffffc00077a000
> [  182.639761 ] [00000000] *pgd=00000000b9422003, *pud=00000000b9422003, *pmd=00000000b9423003, *pte=0060000008000707
> [  182.640749 ] Internal error: Oops: 94000006 [#1] SMP
> [  182.641197 ] Modules linked in:
> [  182.641580 ] CPU: 1 PID: 26 Comm: khugepaged Tainted: G        W       4.3.0-rc6-next-20151022ajb-00001-g32f3386-dirty #3
> [  182.642077 ] Hardware name: linux,dummy-virt (DT)
> [  182.642227 ] task: ffffffc07957c080 ti: ffffffc079638000 task.ti: ffffffc079638000
> [  182.642598 ] PC is at khugepaged+0x378/0x1af8
> [  182.642826 ] LR is at khugepaged+0x418/0x1af8
> [  182.643047 ] pc : [<ffffffc0001980ac>] lr : [<ffffffc00019814c>] pstate: 60000145
> [  182.643490 ] sp : ffffffc07963bca0
> [  182.643650 ] x29: ffffffc07963bca0 x28: ffffffc00075c000
> [  182.644024 ] x27: ffffffc00f275040 x26: ffffffc0006c7000
> [  182.644334 ] x25: 00e8000048800f51 x24: 0000000006400000
> [  182.644687 ] x23: 0000000000000002 x22: 0000000000000000
> [  182.644972 ] x21: 0000000000000000 x20: 0000000000000000
> [  182.645446 ] x19: 0000000000000000 x18: 0000007ff86d0990
> [  182.645931 ] x17: 00000000007ef9c8 x16: ffffffc000098390
> [  182.646236 ] x15: ffffffffffffffff x14: 00000000ffffffff
> [  182.646649 ] x13: 000000000000016a x12: 0000000000000000
> [  182.647046 ] x11: ffffffc07f025020 x10: 0000000000000000
> [  182.647395 ] x9 : 0000000000000048 x8 : ffffffc000721e28
> [  182.647872 ] x7 : 0000000000000000 x6 : ffffffc07f02d000
> [  182.648261 ] x5 : fffffffffffffe00 x4 : ffffffc00f275040
> [  182.648611 ] x3 : 0000000000000000 x2 : ffffffc00f2ad000
> [  182.648908 ] x1 : 0000000000000000 x0 : ffffffc000727000
> [  182.649147 ]
> [  182.649252 ] Process khugepaged (pid: 26, stack limit = 0xffffffc079638020)
> [  182.649724 ] Stack: (0xffffffc07963bca0 to 0xffffffc07963c000)
> [  182.650141 ] bca0: ffffffc07963be30 ffffffc0000b5044 ffffffc07961fb80 ffffffc00072e630
> [  182.650587 ] bcc0: ffffffc0005d5090 0000000000000000 ffffffc000197d34 0000000000000000
> [  182.651009 ] bce0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [  182.651446 ] bd00: ffffffc07963bd90 ffffffc07f1cbf80 000000004f3be003 ffffffc00f2750a4
> [  182.651956 ] bd20: ffffffc00f3bf000 ffffffc000000001 0000000000000001 ffffffc07f085740
> [  182.652520 ] bd40: ffffffc00f2ad188 ffffffc000000000 0000000006200000 ffffffc00f275040
> [  182.652972 ] bd60: ffffffc0006b1a90 ffffffc079638000 ffffffc07963be20 ffffffc00f0144d0
> [  182.653357 ] bd80: ffffffc000000000 0000000006400000 ffffffc00f0144d0 00000a0800000001
> [  182.653793 ] bda0: 0000100000000001 ffffffc000000001 ffffffc07f025000 ffffffc00f2750a8
> [  182.654226 ] bdc0: 00000001000005f8 ffffffc00075a000 0000000006a00000 ffffffc000727000
> [  182.654522 ] bde0: ffffffc0006e8478 ffffffc000000000 0000000100000000 ffffffc078fb9000
> [  182.654869 ] be00: ffffffc07963be30 ffffffc000000000 ffffffc07957c080 ffffffc0000cfc4c
> [  182.655225 ] be20: ffffffc07963be20 ffffffc07963be20 0000000000000000 ffffffc000085c50
> [  182.655588 ] be40: ffffffc0000b4f64 ffffffc07961fb80 0000000000000000 0000000000000000
> [  182.656138 ] be60: 0000000000000000 ffffffc0000bee2c ffffffc0000b4f64 0000000000000000
> [  182.656609 ] be80: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [  182.657145 ] bea0: ffffffc07963bea0 ffffffc07963bea0 0000000000000000 ffffffc000000000
> [  182.657475 ] bec0: ffffffc07963bec0 ffffffc07963bec0 0000000000000000 0000000000000000
> [  182.657922 ] bee0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [  182.658558 ] bf00: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [  182.658972 ] bf20: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [  182.659291 ] bf40: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [  182.659722 ] bf60: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [  182.660122 ] bf80: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [  182.660654 ] bfa0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [  182.661064 ] bfc0: 0000000000000000 0000000000000000 0000000000000000 0000000000000005
> [  182.661466 ] bfe0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [  182.661848 ] Call trace:
> [  182.662050 ] [<ffffffc0001980ac>] khugepaged+0x378/0x1af8
> [  182.662294 ] [<ffffffc0000b5040>] kthread+0xdc/0xf4
> [  182.662605 ] [<ffffffc000085c4c>] ret_from_fork+0xc/0x40
> [  182.663046 ] Code: 35001700 f0002c60 aa0703e3 f9009fa0 (f94000e0)
> [  182.663901 ] ---[ end trace 637503d8e28ae69e  ]---
> [  182.664160 ] Kernel panic - not syncing: Fatal exception
> [  182.664571 ] CPU2: stopping
> [  182.664794 ] CPU: 2 PID: 0 Comm: swapper/2 Tainted: G      D W       4.3.0-rc6-next-20151022ajb-00001-g32f3386-dirty #3
> [  182.665248 ] Hardware name: linux,dummy-virt (DT)
>
> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>

This is a fix for:
http://www.ozlabs.org/~akpm/mmots/broken-out/mm-add-tracepoint-for-scanning-pages.patch

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
