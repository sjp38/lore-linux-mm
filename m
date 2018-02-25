Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 599506B0007
	for <linux-mm@kvack.org>; Sun, 25 Feb 2018 18:20:05 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id m6so6715290plt.14
        for <linux-mm@kvack.org>; Sun, 25 Feb 2018 15:20:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e6sor2006626pfi.35.2018.02.25.15.20.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Feb 2018 15:20:04 -0800 (PST)
Date: Mon, 26 Feb 2018 10:19:51 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH v12 22/22] selftests/vm: Fix deadlock in
 protection_keys.c
Message-ID: <20180226101951.0136f963@balbir.ozlabs.ibm.com>
In-Reply-To: <1519264541-7621-23-git-send-email-linuxram@us.ibm.com>
References: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
	<1519264541-7621-23-git-send-email-linuxram@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, arnd@arndb.de

On Wed, 21 Feb 2018 17:55:41 -0800
Ram Pai <linuxram@us.ibm.com> wrote:

> From: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
> 
> The sig_chld() handler calls dprintf2() taking care of setting
> dprint_in_signal so that sigsafe_printf() won't call printf().
> Unfortunately, this precaution is is negated by dprintf_level(), which
> has a call to fflush().
>

fflush() is not the signal-safe function list, so this makes sense.
I wonder if fflush() is needed in sigsafe_printf()?

How about?

diff --git a/tools/testing/selftests/x86/pkey-helpers.h b/tools/testing/selftests/x86/pkey-helpers.h
index b3cb7670e026..2c3b39851f10 100644
--- a/tools/testing/selftests/x86/pkey-helpers.h
+++ b/tools/testing/selftests/x86/pkey-helpers.h
@@ -29,6 +29,7 @@ static inline void sigsafe_printf(const char *format, ...)
 	va_start(ap, format);
 	if (!dprint_in_signal) {
 		vprintf(format, ap);
+		fflush(NULL);				\
 	} else {
 		int ret;
 		int len = vsnprintf(dprint_in_signal_buffer,
@@ -49,7 +50,6 @@ static inline void sigsafe_printf(const char *format, ...)
 #define dprintf_level(level, args...) do {	\
 	if (level <= DEBUG_LEVEL)		\
 		sigsafe_printf(args);		\
-	fflush(NULL);				\
 } while (0)
 #define dprintf0(args...) dprintf_level(0, args)
 #define dprintf1(args...) dprintf_level(1, args)


But both are equivalent I guess, so
Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
