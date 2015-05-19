Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 324726B0071
	for <linux-mm@kvack.org>; Mon, 18 May 2015 22:52:32 -0400 (EDT)
Received: by obfe9 with SMTP id e9so1449602obf.1
        for <linux-mm@kvack.org>; Mon, 18 May 2015 19:52:31 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id t5si7570056oei.69.2015.05.18.19.52.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 18 May 2015 19:52:31 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: linux-next: Tree for May 18 (mm/memory-failure.c)
Date: Tue, 19 May 2015 02:49:34 +0000
Message-ID: <20150519024933.GA1614@hori1.linux.bs1.fc.nec.co.jp>
References: <20150518185226.23154d47@canb.auug.org.au>
 <555A0327.9060709@infradead.org>
In-Reply-To: <555A0327.9060709@infradead.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <2F4B3B4E2F923C47B3A954904CAE6826@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Davis <jim.epost@gmail.com>, Chen Gong <gong.chen@linux.intel.com>

On Mon, May 18, 2015 at 08:20:07AM -0700, Randy Dunlap wrote:
> On 05/18/15 01:52, Stephen Rothwell wrote:
> > Hi all,
> >=20
> > Changes since 20150515:
> >=20
>=20
> on i386:
>=20
> mm/built-in.o: In function `action_result':
> memory-failure.c:(.text+0x344a5): undefined reference to `__tracepoint_me=
mory_failure_event'
> memory-failure.c:(.text+0x344d5): undefined reference to `__tracepoint_me=
mory_failure_event'
> memory-failure.c:(.text+0x3450c): undefined reference to `__tracepoint_me=
mory_failure_event'

Thanks for the reporting, Randy.
Here is a patch for this problem, could you try it?

Thanks,
Naoya
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] ras: hwpoison: fix build failure around
 trace_memory_failure_event

next-20150515 fails to build on i386 with the following error:

  mm/built-in.o: In function `action_result':
  memory-failure.c:(.text+0x344a5): undefined reference to `__tracepoint_me=
mory_failure_event'
  memory-failure.c:(.text+0x344d5): undefined reference to `__tracepoint_me=
mory_failure_event'
  memory-failure.c:(.text+0x3450c): undefined reference to `__tracepoint_me=
mory_failure_event'

Defining CREATE_TRACE_POINTS and TRACE_INCLUDE_PATH fixes it.

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Reported-by: Jim Davis <jim.epost@gmail.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 drivers/ras/ras.c       | 1 -
 include/ras/ras_event.h | 2 ++
 mm/memory-failure.c     | 1 +
 3 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/ras/ras.c b/drivers/ras/ras.c
index b67dd362b7b6..3e2745d8e221 100644
--- a/drivers/ras/ras.c
+++ b/drivers/ras/ras.c
@@ -9,7 +9,6 @@
 #include <linux/ras.h>
=20
 #define CREATE_TRACE_POINTS
-#define TRACE_INCLUDE_PATH ../../include/ras
 #include <ras/ras_event.h>
=20
 static int __init ras_init(void)
diff --git a/include/ras/ras_event.h b/include/ras/ras_event.h
index 1443d79e4fe6..43054c0fcf65 100644
--- a/include/ras/ras_event.h
+++ b/include/ras/ras_event.h
@@ -1,6 +1,8 @@
 #undef TRACE_SYSTEM
 #define TRACE_SYSTEM ras
 #define TRACE_INCLUDE_FILE ras_event
+#undef TRACE_INCLUDE_PATH
+#define TRACE_INCLUDE_PATH ../../include/ras
=20
 #if !defined(_TRACE_HW_EVENT_MC_H) || defined(TRACE_HEADER_MULTI_READ)
 #define _TRACE_HW_EVENT_MC_H
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 8cbe23ac1056..e88e14d87571 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -57,6 +57,7 @@
 #include <linux/mm_inline.h>
 #include <linux/kfifo.h>
 #include "internal.h"
+#define CREATE_TRACE_POINTS
 #include "ras/ras_event.h"
=20
 int sysctl_memory_failure_early_kill __read_mostly =3D 0;
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
