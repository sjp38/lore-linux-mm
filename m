Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 88C4B6B00F2
	for <linux-mm@kvack.org>; Wed, 20 May 2015 02:03:26 -0400 (EDT)
Received: by iepj10 with SMTP id j10so31444237iep.3
        for <linux-mm@kvack.org>; Tue, 19 May 2015 23:03:26 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id q18si4541115ico.33.2015.05.19.23.03.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 19 May 2015 23:03:26 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 1/2] ras: hwpoison: fix build failure around
 trace_memory_failure_event
Date: Wed, 20 May 2015 06:01:20 +0000
Message-ID: <20150520060119.GB27005@hori1.linux.bs1.fc.nec.co.jp>
References: <20150518185226.23154d47@canb.auug.org.au>
 <555A0327.9060709@infradead.org>
 <20150519024933.GA1614@hori1.linux.bs1.fc.nec.co.jp>
 <20150519094636.67c9a4a3@gandalf.local.home>
 <20150520053614.GA6236@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150520053614.GA6236@hori1.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <7EE67BA929DD6C4D998C934904A334B5@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, Stephen Rothwell <sfr@canb.auug.org.au>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Davis <jim.epost@gmail.com>, Chen Gong <gong.chen@linux.intel.com>

Here's an updated patch.

# Randy, I dropped your Ack because there's a major change on this version.
# Would you mind looking at it, please?

---
next-20150515 fails to build on i386 with the following error:

  mm/built-in.o: In function `action_result':
  memory-failure.c:(.text+0x344a5): undefined reference to `__tracepoint_me=
mory_failure_event'
  memory-failure.c:(.text+0x344d5): undefined reference to `__tracepoint_me=
mory_failure_event'
  memory-failure.c:(.text+0x3450c): undefined reference to `__tracepoint_me=
mory_failure_event'

The root cause of this error is the lack of dependency between CONFIG_RAS a=
nd
CONFIG_MEMORY_FAILURE.
"CONFIG_RAS=3Dn and CONFIG_MEMORY_FAILURE=3Dy" can happen on 32-bit systems=
 with
CONFIG_SPARSEMEM=3Dn (and all other dependencies of CONFIG_RAS from ACPI_EX=
TLOG/
PCIEAER/EDAC are false), but that's not supposed to happen.

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Reported-by: Jim Davis <jim.epost@gmail.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 52ffb863383c..e79de2bd12cd 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -368,6 +368,7 @@ config MEMORY_FAILURE
 	depends on ARCH_SUPPORTS_MEMORY_FAILURE
 	bool "Enable recovery from hardware memory errors"
 	select MEMORY_ISOLATION
+	select RAS
 	help
 	  Enables code to recover from some memory failures on systems
 	  with MCA recovery. This allows a system to continue running
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
