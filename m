Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6FBE26B0003
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 11:24:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r78so1296971wmd.0
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 08:24:44 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id t45si391750edm.184.2018.04.11.08.24.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Apr 2018 08:24:39 -0700 (PDT)
Date: Wed, 11 Apr 2018 17:24:38 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH] x86/pgtable: Don't set huge pud/pmd on non-leaf entries
Message-ID: <20180411152437.GC15462@8bytes.org>
References: <1521228593-3820-1-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1521228593-3820-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, "David H. Gutteridge" <dhgutteridge@sympatico.ca>

Hi Ingo, Thomas,

below patch is an update to this series and I plan to include it in the
next post. David H. Gutteridge (CC'ed) was so kind to do additional
testing of these patches and found that a BUG_ON was triggered in
vmalloc_sync_one() when PTI is enabled.

My debugging showed that the bug was present before my patches but that
they uncovered this bug by setting SHARED_KERNEL_PMD to 0 when PTI is
enabled.

So please have a look at the issue description below and the patch and
let me know what you think. I know there are other and better variants
to fix that, but I felt a rework to make the generic ioremap code more
safe against this is out-of-scope at least for this patch-set.


Thanks,

	Joerg
