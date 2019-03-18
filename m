Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 642C9C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:18:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 198A52133F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 17:18:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="EXAkqzYX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 198A52133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C59C6B0010; Mon, 18 Mar 2019 13:18:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54FE16B0266; Mon, 18 Mar 2019 13:18:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A1636B0269; Mon, 18 Mar 2019 13:18:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0926A6B0010
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 13:18:15 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id k5so17086649qte.0
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 10:18:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=nIZeb0pZ+Rs1twP/26IxdjvHz5r8ncIzXCkOe4U4COg=;
        b=rjr+re3gU2sUpBkhjbQttv1KS5V/gpJcw385aEDZS6oZb1L7AXiJLU230c3H08Jfl3
         9tSR9ca43ydQFa2FBvLGN92bEZTgEctj+1i4Dlr/M7lmin5TbtWUKdXP14mkAfB+FDMj
         oXTA12uZL2VChJ2tU1HbV5uuXFLz7U8pPm+CKoykU001XXJdafZh1IR6mtI9R/H4BoCa
         yhI0tL6f8lQRJesyEkzuvpAkPnOrZJjjs8lFnneJ6sSTuj2ungYT+taX3oRkU4fYScAy
         Y5Y7KJxWI6oRqZ31EPIAherqKOHXN8DvwsGW/z+pW+VMBT8KIidanQD2mg+zZBueoWh8
         2D+Q==
X-Gm-Message-State: APjAAAXsCAhYbw/VMlBCyflUyZzslCFsiAk/nNYmnJHFhmTPJfg8AYYy
	FHlUFz3AX9jyXXvfpRKbPgrzp8JcWkJTwOotosn4ep4HWDsYwXpSZrE2j84qun1NpIdW+Q0ce22
	2L43PBV+JjLfesWFrxDc25AjRZRyglZcyIaTl8Xy5pjwxbFBc5WNmLgOaQjz+v+2Vcw==
X-Received: by 2002:a37:38c7:: with SMTP id f190mr13037423qka.77.1552929494808;
        Mon, 18 Mar 2019 10:18:14 -0700 (PDT)
X-Received: by 2002:a37:38c7:: with SMTP id f190mr13037371qka.77.1552929494031;
        Mon, 18 Mar 2019 10:18:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552929494; cv=none;
        d=google.com; s=arc-20160816;
        b=BMC0RGPPpPHtR0VzW0w6cjBequ50rYvQb+frfQQCt2SbvleW/j6BtAvPXRXPjMybet
         S0oejED+x3jGa1D4zZFhXjJMeEtJRZssFOYgSnQio77UXLklOaYB7268PR38yaHFYyEZ
         tn6dPsQ9EktOl3gyGSfAjvd6Dd8sZ6D4HvnyLoDdqXbWOW7e68VJiaRP9x7/JLTGiv40
         0UTNLElntuI7hDKVKkoGrk3+drmR06vhk7iHpVRf6xHWrNBOaYI5bQKjk6s+1QI3O3Qh
         VO8DrYso76Slm0BkTqe6o06IDAbKgWSzlPtUKekWhZ75ohqnMQwQUNaNPm46hiBg0hsj
         K19g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=nIZeb0pZ+Rs1twP/26IxdjvHz5r8ncIzXCkOe4U4COg=;
        b=W6odxnHBjsuUg1h/pUNg2rgCJNuf0HbEMraOjlWdjEU488IHYywQlrEj/C6L+Qju+w
         /L6P8nj5dNdQWc+Er87hg9ee/VNUyk7muqgACgrEeXaZWGi+XlyinaeVW/04849pZQBT
         XXrdAHuAC4R9nFAiV+vRgp0jKeeUyIkI7VnKWKDd1Qduf3UQ7HoF9U+q9rZxKHKJ17dy
         pmw9BUvn8ivfyjg4tkPD4BmhoMoJDuU9/PZAdtrglHHIv/e66Ok9+iPtPoEiACnj3niR
         URMQnZkFVq3wFGwk/+bY/rvhXGEbmMe13mABoJwnFcQM21M8bv+mp8IdlGvM6grgp/Ra
         oKow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EXAkqzYX;
       spf=pass (google.com: domain of 31dkpxaokckqerhvicorzpksskpi.gsqpmryb-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=31dKPXAoKCKQERHVIcORZPKSSKPI.GSQPMRYb-QQOZEGO.SVK@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id q11sor4326297qtq.28.2019.03.18.10.18.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 10:18:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of 31dkpxaokckqerhvicorzpksskpi.gsqpmryb-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EXAkqzYX;
       spf=pass (google.com: domain of 31dkpxaokckqerhvicorzpksskpi.gsqpmryb-qqozego.svk@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=31dKPXAoKCKQERHVIcORZPKSSKPI.GSQPMRYb-QQOZEGO.SVK@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=nIZeb0pZ+Rs1twP/26IxdjvHz5r8ncIzXCkOe4U4COg=;
        b=EXAkqzYXquwoZW9zPquYoEc1VixgrJrxtJjurULtOsll9F/x8BSgkuYbNYqPNAK+sc
         QdGu01FYNxKrm1YnjhDssa3BGmNkam/8XvRG+67blmdUDkqpgD3yiL0tqlkzvcOHlEdD
         fz/vfMUJKMxApfo9M6ta6ANBN/hBFJ8sHT6IIlVMu94hJTj8vY7Ch6oVS78GY6mduhfg
         Mfa3G2yUPRZbMrYKuIq4vjmPLT9/Hrg9S0x5wCC0nEBvOOrzKzgwcqVZmA0wCyKJejEO
         fM02iW8f+3jGAOZtPgjTq3dSiMBluDfCCoyJ/neHAzTlpna8RAP9peqgVYpDqOfBkGtD
         dYvQ==
X-Google-Smtp-Source: APXvYqxadZqo6uzYQyuENLgyHusNMUz8mCv/BxMvfZyt1rftgNKCVV69MZQdKa9n4B6FLFRP2mw6D3xauqnW81d3
X-Received: by 2002:ac8:38b7:: with SMTP id f52mr10498903qtc.7.1552929493810;
 Mon, 18 Mar 2019 10:18:13 -0700 (PDT)
Date: Mon, 18 Mar 2019 18:17:40 +0100
In-Reply-To: <cover.1552929301.git.andreyknvl@google.com>
Message-Id: <80e79c47dc7c5ee3572034a1d69bb724fbed2ecb.1552929301.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552929301.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v12 08/13] net, arm64: untag user pointers in tcp_zerocopy_receive
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

tcp_zerocopy_receive() uses provided user pointers for vma lookups, which
can only by done with untagged pointers.

Untag user pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 net/ipv4/tcp.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 6baa6dc1b13b..e76beb5ff1ff 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1749,7 +1749,7 @@ EXPORT_SYMBOL(tcp_mmap);
 static int tcp_zerocopy_receive(struct sock *sk,
 				struct tcp_zerocopy_receive *zc)
 {
-	unsigned long address = (unsigned long)zc->address;
+	unsigned long address;
 	const skb_frag_t *frags = NULL;
 	u32 length = 0, seq, offset;
 	struct vm_area_struct *vma;
@@ -1758,7 +1758,12 @@ static int tcp_zerocopy_receive(struct sock *sk,
 	int inq;
 	int ret;
 
-	if (address & (PAGE_SIZE - 1) || address != zc->address)
+	address = (unsigned long)untagged_addr(zc->address);
+
+	/* The second test in this if detects if the u64->unsigned long
+	 * conversion had any truncated bits.
+	 */
+	if (address & (PAGE_SIZE - 1) || address != untagged_addr(zc->address))
 		return -EINVAL;
 
 	if (sk->sk_state == TCP_LISTEN)
-- 
2.21.0.225.g810b269d1ac-goog

