Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 308E88E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 04:04:26 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e124-v6so5361556pgc.11
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 01:04:26 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e11-v6si25366702pga.150.2018.09.21.01.04.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 01:04:24 -0700 (PDT)
Subject: Patch "x86/mm/pti: Add an overflow check to pti_clone_pmds()" has been added to the 4.14-stable tree
From: <gregkh@linuxfoundation.org>
Date: Fri, 21 Sep 2018 09:53:31 +0200
Message-ID: <153751641157178@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 1531906876-13451-25-git-send-email-joro@8bytes.org, David.Laight@aculab.com, aarcange@redhat.com, alexander.levin@microsoft.com, aliguori@amazon.com, boris.ostrovsky@oracle.com, bp@alien8.de, brgerst@gmail.com, daniel.gruss@iaik.tugraz.at, dave.hansen@intel.com, dhgutteridge@sympatico.ca, dvlasenk@redhat.com, eduval@amazon.com, gregkh@linuxfoundation.org, hpa@zytor.com, hughd@google.com, jgross@suse.com, jkosina@suse.czjoro@8bytes.org, jpoimboe@redhat.com, jroedel@suse.de, keescook@google.com, linux-mm@kvack.org, llong@redhat.com, luto@kernel.org, pavel@ucw.cz, peterz@infradead.org, tglx@linutronix.de, torvalds@linux-foundation.org, will.deacon@arm.com
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/mm/pti: Add an overflow check to pti_clone_pmds()

to the 4.14-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-mm-pti-add-an-overflow-check-to-pti_clone_pmds.patch
and it can be found in the queue-4.14 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From foo@baz Fri Sep 21 09:51:45 CEST 2018
From: Joerg Roedel <jroedel@suse.de>
Date: Wed, 18 Jul 2018 11:41:01 +0200
Subject: x86/mm/pti: Add an overflow check to pti_clone_pmds()

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
Link: https://lkml.kernel.org/r/1531906876-13451-25-git-send-email-joro@8bytes.org
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 arch/x86/mm/pti.c |    4 ++++
 1 file changed, 4 insertions(+)

--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -291,6 +291,10 @@ pti_clone_pmds(unsigned long start, unsi
 		p4d_t *p4d;
 		pud_t *pud;
 
+		/* Overflow check */
+		if (addr < start)
+			break;
+
 		pgd = pgd_offset_k(addr);
 		if (WARN_ON(pgd_none(*pgd)))
 			return;


Patches currently in stable-queue which might be from jroedel@suse.de are

queue-4.14/x86-mm-pti-add-an-overflow-check-to-pti_clone_pmds.patch
