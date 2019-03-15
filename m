Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 404C2C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E537B2063F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BOrKvCBJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E537B2063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 792516B02B3; Fri, 15 Mar 2019 15:52:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76D2D6B02B4; Fri, 15 Mar 2019 15:52:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65AD66B02B5; Fri, 15 Mar 2019 15:52:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D3576B02B3
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 15:52:07 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id b1so9684360qtk.11
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 12:52:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=z6K/c9VtqxQi5aBAmUht43d+X7x4sfj8BAD1AB++2bA=;
        b=afH2qIDeiEjQeTvRUAm5n5PdmBGHqYVKeXpnCSJMJdwHHLY5tmxwPXgR7X90w0QniV
         OHGkQgfQmx3JoSk+ksabTjpFOeWjjIhPlX9NfUbUEmShW5obuG3ECjYIjgzpb93wbOiJ
         np6iAIYzdlMOz2ARDyYPXf/FnmJPuctbea2chTQRnaDq9/CAePBLP5oKZwZS3XBsiJCX
         TeniSprnOhIu0FSGhm+Oh5mDch8ltl/NwdyhuphrdKMOQsai1jBDcirner1E00CIbqWO
         m/1A9qJDLhDGq7ZFX1Z2tNM+HcTaOM+R5v2ejK/ibv26E5HqqYLAF77Bfsuxg9WnLDqa
         wimg==
X-Gm-Message-State: APjAAAUtrtVdWJa6bVtiuCbpQIZOzBqhHFc/ngZkoBEv+LZ6fbVlmsIU
	gqtqzenqfGXE8Kh6+VPBIlHhcVtw2sKT8ye3xuGhVTXFgEPh2iC6/ynm7vOzArFpTZ+NCTcsXDL
	I5aoeY/s8T5VyZIgWRybmSPwZwAe813BmSMZ2POQjYLftlieWw1gXzzeIJ99FJPXQzQ==
X-Received: by 2002:a37:c517:: with SMTP id p23mr4311093qki.167.1552679527041;
        Fri, 15 Mar 2019 12:52:07 -0700 (PDT)
X-Received: by 2002:a37:c517:: with SMTP id p23mr4311049qki.167.1552679526287;
        Fri, 15 Mar 2019 12:52:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552679526; cv=none;
        d=google.com; s=arc-20160816;
        b=VCI+D7jX+lRdtCraqVetcw65KqAFKnyGUjLbu+ppnBB5wm7XFIgxundlyHU3QOxBNR
         0cm+jalyH0ofYFiz3eg7HD0GsQPANN11Nj0lTJrkHn/vjWqU35J5I/Q0LlMuNSqdU9Ge
         n88L/tlO5/i2uabu9eJQm14vTwevIHtY0KSSuvfHH8udJaPd1yCys3rOMXfWyUa3eOnL
         S8o8vojnRFZ8AoLPpW156XmC2f/+TRhERDbFgvL2GiaJ9gzb4XumyUpmDOgpLBvTfQuL
         ZyIYgsgypIQ8tZV71b8U/PF1DLTwK2z1F4Y8CIibMngLRHNrN1v2ifDGuY125uSKrnRm
         yiuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=z6K/c9VtqxQi5aBAmUht43d+X7x4sfj8BAD1AB++2bA=;
        b=LtNezxaL3k47FXUF+UzXjtpzyptYx08Ikcs19R7XAV0l10w/RQCLfDhfiX+yxPbfmL
         X3I/+y34kl3agXW79BDi3wIwxvjQI4q+6JyF4y0A7jhwUK5wY6n21FXORk8QGUIpuapA
         r46s7XNbw3io1LWbhNHj6+KNjwCTkc+PzPoQDwepomR/q3Nf+P3EzhQ/HXRNFCrlZUQP
         /vso9x8YO7MY9bns1EDkJ1oxCYJJFs5GJAQzkycTOKxh5x3s/847DVPXJj33zfKG7P8Q
         9RbdhCgXmAnt0urUJHfmtRIXfQuxcv8a/dxJ+LSa7smGY86l1f/tH+uSyzGYPHmQZv99
         IYyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BOrKvCBJ;
       spf=pass (google.com: domain of 3zgkmxaokciujwm0n7tw4upxxpun.lxvurw36-vvt4jlt.x0p@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3ZgKMXAoKCIUjwm0n7tw4upxxpun.lxvurw36-vvt4jlt.x0p@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id c42sor3656316qtc.60.2019.03.15.12.52.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 12:52:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3zgkmxaokciujwm0n7tw4upxxpun.lxvurw36-vvt4jlt.x0p@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BOrKvCBJ;
       spf=pass (google.com: domain of 3zgkmxaokciujwm0n7tw4upxxpun.lxvurw36-vvt4jlt.x0p@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3ZgKMXAoKCIUjwm0n7tw4upxxpun.lxvurw36-vvt4jlt.x0p@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=z6K/c9VtqxQi5aBAmUht43d+X7x4sfj8BAD1AB++2bA=;
        b=BOrKvCBJgVmoeAFlZRf59PYgkXTKjrRMRrX63X976vqS2WZ9qHZEKHeBVwJtTWhSuu
         lUvSWiTVC/sbszWaQppDDR/3GWTkX31v65WrFbh4cWKv7GdWuy0PXeDkNLjKRPen898X
         V9cymVDbaCKNbzgoG3JjfivP1S/Za/rbL9bJ2fcItc9gQOVwpi9wJOepWPz1VdAZPUT1
         cjQr07t64SwJCV+OZh/j0pkNHMF9Z/MNDj5cHLhFPLalavSnR7OPvVyx0xN4qyU3goh4
         CsFQJ7ZthwFgkdSG7A7Q7uo8+32OwkFTx9gfh1M9rs57t4EWTuZWy/0ZLkAzrIEKwWdx
         tB7w==
X-Google-Smtp-Source: APXvYqwJfi74QVD/zofU2P0/g2gg7ooywVFBEIF7szplHks32+LZURK6/93aOzRnjw5Hkh4ZybpGRgonk8XbJOel
X-Received: by 2002:ac8:3798:: with SMTP id d24mr3191740qtc.40.1552679526081;
 Fri, 15 Mar 2019 12:52:06 -0700 (PDT)
Date: Fri, 15 Mar 2019 20:51:31 +0100
In-Reply-To: <cover.1552679409.git.andreyknvl@google.com>
Message-Id: <4368bfa2a799442392ee9582dd1cccb8c96e524d.1552679409.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v11 07/14] fs, arm64: untag user pointers in fs/userfaultfd.c
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, 
	linux-mm@kvack.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, 
	bpf@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

userfaultfd_register() and userfaultfd_unregister() use provided user
pointers for vma lookups, which can only by done with untagged pointers.

Untag user pointers in these functions.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 fs/userfaultfd.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 89800fc7dc9d..a3b70e0d9756 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1320,6 +1320,9 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		goto out;
 	}
 
+	uffdio_register.range.start =
+		untagged_addr(uffdio_register.range.start);
+
 	ret = validate_range(mm, uffdio_register.range.start,
 			     uffdio_register.range.len);
 	if (ret)
@@ -1507,6 +1510,8 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
 		goto out;
 
+	uffdio_unregister.start = untagged_addr(uffdio_unregister.start);
+
 	ret = validate_range(mm, uffdio_unregister.start,
 			     uffdio_unregister.len);
 	if (ret)
-- 
2.21.0.360.g471c308f928-goog

