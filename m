Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9525D6B000E
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 04:26:55 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g15-v6so8296031pfh.10
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 01:26:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w6-v6si11728911pgr.164.2018.06.18.01.26.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 01:26:54 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.16 240/279] x86/pkeys/selftests: Avoid printf-in-signal deadlocks
Date: Mon, 18 Jun 2018 10:13:45 +0200
Message-Id: <20180618080618.719688426@linuxfoundation.org>
In-Reply-To: <20180618080608.851973560@linuxfoundation.org>
References: <20180618080608.851973560@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Ellermen <mpe@ellerman.id.au>, Peter Zijlstra <peterz@infradead.org>, Ram Pai <linuxram@us.ibm.com>, Shuah Khan <shuah@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Sasha Levin <alexander.levin@microsoft.com>

4.16-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Dave Hansen <dave.hansen@linux.intel.com>

[ Upstream commit caf9eb6b4c82fc6cbd03697052ff22d97b0c377b ]

printf() and friends are unusable in signal handlers.  They deadlock.
The pkey selftest does not do any normal printing in signal handlers,
only extra debugging.  So, just print the format string so we get
*some* output when debugging.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michael Ellermen <mpe@ellerman.id.au>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ram Pai <linuxram@us.ibm.com>
Cc: Shuah Khan <shuah@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/20180509171344.C53FD2F3@viggo.jf.intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 tools/testing/selftests/x86/pkey-helpers.h |   20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

--- a/tools/testing/selftests/x86/pkey-helpers.h
+++ b/tools/testing/selftests/x86/pkey-helpers.h
@@ -26,30 +26,26 @@ static inline void sigsafe_printf(const
 {
 	va_list ap;
 
-	va_start(ap, format);
 	if (!dprint_in_signal) {
+		va_start(ap, format);
 		vprintf(format, ap);
+		va_end(ap);
 	} else {
 		int ret;
-		int len = vsnprintf(dprint_in_signal_buffer,
-				    DPRINT_IN_SIGNAL_BUF_SIZE,
-				    format, ap);
 		/*
-		 * len is amount that would have been printed,
-		 * but actual write is truncated at BUF_SIZE.
+		 * No printf() functions are signal-safe.
+		 * They deadlock easily. Write the format
+		 * string to get some output, even if
+		 * incomplete.
 		 */
-		if (len > DPRINT_IN_SIGNAL_BUF_SIZE)
-			len = DPRINT_IN_SIGNAL_BUF_SIZE;
-		ret = write(1, dprint_in_signal_buffer, len);
+		ret = write(1, format, strlen(format));
 		if (ret < 0)
-			abort();
+			exit(1);
 	}
-	va_end(ap);
 }
 #define dprintf_level(level, args...) do {	\
 	if (level <= DEBUG_LEVEL)		\
 		sigsafe_printf(args);		\
-	fflush(NULL);				\
 } while (0)
 #define dprintf0(args...) dprintf_level(0, args)
 #define dprintf1(args...) dprintf_level(1, args)
