Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 98AFC6B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 19:35:37 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id r129so1465535wmr.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 16:35:37 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id j13si262456wmd.85.2016.01.29.16.35.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 16:35:36 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id 128so201102wmz.3
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 16:35:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160114043956.GA8496@pd.tnic>
References: <CA+8MBbL5Cwxjr_vtfE5n+XHPknFK4QMC3QNwaif5RvWo-eZATQ@mail.gmail.com>
	<CALCETrVQ_NxcnDr4N-VqROrMJ2hUzMKgmxjxAZu9TFbznqSDcg@mail.gmail.com>
	<CA+8MBbLUtVh3E4RqcHbZ165v+fURGYPm=ejOn2cOPq012BwLSg@mail.gmail.com>
	<CAPcyv4hAenpeqPsj7Rd0Un_SgDpm+CjqH3EK72ho-=zZFvG7wA@mail.gmail.com>
	<CALCETrVRgaWS86wq4B6oZbEY5_ODb3Nh5OeE9vvdGdds6j_pYg@mail.gmail.com>
	<CAPcyv4iCbp0oR_V+XCTduLd1t2UxyFwaoJVk0_vwk8aO2Uh=bQ@mail.gmail.com>
	<CA+8MBbLFb1gdhFWeG-3V4=gHd-fHK_n1oJEFCrYiNa8Af6XAng@mail.gmail.com>
	<20160110112635.GC22896@pd.tnic>
	<20160111104425.GA29448@gmail.com>
	<CA+8MBbJpFWdkwC-yvmDFdFuLrchv2-XhPd3fk8A_hqOOyzm5og@mail.gmail.com>
	<20160114043956.GA8496@pd.tnic>
Date: Fri, 29 Jan 2016 16:35:35 -0800
Message-ID: <CA+8MBbKdH8v=gkTqzxpPRX9-jBEobU9XaEfZh=4cOXDjPE9fBA@mail.gmail.com>
Subject: Re: [PATCH v8 3/3] x86, mce: Add __mcsafe_copy()
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Ingo Molnar <mingo@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-nvdimm <linux-nvdimm@ml01.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Robert <elliott@hpe.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>

On Wed, Jan 13, 2016 at 8:39 PM, Borislav Petkov <bp@alien8.de> wrote:
> On Wed, Jan 13, 2016 at 03:22:58PM -0800, Tony Luck wrote:
>> Are there some examples of synthetic CPUID bits?
>
> X86_FEATURE_ALWAYS is one. The others got renamed into X86_BUG_* ones,
> the remaining mechanism is the same, though.

So something like this [gmail will line wrap, but should still be legible]

Then Dan will be able to use:

      if (cpu_has(c, X86_FEATURE_MCRECOVERY))

to decide whether to use the (slightly slower, but recovery capable)
__mcsafe_copy()
or just pick the fastest memcpy() instead.

-Tony


diff --git a/arch/x86/include/asm/cpufeature.h
b/arch/x86/include/asm/cpufeature.h
index 7ad8c9464297..621e05103633 100644
--- a/arch/x86/include/asm/cpufeature.h
+++ b/arch/x86/include/asm/cpufeature.h
@@ -106,6 +106,7 @@
 #define X86_FEATURE_APERFMPERF ( 3*32+28) /* APERFMPERF */
 #define X86_FEATURE_EAGER_FPU  ( 3*32+29) /* "eagerfpu" Non lazy FPU restore */
 #define X86_FEATURE_NONSTOP_TSC_S3 ( 3*32+30) /* TSC doesn't stop in
S3 state */
+#define X86_FEATURE_MCRECOVERY ( 3*32+31) /* cpu has recoverable
machine checks */

 /* Intel-defined CPU features, CPUID level 0x00000001 (ecx), word 4 */
 #define X86_FEATURE_XMM3       ( 4*32+ 0) /* "pni" SSE-3 */
diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
index a006f4cd792b..b8980d767240 100644
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -1694,6 +1694,14 @@ void mcheck_cpu_init(struct cpuinfo_x86 *c)
                return;
        }

+       /*
+        * MCG_CAP.MCG_SER_P is necessary but not sufficient to know
+        * whether this processor will actually generate recoverable
+        * machine checks. Check to see if this is an E7 model Xeon.
+        */
+       if (mca_cfg.ser && !strncmp(c->x86_model_id, "Intel(R) Xeon(R)
CPU E7-", 24))
+               set_cpu_cap(c, X86_FEATURE_MCRECOVERY);
+
        if (mce_gen_pool_init()) {
                mca_cfg.disabled = true;
                pr_emerg("Couldn't allocate MCE records pool!\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
