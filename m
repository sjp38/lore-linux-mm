Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 821C56B1CB7
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 16:55:03 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id t22so642444plo.10
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:55:03 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id s8si4586261plq.345.2018.11.19.13.55.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 13:55:01 -0800 (PST)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v6 07/11] x86/cet/ibt: Add ENDBR to op-code-map
Date: Mon, 19 Nov 2018 13:49:30 -0800
Message-Id: <20181119214934.6174-8-yu-cheng.yu@intel.com>
In-Reply-To: <20181119214934.6174-1-yu-cheng.yu@intel.com>
References: <20181119214934.6174-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Add control transfer terminating instructions:

ENDBR64/ENDBR32:
    Mark a valid 64/32-bit control transfer endpoint.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/lib/x86-opcode-map.txt               | 13 +++++++++++--
 tools/objtool/arch/x86/lib/x86-opcode-map.txt | 13 +++++++++++--
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/arch/x86/lib/x86-opcode-map.txt b/arch/x86/lib/x86-opcode-map.txt
index c5e825d44766..fbc53481bc59 100644
--- a/arch/x86/lib/x86-opcode-map.txt
+++ b/arch/x86/lib/x86-opcode-map.txt
@@ -620,7 +620,16 @@ ea: SAVEPREVSSP (f3)
 # Skip 0xeb-0xff
 EndTable
 
-Table: 3-byte opcode 2 (0x0f 0x38)
+Table: 3-byte opcode 2 (0x0f 0x1e)
+Referrer:
+AVXcode:
+# Skip 0x00-0xf9
+fa: ENDBR64 (f3)
+fb: ENDBR32 (f3)
+#skip 0xfc-0xff
+EndTable
+
+Table: 3-byte opcode 3 (0x0f 0x38)
 Referrer: 3-byte escape 1
 AVXcode: 2
 # 0x0f 0x38 0x00-0x0f
@@ -804,7 +813,7 @@ f6: ADCX Gy,Ey (66) | ADOX Gy,Ey (F3) | MULX By,Gy,rDX,Ey (F2),(v) | WRSS Pq,Qq
 f7: BEXTR Gy,Ey,By (v) | SHLX Gy,Ey,By (66),(v) | SARX Gy,Ey,By (F3),(v) | SHRX Gy,Ey,By (F2),(v)
 EndTable
 
-Table: 3-byte opcode 3 (0x0f 0x3a)
+Table: 3-byte opcode 4 (0x0f 0x3a)
 Referrer: 3-byte escape 2
 AVXcode: 3
 # 0x0f 0x3a 0x00-0xff
diff --git a/tools/objtool/arch/x86/lib/x86-opcode-map.txt b/tools/objtool/arch/x86/lib/x86-opcode-map.txt
index c5e825d44766..fbc53481bc59 100644
--- a/tools/objtool/arch/x86/lib/x86-opcode-map.txt
+++ b/tools/objtool/arch/x86/lib/x86-opcode-map.txt
@@ -620,7 +620,16 @@ ea: SAVEPREVSSP (f3)
 # Skip 0xeb-0xff
 EndTable
 
-Table: 3-byte opcode 2 (0x0f 0x38)
+Table: 3-byte opcode 2 (0x0f 0x1e)
+Referrer:
+AVXcode:
+# Skip 0x00-0xf9
+fa: ENDBR64 (f3)
+fb: ENDBR32 (f3)
+#skip 0xfc-0xff
+EndTable
+
+Table: 3-byte opcode 3 (0x0f 0x38)
 Referrer: 3-byte escape 1
 AVXcode: 2
 # 0x0f 0x38 0x00-0x0f
@@ -804,7 +813,7 @@ f6: ADCX Gy,Ey (66) | ADOX Gy,Ey (F3) | MULX By,Gy,rDX,Ey (F2),(v) | WRSS Pq,Qq
 f7: BEXTR Gy,Ey,By (v) | SHLX Gy,Ey,By (66),(v) | SARX Gy,Ey,By (F3),(v) | SHRX Gy,Ey,By (F2),(v)
 EndTable
 
-Table: 3-byte opcode 3 (0x0f 0x3a)
+Table: 3-byte opcode 4 (0x0f 0x3a)
 Referrer: 3-byte escape 2
 AVXcode: 3
 # 0x0f 0x3a 0x00-0xff
-- 
2.17.1
