Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3F04C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 09:00:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9716C2081C
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 09:00:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9716C2081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1ED086B0005; Wed,  1 May 2019 05:00:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 176916B0006; Wed,  1 May 2019 05:00:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03F9A6B0007; Wed,  1 May 2019 05:00:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id A93EA6B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 05:00:58 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id x9so17649255wrw.20
        for <linux-mm@kvack.org>; Wed, 01 May 2019 02:00:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=KcScPEYzXmrU46chU69vi6QPbKaYevpdbKDRQQ5AL0k=;
        b=IE6mpuk/6v2ranAWvUiQfktd1ztewQhCwnCv3z91EEjwAjqvsMTaQD4iWclRGMdGd6
         gsEUq0dEx/PG6em2AipKUwjsrMotubNJdEwdSBIPuG20VEj0q7QMocsP4vD7iMClppP+
         u7jStqIEfNim8bsfdOCFz+2kdzAgdpTXzyW5KhDQd+jhAXvEylE2apCwebFtIqAEbzte
         bspAKFimTixbC3cFUlTg8aUVT5IoPhIk/IfR4OYotJaFSXm66WlLXfdpzpJhHyRnl2m5
         ioeAnu4/PWJHIVbTtA1ciF1Pd9l3N+DnGFRn9NpOMrU0W01hfrCdpghNiFtM1Qck2ugY
         +vbg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: APjAAAWjUNhty6t3IlT2Q0S7T+inOuRKc9zB6hjxNKjvam+4DRL0pVXU
	TZxn8Pr0ZPCJXD41xWSgs9qrxtBXZcTgu0h3yeDlcbOoJ0y7YDThBOb6JYe5QKwupwr4wm9Gq/P
	LJ3y+kGxDzP2rqBugWDpmXNzL5usjKx8xHq5sc6oyKWKicejPy3wvdN/zPYszG7agLg==
X-Received: by 2002:adf:ec51:: with SMTP id w17mr7339693wrn.326.1556701258168;
        Wed, 01 May 2019 02:00:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHRbnjIpowwKK0XBqt8QU4fJitQVu4Q1lTXm23RUtRejatsdXM8OxcqPzqmeah8yaOe/Ca
X-Received: by 2002:adf:ec51:: with SMTP id w17mr7339631wrn.326.1556701257162;
        Wed, 01 May 2019 02:00:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556701257; cv=none;
        d=google.com; s=arc-20160816;
        b=i0kt0iQHQM9cPBwpISACVmNcRulkrFJ3hdyweW8pjbiOc6ZGCl+yLHSGoMD6nxj1v4
         FwOvv55wEp+0Ci0oWugahybRUpEmh8FOi2KIQAnD9DRJDdg70/FOorXAopCiQxMmvrMa
         /Q4AWOCrkZ/C2y6BfW59ncUHkNOmgNYMz8ip/CMgzChZpJAkV8xTH6xzS42l9vxLy4ZE
         Wye7B0XMPGV3bo6TocK3QiIIn9LtcmKbQhZl3p6Wazsjms1dbLf9qUZFbhW6pqK4IU/J
         Tz9f0c8bHHv4V/hdBTZHlioaMWDkFBDFIUnvF42QWaRVoRiz34RFu771Q3TADDADm1sO
         ESnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=KcScPEYzXmrU46chU69vi6QPbKaYevpdbKDRQQ5AL0k=;
        b=icIGpKMZ7Ow4kxFDOtbXJD7JvRdj4lb7wPTyB67Le9WD/dpfqxWU7mqEwfW9sXfLiq
         Io1OEDY86HsYty/S4bfKnjCt3p1BvRAAprVHsyvlG9r5SUccSOgDkdPVsBINYNOJ5gBP
         n9Hn5YbIpdB6v4A6MHviiEmI6wDFKSWGla4+MtaFn/kg3DH+KLfITqe8PDRHoAQ++BQk
         X8JfPELCsxxupo54Gi9h1HOy3bRgpRCwPWfbqpoQEVebOBFDyZF1JJnsIQgvPbDeavW3
         cEnTUnDziHQGndib2TxyoPoz9M6ubNodH3RDpLHGUm3oeCZTQKA70qfmyuLqqDesbrGs
         xc5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id m18si27164989wrj.311.2019.05.01.02.00.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 01 May 2019 02:00:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hLl6e-00025P-Lh; Wed, 01 May 2019 11:00:48 +0200
Date: Wed, 1 May 2019 11:00:48 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Qian Cai <cai@lca.pw>
Cc: dave.hansen@intel.com, bp@suse.de, tglx@linutronix.de, x86@kernel.org,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	luto@amacapital.net, hpa@zytor.com, mingo@kernel.org,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH] x86/fpu: Use get_user_pages_unlocked() to fault-in pages
Message-ID: <20190501090048.emqugoplr4sajnqc@linutronix.de>
References: <1556657902.6132.13.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <1556657902.6132.13.camel@lca.pw>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Using get_user_pages() seems to be problematic: KASAN reports
use-after-free in LTP's signal06 testcase.
The test invokes the signal handler with a provided stack and changes
the RW/WO page flags of the stack while the signal is invoked.  A crash
due to a NULL pointer has also been observed.

get_user_pages() may be invoked (or so I assumed) without holding the
mmap_sem for pre-faulting. KASAN probably slows down processing that we
can observe the user-after-free while page-flags are changed. It does
not happen without KASAN.

Use get_user_pages_unlocked() which holds the mm_sem around while
paging-in user memory.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---

While this fixes the problem and the crash later on, I would like to
hear from MM folks if it is intended to invoke get_user_pages() without
holding the mmap_sem. Without passing lockde & pages we only do:
  __get_user_pages_locked()
    - __get_user_pages()
    - if (!pages)
	/* If it's a prefault don't insist harder
	 */
	return ret;
Which was my intention.=20
The comment above faultin_page() says "mmap_sem must be held on entry"
so this makes me thing that one must hold it=E2=80=A6

 arch/x86/kernel/fpu/signal.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/fpu/signal.c b/arch/x86/kernel/fpu/signal.c
index eaddb185cac95..3a94e3d2e3bdf 100644
--- a/arch/x86/kernel/fpu/signal.c
+++ b/arch/x86/kernel/fpu/signal.c
@@ -172,8 +172,8 @@ int copy_fpstate_to_sigframe(void __user *buf, void __u=
ser *buf_fx, int size)
 		aligned_size =3D offset_in_page(buf_fx) + fpu_user_xstate_size;
 		nr_pages =3D DIV_ROUND_UP(aligned_size, PAGE_SIZE);
=20
-		ret =3D get_user_pages((unsigned long)buf_fx, nr_pages,
-				     FOLL_WRITE, NULL, NULL);
+		ret =3D get_user_pages_unlocked((unsigned long)buf_fx, nr_pages,
+					      NULL, FOLL_WRITE);
 		if (ret =3D=3D nr_pages)
 			goto retry;
 		return -EFAULT;
--=20
2.20.1

