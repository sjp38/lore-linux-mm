Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8A57C76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 650E2218A0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="mF8OyWPt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 650E2218A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 173BF8E0014; Tue, 23 Jul 2019 13:59:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 127678E0002; Tue, 23 Jul 2019 13:59:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0A848E0014; Tue, 23 Jul 2019 13:59:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C994D8E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:59:49 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id n190so37138833qkd.5
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:59:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=IHvI+dZahLSsu4iMw8K110v852ALNB6rzz3nOC21G6Y=;
        b=KEE09a67ocR6DgZyQ/vXOVzh4YjlM1E3f7xdIwLH5mPeiPazEIUf7lnNW6ZyCJAo5+
         WtvAXNi9EVRE55Gw+9sTorj9GNuQOcoq3B0+K+Vvjk1hvlNxSJJJiMw13oPLm5hLZ0uS
         HR/ZoEJ03D3FgZepvigA5ENsyGta0KZjKULOm2LuXcYTQg2MI5nUZPem5VpwPqiXabOS
         2HZAJ1g2GUeSCEMS1nbVSGpxBmn8G2S8phd+B9QL+owRFS+klkhQSk08lJa4iMyYgn7Y
         IrFTqah0tRGQpXdRZIphNBEQfoYb0WrekJbHj6glk8TsSP4ReloyW4trPnsNMAmR9XDq
         WpGw==
X-Gm-Message-State: APjAAAUo/GZeV6ja/s0A7Xu+zkV39sxgwXqRWeYDasTIgpEDV4AKNk9m
	x084PbUFaxgDf2kVQUYmlzRV4Hncseek4Hbgkbhvs2JfZmxXHjLVs1Q/t05/mlV0xBobUFPBikJ
	CrruRxYZc4mOTNMGvxyKrQ39l8R0VcHurITiazWGfp26SJEX3ye2GjcDJH/QlOyNHKA==
X-Received: by 2002:a0c:d94e:: with SMTP id t14mr53410266qvj.18.1563904789611;
        Tue, 23 Jul 2019 10:59:49 -0700 (PDT)
X-Received: by 2002:a0c:d94e:: with SMTP id t14mr53410255qvj.18.1563904789121;
        Tue, 23 Jul 2019 10:59:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563904789; cv=none;
        d=google.com; s=arc-20160816;
        b=VWUYXd8lm26qh/UlzaR8+gWDrkTf8TYNjjb30iQBbWzNY//vjHGM2lMUf9TO+B/XE0
         gTiGkjWOZWv8btWQRbxRJFOfggCH6HF16nk/2+LjXnoE7qAqPyCR/CQhjr40sGdlnN7O
         6O0IoydEQeQ7WWgqM/BiDtrCx4r7qjkv1FWCWHSuum47b4PIANV7+WL2Dm44aTio3NQG
         +6nQkLPC4OqhrLQ0CwUUaYjwrwpy005lVufrSpz6u2Dmn6QN57TZB/pmvV7m3p3vNond
         Mn/IsLdBtwUyBx7dXOZ/JZoS5/cJ5GQRgQIlFkNvEbBrL6UM6EPFtFqJkj+7ALz4keCL
         PM/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=IHvI+dZahLSsu4iMw8K110v852ALNB6rzz3nOC21G6Y=;
        b=fmjExz0eMOIXGxsgDpho0j/Y6Z/XLLj7/8LJG0cu5+Kfb6sMeT5Q5WBL1FKIi8qPXm
         mCK3qrAFXuZ8P/iye9D/jmFqRYpWfTST893BySgli8tinqMsqFFW/vSc6gEeO6PwLn2E
         mdLeXpLEQI+vJyjduufURWc6/hdlXyAWzLPDvTDiZ3Yk4lgmb+skpURN4/KVJE7qKHPL
         Kbfv0rtHfXBzBXsHgY7MqPDQS3KoOspHHQAGqeAOjCBQmZfemeIsPBuCCuoLUKUWVn6O
         hdR387ruPYvHDWp5a6RImepqWMWaNpuajbXIL+wohF40ZtbUqxUYGZAbTbKQ8zru6MNu
         r3KQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mF8OyWPt;
       spf=pass (google.com: domain of 3fes3xqokchcviymztfiqgbjjbgz.xjhgdips-hhfqvxf.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3FEs3XQoKCHcViYmZtfiqgbjjbgZ.Xjhgdips-hhfqVXf.jmb@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id h3sor38015305qvc.37.2019.07.23.10.59.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 10:59:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3fes3xqokchcviymztfiqgbjjbgz.xjhgdips-hhfqvxf.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mF8OyWPt;
       spf=pass (google.com: domain of 3fes3xqokchcviymztfiqgbjjbgz.xjhgdips-hhfqvxf.jmb@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3FEs3XQoKCHcViYmZtfiqgbjjbgZ.Xjhgdips-hhfqVXf.jmb@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=IHvI+dZahLSsu4iMw8K110v852ALNB6rzz3nOC21G6Y=;
        b=mF8OyWPtPa27KaGkiSCnss6c8b+Y3jxSBp/iDga+MY7c9cKbX9nGHJwK2xlzSk0dvM
         46/b1IA06ke81wJzctvuMT0KvjYlT0hkwU/YFyMD3O3ZkppaxsJ6Qh96lV4fTWRGdGnB
         ViGf78WRhfhot+50mrRcEJP8ehDMTkQZYjXXgXUH6rOFs4T1KVaDzPVU6ktcbKr8zaRJ
         i3A/F+iOLc+6M6QJ7QteIj4THksgVZVnbx5C2fEtCjTVS1TOypq05pLtbtct8EtWO8pG
         Q61f0pOK8VaMaWwFM4favMJo4cb+2j4wmdeEX5CGZBr0ScIwqtpQSHdV7dFwlIUR9Dz4
         yLvg==
X-Google-Smtp-Source: APXvYqzRyHp7WBTqlPGt29onShJXh3Cp/pE5/lej0P3nE1XW0gw1bUQxpG45N1NN4OdbAYc7oUndTzJUESDpF144
X-Received: by 2002:a0c:ffc5:: with SMTP id h5mr55634338qvv.43.1563904788555;
 Tue, 23 Jul 2019 10:59:48 -0700 (PDT)
Date: Tue, 23 Jul 2019 19:58:50 +0200
In-Reply-To: <cover.1563904656.git.andreyknvl@google.com>
Message-Id: <4b993f33196b3566ac81285ff8453219e2079b45.1563904656.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1563904656.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
Subject: [PATCH v19 13/15] tee/shm: untag user pointers in tee_shm_register
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends kernel ABI to allow to pass
tagged user pointers (with the top byte set to something else other than
0x00) as syscall arguments.

tee_shm_register()->optee_shm_unregister()->check_mem_type() uses provided
user pointers for vma lookups (via __check_mem_type()), which can only by
done with untagged pointers.

Untag user pointers in this function.

Reviewed-by: Kees Cook <keescook@chromium.org>
Acked-by: Jens Wiklander <jens.wiklander@linaro.org>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/tee/tee_shm.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/tee/tee_shm.c b/drivers/tee/tee_shm.c
index 2da026fd12c9..09ddcd06c715 100644
--- a/drivers/tee/tee_shm.c
+++ b/drivers/tee/tee_shm.c
@@ -254,6 +254,7 @@ struct tee_shm *tee_shm_register(struct tee_context *ctx, unsigned long addr,
 	shm->teedev = teedev;
 	shm->ctx = ctx;
 	shm->id = -1;
+	addr = untagged_addr(addr);
 	start = rounddown(addr, PAGE_SIZE);
 	shm->offset = addr - start;
 	shm->size = length;
-- 
2.22.0.709.g102302147b-goog

