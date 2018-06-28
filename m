Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0716B0007
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 19:21:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c20-v6so2462188eds.21
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 16:21:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m1-v6sor3507703eds.47.2018.06.28.16.21.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Jun 2018 16:21:22 -0700 (PDT)
Date: Fri, 29 Jun 2018 01:21:20 +0200
From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: [PATCH] sparse: stricter warning for explicit cast to ulong
Message-ID: <20180628232119.5jaavhewv5nb6ufb@ltop.local>
References: <cover.1529507994.git.andreyknvl@google.com>
 <CAAeHK+zqtyGzd_CZ7qKZKU-uZjZ1Pkmod5h8zzbN0xCV26nSfg@mail.gmail.com>
 <20180626172900.ufclp2pfrhwkxjco@armageddon.cambridge.arm.com>
 <CAAeHK+yqWKTdTG+ymZ2-5XKiDANV+fmUjnQkRy-5tpgphuLJRA@mail.gmail.com>
 <0cef1643-a523-98e7-95e2-9ec595137642@arm.com>
 <20180627171757.amucnh5znld45cpc@armageddon.cambridge.arm.com>
 <20180628061758.j6bytsaj5jk4aocg@ltop.local>
 <20180628102741.vk6vphfinlj3lvhv@armageddon.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180628102741.vk6vphfinlj3lvhv@armageddon.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Will Deacon <Will.Deacon@arm.com>, Kostya Serebryany <kcc@google.com>, "linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Evgeniy Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Andrey Konovalov <andreyknvl@google.com>, Lee Smith <Lee.Smith@arm.com>, Al Viro <viro@zeniv.linux.org.uk>nd <nd@arm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Ramana Radhakrishnan <ramana.radhakrishnan@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <Robin.Murphy@arm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-sparse@vger.kernel.org

sparse issues a warning when user pointers are casted to integer
types except to unsigned longs which are explicitly allowed.
However it may happen that we would like to also be warned
on casts to unsigned long.

Fix this by adding a new warning flag: -Wcast-from-as (to mirrors
-Wcast-to-as) which extends -Waddress-space to all casts that
remove an address space attribute (without using __force).

References: https://lore.kernel.org/lkml/20180628102741.vk6vphfinlj3lvhv@armageddon.cambridge.arm.com/
Signed-off-by: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
---

This patch is available in the Git repository at:
  git://github.com/lucvoo/sparse-dev.git warn-cast-from-as

----------------------------------------------------------------
Luc Van Oostenryck (1):
      stricter warning for explicit cast to ulong

 evaluate.c                         |  4 +--
 lib.c                              |  2 ++
 lib.h                              |  1 +
 sparse.1                           |  9 ++++++
 validation/Waddress-space-strict.c | 56 ++++++++++++++++++++++++++++++++++++++
 5 files changed, 70 insertions(+), 2 deletions(-)
 create mode 100644 validation/Waddress-space-strict.c

diff --git a/evaluate.c b/evaluate.c
index 194b97218..64e1067ce 100644
--- a/evaluate.c
+++ b/evaluate.c
@@ -2998,14 +2998,14 @@ static struct symbol *evaluate_cast(struct expression *expr)
 		}
 	}
 
-	if (ttype == &ulong_ctype)
+	if (ttype == &ulong_ctype && !Wcast_from_as)
 		tas = -1;
 	else if (tclass == TYPE_PTR) {
 		examine_pointer_target(ttype);
 		tas = ttype->ctype.as;
 	}
 
-	if (stype == &ulong_ctype)
+	if (stype == &ulong_ctype && !Wcast_from_as)
 		sas = -1;
 	else if (sclass == TYPE_PTR) {
 		examine_pointer_target(stype);
diff --git a/lib.c b/lib.c
index 308f8f699..0bb5232ab 100644
--- a/lib.c
+++ b/lib.c
@@ -248,6 +248,7 @@ static struct token *pre_buffer_end = NULL;
 int Waddress = 0;
 int Waddress_space = 1;
 int Wbitwise = 1;
+int Wcast_from_as = 0;
 int Wcast_to_as = 0;
 int Wcast_truncate = 1;
 int Wconstexpr_not_const = 0;
@@ -678,6 +679,7 @@ static const struct flag warnings[] = {
 	{ "address", &Waddress },
 	{ "address-space", &Waddress_space },
 	{ "bitwise", &Wbitwise },
+	{ "cast-from-as", &Wcast_from_as },
 	{ "cast-to-as", &Wcast_to_as },
 	{ "cast-truncate", &Wcast_truncate },
 	{ "constexpr-not-const", &Wconstexpr_not_const},
diff --git a/lib.h b/lib.h
index b0453bb6e..46e685421 100644
--- a/lib.h
+++ b/lib.h
@@ -137,6 +137,7 @@ extern int preprocess_only;
 extern int Waddress;
 extern int Waddress_space;
 extern int Wbitwise;
+extern int Wcast_from_as;
 extern int Wcast_to_as;
 extern int Wcast_truncate;
 extern int Wconstexpr_not_const;
diff --git a/sparse.1 b/sparse.1
index 806fb0cf0..62956f18b 100644
--- a/sparse.1
+++ b/sparse.1
@@ -77,6 +77,15 @@ Sparse issues these warnings by default.  To turn them off, use
 \fB\-Wno\-bitwise\fR.
 .
 .TP
+.B \-Wcast\-from\-as
+Warn about which remove an address space to a pointer type.
+
+This is similar to \fB\-Waddress\-space\fR but will also warn
+on casts to \fBunsigned long\fR.
+
+Sparse does not issues these warnings by default.
+.
+.TP
 .B \-Wcast\-to\-as
 Warn about casts which add an address space to a pointer type.
 
diff --git a/validation/Waddress-space-strict.c b/validation/Waddress-space-strict.c
new file mode 100644
index 000000000..ad23f74ae
--- /dev/null
+++ b/validation/Waddress-space-strict.c
@@ -0,0 +1,56 @@
+#define __user __attribute__((address_space(1)))
+
+typedef unsigned long ulong;
+typedef long long llong;
+typedef struct s obj_t;
+
+static void expl(int i, ulong u, llong l, void *v, obj_t *o, obj_t __user *p)
+{
+	(obj_t*)(i);
+	(obj_t __user*)(i);
+
+	(obj_t*)(u);
+	(obj_t __user*)(u);
+
+	(obj_t*)(l);
+	(obj_t __user*)(l);
+
+	(obj_t*)(v);
+	(obj_t __user*)(v);
+
+	(int)(o);
+	(ulong)(o);
+	(llong)(o);
+	(void *)(o);
+	(obj_t*)(o);
+	(obj_t __user*)(o);
+
+	(int)(p);		// w
+	(ulong)(p);		// w!
+	(llong)(p);		// w
+	(void *)(p);		// w
+	(obj_t*)(p);		// w
+	(obj_t __user*)(p);	// ok
+}
+
+/*
+ * check-name: Waddress-space-strict
+ * check-command: sparse -Wcast-from-as -Wcast-to-as $file
+ *
+ * check-error-start
+Waddress-space-strict.c:10:10: warning: cast adds address space to expression (<asn:1>)
+Waddress-space-strict.c:13:10: warning: cast adds address space to expression (<asn:1>)
+Waddress-space-strict.c:16:10: warning: cast adds address space to expression (<asn:1>)
+Waddress-space-strict.c:19:10: warning: cast adds address space to expression (<asn:1>)
+Waddress-space-strict.c:26:10: warning: cast adds address space to expression (<asn:1>)
+Waddress-space-strict.c:28:10: warning: cast removes address space of expression
+Waddress-space-strict.c:29:10: warning: cast removes address space of expression
+Waddress-space-strict.c:30:10: warning: cast removes address space of expression
+Waddress-space-strict.c:31:10: warning: cast removes address space of expression
+Waddress-space-strict.c:32:10: warning: cast removes address space of expression
+Waddress-space-strict.c:9:10: warning: non size-preserving integer to pointer cast
+Waddress-space-strict.c:10:10: warning: non size-preserving integer to pointer cast
+Waddress-space-strict.c:21:10: warning: non size-preserving pointer to integer cast
+Waddress-space-strict.c:28:10: warning: non size-preserving pointer to integer cast
+ * check-error-end
+ */
-- 
2.18.0
