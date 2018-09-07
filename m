Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 03D546B7B98
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 20:40:07 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l7-v6so12678229qte.2
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 17:40:06 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0111.outbound.protection.outlook.com. [104.47.33.111])
        by mx.google.com with ESMTPS id l8-v6si4477841qvo.196.2018.09.06.17.40.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 06 Sep 2018 17:40:06 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: [PATCH AUTOSEL 4.14 67/67] x86/mm/pti: Add an overflow check to
 pti_clone_pmds()
Date: Fri, 7 Sep 2018 00:38:10 +0000
Message-ID: <20180907003716.57737-67-alexander.levin@microsoft.com>
References: <20180907003716.57737-1-alexander.levin@microsoft.com>
In-Reply-To: <20180907003716.57737-1-alexander.levin@microsoft.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Joerg Roedel <jroedel@suse.de>, Thomas Gleixner <tglx@linutronix.de>, "H .
 Peter Anvin" <hpa@zytor.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "aliguori@amazon.com" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, "hughd@google.com" <hughd@google.com>, "keescook@google.com" <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, "joro@8bytes.org" <joro@8bytes.org>, Sasha Levin <Alexander.Levin@microsoft.com>

From: Joerg Roedel <jroedel@suse.de>

[ Upstream commit 935232ce28dfabff1171e5a7113b2d865fa9ee63 ]

The addr counter will overflow if the last PMD of the address space is
cloned, resulting in an endless loop.

Check for that and bail out of the loop when it happens.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: Pavel Machek <pavel@ucw.cz>
Cc: "H . Peter Anvin" <hpa@zytor.com>
Cc: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Jiri Kosina <jkosina@suse.cz>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: David Laight <David.Laight@aculab.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Eduardo Valentin <eduval@amazon.com>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: hughd@google.com
Cc: keescook@google.com
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Waiman Long <llong@redhat.com>
Cc: "David H . Gutteridge" <dhgutteridge@sympatico.ca>
Cc: joro@8bytes.org
Link: https://lkml.kernel.org/r/1531906876-13451-25-git-send-email-joro@8by=
tes.org
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
---
 arch/x86/mm/pti.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
index 7786ab306225..b07e3ffc5ac5 100644
--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -291,6 +291,10 @@ pti_clone_pmds(unsigned long start, unsigned long end,=
 pmdval_t clear)
 		p4d_t *p4d;
 		pud_t *pud;
=20
+		/* Overflow check */
+		if (addr < start)
+			break;
+
 		pgd =3D pgd_offset_k(addr);
 		if (WARN_ON(pgd_none(*pgd)))
 			return;
--=20
2.17.1
