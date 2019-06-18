Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FA60C31E5D
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 18:55:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE61D206BA
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 18:55:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="PCSfTOPJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE61D206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BF5C6B0003; Tue, 18 Jun 2019 14:55:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46FBA8E0002; Tue, 18 Jun 2019 14:55:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3371E8E0001; Tue, 18 Jun 2019 14:55:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 11CDA6B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 14:55:58 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g30so13303168qtm.17
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 11:55:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=hXnlrwSMDb2KXQ2kUpfowsfYiMjlQHuh1AdwWvUKWgU=;
        b=LfhGNUeVxZZVeIAGwreDx4y2lAmeB99OquBjw5rn3m2Cb1OMATdWJHneFIGk5kMmXS
         x+SFv3aP7uMhYEPCSZhuS7UCV39VvNHA+GP9DDlvPC2OT3t4saRTzT3EUOc9S+aeJs/N
         zjpthVsVMtnLGpfRDV9p7t3mjxWwd6MU5pgp5023yJKj65LCgloIuvr6hLN71GDT983g
         Q/YhdjI+XV2Qdlt2JbKGS5vMHm2RIM7mXoIKn0Yn30PQlqcPdhNrXJYobiRx4i8m1/tV
         4ekancS2jAYizmnPcBRhyFdZcnsGdH++THAR9qXI+shLmXRcSO9+rWfrCkPRa1SiU0Nl
         avmQ==
X-Gm-Message-State: APjAAAWFS6a81nlsZMFGmpMKQ4CGEnesJOtFtIsUDmG1yiZwOYSHIN0Q
	x83iuXEI8oYBF/vX4e5VsZVTP/gSYC9rstlWexhEOhtOic5L9ExxW2OtA3kijf2lridBgAqYmZw
	XPc/Mnm9cA5XPV6ZlVZTXa6qXbWVOl3vSAPqJGxZeuDsmEgM5jHfGgb3xTItfiDKA1A==
X-Received: by 2002:a37:6b87:: with SMTP id g129mr86304165qkc.305.1560884157786;
        Tue, 18 Jun 2019 11:55:57 -0700 (PDT)
X-Received: by 2002:a37:6b87:: with SMTP id g129mr86304128qkc.305.1560884157030;
        Tue, 18 Jun 2019 11:55:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560884157; cv=none;
        d=google.com; s=arc-20160816;
        b=o8naFPiY51pYePVzpcZvGNEfajup2216K+r+ER26/ui+Zi6bo2zHLFRVDKXSHtvPEU
         UlMHXvtWnOm7UeUjHNnebHt3BdhQ0dXNpUemyry0tikVaOpo33gQ/J0ug9gZldZs7Czg
         uzF9il9SczqvjOR9X9frs3/lRMw8ZifGYnL+18nY1YiNypQM1RwrlMKgHILpW34/I6gK
         x6x0tPYXZNxG2RD16HAubI2WRJ0FA8LTZZQXXd1BJN46iTc5v/Us6aLymc+6NDwM9U8o
         3v4uLcZH3Cd/a93fd8xoFDFgRK+etvbEMic/GuRkwjWtRV+e26mSQ/ON7GsODPj1m0LU
         IkTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=hXnlrwSMDb2KXQ2kUpfowsfYiMjlQHuh1AdwWvUKWgU=;
        b=yFSilUUSXsr1fgARcnFlOE0VvkyLyJbolbDHc9e3XpA24c8UDEaTXS6xBMZkxjdxWF
         65bdM5DgMo+yY5jdVGZP0pw2T+WPNLKG3e+9ir1TldpGqDBGV6GHllhFULgt9CTNJ/VX
         DHl7IABWZ00WSbL0vS2lzl6s4D2O44fDDdrL1A4Vp4YSthCVupBhokUBGJuZ/gkXoUHB
         WhlIipAbb/ogqVXz1WdwB5WqRKXTgEHINUlqQMpycn9R2ayf4n74LfNipgg72jxbwqel
         wenLp84qK3FpeV0X/DYXMwXlccrN++IXeVBUsXfSNxAYBLpve2M9Cda3vdOKhmbekMj+
         ow8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=PCSfTOPJ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k12sor9611198qkg.11.2019.06.18.11.55.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 11:55:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=PCSfTOPJ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=hXnlrwSMDb2KXQ2kUpfowsfYiMjlQHuh1AdwWvUKWgU=;
        b=PCSfTOPJhKvREdZ5xmkF2xPmb8AA5MtPK22PwiRyTbCbI9n4CnJdW/qq3WiSMdiUy4
         6Z/IIW8iNAiO52TupOZYX1bP0ZYvZA2VvIVMD7rhz9DB6xzcL8VhPuHnFJVM+LqaVDy4
         eoh4ivskUQESpEUflxImNhbiMcEzVAwMLSOzW1JZcP/LFSLq2bKsmf5Xe1tMeaMO9a8j
         1awvPochrqqHFzLHQiREBjty59bhtgqM1Hx8EpZVefBLXue+iue6tkPzV3aLPoAa9K/4
         eAlHpkRxnJvQyiQsJsHvbnZ1QoFRrPmfZsAnJSukHSDtbHZzYFbrauhu8anr3n5RV2Tu
         ajGw==
X-Google-Smtp-Source: APXvYqyd+i6cTg2Tugb4a/2Cz8C0TtEUZL3kmahVSIFwk8sIJzOkIjm/6TLS4YnWGmfBfWmeHHI2Cw==
X-Received: by 2002:a37:680e:: with SMTP id d14mr853394qkc.287.1560884156517;
        Tue, 18 Jun 2019 11:55:56 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id 6sm7888729qkk.69.2019.06.18.11.55.56
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jun 2019 11:55:56 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hdJGt-000090-Km; Tue, 18 Jun 2019 15:55:55 -0300
Date: Tue, 18 Jun 2019 15:55:55 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	Philip Yang <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 04/12] mm/hmm: Simplify hmm_get_or_create and make
 it reliable
Message-ID: <20190618185555.GO6961@ziepe.ca>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-5-jgg@ziepe.ca>
 <20190615141211.GD17724@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190615141211.GD17724@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 15, 2019 at 07:12:11AM -0700, Christoph Hellwig wrote:
> > +	spin_lock(&mm->page_table_lock);
> > +	if (mm->hmm) {
> > +		if (kref_get_unless_zero(&mm->hmm->kref)) {
> > +			spin_unlock(&mm->page_table_lock);
> > +			return mm->hmm;
> > +		}
> > +	}
> > +	spin_unlock(&mm->page_table_lock);
> 
> This could become:
> 
> 	spin_lock(&mm->page_table_lock);
> 	hmm = mm->hmm
> 	if (hmm && kref_get_unless_zero(&hmm->kref))
> 		goto out_unlock;
> 	spin_unlock(&mm->page_table_lock);
> 
> as the last two lines of the function already drop the page_table_lock
> and then return hmm.  Or drop the "hmm = mm->hmm" asignment above and
> return mm->hmm as that should be always identical to hmm at the end
> to save another line.
> 
> > +	/*
> > +	 * The mm->hmm pointer is kept valid while notifier ops can be running
> > +	 * so they don't have to deal with a NULL mm->hmm value
> > +	 */
> 
> The comment confuses me.  How does the page_table_lock relate to
> possibly running notifiers, as I can't find that we take
> page_table_lock?  Or is it just about the fact that we only clear
> mm->hmm in the free callback, and not in hmm_free?

Revised with:

From bdc02a1d502db08457823e6b2b983861a3574a76 Mon Sep 17 00:00:00 2001
From: Jason Gunthorpe <jgg@mellanox.com>
Date: Thu, 23 May 2019 10:24:13 -0300
Subject: [PATCH] mm/hmm: Simplify hmm_get_or_create and make it reliable

As coded this function can false-fail in various racy situations. Make it
reliable and simpler by running under the write side of the mmap_sem and
avoiding the false-failing compare/exchange pattern. Due to the mmap_sem
this no longer has to avoid racing with a 2nd parallel
hmm_get_or_create().

Unfortunately this still has to use the page_table_lock as the
non-sleeping lock protecting mm->hmm, since the contexts where we free the
hmm are incompatible with mmap_sem.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Tested-by: Philip Yang <Philip.Yang@amd.com>
---
v2:
- Fix error unwind of mmgrab (Jerome)
- Use hmm local instead of 2nd container_of (Jerome)
v3:
- Can't use mmap_sem in the SRCU callback, keep using the
  page_table_lock (Philip)
v4:
- Put the mm->hmm = NULL in the kref release, reduce LOC
  in hmm_get_or_create() (Christoph)
---
 mm/hmm.c | 77 ++++++++++++++++++++++----------------------------------
 1 file changed, 30 insertions(+), 47 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 080b17a2e87e2d..0423f4ca3a7e09 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -31,16 +31,6 @@
 #if IS_ENABLED(CONFIG_HMM_MIRROR)
 static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
 
-static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
-{
-	struct hmm *hmm = READ_ONCE(mm->hmm);
-
-	if (hmm && kref_get_unless_zero(&hmm->kref))
-		return hmm;
-
-	return NULL;
-}
-
 /**
  * hmm_get_or_create - register HMM against an mm (HMM internal)
  *
@@ -55,11 +45,16 @@ static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
  */
 static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 {
-	struct hmm *hmm = mm_get_hmm(mm);
-	bool cleanup = false;
+	struct hmm *hmm;
+
+	lockdep_assert_held_exclusive(&mm->mmap_sem);
 
-	if (hmm)
-		return hmm;
+	/* Abuse the page_table_lock to also protect mm->hmm. */
+	spin_lock(&mm->page_table_lock);
+	hmm = mm->hmm;
+	if (mm->hmm && kref_get_unless_zero(&mm->hmm->kref))
+		goto out_unlock;
+	spin_unlock(&mm->page_table_lock);
 
 	hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
 	if (!hmm)
@@ -74,57 +69,45 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	hmm->notifiers = 0;
 	hmm->dead = false;
 	hmm->mm = mm;
-	mmgrab(hmm->mm);
 
-	spin_lock(&mm->page_table_lock);
-	if (!mm->hmm)
-		mm->hmm = hmm;
-	else
-		cleanup = true;
-	spin_unlock(&mm->page_table_lock);
+	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
+	if (__mmu_notifier_register(&hmm->mmu_notifier, mm)) {
+		kfree(hmm);
+		return NULL;
+	}
 
-	if (cleanup)
-		goto error;
+	mmgrab(hmm->mm);
 
 	/*
-	 * We should only get here if hold the mmap_sem in write mode ie on
-	 * registration of first mirror through hmm_mirror_register()
+	 * We hold the exclusive mmap_sem here so we know that mm->hmm is
+	 * still NULL or 0 kref, and is safe to update.
 	 */
-	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
-	if (__mmu_notifier_register(&hmm->mmu_notifier, mm))
-		goto error_mm;
-
-	return hmm;
-
-error_mm:
 	spin_lock(&mm->page_table_lock);
-	if (mm->hmm == hmm)
-		mm->hmm = NULL;
+	mm->hmm = hmm;
+
+out_unlock:
 	spin_unlock(&mm->page_table_lock);
-error:
-	mmdrop(hmm->mm);
-	kfree(hmm);
-	return NULL;
+	return hmm;
 }
 
 static void hmm_free_rcu(struct rcu_head *rcu)
 {
-	kfree(container_of(rcu, struct hmm, rcu));
+	struct hmm *hmm = container_of(rcu, struct hmm, rcu);
+
+	mmdrop(hmm->mm);
+	kfree(hmm);
 }
 
 static void hmm_free(struct kref *kref)
 {
 	struct hmm *hmm = container_of(kref, struct hmm, kref);
-	struct mm_struct *mm = hmm->mm;
 
-	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);
+	spin_lock(&hmm->mm->page_table_lock);
+	if (hmm->mm->hmm == hmm)
+		hmm->mm->hmm = NULL;
+	spin_unlock(&hmm->mm->page_table_lock);
 
-	spin_lock(&mm->page_table_lock);
-	if (mm->hmm == hmm)
-		mm->hmm = NULL;
-	spin_unlock(&mm->page_table_lock);
-
-	mmdrop(hmm->mm);
+	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, hmm->mm);
 	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);
 }
 
-- 
2.21.0

