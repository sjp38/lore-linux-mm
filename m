Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9416B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 17:01:25 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 5so43793410ioy.2
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 14:01:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m1si5699489pam.102.2016.06.06.14.01.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 14:01:24 -0700 (PDT)
Date: Mon, 6 Jun 2016 14:01:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 119641] New: hugetlbfs: disabling because there are no
 supported hugepage sizes
Message-Id: <20160606140123.bbc4b06d0f9d8b974f7b323f@linux-foundation.org>
In-Reply-To: <bug-119641-27@https.bugzilla.kernel.org/>
References: <bug-119641-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, jp.pozzi@izzop.net, Ingo Molnar <mingo@elte.hu>, Jan Beulich <JBeulich@suse.com>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

Does anyone have any theories about this?  I went through the
4.5.2->4.5.5 changelog searching for "huget" but came up blank..

I'm suspiciously staring at Ingo's change

commit b2eafe890d4a09bfa63ab31ff018d7d6bb8cfefc
Merge: abfb949 ea5dfb5
Author:     Ingo Molnar <mingo@kernel.org>
AuthorDate: Fri Apr 22 10:12:19 2016 +0200
Commit:     Ingo Molnar <mingo@kernel.org>
CommitDate: Fri Apr 22 10:13:53 2016 +0200

    Merge branch 'x86/urgent' into x86/asm, to fix semantic conflict
    
    'cpu_has_pse' has changed to boot_cpu_has(X86_FEATURE_PSE), fix this
    up in the merge commit when merging the x86/urgent tree that includes
    the following commit:
    
      103f6112f253 ("x86/mm/xen: Suppress hugetlbfs in PV guests")
    
    Signed-off-by: Ingo Molnar <mingo@kernel.org>

--- a/arch/x86/include/asm/hugetlb.h
+++ b/arch/x86/include/asm/hugetlb.h
@@@ -4,6 -4,7 +4,7 @@@
  #include <asm/page.h>
  #include <asm-generic/hugetlb.h>
  
 -#define hugepages_supported() cpu_has_pse
++#define hugepages_supported() boot_cpu_has(X86_FEATURE_PSE)
  
  static inline int is_hugepage_only_range(struct mm_struct *mm,
                                         unsigned long addr,


Which is a followon to Jan's

y:/usr/src/git26> gitshow 103f6112f253
commit 103f6112f253017d7062cd74d17f4a514ed4485c
Author:     Jan Beulich <JBeulich@suse.com>
AuthorDate: Thu Apr 21 00:27:04 2016 -0600
Commit:     Ingo Molnar <mingo@kernel.org>
CommitDate: Fri Apr 22 10:05:00 2016 +0200

    x86/mm/xen: Suppress hugetlbfs in PV guests
    
    Huge pages are not normally available to PV guests. Not suppressing
    hugetlbfs use results in an endless loop of page faults when user mode
    code tries to access a hugetlbfs mapped area (since the hypervisor
    denies such PTEs to be created, but error indications can't be
    propagated out of xen_set_pte_at(), just like for various of its
    siblings), and - once killed in an oops like this:


On Sat, 04 Jun 2016 17:08:36 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=119641
> 
>             Bug ID: 119641
>            Summary: hugetlbfs: disabling because there are no supported
>                     hugepage sizes
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 3.6.1
>           Hardware: Intel
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: jp.pozzi@izzop.net
>         Regression: No
> 
> Created attachment 219011
>   --> https://bugzilla.kernel.org/attachment.cgi?id=219011&action=edit
> .config for 4.6.1 kernel
> 
> Hello,
> 
> I get a message while starting the 4.6.1 kernel under Xen :
> hugetlbfs: disabling because there are no supported hugepage sizes
> 
> And after grepping /proc/meminfo for Huge I get only :
> grep -i huge /proc/meminfo 
> AnonHugePages:         0 kB
> 
> I get this message only when starting the kernel under Xen, when starting
> kernel alone All is OK and I get the "normal" hugepages list.
> 
> I test some previous kernels versions :
> 4.5.2   OK
> 4.5.5   KO
> 4.6.0   KO
> 
> My system is 
> CPU     Intel Core I7 6700
> MEM     32Go
> Disks   some ...
> System  Debian unstable up to date
> 
> I enclose the .config file.
> 
> Regards
> 
> JP P
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
