Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id AE5A06B037A
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 15:11:50 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id a17so1303436otd.15
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 12:11:50 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t4si7304014wmt.2.2018.01.03.12.11.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 12:11:49 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.4 01/37] x86/boot: Add early cmdline parsing for options with arguments
Date: Wed,  3 Jan 2018 21:11:07 +0100
Message-Id: <20180103195056.919290887@linuxfoundation.org>
In-Reply-To: <20180103195056.837404126@linuxfoundation.org>
References: <20180103195056.837404126@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Tom Lendacky <thomas.lendacky@amd.com>, Thomas Gleixner <tglx@linutronix.de>, Alexander Potapenko <glider@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, Brijesh Singh <brijesh.singh@amd.com>, Dave Young <dyoung@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Larry Woodman <lwoodman@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Peter Zijlstra <peterz@infradead.org>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Rik van Riel <riel@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, kasan-dev@googlegroups.com, kvm@vger.kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-efi@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.4-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Tom Lendacky <thomas.lendacky@amd.com>

commit e505371dd83963caae1a37ead9524e8d997341be upstream.

Add a cmdline_find_option() function to look for cmdline options that
take arguments. The argument is returned in a supplied buffer and the
argument length (regardless of whether it fits in the supplied buffer)
is returned, with -1 indicating not found.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Alexander Potapenko <glider@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brijesh Singh <brijesh.singh@amd.com>
Cc: Dave Young <dyoung@redhat.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Larry Woodman <lwoodman@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matt Fleming <matt@codeblueprint.co.uk>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Toshimitsu Kani <toshi.kani@hpe.com>
Cc: kasan-dev@googlegroups.com
Cc: kvm@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-doc@vger.kernel.org
Cc: linux-efi@vger.kernel.org
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/36b5f97492a9745dce27682305f990fc20e5cf8a.1500319216.git.thomas.lendacky@amd.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/include/asm/cmdline.h |    2 
 arch/x86/lib/cmdline.c         |  105 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 107 insertions(+)

--- a/arch/x86/include/asm/cmdline.h
+++ b/arch/x86/include/asm/cmdline.h
@@ -2,5 +2,7 @@
 #define _ASM_X86_CMDLINE_H
 
 int cmdline_find_option_bool(const char *cmdline_ptr, const char *option);
+int cmdline_find_option(const char *cmdline_ptr, const char *option,
+			char *buffer, int bufsize);
 
 #endif /* _ASM_X86_CMDLINE_H */
--- a/arch/x86/lib/cmdline.c
+++ b/arch/x86/lib/cmdline.c
@@ -82,3 +82,108 @@ int cmdline_find_option_bool(const char
 
 	return 0;	/* Buffer overrun */
 }
+
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
