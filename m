Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id C493C6B0255
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 15:45:37 -0400 (EDT)
Received: by oixx17 with SMTP id x17so11912705oix.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 12:45:37 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 140si1884239oic.123.2015.09.22.12.45.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 12:45:37 -0700 (PDT)
Message-ID: <5601AE53.9010601@oracle.com>
Date: Tue, 22 Sep 2015 15:38:59 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: ksm: WARNING: CPU: 3 PID: 22593 at mm/ksm.c:715 remove_stable_node+0xc7/0xf0()
References: <55FAFBBA.10602@oracle.com> <alpine.LSU.2.11.1509211657210.8889@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1509211657210.8889@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>

On 09/21/2015 08:13 PM, Hugh Dickins wrote:
> On Thu, 17 Sep 2015, Sasha Levin wrote:
> 
>> > Hi all,
>> > 
>> > I've observed the following warning while fuzzing with trinity inside a KVM tools
>> > guest running -next:
>> > 
>> > [1385507.811807] Out of memory (oom_kill_allocating_task): Kill process 22593 (ksm04) score 0 or sacrifice child
>> > [1385507.815277] Killed process 22612 (ksm04) total-vm:139476kB, anon-rss:131204kB, file-rss:896kB
>> > [1385507.821799] Out of memory (oom_kill_allocating_task): Kill process 22593 (ksm04) score 0 or sacrifice child
>> > [1385507.823082] Killed process 22613 (ksm04) total-vm:139476kB, anon-rss:131204kB, file-rss:896kB
>> > [1385508.569555] Out of memory (oom_kill_allocating_task): Kill process 22593 (ksm04) score 0 or sacrifice child
>> > [1385508.574114] Killed process 22614 (ksm04) total-vm:139476kB, anon-rss:131204kB, file-rss:896kB
>> > [1385508.589529] Out of memory (oom_kill_allocating_task): Kill process 22593 (ksm04) score 0 or sacrifice child
>> > [1385508.591203] Killed process 22593 (ksm04) total-vm:8408kB, anon-rss:148kB, file-rss:1508kB
>> > [1385509.046298] ------------[ cut here ]------------
>> > [1385509.047136] WARNING: CPU: 3 PID: 22593 at mm/ksm.c:715 remove_stable_node+0xc7/0xf0()
>> > [1385509.048308] Modules linked in:
>> > [1385509.069698] CPU: 3 PID: 22593 Comm: ksm04 Not tainted 4.3.0-rc1-next-20150914-sasha-00043-geddd763-dirty #2557
>> > [1385509.072158]  ffffffffa4750740 ffff8803f60bfab0 ffffffff9bf8bc6a 0000000000000000
>> > [1385509.073347]  ffff8803f60bfaf0 ffffffff9a369096 ffffffff9a7bd007 ffffea000042a5c0
>> > [1385509.074533]  00000000fffffff0 0000000000000000 0000000000000000 ffffffffaaa16540
>> > [1385509.075700] Call Trace:
>> > [1385509.076152] dump_stack (lib/dump_stack.c:52)
>> > [1385509.076971] warn_slowpath_common (kernel/panic.c:448)
>> > [1385509.078823] warn_slowpath_null (kernel/panic.c:482)
>> > [1385509.079700] remove_stable_node (mm/ksm.c:715 (discriminator 3))
>> > [1385509.080565] remove_all_stable_nodes (mm/ksm.c:751)
>> > [1385509.081515] run_store (include/linux/oom.h:65 mm/ksm.c:2162)
>> > [1385509.089983] kobj_attr_store (lib/kobject.c:780)
>> > [1385509.092142] sysfs_kf_write (fs/sysfs/file.c:131)
>> > [1385509.093899] kernfs_fop_write (fs/kernfs/file.c:312)
>> > [1385509.094793] __vfs_write (fs/read_write.c:487)
>> > [1385509.101787] vfs_write (fs/read_write.c:539)
>> > [1385509.102575] SyS_write (fs/read_write.c:586 fs/read_write.c:577)
>> > [1385509.106273] tracesys_phase2 (arch/x86/entry/entry_64.S:273)
>> > [1385509.188672] ---[ end trace 66cda70045475cf9 ]---
> Thanks for the report, Sasha.
> 
> My first inclination is to be lazy, and take this as confirmation
> that the WARN_ON_ONCE was indeed just the right thing to do.  There
> are some holes in undoing KSM, but nobody's data is in danger from
> them, there's no unbounded leak, and no user has yet complained
> (useful though it is, trinity doesn't quite count as a user).
> 
> But...
> 
> I've been assuming you're just doing something new with trinity,
> turning it towards KSM and now hitting this.  But perhaps that's
> not so, and you're doing the same as before, but -next contains
> a change somewhere (not in ksm.c) which is in conflict with KSM's
> assumptions.  Please reassure me that this is not the case, that
> you can reproduce this warning on older kernels.

Hi Hugh,

There's nothing new about the way trinity works with KSM. In this particular
report trinity seems to have executed LTP's ksm04 test
(http://sourceforge.net/p/ltp/git/ci/1eb440c2b5fe43a3e5023015a16aa5d7d3385b1e/tree/testcases/kernel/mem/ksm/ksm04.c).

This issue doesn't reproduce too often, so it's hard to confirm it on
older kernels, but I don't see anything new in the test tools that could
trigger that.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
