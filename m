Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B24306B0033
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 11:48:17 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id s105so5502389wrc.23
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 08:48:17 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a136si13619830wmd.169.2017.12.27.08.48.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Dec 2017 08:48:16 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 20/74] x86/uv: Use the right TLB-flush API
Date: Wed, 27 Dec 2017 17:45:53 +0100
Message-Id: <20171227164614.911155949@linuxfoundation.org>
In-Reply-To: <20171227164614.109898944@linuxfoundation.org>
References: <20171227164614.109898944@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Banman <abanman@hpe.com>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mike Travis <mike.travis@hpe.com>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Peter Zijlstra <peterz@infradead.org>

commit 3e46e0f5ee3643a1239be9046c7ba6c66ca2b329 upstream.

Since uv_flush_tlb_others() implements flush_tlb_others() which is
about flushing user mappings, we should use __flush_tlb_single(),
which too is about flushing user mappings.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Acked-by: Andrew Banman <abanman@hpe.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: David Laight <David.Laight@aculab.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Eduardo Valentin <eduval@amazon.com>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mike Travis <mike.travis@hpe.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: hughd@google.com
Cc: keescook@google.com
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/platform/uv/tlb_uv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/arch/x86/platform/uv/tlb_uv.c
+++ b/arch/x86/platform/uv/tlb_uv.c
@@ -299,7 +299,7 @@ static void bau_process_message(struct m
 		local_flush_tlb();
 		stat->d_alltlb++;
 	} else {
-		__flush_tlb_one(msg->address);
+		__flush_tlb_single(msg->address);
 		stat->d_onetlb++;
 	}
 	stat->d_requestee++;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
