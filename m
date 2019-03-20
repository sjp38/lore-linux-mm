Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C847C10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F3522186A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="JCUhTsom"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F3522186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB8CA6B0266; Wed, 20 Mar 2019 10:52:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6CB96B0269; Wed, 20 Mar 2019 10:52:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 908246B026A; Wed, 20 Mar 2019 10:52:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 52C746B0266
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:52:14 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id y1so2936608pgo.0
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:52:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=JtqBUblhyywi4YhvTkJHhe/ifq9XLr2+qZst5mD5EtU=;
        b=jo1i7kV/Avnzf3eD7gEwKypwPr+xvGasV6YU4FJqYaC/F8rkMf6Msq3vwj8z5gEkwL
         Lk0Tdt2jGW0qOtkAPN8+HdH8qAihvRD1YXSYxPk1Kr/fYsi+qZO7C0XudUNeEEY4VYS+
         pzKRsg017DKsDR4Nf1ZPLzwr5nb50uct2EJgv3VqXMN7Qfzp9GfQKXfIO9v9jqTFFH+w
         zvKqfGZ7LMbh33wNmghKfCXYoFMgjZKlzHcDaVqIq0g5YrYKYMh90ezGzJani4JJMur7
         A6FDsAAnBmWFaHHfqOdRqNWL5RZeMoq/SCJQ/gWIcrFMiXfDWgE1/GJuBebfah6h+JII
         yGzw==
X-Gm-Message-State: APjAAAWiF4J8Bzx7VJZqP2Zu1l6gbOXxthABpYNjkpkR5hHy1bFJpz2/
	0OFehCJuM3FQFwc4+40T4z4tybOAQ+CXhaqClWwlajTnCKnix+1a4r80OY/pqzLYRTvLJqJCUmu
	q1p9nb8v6zkzVEU+rGKZcf1DtB/O1gFtEryDe8p0Xc4kAxTsCG6ApacGZ4koY3dFQlw==
X-Received: by 2002:a17:902:b687:: with SMTP id c7mr8429396pls.270.1553093533878;
        Wed, 20 Mar 2019 07:52:13 -0700 (PDT)
X-Received: by 2002:a17:902:b687:: with SMTP id c7mr8429322pls.270.1553093532900;
        Wed, 20 Mar 2019 07:52:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093532; cv=none;
        d=google.com; s=arc-20160816;
        b=xQeeHTjapLLkiO/1tVv6O1ANt9JYDLoLQLuSL8xCfTjg3PIsnzVeez8lsS7nrElcS7
         +xKPP9381dsnph3evUbHhNRTFknYLaTnbEE9LnHYwGgzGvlXGHXUZFc2ucaKHhH6B9n9
         rgHvB8iu2azbnyTHQmjS1mrxfa9gufVFk89aEYxaxNHTMmjd6vWXrWO6f3nEMlGEHs2F
         mIUBHJYRzb1Pvl8H5G2jnwuRiMIQH1dFyp9e+yksA45XG/JjTJ58M606P5vBo23KC6+j
         kEbtBPCYHPZPNg8MhShfdHW4EXzk+olIcxVLH1JbugGBs3Inp4ar2yc8IEdig9iqEcbc
         Pr5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=JtqBUblhyywi4YhvTkJHhe/ifq9XLr2+qZst5mD5EtU=;
        b=tXGH23f9CXsoNt0uOqO9Awlq4XrnL+EdKdVRWPdCNF5lauzFKqQdiSavHtYX+Oa7ER
         Xq04/z4ISmOvQchpFKFKPH5skslNybL+vml144Q7FPPv+ksZ7UDXDZ9/hV6H1D6GGTLo
         enJrgcAdE1zDN8P8w8gJdy80tJ6dhzv7VlcjMGyRTSaI4cllHulIF9oEb7o5e1Tupp7s
         4jUtnd5uwrOcEJDfgD5W8HWpb75BSO7Gg393OvenZhAAkrXzjfkZY4gVbnHiPv6tGViq
         N4afKDfFLpXq322eP9Ei8O1w5D/tN15rYCk1K2XVuS29VEk62UlbqjJbAbRklN9nmcK+
         zuUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JCUhTsom;
       spf=pass (google.com: domain of 3nfosxaokchcviymztfiqgbjjbgz.xjhgdips-hhfqvxf.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3nFOSXAoKCHcViYmZtfiqgbjjbgZ.Xjhgdips-hhfqVXf.jmb@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id d19sor2556767pgh.19.2019.03.20.07.52.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:52:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3nfosxaokchcviymztfiqgbjjbgz.xjhgdips-hhfqvxf.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JCUhTsom;
       spf=pass (google.com: domain of 3nfosxaokchcviymztfiqgbjjbgz.xjhgdips-hhfqvxf.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3nFOSXAoKCHcViYmZtfiqgbjjbgZ.Xjhgdips-hhfqVXf.jmb@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=JtqBUblhyywi4YhvTkJHhe/ifq9XLr2+qZst5mD5EtU=;
        b=JCUhTsom3sv4Qp9BgYwbkXDdkciE1//Hw4N0DNNMC4xTTSQ4lLZpC9fonlZAwhGa5s
         GNZfPO7WKhbqfkLhUEXh2Q2IsqhkYYT63boD5rJQKFDull6EmJ/3UNaGEyGsIksVaOC8
         tVa6dAYXJVSE0a/Y3iEyW9RkRqD5ULEHrrYNKdC8hIFFIscPITax04Ehb6yZo3/Kv5gE
         4GrdjKthKOiZlqCKJ11zuUzlpowQXS31kWI1psH6mvXWAsMM/BUWqqUj3E1L86ZSFVnv
         UTo+HsA5H9AlfhMDC0xK9OSBVfCenoUTzBKRmg/WwAJv8lBEwyEQzOI3ORQRTNGew37R
         fDYw==
X-Google-Smtp-Source: APXvYqxTeQTCrSfKvGumpNCKTbPirWsdeFkFdjLvtHz5QB/GJ2l6iQCjaYJVOq8eYP8TPKdTa2JL6S1R/puOA8Yr
X-Received: by 2002:a63:1e10:: with SMTP id e16mr1614319pge.103.1553093532279;
 Wed, 20 Mar 2019 07:52:12 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:23 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <2280b62096ce1fa5c9e9429d18f08f82f4be1b0b.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 09/20] net, arm64: untag user pointers in tcp_zerocopy_receive
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
	Alex Deucher <alexander.deucher@amd.com>, 
	"=?UTF-8?q?Christian=20K=C3=B6nig?=" <christian.koenig@amd.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, 
	Yishai Hadas <yishaih@mellanox.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-arch@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
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
index 6baa6dc1b13b..855a1f68c1ea 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1761,6 +1761,8 @@ static int tcp_zerocopy_receive(struct sock *sk,
 	if (address & (PAGE_SIZE - 1) || address != zc->address)
 		return -EINVAL;
 
+	address = untagged_addr(address);
+
 	if (sk->sk_state == TCP_LISTEN)
 		return -ENOTCONN;
 
-- 
2.21.0.225.g810b269d1ac-goog

