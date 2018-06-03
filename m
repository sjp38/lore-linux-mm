Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 013496B0003
	for <linux-mm@kvack.org>; Sun,  3 Jun 2018 16:18:44 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 33-v6so22398216wrb.12
        for <linux-mm@kvack.org>; Sun, 03 Jun 2018 13:18:43 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h6-v6si21258449wrb.44.2018.06.03.13.18.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jun 2018 13:18:42 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w53KESIY034731
	for <linux-mm@kvack.org>; Sun, 3 Jun 2018 16:18:40 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jc8e24x8u-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 03 Jun 2018 16:18:40 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Sun, 3 Jun 2018 21:18:39 +0100
Date: Sun, 3 Jun 2018 13:18:32 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: pkeys on POWER: Access rights not reset on execve
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <53828769-23c4-b2e3-cf59-239936819c3e@redhat.com>
 <20180519011947.GJ5479@ram.oc3035372033.ibm.com>
 <CALCETrWMP9kTmAFCR0WHR3YP93gLSzgxhfnb0ma_0q=PCuSdQA@mail.gmail.com>
 <20180519202747.GK5479@ram.oc3035372033.ibm.com>
 <CALCETrVz9otkOQAxVkz6HtuMwjAeY6mMuLgFK_o0M0kbkUznwg@mail.gmail.com>
 <20180520060425.GL5479@ram.oc3035372033.ibm.com>
 <CALCETrVvQkphypn10A_rkX35DNqi29MJcXYRpRiCFNm02VYz2g@mail.gmail.com>
 <20180520191115.GM5479@ram.oc3035372033.ibm.com>
 <aae1952c-886b-cfc8-e98b-fa3be5fab0fa@redhat.com>
MIME-Version: 1.0
In-Reply-To: <aae1952c-886b-cfc8-e98b-fa3be5fab0fa@redhat.com>
Message-Id: <20180603201832.GA10109@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>, Linux-MM <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Dave Hansen <dave.hansen@intel.com>

On Mon, May 21, 2018 at 01:29:11PM +0200, Florian Weimer wrote:
> On 05/20/2018 09:11 PM, Ram Pai wrote:
> >Florian,
> >
> >	Does the following patch fix the problem for you?  Just like x86
> >	I am enabling all keys in the UAMOR register during
> >	initialization itself. Hence any key created by any thread at
> >	any time, will get activated on all threads. So any thread
> >	can change the permission on that key. Smoke tested it
> >	with your test program.
> 
> I think this goes in the right direction, but the AMR value after
> fork is still strange:
> 
> AMR (PID 34912): 0x0000000000000000
> AMR after fork (PID 34913): 0x0000000000000000
> AMR (PID 34913): 0x0000000000000000
> Allocated key in subprocess (PID 34913): 2
> Allocated key (PID 34912): 2
> Setting AMR: 0xffffffffffffffff
> New AMR value (PID 34912): 0x0fffffffffffffff
> About to call execl (PID 34912) ...
> AMR (PID 34912): 0x0fffffffffffffff
> AMR after fork (PID 34914): 0x0000000000000003
> AMR (PID 34914): 0x0000000000000003
> Allocated key in subprocess (PID 34914): 2
> Allocated key (PID 34912): 2
> Setting AMR: 0xffffffffffffffff
> New AMR value (PID 34912): 0x0fffffffffffffff
> 
> I mean this line:
> 
> AMR after fork (PID 34914): 0x0000000000000003
> 
> Shouldn't it be the same as in the parent process?

Fixed it. Please try this patch. If it all works to your satisfaction, I
will clean it up further and send to Michael Ellermen(ppc maintainer).


commit 51f4208ed5baeab1edb9b0f8b68d7144449b3527
Author: Ram Pai <linuxram@us.ibm.com>
Date:   Sun Jun 3 14:44:32 2018 -0500

    Fix for the fork bug.
    
    Signed-off-by: Ram Pai <linuxram@us.ibm.com>

diff --git a/arch/powerpc/kernel/process.c b/arch/powerpc/kernel/process.c
index 1237f13..999dd08 100644
--- a/arch/powerpc/kernel/process.c
+++ b/arch/powerpc/kernel/process.c
@@ -582,6 +582,7 @@ static void save_all(struct task_struct *tsk)
 		__giveup_spe(tsk);
 
 	msr_check_and_clear(msr_all_available);
+	thread_pkey_regs_save(&tsk->thread);
 }
 
 void flush_all_to_thread(struct task_struct *tsk)
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index ab4519a..af6aa4a 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -294,6 +294,7 @@ void thread_pkey_regs_save(struct thread_struct *thread)
 	 */
 	thread->amr = read_amr();
 	thread->iamr = read_iamr();
+	thread->uamor = read_uamor();
 }
 
 void thread_pkey_regs_restore(struct thread_struct *new_thread,
@@ -315,9 +316,13 @@ void thread_pkey_regs_init(struct thread_struct *thread)
 	if (static_branch_likely(&pkey_disabled))
 		return;
 
-	thread->amr = read_amr() & pkey_amr_mask;
-	thread->iamr = read_iamr() & pkey_iamr_mask;
+	thread->amr = pkey_amr_mask;
+	thread->iamr = pkey_iamr_mask;
 	thread->uamor = pkey_uamor_mask;
+
+	write_uamor(pkey_uamor_mask);
+	write_amr(pkey_amr_mask);
+	write_iamr(pkey_iamr_mask);
 }
 
 static inline bool pkey_allows_readwrite(int pkey)


> 
> Thanks,
> Florian

-- 
Ram Pai
