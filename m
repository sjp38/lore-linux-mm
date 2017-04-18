Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 199332806D9
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:22:13 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u68so1360009qkd.20
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:22:13 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0052.outbound.protection.outlook.com. [104.47.33.52])
        by mx.google.com with ESMTPS id m22si341787qtf.10.2017.04.18.14.22.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 14:22:12 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v5 30/32] x86/boot: Add early cmdline parsing for options
 with arguments
Date: Tue, 18 Apr 2017 16:22:00 -0500
Message-ID: <20170418212200.10190.18044.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

Add a cmdline_find_option() function to look for cmdline options that
take arguments. The argument is returned in a supplied buffer and the
argument length (regardless of whether it fits in the supplied buffer)
is returned, with -1 indicating not found.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/cmdline.h |    2 +
 arch/x86/lib/cmdline.c         |  105 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 107 insertions(+)

diff --git a/arch/x86/include/asm/cmdline.h b/arch/x86/include/asm/cmdline.h
index e01f7f7..84ae170 100644
--- a/arch/x86/include/asm/cmdline.h
+++ b/arch/x86/include/asm/cmdline.h
@@ -2,5 +2,7 @@
 #define _ASM_X86_CMDLINE_H
 
 int cmdline_find_option_bool(const char *cmdline_ptr, const char *option);
+int cmdline_find_option(const char *cmdline_ptr, const char *option,
+			char *buffer, int bufsize);
 
 #endif /* _ASM_X86_CMDLINE_H */
diff --git a/arch/x86/lib/cmdline.c b/arch/x86/lib/cmdline.c
index 5cc78bf..3261abb 100644
--- a/arch/x86/lib/cmdline.c
+++ b/arch/x86/lib/cmdline.c
@@ -104,7 +104,112 @@ static inline int myisspace(u8 c)
 	return 0;	/* Buffer overrun */
 }
 
+/*
+ * Find a non-boolean option (i.e. option=argument). In accordance with
+ * standard Linux practice, if this option is repeated, this returns the
+ * last instance on the command line.
+ *
+ * @cmdline: the cmdline string
+ * @max_cmdline_size: the maximum size of cmdline
+ * @option: option string to look for
+ * @buffer: memory buffer to return the option argument
+ * @bufsize: size of the supplied memory buffer
+ *
+ * Returns the length of the argument (regardless of if it was
+ * truncated to fit in the buffer), or -1 on not found.
+ */
+static int
+__cmdline_find_option(const char *cmdline, int max_cmdline_size,
+		      const char *option, char *buffer, int bufsize)
+{
+	char c;
+	int pos = 0, len = -1;
+	const char *opptr = NULL;
+	char *bufptr = buffer;
+	enum {
+		st_wordstart = 0,	/* Start of word/after whitespace */
+		st_wordcmp,	/* Comparing this word */
+		st_wordskip,	/* Miscompare, skip */
+		st_bufcpy,	/* Copying this to buffer */
+	} state = st_wordstart;
+
+	if (!cmdline)
+		return -1;      /* No command line */
+
+	/*
+	 * This 'pos' check ensures we do not overrun
+	 * a non-NULL-terminated 'cmdline'
+	 */
+	while (pos++ < max_cmdline_size) {
+		c = *(char *)cmdline++;
+		if (!c)
+			break;
+
+		switch (state) {
+		case st_wordstart:
+			if (myisspace(c))
+				break;
+
+			state = st_wordcmp;
+			opptr = option;
+			/* fall through */
+
+		case st_wordcmp:
+			if ((c == '=') && !*opptr) {
+				/*
+				 * We matched all the way to the end of the
+				 * option we were looking for, prepare to
+				 * copy the argument.
+				 */
+				len = 0;
+				bufptr = buffer;
+				state = st_bufcpy;
+				break;
+			} else if (c == *opptr++) {
+				/*
+				 * We are currently matching, so continue
+				 * to the next character on the cmdline.
+				 */
+				break;
+			}
+			state = st_wordskip;
+			/* fall through */
+
+		case st_wordskip:
+			if (myisspace(c))
+				state = st_wordstart;
+			break;
+
+		case st_bufcpy:
+			if (myisspace(c)) {
+				state = st_wordstart;
+			} else {
+				/*
+				 * Increment len, but don't overrun the
+				 * supplied buffer and leave room for the
+				 * NULL terminator.
+				 */
+				if (++len < bufsize)
+					*bufptr++ = c;
+			}
+			break;
+		}
+	}
+
+	if (bufsize)
+		*bufptr = '\0';
+
+	return len;
+}
+
 int cmdline_find_option_bool(const char *cmdline, const char *option)
 {
 	return __cmdline_find_option_bool(cmdline, COMMAND_LINE_SIZE, option);
 }
+
+int cmdline_find_option(const char *cmdline, const char *option, char *buffer,
+			int bufsize)
+{
+	return __cmdline_find_option(cmdline, COMMAND_LINE_SIZE, option,
+				     buffer, bufsize);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
