Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9EF2E6B0253
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 03:50:32 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id n126so4904786wma.7
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 00:50:32 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j4si4512700wrd.355.2017.12.22.00.50.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 00:50:31 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.4 05/78] x86/mm: Add a noinvpcid boot option to turn off INVPCID
Date: Fri, 22 Dec 2017 09:45:46 +0100
Message-Id: <20171222084557.425162793@linuxfoundation.org>
In-Reply-To: <20171222084556.909780563@linuxfoundation.org>
References: <20171222084556.909780563@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Luis R. Rodriguez" <mcgrof@suse.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Toshi Kani <toshi.kani@hp.com>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.4-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Andy Lutomirski <luto@kernel.org>

commit d12a72b844a49d4162f24cefdab30bed3f86730e upstream.

This adds a chicken bit to turn off INVPCID in case something goes
wrong.  It's an early_param() because we do TLB flushes before we
parse __setup() parameters.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
Reviewed-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/f586317ed1bc2b87aee652267e515b90051af385.1454096309.git.luto@kernel.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 Documentation/kernel-parameters.txt |    2 ++
 arch/x86/kernel/cpu/common.c        |   16 ++++++++++++++++
 2 files changed, 18 insertions(+)

--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2519,6 +2519,8 @@ bytes respectively. Such letter suffixes
 
 	nointroute	[IA-64]
 
+	noinvpcid	[X86] Disable the INVPCID cpu feature.
+
 	nojitter	[IA-64] Disables jitter checking for ITC timers.
 
 	no-kvmclock	[X86,KVM] Disable paravirtualized KVM clock driver
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -162,6 +162,22 @@ static int __init x86_mpx_setup(char *s)
 }
 __setup("nompx", x86_mpx_setup);
 
+static int __init x86_noinvpcid_setup(char *s)
+{
+	/* noinvpcid doesn't accept parameters */
+	if (s)
+		return -EINVAL;
+
+	/* do not emit a message if the feature is not present */
+	if (!boot_cpu_has(X86_FEATURE_INVPCID))
+		return 0;
+
+	setup_clear_cpu_cap(X86_FEATURE_INVPCID);
+	pr_info("noinvpcid: INVPCID feature disabled\n");
+	return 0;
+}
+early_param("noinvpcid", x86_noinvpcid_setup);
+
 #ifdef CONFIG_X86_32
 static int cachesize_override = -1;
 static int disable_x86_serial_nr = 1;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
