Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B8EED6B0266
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 16:27:40 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p64so121309068pfb.0
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 13:27:40 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id sp8si5195475pab.2.2016.07.20.13.27.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 13:27:25 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id ks6so21478001pab.0
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 13:27:22 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v4 10/12] s390/uaccess: Enable hardened usercopy
Date: Wed, 20 Jul 2016 13:27:05 -0700
Message-Id: <1469046427-12696-11-git-send-email-keescook@chromium.org>
In-Reply-To: <1469046427-12696-1-git-send-email-keescook@chromium.org>
References: <1469046427-12696-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@fedoraproject.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Enables CONFIG_HARDENED_USERCOPY checks on s390.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/s390/Kconfig       | 1 +
 arch/s390/lib/uaccess.c | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index a8c259059adf..9f694311c9ed 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -122,6 +122,7 @@ config S390
 	select HAVE_ALIGNED_STRUCT_PAGE if SLUB
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_EARLY_PFN_TO_NID
+	select HAVE_ARCH_HARDENED_USERCOPY
 	select HAVE_ARCH_JUMP_LABEL
 	select CPU_NO_EFFICIENT_FFS if !HAVE_MARCH_Z9_109_FEATURES
 	select HAVE_ARCH_SECCOMP_FILTER
diff --git a/arch/s390/lib/uaccess.c b/arch/s390/lib/uaccess.c
index ae4de559e3a0..6986c20166f0 100644
--- a/arch/s390/lib/uaccess.c
+++ b/arch/s390/lib/uaccess.c
@@ -104,6 +104,7 @@ static inline unsigned long copy_from_user_mvcp(void *x, const void __user *ptr,
 
 unsigned long __copy_from_user(void *to, const void __user *from, unsigned long n)
 {
+	check_object_size(to, n, false);
 	if (static_branch_likely(&have_mvcos))
 		return copy_from_user_mvcos(to, from, n);
 	return copy_from_user_mvcp(to, from, n);
@@ -177,6 +178,7 @@ static inline unsigned long copy_to_user_mvcs(void __user *ptr, const void *x,
 
 unsigned long __copy_to_user(void __user *to, const void *from, unsigned long n)
 {
+	check_object_size(from, n, true);
 	if (static_branch_likely(&have_mvcos))
 		return copy_to_user_mvcos(to, from, n);
 	return copy_to_user_mvcs(to, from, n);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
