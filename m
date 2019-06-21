Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98421C48BE0
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:28:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 613482089E
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:28:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="gHewrOsG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 613482089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EFE7A8E0005; Fri, 21 Jun 2019 10:28:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EAEA38E0001; Fri, 21 Jun 2019 10:28:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC4048E0005; Fri, 21 Jun 2019 10:28:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id BAF558E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 10:28:26 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id d26so8028306qte.19
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 07:28:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QN9JaLjC+aXpYQwYy0rUybeOk/75jD5iu87wcqgiv+A=;
        b=p5NRbTEARUEpH7vtRTx73I9YhNtjYoUAYVWodowLgOFogSr7ItlA3CBtDLVGYuMom2
         L0BtOhDJTS8XasEqVVK9TTIVBDZOg+wpmgp3BWCksafSVs/cs9Ou6OTrAd2Mc9+Z9Whw
         u1Gc0AEdxse4wZD0yT9bp2nIXvF9IrZE21jAmnHumWt2Ppy5LdY++zfu+9Q/ACVHJozy
         1lrYa0R3sqUQvdQANT/kXMBg2NKOHP9RFgUmS7zKbAhlkexX1gX3flGkc6fBFX7IpQ+e
         IGYWG4FYs9R/CSJ7X9cT1ieYmx849bWcyXGOs3sDq60N/4mNR+s6YLKlwE5ID95/RtWs
         JBMg==
X-Gm-Message-State: APjAAAXRR4bzDb6eHsktQh7zG+GC0nlr7h5y/JKVQvlON/vRI1f7Rlxa
	i1S1jJmtgCmeFSeProh1RxJ7RrIACjFKZv9TQ+KuPtvk7Wk53v75lVurW+RGFE5w/X9HPQEX72J
	mO/BB0NJW/Bvc5LVfQSc/rZdofdjzC7revOiOvUipd+Q82MObRMCdvsnvt7nlDSm8Iw==
X-Received: by 2002:a0c:b758:: with SMTP id q24mr45020228qve.45.1561127306505;
        Fri, 21 Jun 2019 07:28:26 -0700 (PDT)
X-Received: by 2002:a0c:b758:: with SMTP id q24mr45020172qve.45.1561127305810;
        Fri, 21 Jun 2019 07:28:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561127305; cv=none;
        d=google.com; s=arc-20160816;
        b=dOz/RS8VVL9smqKs9gObODkF3zf4mOHATXehJcY6pjGxDHXD+hQFjLZyznFY5KIWw/
         ldyVxEOaGohtoshLn0NIRIn7/kC4EoDRRAvCgNIDPRWcPKErcG35UlHIFRrPjYsOhGhK
         al5CkET7aQu1PAqqkfVXyejyWsSps5qY0h/n2FR9eLpbPnchDs/u9+RORWVzLV/1XNJ9
         IfpAy0QQtPC3DZfnsq9pcecabhJrNbFOeb8L06q3HAPFA+OJf00A4kdrkF+mWQpdViOX
         BIdTFpy+XrW6uupx0lGo+zDSQz5qCC3F7m3hlofaFz/+zxDZI5AXcOIMXGs8+GtQ9qAe
         WLRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QN9JaLjC+aXpYQwYy0rUybeOk/75jD5iu87wcqgiv+A=;
        b=p2eOjXZ/DoXvgEonlRjeSRvjAGjxp9SBNtfFaTNYJVk9lP5rFjOEcwvHWE8jMXjGCa
         puEZ2jfELSLWm3ZKrS2wWqdz0pgucPuDFnkLaDSzzfOqVCAl/BziNtn+z0NCAYGntKtw
         xGwW0LRmmdSR7w/AgF6LiMyRCbl75yKrAsmtuORR1Ilf3h5shHkEXrVGxa2lkyEQd0wT
         FoenHtQ6xd1utd0of0QdTRvA/t76vZD7Lq5dao07Pmnnkd96EwRxCkXLgbdPxWnWds7Q
         nQY8+NkeSiSPG/olpeRAz9SoaqT1YSYUaey/QbvN+io68C+VzOlnW6iLhaXoGeKgXMNV
         0tyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=gHewrOsG;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u207sor1596817qka.127.2019.06.21.07.28.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 07:28:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=gHewrOsG;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QN9JaLjC+aXpYQwYy0rUybeOk/75jD5iu87wcqgiv+A=;
        b=gHewrOsGYjfruRd4d1g7uEoXFq0aPB7SLlglrbzK6BXTkmLdPbiazxpOboA2jm7wrI
         b8d8+E6FX9OR7u+IFNEKrAnJnOqu/5F1VZLUMNCMCU+wgS6y2EkbpkHsbU8+r3JHZVql
         PIegARKFvfPWOqpFRbR76bztPULQ83Vuao8w4HpYbgS5VaeHCUZ/9LZHChOTJFGspzyL
         atunFnhPQ2nD+493uKquWuaHkbcR/Qbt9BLiGb7yOcsFbUDnB07oOdzvU9IpHgGWj6ES
         glaSilKeeyF/aLMWsYWTQY3pAMonUdx/dUq0pDX6f1CXEmbwIgHnehnriMkvZWZLQO1T
         0B5Q==
X-Google-Smtp-Source: APXvYqydWDme2tP2dVS/BqtEvh4YdCf0/vXc8OQrQ6NRAaTCyw2Eaq6p7IUxO9RX+s8DYAJPYZ5q+A==
X-Received: by 2002:a05:620a:1107:: with SMTP id o7mr77780538qkk.324.1561127305462;
        Fri, 21 Jun 2019 07:28:25 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id y14sm1370164qkb.109.2019.06.21.07.28.24
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Jun 2019 07:28:24 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1heKWe-0000lt-CN; Fri, 21 Jun 2019 11:28:24 -0300
Date: Fri, 21 Jun 2019 11:28:24 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 10/16] mm: rename CONFIG_HAVE_GENERIC_GUP to
 CONFIG_HAVE_FAST_GUP
Message-ID: <20190621142824.GP19891@ziepe.ca>
References: <20190611144102.8848-1-hch@lst.de>
 <20190611144102.8848-11-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190611144102.8848-11-hch@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 04:40:56PM +0200, Christoph Hellwig wrote:
> We only support the generic GUP now, so rename the config option to
> be more clear, and always use the mm/Kconfig definition of the
> symbol and select it from the arch Kconfigs.

Looks OK to me

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

But could you also roll something like this in to the series? There is
no longer any reason for the special __weak stuff that I can see -
just follow the normal pattern for stubbing config controlled
functions through the header file.

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b76c..13b1cb573383d5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1561,8 +1561,17 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 		    struct page **pages, unsigned int gup_flags);
 
+#ifdef CONFIG_HAVE_FAST_GUP
 int get_user_pages_fast(unsigned long start, int nr_pages,
 			unsigned int gup_flags, struct page **pages);
+#else
+static inline int get_user_pages_fast(unsigned long start, int nr_pages,
+				      unsigned int gup_flags,
+				      struct page **pages)
+{
+	return get_user_pages_unlocked(start, nr_pages, pages, gup_flags);
+}
+#endif
 
 /* Container for pinned pfns / pages */
 struct frame_vector {
@@ -1668,8 +1677,17 @@ extern int mprotect_fixup(struct vm_area_struct *vma,
 /*
  * doesn't attempt to fault and will return short.
  */
+#ifdef CONFIG_HAVE_FAST_GUP
 int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			  struct page **pages);
+#else
+static inline int __get_user_pages_fast(unsigned long start, int nr_pages,
+					int write, struct page **pages)
+{
+	return 0;
+}
+#endif
+
 /*
  * per-process(per-mm_struct) statistics.
  */
diff --git a/mm/util.c b/mm/util.c
index 9834c4ab7d8e86..68575a315dc5ad 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -300,53 +300,6 @@ void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 }
 #endif
 
-/*
- * Like get_user_pages_fast() except its IRQ-safe in that it won't fall
- * back to the regular GUP.
- * Note a difference with get_user_pages_fast: this always returns the
- * number of pages pinned, 0 if no pages were pinned.
- * If the architecture does not support this function, simply return with no
- * pages pinned.
- */
-int __weak __get_user_pages_fast(unsigned long start,
-				 int nr_pages, int write, struct page **pages)
-{
-	return 0;
-}
-EXPORT_SYMBOL_GPL(__get_user_pages_fast);
-
-/**
- * get_user_pages_fast() - pin user pages in memory
- * @start:	starting user address
- * @nr_pages:	number of pages from start to pin
- * @gup_flags:	flags modifying pin behaviour
- * @pages:	array that receives pointers to the pages pinned.
- *		Should be at least nr_pages long.
- *
- * get_user_pages_fast provides equivalent functionality to get_user_pages,
- * operating on current and current->mm, with force=0 and vma=NULL. However
- * unlike get_user_pages, it must be called without mmap_sem held.
- *
- * get_user_pages_fast may take mmap_sem and page table locks, so no
- * assumptions can be made about lack of locking. get_user_pages_fast is to be
- * implemented in a way that is advantageous (vs get_user_pages()) when the
- * user memory area is already faulted in and present in ptes. However if the
- * pages have to be faulted in, it may turn out to be slightly slower so
- * callers need to carefully consider what to use. On many architectures,
- * get_user_pages_fast simply falls back to get_user_pages.
- *
- * Return: number of pages pinned. This may be fewer than the number
- * requested. If nr_pages is 0 or negative, returns 0. If no pages
- * were pinned, returns -errno.
- */
-int __weak get_user_pages_fast(unsigned long start,
-				int nr_pages, unsigned int gup_flags,
-				struct page **pages)
-{
-	return get_user_pages_unlocked(start, nr_pages, pages, gup_flags);
-}
-EXPORT_SYMBOL_GPL(get_user_pages_fast);
-
 unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
 	unsigned long flag, unsigned long pgoff)

