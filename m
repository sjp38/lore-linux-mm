Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id EECAB6B05FA
	for <linux-mm@kvack.org>; Sun, 20 May 2018 15:11:29 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id f23-v6so10074870wra.20
        for <linux-mm@kvack.org>; Sun, 20 May 2018 12:11:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u26-v6si5319807eda.395.2018.05.20.12.11.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 May 2018 12:11:28 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4KJ9FmA007174
	for <linux-mm@kvack.org>; Sun, 20 May 2018 15:11:26 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2j31aknx0p-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 20 May 2018 15:11:25 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Sun, 20 May 2018 20:11:23 +0100
Date: Sun, 20 May 2018 12:11:15 -0700
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
MIME-Version: 1.0
In-Reply-To: <CALCETrVvQkphypn10A_rkX35DNqi29MJcXYRpRiCFNm02VYz2g@mail.gmail.com>
Message-Id: <20180520191115.GM5479@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Florian Weimer <fweimer@redhat.com>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>

On Sat, May 19, 2018 at 11:06:20PM -0700, Andy Lutomirski wrote:
> On Sat, May 19, 2018 at 11:04 PM Ram Pai <linuxram@us.ibm.com> wrote:
> 
> > On Sat, May 19, 2018 at 04:47:23PM -0700, Andy Lutomirski wrote: > On
> Sat, May 19, 2018 at 1:28 PM Ram Pai <linuxram@us.ibm.com> wrote:
> 
> > ...snip...
> > >
> > > So is it possible for two threads to each call pkey_alloc() and end up
> with
> > > the same key?  If so, it seems entirely broken.
> 
> > No. Two threads cannot allocate the same key; just like x86.
> 
> > > If not, then how do you
> > > intend for a multithreaded application to usefully allocate a new key?
> > > Regardless, it seems like the current behavior on POWER is very
> difficult
> > > to work with.  Can you give an example of a use case for which POWER's
> > > behavior makes sense?
> > >
> > > For the use cases I've imagined, POWER's behavior does not make sense.
> > >   x86's is not ideal but is still better.  Here are my two example use
> cases:
> > >
> > > 1. A crypto library.  Suppose I'm writing a TLS-terminating server, and
> I
> > > want it to be resistant to Heartbleed-like bugs.  I could store my
> private
> > > keys protected by mprotect_key() and arrange for all threads and signal
> > > handlers to have PKRU/AMR values that prevent any access to the memory.
> > > When an explicit call is made to sign with the key, I would temporarily
> > > change PKRU/AMR to allow access, compute the signature, and change
> PKRU/AMR
> > > back.  On x86 right now, this works nicely.  On POWER, it doesn't,
> because
> > > any thread started before my pkey_alloc() call can access the protected
> > > memory, as can any signal handler.
> > >
> > > 2. A database using mmap() (with persistent memory or otherwise).  It
> would
> > > be nice to be resistant to accidental corruption due to stray writes.  I
> > > would do more or less the same thing as (1), except that I would want
> > > threads that are not actively writing to the database to be able the
> > > protected memory.  On x86, I need to manually convince threads that may
> > > have been started before my pkey_alloc() call as well as signal
> handlers to
> > > update their PKRU values.  On POWER, as in example (1), the error goes
> the
> > > other direction -- if I fail to propagate the AMR bits to all threads,
> > > writes are not blocked.
> 
> > I see the problem from an application's point of view, on powerpc.  If
> > the key allocated in one thread is not activated on all threads
> > (existing one and future one), than other threads will not be able
> > to modify the key's permissions. Hence they will not be able to control
> > access/write to pages to which the key is associated.
> 
> > As Florian suggested, I should enable the key's bit in the UAMOR value
> > corresponding to existing threads, when a new key is allocated.
> 
> > Now, looking at the implementation for x86, I see that sys_mpkey_alloc()
> > makes no attempt to modify anything of any other thread. How
> > does it manage to activate the key on any other thread? Is this
> > magic done by the hardware?
> 
> x86 has no equivalent concept to UAMOR.  There are 16 keys no matter what.


Florian,

	Does the following patch fix the problem for you?  Just like x86
	I am enabling all keys in the UAMOR register during
	initialization itself. Hence any key created by any thread at
	any time, will get activated on all threads. So any thread
	can change the permission on that key. Smoke tested it
	with your test program.


Signed-off-by: Ram Pai <linuxram@us.ibm.com>
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 0eafdf01..ab4519a 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -15,8 +15,9 @@
 int  pkeys_total;		/* Total pkeys as per device tree */
 bool pkeys_devtree_defined;	/* pkey property exported by device tree */
 u32  initial_allocation_mask;	/* Bits set for reserved keys */
-u64  pkey_amr_uamor_mask;	/* Bits in AMR/UMOR not to be touched */
+u64  pkey_amr_mask;		/* Bits in AMR not to be touched */
 u64  pkey_iamr_mask;		/* Bits in AMR not to be touched */
+u64  pkey_uamor_mask;		/* Bits in UMOR not to be touched */
 
 #define AMR_BITS_PER_PKEY 2
 #define AMR_RD_BIT 0x1UL
@@ -24,6 +25,7 @@
 #define IAMR_EX_BIT 0x1UL
 #define PKEY_REG_BITS (sizeof(u64)*8)
 #define pkeyshift(pkey) (PKEY_REG_BITS - ((pkey+1) * AMR_BITS_PER_PKEY))
+#define switch_off(bitmask, i) (bitmask &= ~(0x3ul << pkeyshift(i)))
 
 static void scan_pkey_feature(void)
 {
@@ -120,19 +122,31 @@ int pkey_initialize(void)
 	os_reserved = 0;
 #endif
 	initial_allocation_mask = ~0x0;
-	pkey_amr_uamor_mask = ~0x0ul;
+
+	/* register mask is in BE format */
+	pkey_amr_mask = ~0x0ul;
 	pkey_iamr_mask = ~0x0ul;
-	/*
-	 * key 0, 1 are reserved.
-	 * key 0 is the default key, which allows read/write/execute.
-	 * key 1 is recommended not to be used. PowerISA(3.0) page 1015,
-	 * programming note.
-	 */
-	for (i = 2; i < (pkeys_total - os_reserved); i++) {
-		initial_allocation_mask &= ~(0x1 << i);
-		pkey_amr_uamor_mask &= ~(0x3ul << pkeyshift(i));
+
+	for (i = 0; i < (pkeys_total - os_reserved); i++) {
+		if (i != 0 &&  i != 1) /* 0 and 1 are already allocated */
+			initial_allocation_mask &= ~(0x1 << i);
+		pkey_amr_mask &= ~(0x3ul << pkeyshift(i));
 		pkey_iamr_mask &= ~(0x1ul << pkeyshift(i));
 	}
+
+	pkey_uamor_mask = ~0x0ul;
+	switch_off(pkey_uamor_mask, 0);
+	/*
+	 * key 1 is recommended not to be used.
+	 * PowerISA(3.0) page 1015,
+	 * @TODO: Revisit this. This is only applicable on
+	 * pseries kernel running on powerVM.
+	 */
+	switch_off(pkey_uamor_mask, 1);
+	for (i = (pkeys_total - os_reserved); i < pkeys_total; i++)
+		switch_off(pkey_uamor_mask, i);
+
+	printk("pkey_uamor_mask=0x%llx \n", pkey_uamor_mask);
 	return 0;
 }
 
@@ -280,7 +294,6 @@ void thread_pkey_regs_save(struct thread_struct *thread)
 	 */
 	thread->amr = read_amr();
 	thread->iamr = read_iamr();
-	thread->uamor = read_uamor();
 }
 
 void thread_pkey_regs_restore(struct thread_struct *new_thread,
@@ -289,9 +302,6 @@ void thread_pkey_regs_restore(struct thread_struct *new_thread,
 	if (static_branch_likely(&pkey_disabled))
 		return;
 
-	/*
-	 * TODO: Just set UAMOR to zero if @new_thread hasn't used any keys yet.
-	 */
 	if (old_thread->amr != new_thread->amr)
 		write_amr(new_thread->amr);
 	if (old_thread->iamr != new_thread->iamr)
@@ -305,9 +315,9 @@ void thread_pkey_regs_init(struct thread_struct *thread)
 	if (static_branch_likely(&pkey_disabled))
 		return;
 
-	thread->amr = read_amr() & pkey_amr_uamor_mask;
+	thread->amr = read_amr() & pkey_amr_mask;
 	thread->iamr = read_iamr() & pkey_iamr_mask;
-	thread->uamor = read_uamor() & pkey_amr_uamor_mask;
+	thread->uamor = pkey_uamor_mask;
 }
 
 static inline bool pkey_allows_readwrite(int pkey)


> 
> --Andy

-- 
Ram Pai
