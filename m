Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE26CC10F0B
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81D3F21901
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="qeml8KMl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81D3F21901
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 263916B02B5; Fri, 15 Mar 2019 15:52:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23A806B02B6; Fri, 15 Mar 2019 15:52:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1508F6B02B7; Fri, 15 Mar 2019 15:52:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id D570B6B02B5
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 15:52:10 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id c203so2694817oib.20
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 12:52:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=o99IPl+uG2EzV+A51yAxAJoGFkhXN8vGRgmKAMdYgSA=;
        b=LmjCIuSYvQXDgkCArSRZR8oe5ZGe9crCxZqGm4CYJSq36DScto8sAs7oAvwY21a/lN
         j9KxbiY4G515BzomSyuJ7XiJB2S8wqkowVFONNXtUzg5IN5AyiaOStC7jRmSRp2dGqEF
         9fJKj/rUZG6vFhbkOi+l87AFBdper9tQQQT3v7UKNbQmpae4FNAgAIZYwbNBuFBH+U/2
         TSzcoaGKw/WR2k2p/uU2+txY5qn+stBQaMPxHBe/MiZ9a/8UdW+9Bh0fEnbW8SlLh/5o
         qKem/t5+fxuMhZ3j7SECQ3pura3zwM4PVaDtd2AQoIPG+iSr1OavJJV+BbvHa5PuBznz
         yhUg==
X-Gm-Message-State: APjAAAVVjHtQ7MVI+C3yQjybfd8gT0n3rQbMxLx3vo1H4x5yYaPiq1OH
	4PC8IubyjcDrz7jbzH0DCM1d0CZywaczRlISPx7QMd2oNxG3nGd/ODs/fhJkR2B3v0WX84E6t3Q
	JX8m4q86HCIv+UB2Lv6pc9sYwyf6toHm6skeO0yR7+VOkGl4dlN/AoVpr2PTiBP1jnw==
X-Received: by 2002:a9d:6515:: with SMTP id i21mr3368544otl.325.1552679530427;
        Fri, 15 Mar 2019 12:52:10 -0700 (PDT)
X-Received: by 2002:a9d:6515:: with SMTP id i21mr3368510otl.325.1552679529653;
        Fri, 15 Mar 2019 12:52:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552679529; cv=none;
        d=google.com; s=arc-20160816;
        b=MGtOB1Lr9yEo7N9K0T2ElQkVjQ3tG+n5GD5/78Q42q91P8vRDu0uX1sdUrVlBPdFiO
         fq2bWZS7wjQyzvaT1TxQh9F5izSngSpC8ZXRGXFr4AoiH1gAb651SMlqYU6ZAonvOvp9
         I0lJSPlavzo9Rsr6JHnNO5UgYXMRZocp2hqj9c3BcBMgO6GaqOg7ysJ4ZktYI0cfWOiA
         ZJstYdwRjjEfgow5UqG1AJf0Q40ldn8Nwij/ZC+AbM9weeldTLaPy0+H5ft91QP4Wc6E
         4h3ZQWGVtwqDux1pxWUqkSmKBFkOARYph0Zgh5nOjV7Np399D9Aj68msg+Hip9pTdnf5
         hULQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=o99IPl+uG2EzV+A51yAxAJoGFkhXN8vGRgmKAMdYgSA=;
        b=TVdCXdBgMqMo9+nESj7n+NWCl2E9Emhc7ypK1DduvDO5U+usD/2zacTlny6PoPpY1x
         ljSweOtbJHLtGc/VZQRhSZAQkxij9KwP8b7L8GRX99vUU/Upmk04PfzreVteVfGs3hsh
         PEQ5vvpLbYPe+owx0A71VPtxLA3irWI/q+MrrLzxBOJpy5ePkJCH0KQPfTVZutVvd+1x
         6ustZV+E//mCCpSzLYJg6RsXYiJ/IHWVlIJxWOFzyZ1dO5pxgNwQbSc3RewNIhTEWBHm
         //VNmhCGzgg4kIkY3atZ1InauyoNvxeDcr1tVGHRT8avTUl0n/VShG/5GZ2ZvaYpNHoE
         oyxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qeml8KMl;
       spf=pass (google.com: domain of 3aqkmxaokcigmzp3qawz7xs00sxq.o0yxuz69-yyw7mow.03s@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3aQKMXAoKCIgmzp3qAwz7xs00sxq.o0yxuz69-yyw7mow.03s@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id b204sor1762046oii.147.2019.03.15.12.52.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 12:52:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3aqkmxaokcigmzp3qawz7xs00sxq.o0yxuz69-yyw7mow.03s@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qeml8KMl;
       spf=pass (google.com: domain of 3aqkmxaokcigmzp3qawz7xs00sxq.o0yxuz69-yyw7mow.03s@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3aQKMXAoKCIgmzp3qAwz7xs00sxq.o0yxuz69-yyw7mow.03s@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=o99IPl+uG2EzV+A51yAxAJoGFkhXN8vGRgmKAMdYgSA=;
        b=qeml8KMlP7rmAvIxGUwmqXR6s58tv3WFmWASkki2NWsIADrbc1k8lfVc0+MTWbLpzs
         TVLOcfO6bk+g3/mT4x135nyZgaRh/a1cI0EJSPVigzGsRAp8PAEjxUHPFZAzqhmXZx4l
         8Q3KL5oxK5OHSh9sOaBJzftYgvN7gNgSHSwrNoWatq8tKEtYq3SVrekzbwazA+QWLKeH
         U6r1Zznc3OnEUZ0dR61U5DX56ScUlBeamodtGHalBVARU3JboxCMy3bCQIt/yf/PIiTQ
         7ti2uUkzpKUEL7B+2/dvfA9GvioOMJDdEfC7KsiAuJ+0KTfpgnd+IOQxpTKu3Bl4+qOo
         qSqQ==
X-Google-Smtp-Source: APXvYqxLoKEgsAEPjIF9NsjndQ5gVGqmokYLJoZMnp0FGqwROodj4iKJAPngQ8EF97Yh5xKIjIbFflxcHuXMaJlJ
X-Received: by 2002:aca:2409:: with SMTP id n9mr3111631oic.19.1552679529309;
 Fri, 15 Mar 2019 12:52:09 -0700 (PDT)
Date: Fri, 15 Mar 2019 20:51:32 +0100
In-Reply-To: <cover.1552679409.git.andreyknvl@google.com>
Message-Id: <56d3373c1c5007d776fcd5de4523f4b9da341fb6.1552679409.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v11 08/14] net, arm64: untag user pointers in tcp_zerocopy_receive
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
 net/ipv4/tcp.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 6baa6dc1b13b..89db3b4fc753 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1758,6 +1758,8 @@ static int tcp_zerocopy_receive(struct sock *sk,
 	int inq;
 	int ret;
 
+	address = untagged_addr(address);
+
 	if (address & (PAGE_SIZE - 1) || address != zc->address)
 		return -EINVAL;
 
-- 
2.21.0.360.g471c308f928-goog

