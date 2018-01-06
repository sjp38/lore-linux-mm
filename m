Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id B8C3E6B0038
	for <linux-mm@kvack.org>; Sat,  6 Jan 2018 12:22:38 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id r141so847981oie.9
        for <linux-mm@kvack.org>; Sat, 06 Jan 2018 09:22:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 98si2359698otl.374.2018.01.06.09.22.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 06 Jan 2018 09:22:37 -0800 (PST)
Date: Sat, 6 Jan 2018 18:22:32 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
Message-ID: <20180106172232.GC25546@redhat.com>
References: <20171123003447.1DB395E3@viggo.jf.intel.com>
 <e80ac5b1-c562-fc60-ee84-30a3a40bde60@huawei.com>
 <93776eb2-b6d4-679a-280c-8ba558a69c34@linux.intel.com>
 <bda85c5e-d2be-f4ac-e2b4-4ef01d5a01a5@huawei.com>
 <20a54a5f-f4e5-2126-fb73-6a995d13d52d@linux.intel.com>
 <alpine.LRH.2.00.1801051909160.27010@gjva.wvxbf.pm>
 <ac54449b-feeb-58d2-45e6-5ebb9784ed13@huawei.com>
 <332f4eab-8a3d-8b29-04f2-7c075f81b85b@linux.intel.com>
 <dcab663f-b090-7447-e43a-44cc8c4a8c8b@huawei.com>
 <10ed0bc4-5f98-b771-5020-12838923b0ca@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <10ed0bc4-5f98-b771-5020-12838923b0ca@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Hanjun Guo <guohanjun@huawei.com>, Jiri Kosina <jikos@kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, keescook@google.com, hughd@google.com, x86@kernel.org

On Fri, Jan 05, 2018 at 11:51:38PM -0800, Dave Hansen wrote:
> On 01/05/2018 10:28 PM, Hanjun Guo wrote:
> >> +
> >>  	p4d = p4d_alloc(&tboot_mm, pgd, vaddr);
> > Seems pgd will be re-set after p4d_alloc(), so should
> > we put the code behind (or after pud_alloc())?

Thanks Dave and Jiri for these two tboot and efi_64 fixes.

> 
> <sigh> Yes, it has to go below where the PGD actually gets set which is
> after pud_alloc().  You can put it anywhere later in the function.

Did the exact same oversight yesterday when porting Jiri's fix.

efi_64 booted fine verified yesterday in a respin of what I sent here
by just moving it after pud_alloc too:

		pud = pud_alloc(&init_mm, pgd_efi, addr_pgd);
		if (!pud) {
			pr_err("Failed to allocate pud table!\n");
			break;
		}
+		pgd_efi->pgd &= ~_PAGE_NX;

Now I'm having this tested for tboot too (still untested). With tboot
I expect the first build pass the test. All followups on bz.

diff --git a/arch/x86/kernel/tboot.c b/arch/x86/kernel/tboot.c
index 088681d4fc45..09cff5f4f9a4 100644
--- a/arch/x86/kernel/tboot.c
+++ b/arch/x86/kernel/tboot.c
@@ -131,6 +131,7 @@ static int map_tboot_page(unsigned long vaddr, unsigned long pfn,
 	pud = pud_alloc(&tboot_mm, pgd, vaddr);
 	if (!pud)
 		return -1;
+	pgd->pgd &= ~_PAGE_NX;
 	pmd = pmd_alloc(&tboot_mm, pud, vaddr);
 	if (!pmd)
 		return -1;

Note your upstream submitted version is less theoretically correct than the
above. It won't make a difference in practice, but it is theoretically
wrong to clear the PAGE_NX only if pte_alloc_map succeeds like your
patch does.

If in the future pte_alloc_map fails and for whatever reason the pgd
will still be used and the whole thing will not abort, your fix will
still end up with NX set in the pgd.

Only the first pud allocation establishes itself in the pgd, follow
ups don't if in __pud_alloc pgd_present() will return true.

This is why I did the strictier backport of Jiri's fix yesterday but I
was a little too strict putting it just before pud_alloc and it had to
go just after it.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
