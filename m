Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3A5778E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 05:48:27 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 186-v6so6160033pgc.12
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 02:48:27 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a23-v6si14302756pgk.673.2018.09.17.02.48.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Sep 2018 02:48:26 -0700 (PDT)
Subject: Patch "x86/mm: Remove in_nmi() warning from vmalloc_fault()" has been added to the 3.18-stable tree
From: <gregkh@linuxfoundation.org>
Date: Mon, 17 Sep 2018 11:46:58 +0200
Message-ID: <153717761862153@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 1532533683-5988-2-git-send-email-joro@8bytes.org, David.Laight@aculab.com, aarcange@redhat.com, acme@kernel.org, alexander.levin@microsoft.com, alexander.shishkin@linux.intel.com, aliguori@amazon.com, boris.ostrovsky@oracle.com, bp@alien8.de, brgerst@gmail.com, daniel.gruss@iaik.tugraz.at, dave.hansen@intel.com, dhgutteridge@sympatico.ca, dvlasenk@redhat.com, eduval@amazon.com, gregkh@linuxfoundation.org, hpa@zytor.com, hughd@google.com, jgross@suse.com, jkosina@suse.cz, jolsa@redhat.comjoro@8bytes.org, jpoimboe@redhat.com, jroedel@suse.de, keescook@google.com, linux-mm@kvack.org, llong@redhat.com, luto@kernel.org, namhyung@kernel.org, pavel@ucw.cz, peterz@infradead.org, tglx@linutronix.de, torvalds@linux-foundation.org, will.deacon@arm.com
Cc: stable-commits@vger.kernel.org


This is a note to let you know that I've just added the patch titled

    x86/mm: Remove in_nmi() warning from vmalloc_fault()

to the 3.18-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
     x86-mm-remove-in_nmi-warning-from-vmalloc_fault.patch
and it can be found in the queue-3.18 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@vger.kernel.org> know about it.


>From foo@baz Mon Sep 17 11:45:57 CEST 2018
From: Joerg Roedel <jroedel@suse.de>
Date: Wed, 25 Jul 2018 17:48:01 +0200
Subject: x86/mm: Remove in_nmi() warning from vmalloc_fault()

From: Joerg Roedel <jroedel@suse.de>

[ Upstream commit 6863ea0cda8725072522cd78bda332d9a0b73150 ]

It is perfectly okay to take page-faults, especially on the
vmalloc area while executing an NMI handler. Remove the
warning.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Tested-by: David H. Gutteridge <dhgutteridge@sympatico.ca>
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
Cc: Pavel Machek <pavel@ucw.cz>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Alexander Shishkin <alexander.shishkin@linux.intel.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: joro@8bytes.org
Link: https://lkml.kernel.org/r/1532533683-5988-2-git-send-email-joro@8bytes.org
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 arch/x86/mm/fault.c |    2 --
 1 file changed, 2 deletions(-)

--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -271,8 +271,6 @@ static noinline int vmalloc_fault(unsign
 	if (!(address >= VMALLOC_START && address < VMALLOC_END))
 		return -1;
 
-	WARN_ON_ONCE(in_nmi());
-
 	/*
 	 * Synchronize this task's top level page-table
 	 * with the 'reference' page table.


Patches currently in stable-queue which might be from jroedel@suse.de are

queue-3.18/x86-kexec-allocate-8k-pgds-for-pti.patch
queue-3.18/x86-mm-remove-in_nmi-warning-from-vmalloc_fault.patch
