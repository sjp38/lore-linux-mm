Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6204D6B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:21:52 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id c85so2384535oib.13
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 03:21:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q3si1240210oig.319.2017.12.14.03.21.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 03:21:50 -0800 (PST)
Subject: Re: pkeys: Support setting access rights for signal handlers
References: <5fee976a-42d4-d469-7058-b78ad8897219@redhat.com>
 <c034f693-95d1-65b8-2031-b969c2771fed@intel.com>
 <5965d682-61b2-d7da-c4d7-c223aa396fab@redhat.com>
 <aa4d127f-0315-3ac9-3fdf-1f0a89cf60b8@intel.com>
 <20171212231324.GE5460@ram.oc3035372033.ibm.com>
 <9dc13a32-b1a6-8462-7e19-cfcf9e2c151e@redhat.com>
 <20171213113544.GG5460@ram.oc3035372033.ibm.com>
 <9f86d79e-165a-1b8e-32dd-7e4e8579da59@redhat.com>
 <c220f36f-c04a-50ae-3fd7-2c6245e27057@intel.com>
 <93153ac4-70f0-9d17-37f1-97b80e468922@redhat.com>
 <20171214001756.GA5471@ram.oc3035372033.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <cf13f6e0-2405-4c58-4cf1-266e8baae825@redhat.com>
Date: Thu, 14 Dec 2017 12:21:44 +0100
MIME-Version: 1.0
In-Reply-To: <20171214001756.GA5471@ram.oc3035372033.ibm.com>
Content-Type: multipart/mixed;
 boundary="------------782D29B7F770EA467EA7855B"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm <linux-mm@kvack.org>, x86@kernel.org, linux-arch <linux-arch@vger.kernel.org>, linux-x86_64@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

This is a multi-part message in MIME format.
--------------782D29B7F770EA467EA7855B
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

On 12/14/2017 01:17 AM, Ram Pai wrote:
> On Wed, Dec 13, 2017 at 04:40:11PM +0100, Florian Weimer wrote:
>> On 12/13/2017 04:22 PM, Dave Hansen wrote:
>>> On 12/13/2017 07:08 AM, Florian Weimer wrote:
>>>> Okay, this model is really quite different from x86.  Is there a
>>>> good reason for the difference?
>>>
>>> Yes, both implementations are simple and take the "natural" behavior.
>>> x86 changes XSAVE-controlled register values on entering a signal, so we
>>> let them be changed (including PKRU).  POWER hardware does not do this
>>> to its PKRU-equivalent, so we do not force it to.
>>
>> Whuy?  Is there a technical reason not have fully-aligned behavior?
>> Can POWER at least implement the original PKEY_ALLOC_SETSIGNAL
>> semantics (reset the access rights for certain keys before switching
>> to the signal handler) in a reasonably efficient manner?
> 
> This can be done on POWER. I can also change the behavior on POWER
> to exactly match x86; i.e reset the value to init value before
> calling the signal handler.

Maybe we can implement a compromise?

Assuming I got the attached patch right, it implements PKRU inheritance 
in signal handlers, similar to what you intend to implement for POWER. 
It still restores the PKRU register value upon regular exit from the 
signal handler, which I think is something we should keep.

I think we still should add a flag, so that applications can easily 
determine if a kernel has this patch.  Setting up a signal handler, 
sending the signal, and thus checking for inheritance is a bit involved, 
and we'd have to do this in the dynamic linker before we can use pkeys 
to harden lazy binding.  The flag could just be a no-op, apart from the 
lack of an EINVAL failure if it is specified.

> But I think, we should clearly define the default behavior, the behavior
> when no flag is specified. Applications tend to rely on default behavior
> and expect the most intuitive behavior to be the default behavior.

Because this feature already shipped on x86, we already have the 
unspecified signal handler behavior in the wild, and if applications 
need the new, clearly defined semantics, there has to be a way to detect 
that the kernel makes this guarantee.

> I tend to think; keeping my biases aside, that the most intuitive
> behavior is to preserve access/write permissions of any key, i.e not
> reset to the init value.  If the application has set the permissions of
> a key to some value, it would'nt expect anyone to change them,
> irrespective of which context it is in.

Sure, it also fixes the siglongjmp issue:

   https://sourceware.org/bugzilla/show_bug.cgi?id=22396

If we do not reset the PKRU register on x86 anymore, a non-pkeys-aware 
signal handler will not clobber it.

Thanks,
Florian

--------------782D29B7F770EA467EA7855B
Content-Type: text/x-patch;
 name="pkeys-signal-inherit.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="pkeys-signal-inherit.patch"

commit 148de78dc299b87ea3dcf13d73c92431f94643a0
Author: Florian Weimer <fweimer@redhat.com>
Date:   Thu Dec 14 11:12:02 2017 -0500

    x86 pkeys: Use PKRU register of interrupted thread in signal handlers
    
    pkeys support for IBM POWER intends to inherited the access rights of
    the current thread in signal handlers.  The advantage is that this
    preserves access to memory regions associated with non-default keys,
    enabling additional usage scenarios for memory protection keys which
    currently do not work due to the unconditional reset to the
    (configurable) default key in signal handlers.
    
    This change does not affect the init_pkru optimization because if the
    thread's PKRU register is zero due to the init_pkru setting, it will
    remain zero in the signal handler through inheritance.
    
    Signed-off-by: Florian Weimer <fweimer@redhat.com>

diff --git a/arch/x86/include/asm/fpu/internal.h b/arch/x86/include/asm/fpu/internal.h
index a38bf5a..a87e99f7 100644
--- a/arch/x86/include/asm/fpu/internal.h
+++ b/arch/x86/include/asm/fpu/internal.h
@@ -33,6 +33,7 @@
 extern void fpu__drop(struct fpu *fpu);
 extern int  fpu__copy(struct fpu *dst_fpu, struct fpu *src_fpu);
 extern void fpu__clear(struct fpu *fpu);
+extern void fpu__clear_signal(struct fpu *fpu);
 extern int  fpu__exception_code(struct fpu *fpu, int trap_nr);
 extern int  dump_fpu(struct pt_regs *ptregs, struct user_i387_struct *fpstate);
 
diff --git a/arch/x86/kernel/fpu/core.c b/arch/x86/kernel/fpu/core.c
index f92a659..a3b3048 100644
--- a/arch/x86/kernel/fpu/core.c
+++ b/arch/x86/kernel/fpu/core.c
@@ -370,21 +370,16 @@ static inline void copy_init_fpstate_to_fpregs(void)
 		copy_kernel_to_fxregs(&init_fpstate.fxsave);
 	else
 		copy_kernel_to_fregs(&init_fpstate.fsave);
-
-	if (boot_cpu_has(X86_FEATURE_OSPKE))
-		copy_init_pkru_to_fpregs();
 }
 
-/*
- * Clear the FPU state back to init state.
- *
- * Called by sys_execve(), by the signal handler code and by various
- * error paths.
- */
-void fpu__clear(struct fpu *fpu)
+static void __fpu_clear(struct fpu *fpu, bool for_signal)
 {
+	u32 pkru;
+
 	WARN_ON_FPU(fpu != &current->thread.fpu); /* Almost certainly an anomaly */
 
+	if (for_signal)
+		pkru = read_pkru();
 	fpu__drop(fpu);
 
 	/*
@@ -395,11 +390,43 @@ void fpu__clear(struct fpu *fpu)
 		fpu__initialize(fpu);
 		user_fpu_begin();
 		copy_init_fpstate_to_fpregs();
+		if (boot_cpu_has(X86_FEATURE_OSPKE)) {
+			/* A signal handler inherits the original PKRU
+			 * value of the interrupted thread.
+			 */
+			if (for_signal)
+				__write_pkru(pkru);
+			else
+				copy_init_pkru_to_fpregs();
+		}
 		preempt_enable();
 	}
 }
 
 /*
+ * Clear the FPU state back to init state.
+ *
+ * Called by sys_execve(), the signal handler return code, and by
+ * various error paths.
+ */
+void fpu__clear(struct fpu *fpu)
+{
+	return __fpu_clear(fpu, false);
+}
+
+/*
+ * Prepare the FPU for invoking a signal handler.
+ *
+ * This is like fpu__clear(), but some CPU registers are inherited
+ * from the current thread and not restored to their initial values,
+ * to match behavior on other architectures.
+ */
+void fpu__clear_signal(struct fpu *fpu)
+{
+	return __fpu_clear(fpu, true);
+}
+
+/*
  * x87 math exception handling:
  */
 
diff --git a/arch/x86/kernel/signal.c b/arch/x86/kernel/signal.c
index b9e00e8..4263f18 100644
--- a/arch/x86/kernel/signal.c
+++ b/arch/x86/kernel/signal.c
@@ -757,7 +757,7 @@ static inline int is_x32_frame(struct ksignal *ksig)
 		 * Ensure the signal handler starts with the new fpu state.
 		 */
 		if (fpu->initialized)
-			fpu__clear(fpu);
+			fpu__clear_signal(fpu);
 	}
 	signal_setup_done(failed, ksig, stepping);
 }

--------------782D29B7F770EA467EA7855B--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
