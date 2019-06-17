Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94D5AC31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:43:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D53520833
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:43:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="BMa1YbBS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D53520833
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D35708E0002; Mon, 17 Jun 2019 10:43:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE6128E0001; Mon, 17 Jun 2019 10:43:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BAE118E0002; Mon, 17 Jun 2019 10:43:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 69C408E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 10:43:32 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b3so16665826edd.22
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 07:43:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=K85gf5017j1tod/NYZbJo+vfUHgdDY1HeypQxTi9sYA=;
        b=TlqQILytzYXKEljXiSUnid1igJItY3ugmg2v3aEeiRY77HK3PbqAUDOu7r9A+KkQeG
         Ut8HQau7iUSgamdxURcmnG+7T+kYGahCKJVvZ9JnAmaSnJc3+XfCVlaZQwR0gjP7JGb6
         HiARvhAYI82lnvK+tiOg1BkTau3lRMYpml9JrC5oMbNgiXogLldbvfjgh3QZHLtS0yG2
         GBt6r9HzZVnvAHSO9uyMu/AMX+zIqfiSUHuNdR0Ofb1kmXo0WsHTLvutGDQUraOPNIMv
         weeFODCzWnnBAcWYjITGimk+kEzWXMAm+QC09vB4xPpTJ+IESkTWBWL5edK7KZgfnr0e
         nYzw==
X-Gm-Message-State: APjAAAW4bXmx1VPNeVB0O91bhndAMl13QNe1uC5sWjw/jMsKwppP/HW2
	2L7Mqett0e/tZLVZEvdvP9Hzw3+pQDZ0Nc7x6L8fZXSQwKfpd/6LE+AhIRpXwDiIaECRu62Eg/v
	8UCBvhCiy+60k9UdzJoWnaWrx5X7R327w7Fxr19b10Nj/RgAms5e3zGIxjbrOdDxJUg==
X-Received: by 2002:a17:906:2a98:: with SMTP id l24mr52888017eje.150.1560782611948;
        Mon, 17 Jun 2019 07:43:31 -0700 (PDT)
X-Received: by 2002:a17:906:2a98:: with SMTP id l24mr52887945eje.150.1560782610947;
        Mon, 17 Jun 2019 07:43:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560782610; cv=none;
        d=google.com; s=arc-20160816;
        b=p3iXFoXXCqIFT/QKZ5XMdo8bIEMJ6OdUzLB+tpJqq0sY8H44SxEXTy8QV+fSO+pWhZ
         PHCV2818UwaOqVSwoRGAx2s9n7y+qjl8mRAgjQgVtzQbUe7vqe/PuARpHXVbvXTKyqth
         VMuspyV9Zjhu0ZnPThNnPYSgwqnd07BUF0FflaD+nyYoi4PKgWnWA5OeFKBwhD3G8C3b
         Ah0yaYSdwMEBPt93hBS1nmigxwaoBJ+kxLCu0IXLh8leA4nFJ1z5DjqvyYhj+QZ7n/hz
         V5hA+FKR49p+Ss9tUJsjiKMh8Lo5IueSx6dyx105ma+0/KR6JxUSYF1vOwZ7pGGg4ak0
         kj4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=K85gf5017j1tod/NYZbJo+vfUHgdDY1HeypQxTi9sYA=;
        b=qjyxi36xfvWosWZ9x14fxMghPeQMGXGLsFCHWMFWW5/fm/iKwJTT9NEJ6YQC2bOhCl
         E7KFO6Ovaz46UIpdszahX8IzrJpkLolP6eIObL6JjsXJZL9tsNbQPr/yydA5zlKLFnwc
         VIU8Erd0K4miEzl+2TI7DRaPKPPQx/YuFUrS9O3ou7YFGekb99JWEdGxvHxvtfauYMLa
         oMZb4NHMIsP1QLYNfosN+w3qanWy/U8qAcU0szx6aLHgtTACmxveCoAR/Ov3HDRbNdUk
         eOO799A1G/7mFjlOb6olOrHEOeN+9/U8adb21OXKYEl3rkvzo36NJdae5gkP9d7Iu4FA
         yF1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=BMa1YbBS;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f25sor3861047eda.21.2019.06.17.07.43.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 07:43:30 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=BMa1YbBS;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=K85gf5017j1tod/NYZbJo+vfUHgdDY1HeypQxTi9sYA=;
        b=BMa1YbBSgDZIXM5VGNMMjaLcVRuBd8nmxVtuGrW7IqhgsklnG1j7LQIofiTnvktb5X
         NfacqHNulzNxnHiigGO2r01I9bO9Uw07KjzXrcHmcKHnVLBHWVz12qK03OEKgPETFtM/
         qZeh3zfnJMXvL8TpzJvYPvrq6+bNQaDFr5GaSNAady+k36GCwP9s9umv3rESfFaRrXSs
         AZHUKUXsPACxV/PSWo1l0bnvbycO362YFdBmOOajjcyRkvJnnCUNnkMMFLh+LUfUT3X4
         HS4496cjbAsJQlEe5ptZSg5GVUyzRjqxA8H3c66kzLMQvXVIAyCbknPu5pOyIccVONrA
         MLXw==
X-Google-Smtp-Source: APXvYqxKksVboAoCrUSwzJFmTrTy7WjsO2JcHGzrcG9LgKGyqYG50hlU16X0Z1afSPy61Siww01umA==
X-Received: by 2002:aa7:c99a:: with SMTP id c26mr25584741edt.118.1560782610573;
        Mon, 17 Jun 2019 07:43:30 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id q56sm3786536eda.28.2019.06.17.07.43.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 07:43:29 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 043CC100F6D; Mon, 17 Jun 2019 17:43:29 +0300 (+03)
Date: Mon, 17 Jun 2019 17:43:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>, linux-mm@kvack.org,
	kvm@vger.kernel.org, keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH, RFC 18/62] x86/mm: Implement syncing per-KeyID direct
 mappings
Message-ID: <20190617144328.oqwx5rb5yfm2ziws@box>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-19-kirill.shutemov@linux.intel.com>
 <20190614095131.GY3436@hirez.programming.kicks-ass.net>
 <20190614224309.t4ce7lpx577qh2gu@box>
 <20190617092755.GA3419@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617092755.GA3419@hirez.programming.kicks-ass.net>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 11:27:55AM +0200, Peter Zijlstra wrote:
> On Sat, Jun 15, 2019 at 01:43:09AM +0300, Kirill A. Shutemov wrote:
> > On Fri, Jun 14, 2019 at 11:51:32AM +0200, Peter Zijlstra wrote:
> > > On Wed, May 08, 2019 at 05:43:38PM +0300, Kirill A. Shutemov wrote:
> > > > For MKTME we use per-KeyID direct mappings. This allows kernel to have
> > > > access to encrypted memory.
> > > > 
> > > > sync_direct_mapping() sync per-KeyID direct mappings with a canonical
> > > > one -- KeyID-0.
> > > > 
> > > > The function tracks changes in the canonical mapping:
> > > >  - creating or removing chunks of the translation tree;
> > > >  - changes in mapping flags (i.e. protection bits);
> > > >  - splitting huge page mapping into a page table;
> > > >  - replacing page table with a huge page mapping;
> > > > 
> > > > The function need to be called on every change to the direct mapping:
> > > > hotplug, hotremove, changes in permissions bits, etc.
> > > 
> > > And yet I don't see anything in pageattr.c.
> > 
> > You're right. I've hooked up the sync in the wrong place.
> > > 
> > > Also, this seems like an expensive scheme; if you know where the changes
> > > where, a more fine-grained update would be faster.
> > 
> > Do we have any hot enough pageattr users that makes it crucial?
> > 
> > I'll look into this anyway.
> 
> The graphics people would be the most agressive users of this I'd think.
> They're the ones that yelled when I broke it last ;-)

I think something like this should do (I'll fold it in after testing):

diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
index 6c973cb1e64c..b30386d84281 100644
--- a/arch/x86/include/asm/mktme.h
+++ b/arch/x86/include/asm/mktme.h
@@ -68,7 +68,7 @@ static inline void arch_free_page(struct page *page, int order)
 		free_encrypted_page(page, order);
 }
 
-int sync_direct_mapping(void);
+int sync_direct_mapping(unsigned long start, unsigned long end);
 
 int mktme_get_alg(int keyid);
 
@@ -86,7 +86,7 @@ static inline bool mktme_enabled(void)
 
 static inline void mktme_disable(void) {}
 
-static inline int sync_direct_mapping(void)
+static inline int sync_direct_mapping(unsigned long start, unsigned long end)
 {
 	return 0;
 }
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index f50a38d86cc4..f8123aeb24a6 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -761,7 +761,7 @@ __kernel_physical_mapping_init(unsigned long paddr_start,
 		pgd_changed = true;
 	}
 
-	ret = sync_direct_mapping();
+	ret = sync_direct_mapping(vaddr_start, vaddr_end);
 	WARN_ON(ret);
 
 	if (pgd_changed)
@@ -1209,7 +1209,7 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
 	end = (unsigned long)__va(end);
 
 	remove_pagetable(start, end, true, NULL);
-	ret = sync_direct_mapping();
+	ret = sync_direct_mapping(start, end);
 	WARN_ON(ret);
 }
 
@@ -1315,7 +1315,6 @@ void mark_rodata_ro(void)
 	unsigned long text_end = PFN_ALIGN(&__stop___ex_table);
 	unsigned long rodata_end = PFN_ALIGN(&__end_rodata);
 	unsigned long all_end;
-	int ret;
 
 	printk(KERN_INFO "Write protecting the kernel read-only data: %luk\n",
 	       (end - start) >> 10);
@@ -1349,8 +1348,6 @@ void mark_rodata_ro(void)
 	free_kernel_image_pages((void *)text_end, (void *)rodata_start);
 	free_kernel_image_pages((void *)rodata_end, (void *)_sdata);
 
-	ret = sync_direct_mapping();
-	WARN_ON(ret);
 	debug_checkwx();
 }
 
diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 9d2bb534f2ba..c099e1da055b 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -76,7 +76,7 @@ static void init_page_mktme(void)
 {
 	static_branch_enable(&mktme_enabled_key);
 
-	sync_direct_mapping();
+	sync_direct_mapping(PAGE_OFFSET, PAGE_OFFSET + direct_mapping_size);
 }
 
 struct page_ext_operations page_mktme_ops = {
@@ -596,15 +596,13 @@ static int sync_direct_mapping_p4d(unsigned long keyid,
 	return ret;
 }
 
-static int sync_direct_mapping_keyid(unsigned long keyid)
+static int sync_direct_mapping_keyid(unsigned long keyid,
+		unsigned long addr, unsigned long end)
 {
 	pgd_t *src_pgd, *dst_pgd;
-	unsigned long addr, end, next;
+	unsigned long next;
 	int ret = 0;
 
-	addr = PAGE_OFFSET;
-	end = PAGE_OFFSET + direct_mapping_size;
-
 	dst_pgd = pgd_offset_k(addr + keyid * direct_mapping_size);
 	src_pgd = pgd_offset_k(addr);
 
@@ -643,7 +641,7 @@ static int sync_direct_mapping_keyid(unsigned long keyid)
  *
  * The function is nop until MKTME is enabled.
  */
-int sync_direct_mapping(void)
+int sync_direct_mapping(unsigned long start, unsigned long end)
 {
 	int i, ret = 0;
 
@@ -651,7 +649,7 @@ int sync_direct_mapping(void)
 		return 0;
 
 	for (i = 1; !ret && i <= mktme_nr_keyids; i++)
-		ret = sync_direct_mapping_keyid(i);
+		ret = sync_direct_mapping_keyid(i, start, end);
 
 	flush_tlb_all();
 
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 6a9a77a403c9..eafbe0d8c44f 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -347,6 +347,28 @@ static void cpa_flush(struct cpa_data *data, int cache)
 
 	BUG_ON(irqs_disabled() && !early_boot_irqs_disabled);
 
+	if (mktme_enabled()) {
+		unsigned long start, end;
+
+		start = *cpa->vaddr;
+		end = *cpa->vaddr + cpa->numpages * PAGE_SIZE;
+
+		/* Sync all direct mapping for an array */
+		if (cpa->flags & CPA_ARRAY) {
+			start = PAGE_OFFSET;
+			end = PAGE_OFFSET + direct_mapping_size;
+		}
+
+		/*
+		 * Sync per-KeyID direct mappings with the canonical one
+		 * (KeyID-0).
+		 *
+		 * sync_direct_mapping() does full TLB flush.
+		 */
+		sync_direct_mapping(start, end);
+		return;
+	}
+
 	if (cache && !static_cpu_has(X86_FEATURE_CLFLUSH)) {
 		cpa_flush_all(cache);
 		return;
-- 
 Kirill A. Shutemov

