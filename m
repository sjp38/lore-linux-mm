Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 083F2C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 08:25:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A77EA20674
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 08:25:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JXVqyc+r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A77EA20674
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 237686B0003; Tue, 23 Apr 2019 04:25:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20E9C6B0006; Tue, 23 Apr 2019 04:25:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 124D36B0007; Tue, 23 Apr 2019 04:25:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id E78726B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 04:25:07 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id 79so14906314itz.3
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 01:25:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=486psj+sENvabR+BWnaVeA+iic8CMCHnGgf5S4MT6mU=;
        b=j+2CkLkSRrpXYCf2KMBDuEU2HXWwF1HJbVo/44Q0oAecr0sUO6kDvuiSTZv/hETVce
         nSXq0A+GcTQd202Keg1wVW3GTA3EXOdj10bRo7IzQHvXj5Nh/ZOD1cBOppN9w7yp1qKe
         dtpMHVl/Q72N3XkYl+KvSMuTXCEKBiT262CzRFgcHggqlZKd0ppiL7BnahUWYiCtUc4f
         v9W2K9vbyaK85f2UTbXPjWkCd+3s4yD5CBBV25XB9BYoYxfgbk6bUy6GqNxiVssLuSjN
         wX2fcMORZsGUmjdm74x97vnA0IowsYe4mikkwYbiujngzmJEQkVrCDUiaw3jqCoXzHLW
         BIWA==
X-Gm-Message-State: APjAAAWqD/+uHDWAb3sKuShTJzAsgE6yjUH5pni6L6BL5pFfTONIThci
	zvuqOx/8/oAkDSMMmknglEpR0nSqC9PZ8CPl4oBlMImA3lr3KA9iJkyfjxdJ1Y9WpG55k9/CS8e
	kOQV/UYp5EIKr8CW00sS5ySm+1eaysoQDWfjAIydQSITY4q1wMmOUL6Uzc/IzZFnEkA==
X-Received: by 2002:a24:ac45:: with SMTP id m5mr1200714iti.28.1556007907645;
        Tue, 23 Apr 2019 01:25:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVAVApsaL/j49iK6Dxopw1Ngf6CYm1BtEwMwMrXwbNTSBFlLxDjl/gChJtRERsYXKjQ+Lq
X-Received: by 2002:a24:ac45:: with SMTP id m5mr1200686iti.28.1556007906833;
        Tue, 23 Apr 2019 01:25:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556007906; cv=none;
        d=google.com; s=arc-20160816;
        b=fhcISNj/JezId2SdLGLwCS9c/ced3MIyA6ypXFOej1ruhw2nDNjKChoI+Dm4m+njmO
         C7cfeNRy7yPXm0DuJAIlb8Tvj8uiqbu4HplTn00VsX52+ED0pD8aAql+ZzkJhDwJJFBQ
         TOjH1ZRN8l3dVA/Wu6OO02SQnIBZcK0/vg6fCzF6wfPyo4qmdMIR7+uPlA2h/Ub6/qe0
         D32yf7Aemzi1vHkbkL/7tIo3cRSSWJDu1afUQ4FAbjqoxHT7Z9xN7XNAYIJHe4us35Qt
         ZZVnpdd1URWCK6oKV2WL8Bg0JaIbo7Qq5LKw6aMX+XDYMY2xdj0AkNlLmaAWbFzaMrmY
         vQdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=486psj+sENvabR+BWnaVeA+iic8CMCHnGgf5S4MT6mU=;
        b=pYCfeIPvzlaFKEHqz2LTyn26RQSYdoydDMbg7SebCOEDi1xFiDmWt9ZkVAaiJx4G/9
         5dN8JDfxMvG5dBgjaNx7qGJdhTnLHpW1Fs5SUA7+GUOEtvNRK8bWmChH1QElpdYcK91g
         IfwnzjK3zQbm2G2imSDKILwKEzuQOTFmKH/iBbA2AzNHzCXo3N8Z9SDt/kagyssBV1g3
         mGgRtCvYggENuWddrrsTdIoSDE1OZHcPMv12Xj9a5JVqCthkKzOQ0F1Yq4/CAtjbeZwd
         ZpAZUAjZq0zdeRxYNnWXGtFGatinn2M3RShPv3peFThi9By7ZJPWKH7E7jreVlhTKUp6
         Resg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=JXVqyc+r;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id u138si9775625ita.49.2019.04.23.01.25.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 01:25:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=JXVqyc+r;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=486psj+sENvabR+BWnaVeA+iic8CMCHnGgf5S4MT6mU=; b=JXVqyc+rvPckzr3h4llI1qg+T
	axl1zJwMs8J7iWwe3fPjVKfxETdgGT6x3PD5h5IQO2DaNYsDRrSRB3JPYpRMqeRjxhrwlDbP6NLLa
	d9Gv+ipg04uE7doZGtfZCeO9ePt6iuHP9gf5FY1AJ9UNrO5RmSaDE1j4yPzTLG+zusm0cUv4Ecm+V
	X3l748BCsX2VW1nSetCSxcUIFkJvaP0TiOhaVkwJRclhVxGYiyITTXpC0jguuvedt2TeIzuWJC+/5
	pnNDaXXkM9fTcK6ha11moWgE7p1En0ThQu8e/4nAokdj469bkOVaGQvRwLWE6bYmH5prcy8ZMfrIm
	+7UJb5GMQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIqjU-0000vO-0J; Tue, 23 Apr 2019 08:24:52 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id DDBC129B47DC4; Tue, 23 Apr 2019 10:24:48 +0200 (CEST)
Date: Tue, 23 Apr 2019 10:24:48 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, broonie@kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
	mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
	Josh Poimboeuf <jpoimboe@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@kernel.org>
Subject: Re: mmotm 2019-04-19-14-53 uploaded (objtool)
Message-ID: <20190423082448.GY11158@hirez.programming.kicks-ass.net>
References: <20190419215358.WMVFXV3bT%akpm@linux-foundation.org>
 <af3819b4-008f-171e-e721-a9a20f85d8d1@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <af3819b4-008f-171e-e721-a9a20f85d8d1@infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 19, 2019 at 09:36:46PM -0700, Randy Dunlap wrote:
> On 4/19/19 2:53 PM, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2019-04-19-14-53 has been uploaded to
> > 
> >    http://www.ozlabs.org/~akpm/mmotm/
> > 
> > mmotm-readme.txt says
> > 
> > README for mm-of-the-moment:
> > 
> > http://www.ozlabs.org/~akpm/mmotm/
> > 
> > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > more than once a week.
> 
> on x86_64:
> 
>   CC      lib/strncpy_from_user.o
> lib/strncpy_from_user.o: warning: objtool: strncpy_from_user()+0x315: call to __ubsan_handle_add_overflow() with UACCESS enabled
>   CC      lib/strnlen_user.o
> lib/strnlen_user.o: warning: objtool: strnlen_user()+0x337: call to __ubsan_handle_sub_overflow() with UACCESS enabled

Lemme guess, you're using GCC < 8 ? That had a bug where UBSAN
considered signed overflow UB when using -fno-strict-overflow or
-fwrapv.

Now, we could of course allow this symbol, but I found only the below
was required to make allyesconfig build without issue.

Andy, Linus?

(note: the __put_user thing is from this one:

  drivers/gpu/drm/i915/i915_gem_execbuffer.c:	if (unlikely(__put_user(offset, &urelocs[r-stack].presumed_offset))) {

 where (ptr) ends up non-trivial due to UBSAN)

---

diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
index 22ba683afdc2..c82abd6e4ca3 100644
--- a/arch/x86/include/asm/uaccess.h
+++ b/arch/x86/include/asm/uaccess.h
@@ -427,10 +427,11 @@ do {									\
 ({								\
 	__label__ __pu_label;					\
 	int __pu_err = -EFAULT;					\
-	__typeof__(*(ptr)) __pu_val;				\
-	__pu_val = x;						\
+	__typeof__(*(ptr)) __pu_val = (x);			\
+	__typeof__(ptr) __pu_ptr = (ptr);			\
+	__typeof__(size) __pu_size = (size);			\
 	__uaccess_begin();					\
-	__put_user_size(__pu_val, (ptr), (size), __pu_label);	\
+	__put_user_size(__pu_val, __pu_ptr, __pu_size, __pu_label);	\
 	__pu_err = 0;						\
 __pu_label:							\
 	__uaccess_end();					\
diff --git a/lib/strncpy_from_user.c b/lib/strncpy_from_user.c
index 58eacd41526c..07045bc4872e 100644
--- a/lib/strncpy_from_user.c
+++ b/lib/strncpy_from_user.c
@@ -26,7 +26,7 @@
 static inline long do_strncpy_from_user(char *dst, const char __user *src, long count, unsigned long max)
 {
 	const struct word_at_a_time constants = WORD_AT_A_TIME_CONSTANTS;
-	long res = 0;
+	unsigned long res = 0;
 
 	/*
 	 * Truncate 'max' to the user-specified limit, so that
diff --git a/lib/strnlen_user.c b/lib/strnlen_user.c
index 1c1a1b0e38a5..0729378ad3e9 100644
--- a/lib/strnlen_user.c
+++ b/lib/strnlen_user.c
@@ -28,7 +28,7 @@
 static inline long do_strnlen_user(const char __user *src, unsigned long count, unsigned long max)
 {
 	const struct word_at_a_time constants = WORD_AT_A_TIME_CONSTANTS;
-	long align, res = 0;
+	unsigned long align, res = 0;
 	unsigned long c;
 
 	/*

