Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AC41C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 22:47:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2148120B1F
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 22:47:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="GtcPmsPK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2148120B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7B5B6B026C; Tue, 28 May 2019 18:47:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2AEB6B0279; Tue, 28 May 2019 18:47:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A44BA6B027C; Tue, 28 May 2019 18:47:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6CE266B026C
	for <linux-mm@kvack.org>; Tue, 28 May 2019 18:47:56 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id g11so333550pfq.7
        for <linux-mm@kvack.org>; Tue, 28 May 2019 15:47:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=MAoBZADCEd0vPKJ49AgS6iE1e+falhQ3CjJBnG9r8fg=;
        b=OibTzQlWBZE1OypdOV9h9iIqSAA95WQcQ5w0xWG9Jcbmx7iVvtgLv/EsdaC0uPWWMp
         3Ecynzeu4yE/XZKtzIAizj8gIZ/6HwQxv3enUbW5KRTz1m0i86I7+7CVRCcjAQtIA34F
         o+CNmRHWTwwJPEqJh6Uy2/PR1IKvDyTY3XLvgNp+tpS65nj4ys8HezCADrzxrnJrDSma
         caPtZGuiU6z78fTzGoU2d9eYiDYGM/jQmd5vfQXyxbSYD1OzfPmS/UsXpM1TxD5nKIiw
         Fpo1nWFSuNLvwBi/9aBaTH8N/1qJvVINaTe+5N0e92d/MyZtDxP3B0QW4tvFQc7ZywR9
         3FuQ==
X-Gm-Message-State: APjAAAVeBzYDcPszl95w0I23sWNDZ34zIObvYSdPgzbu6zYFZUjLeD71
	cQ5rQbcudpGaWyvPtdslyvdlzOyEgtWbGrW4dxwV/1xRE/My08kQ2neYP7MDiI4USWG1lsit69a
	3WVIe9J1/WCB+uZHFxUpism7u6U7hLBxCWG6oGN+Oa/y/sDCbNFPCTgm3GAb5fT9SGg==
X-Received: by 2002:a17:902:522:: with SMTP id 31mr13182463plf.296.1559083676043;
        Tue, 28 May 2019 15:47:56 -0700 (PDT)
X-Received: by 2002:a17:902:522:: with SMTP id 31mr13182430plf.296.1559083675344;
        Tue, 28 May 2019 15:47:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559083675; cv=none;
        d=google.com; s=arc-20160816;
        b=tTNoQKBDZ/91ImXA6+UoRmV+uNTesx9Vg6LbgBpmqmZvhVTDgvSL7EpVpcXJNt+dPu
         ODHcsuvrkgNF1xF3UZ+WNEKujEJjNcV9z/ynJfDzz8EGtRgRmFck73Z2JWyUkWL176O0
         H7+XpwqA1VbI1NcZJTwkznV26S4yb54w6JzeKuKRGZO1Obel6OSry+awOY46rlPydCQ5
         qbP51ciKo+Iz5RaH29UpLesJMkPSK+IROM12W48IQgspW6byOI4wnEVzIdCsPckvoYIT
         VyKFoyrXYydl4TtFNFvTv5yqTGYvcGlHAjKKYDAWoJU75ko0UZuAdXKlSAXYk+m5GzMz
         /Mhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=MAoBZADCEd0vPKJ49AgS6iE1e+falhQ3CjJBnG9r8fg=;
        b=oSovseO8IUndfljc4Ht16+F7Hu2npSL9OI5u6ffbf2e21aPsm5eDHCu/Vs1Ojwm2O3
         9DQyvh9anVxeqwa3Mgcs6yDZu86nJ/nmKThwylBJ+YVRUnMn6vO8ZavKeEjZc7TemrvL
         PnPwLo8u8J1LarhfS8izqZn8JbWbloxdX9KFgKTcmQp3+Bxv2cHbKnIl4RTsXJWYxdEr
         cGAxuMw5UAWhjH/zAKLHxoZ+km6Ck+ps4I4xJbA1QpwFZ/J0TCqRcUsIECf9X4PR0jnK
         zxCv8TJjeUPDJsVo8H7UtZaEpnNjgbIviyvzDms6uCD5v29cZGzWCiK3uU23eec19R45
         xPrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=GtcPmsPK;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o32sor4915640pje.9.2019.05.28.15.47.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 15:47:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=GtcPmsPK;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=MAoBZADCEd0vPKJ49AgS6iE1e+falhQ3CjJBnG9r8fg=;
        b=GtcPmsPKw91P6kvxeDWttl7qxUivQqZl/WB5Gh5hZdnm+5yIO2uZ2t/OSX0OmzEOCy
         sF29tnbeJ8Wm4VkzDktqcRMz5/Pr407jXYYeK2nL1WUL/rdyKRFJ5Lb8dgxEMFjnUV1P
         eERSQVTPegq8oQgSLIS8R6qnR18reixRSXg4k=
X-Google-Smtp-Source: APXvYqw3mv+G541iuDOvP4AUa0q98ok84G11/maYW6QsZbQDV/zVxM/YOwu8VcFjLQuOGKLVHdTGXw==
X-Received: by 2002:a17:90a:b00b:: with SMTP id x11mr8607798pjq.61.1559083674993;
        Tue, 28 May 2019 15:47:54 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id d4sm3450567pju.19.2019.05.28.15.47.53
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 15:47:54 -0700 (PDT)
Date: Tue, 28 May 2019 15:47:52 -0700
From: Kees Cook <keescook@chromium.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Randy Dunlap <rdunlap@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>, Linux MM <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: lib/test_overflow.c causes WARNING and tainted kernel
Message-ID: <201905281518.756178E7@keescook>
References: <9fa84db9-084b-cf7f-6c13-06131efb0cfa@infradead.org>
 <CAGXu5j+yRt_yf2CwvaZDUiEUMwTRRiWab6aeStxqodx9i+BR4g@mail.gmail.com>
 <e2646ac0-c194-4397-c021-a64fa2935388@infradead.org>
 <97c4b023-06fe-2ec3-86c4-bfdb5505bf6d@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <97c4b023-06fe-2ec3-86c4-bfdb5505bf6d@rasmusvillemoes.dk>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 09:53:33AM +0200, Rasmus Villemoes wrote:
> On 25/05/2019 17.33, Randy Dunlap wrote:
> > On 3/13/19 7:53 PM, Kees Cook wrote:
> >> Hi!
> >>
> >> On Wed, Mar 13, 2019 at 2:29 PM Randy Dunlap <rdunlap@infradead.org> wrote:
> >>>
> >>> This is v5.0-11053-gebc551f2b8f9, MAR-12 around 4:00pm PT.
> >>>
> >>> In the first test_kmalloc() in test_overflow_allocation():
> >>>
> >>> [54375.073895] test_overflow: ok: (s64)(0 << 63) == 0
> >>> [54375.074228] WARNING: CPU: 2 PID: 5462 at ../mm/page_alloc.c:4584 __alloc_pages_nodemask+0x33f/0x540
> >>> [...]
> >>> [54375.079236] ---[ end trace 754acb68d8d1a1cb ]---
> >>> [54375.079313] test_overflow: kmalloc detected saturation
> >>
> >> Yup! This is expected and operating as intended: it is exercising the
> >> allocator's detection of insane allocation sizes. :)
> >>
> >> If we want to make it less noisy, perhaps we could add a global flag
> >> the allocators could check before doing their WARNs?
> >>
> >> -Kees
> > 
> > I didn't like that global flag idea.  I also don't like the kernel becoming
> > tainted by this test.
> 
> Me neither. Can't we pass __GFP_NOWARN from the testcases, perhaps with
> a module parameter to opt-in to not pass that flag? That way one can
> make the overflow module built-in (and thus run at boot) without
> automatically tainting the kernel.
> 
> The vmalloc cases do not take gfp_t, would they still cause a warning?

They still warn, but they don't seem to taint. I.e. this patch:

diff --git a/lib/test_overflow.c b/lib/test_overflow.c
index fc680562d8b6..c922f0d86181 100644
--- a/lib/test_overflow.c
+++ b/lib/test_overflow.c
@@ -486,11 +486,12 @@ static int __init test_overflow_shift(void)
  * Deal with the various forms of allocator arguments. See comments above
  * the DEFINE_TEST_ALLOC() instances for mapping of the "bits".
  */
-#define alloc010(alloc, arg, sz) alloc(sz, GFP_KERNEL)
-#define alloc011(alloc, arg, sz) alloc(sz, GFP_KERNEL, NUMA_NO_NODE)
+#define alloc_GFP	(GFP_KERNEL | __GFP_NOWARN)
+#define alloc010(alloc, arg, sz) alloc(sz, alloc_GFP)
+#define alloc011(alloc, arg, sz) alloc(sz, alloc_GFP, NUMA_NO_NODE)
 #define alloc000(alloc, arg, sz) alloc(sz)
 #define alloc001(alloc, arg, sz) alloc(sz, NUMA_NO_NODE)
-#define alloc110(alloc, arg, sz) alloc(arg, sz, GFP_KERNEL)
+#define alloc110(alloc, arg, sz) alloc(arg, sz, alloc_GFP | __GFP_NOWARN)
 #define free0(free, arg, ptr)	 free(ptr)
 #define free1(free, arg, ptr)	 free(arg, ptr)
 
will remove the tainting behavior but is still a bit "noisy". I can't
find a way to pass __GFP_NOWARN to a vmalloc-based allocation, though.

Randy, is removing taint sufficient for you?

> BTW, I noticed that the 'wrap to 8K' depends on 64 bit and
> pagesize==4096; for 32 bit the result is 20K, while if the pagesize is
> 64K one gets 128K and 512K for 32/64 bit size_t, respectively. Don't
> know if that's a problem, but it's easy enough to make it independent of
> pagesize (just make it 9*4096 explicitly), and if we use 5 instead of 9
> it also becomes independent of sizeof(size_t) (wrapping to 16K).

Ah! Yes, all excellent points. I've adjusted that too now. I'll send
the result to Andrew.

Thanks!

-- 
Kees Cook

