Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 186EE6B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 15:10:55 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id o16so14692098wra.2
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 12:10:55 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b80si2476473wma.165.2017.02.10.12.10.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 12:10:53 -0800 (PST)
Date: Fri, 10 Feb 2017 21:10:30 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv4 1/5] x86/mm: split arch_mmap_rnd() on compat/native
 versions
In-Reply-To: <20170209135525.qlwrmlo7njk3fsaq@pd.tnic>
Message-ID: <alpine.DEB.2.20.1702102057330.4042@nanos>
References: <20170130120432.6716-1-dsafonov@virtuozzo.com> <20170130120432.6716-2-dsafonov@virtuozzo.com> <20170209135525.qlwrmlo7njk3fsaq@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org

On Thu, 9 Feb 2017, Borislav Petkov wrote:
> I can't say that I'm thrilled about the ifdeffery this is adding.
> 
> But I can't think of a cleaner approach at a quick glance, though -
> that's generic and arch-specific code intertwined muck. Sad face.

It's trivial enough to do ....

Thanks,

	tglx

---
 arch/x86/mm/mmap.c |   22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

--- a/arch/x86/mm/mmap.c
+++ b/arch/x86/mm/mmap.c
@@ -55,6 +55,10 @@ static unsigned long stack_maxrandom_siz
 #define MIN_GAP (128*1024*1024UL + stack_maxrandom_size())
 #define MAX_GAP (TASK_SIZE/6*5)
 
+#ifndef CONFIG_COMPAT
+# define mmap_rnd_compat_bits	mmap_rnd_bits
+#endif
+
 static int mmap_is_legacy(void)
 {
 	if (current->personality & ADDR_COMPAT_LAYOUT)
@@ -66,20 +70,14 @@ static int mmap_is_legacy(void)
 	return sysctl_legacy_va_layout;
 }
 
-unsigned long arch_mmap_rnd(void)
+static unsigned long arch_rnd(unsigned int rndbits)
 {
-	unsigned long rnd;
-
-	if (mmap_is_ia32())
-#ifdef CONFIG_COMPAT
-		rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
-#else
-		rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
-#endif
-	else
-		rnd = get_random_long() & ((1UL << mmap_rnd_bits) - 1);
+	return (get_random_long() & ((1UL << rndbits) - 1)) << PAGE_SHIFT;
+}
 
-	return rnd << PAGE_SHIFT;
+unsigned long arch_mmap_rnd(void)
+{
+	return arch_rnd(mmap_is_ia32() ? mmap_rnd_compat_bits : mmap_rnd_bits);
 }
 
 static unsigned long mmap_base(unsigned long rnd)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
