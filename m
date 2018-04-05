Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA95B6B0006
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 13:18:43 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id p21so17379988qke.20
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 10:18:43 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0052.outbound.protection.outlook.com. [104.47.33.52])
        by mx.google.com with ESMTPS id l35si9592333qkh.446.2018.04.05.10.18.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Apr 2018 10:18:42 -0700 (PDT)
From: Yury Norov <ynorov@caviumnetworks.com>
Subject: [PATCH 1/5] arm64: entry: isb in el1_irq
Date: Thu,  5 Apr 2018 20:17:56 +0300
Message-Id: <20180405171800.5648-2-ynorov@caviumnetworks.com>
In-Reply-To: <20180405171800.5648-1-ynorov@caviumnetworks.com>
References: <20180405171800.5648-1-ynorov@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Christopher Lameter <cl@linux.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Catalin Marinas <catalin.marinas@arm.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexey Klimov <klimov.linux@gmail.com>
Cc: Yury Norov <ynorov@caviumnetworks.com>, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Kernel text patching framework relies on IPI to ensure that other
SMP cores observe the change. Target core calls isb() in IPI handler
path, but not at the beginning of el1_irq entry. There's a chance
that modified instruction will appear prior isb(), and so will not be
observed.

This patch inserts isb early at el1_irq entry to avoid that chance.

Signed-off-by: Yury Norov <ynorov@caviumnetworks.com>
---
 arch/arm64/kernel/entry.S | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/kernel/entry.S b/arch/arm64/kernel/entry.S
index ec2ee720e33e..9c06b4b80060 100644
--- a/arch/arm64/kernel/entry.S
+++ b/arch/arm64/kernel/entry.S
@@ -593,6 +593,7 @@ ENDPROC(el1_sync)
 
 	.align	6
 el1_irq:
+	isb					// pairs with aarch64_insn_patch_text
 	kernel_entry 1
 	enable_da_f
 #ifdef CONFIG_TRACE_IRQFLAGS
-- 
2.14.1
