Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7D0EC76195
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:36:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A12B52229B
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:36:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="DIJf1MDR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A12B52229B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 268AE6B000C; Mon, 22 Jul 2019 05:36:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F1886B000D; Mon, 22 Jul 2019 05:36:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 045636B000E; Mon, 22 Jul 2019 05:36:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 980816B000C
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 05:36:13 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id s10so3527034lfp.14
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 02:36:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=lwrou0ge1fASn3VFBYr42gXUSv9B+Mk8b6WwMg4i5lM=;
        b=GUEzpuRZHMSuhB0POhuqYp7dop5StDCdOeGE6alj/ofX6sUJDYtImSlzk1XMpXDnc+
         5kDITM4mgJsckJd3cDxZs4g6H1QI7OOQL8NxGzn4A2CV41mq4eOPu1yDy3PZocMblSWS
         PwltJZA8/J7dHaHCooLwG1iI08SYtj9EbTX1HEoAQnWrz1LUNCIFJ+pDOOzRT3OjCDvz
         FZBQbH7qD6w6smbt7duHzgf0f3z6ceRThANwTI4t9RwsFXbhho1GtFB7cRKWrrjuRRmF
         mnyQtr4xKR1p3fBrJ6gqRkW5uoXkKu0Y/oZ4rRJ8xplgQ08QZseRZXQVzjjAg/vQD7rl
         KtAQ==
X-Gm-Message-State: APjAAAWGt6UtdfWdAExOs7Fuoets1C91Nh4f0bjqG5XY5BzvvgRf34Nt
	QOFHxLFhx90B5eJNE+PASiIrgAR5aJtNEUmTnW45/aX9CiVCdo+uBnaoE3EThDrIR6kmf3zzc6H
	f++8XCmvBR93RhBfYECBFSDbN2Rxw7uByjCxQ7lwFju/PpeDhc0rjzIqGbFsbb2SBvQ==
X-Received: by 2002:a2e:8396:: with SMTP id x22mr36733468ljg.135.1563788172975;
        Mon, 22 Jul 2019 02:36:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUN90Fwi1p18cFrHcECK2A4/RECtC7ylWZ8168L2570DTeKnunz4lGk1WTFQxlilKJEfxu
X-Received: by 2002:a2e:8396:: with SMTP id x22mr36733430ljg.135.1563788172189;
        Mon, 22 Jul 2019 02:36:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563788172; cv=none;
        d=google.com; s=arc-20160816;
        b=sV040IiAhlyvGqySwW2slRvMU9qHLXT/j5ESrszZpa3qKIa+l50+XtcA/9lKMQMmJh
         iCEThq29vjbYSHhM14isRGlndi6DFVd3feaRUKavNqt+oZVEgsp6jR5vUHJRN3cSVsp/
         K0sRKQYzBI2TQEHfCFH3sunv/hCCnz6Zdsg3Llc+UwHueMTsrAwLUf6kVqRrkYvTdT2r
         mGhCxrwKnqUmYdAyCTJ/+3D4WHs2+rmyXPpXJw3lTg8P5FtdiBARvZ5Zw12lYFijTS0k
         9V+tAW0hUWJ2b9HY3XYVjCgyDerAyD5ksBfOCEpYogLDxAn+vlYLBKv/DlDr7u1XFr8k
         8dPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=lwrou0ge1fASn3VFBYr42gXUSv9B+Mk8b6WwMg4i5lM=;
        b=cAtAAFRphYYo3BwItVmVOlw0YNvr/1/aG/YAMnDEG0WnW5HDMJ5bLs0W6gi/aHG2wk
         yyiEiy1o7rHXfRkueoppOb93t4G7a85baMIfbPgttgCkEI66OEwIaqkmwtzU3fqwNhCw
         3UbFrEp9kZ1Zvw2RI8yhp3uCv7wK2iGgP3ygADeRhQerqq4fXku+sYCYolxXsYP/6LuB
         aXnhxMaVpPmjrFgVKpINlYUlS0LoTeMF16OegO05Ny7noMSs/OpiSr4itCXf+vwxL5jD
         IhwwrGHdZIODdIQ/MJbtBg85OwSiBUlvBgR6pNncni7AB3p5to6BGG7jBvfvmFSE47Mg
         MSNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=DIJf1MDR;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1p.mail.yandex.net (forwardcorp1p.mail.yandex.net. [77.88.29.217])
        by mx.google.com with ESMTPS id u1si32893739ljk.164.2019.07.22.02.36.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 02:36:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) client-ip=77.88.29.217;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=DIJf1MDR;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 77.88.29.217 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1j.mail.yandex.net (mxbackcorp1j.mail.yandex.net [IPv6:2a02:6b8:0:1619::162])
	by forwardcorp1p.mail.yandex.net (Yandex) with ESMTP id 9F3E62E0DE0;
	Mon, 22 Jul 2019 12:36:11 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id j01G7HEpSm-aB5ajCCf;
	Mon, 22 Jul 2019 12:36:11 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1563788171; bh=lwrou0ge1fASn3VFBYr42gXUSv9B+Mk8b6WwMg4i5lM=;
	h=In-Reply-To:Message-ID:References:Date:To:From:Subject:Cc;
	b=DIJf1MDRS9k2nQaZ1DgVQQtOdHcWYktPONyBemWBggu9EEvRAg6Ds8yKgaBx5Dv6W
	 sGFFBF2U1e2JvDzUAUEP/9sFGmg5kQO55TsEkZv26H6df3OseRxvm+jBfIpXKmXZ3k
	 kC14yyhFJf0AahFHsm9tMubKphNZg5HHcbYzOwtU=
Authentication-Results: mxbackcorp1j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:38b3:1cdf:ad1a:1fe1])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id AdNDBXcM8x-aBAq2o3D;
	Mon, 22 Jul 2019 12:36:11 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH 2/2] mm/filemap: rewrite mapping_needs_writeback in less
 fancy manner
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Jens Axboe <axboe@kernel.dk>,
 Johannes Weiner <hannes@cmpxchg.org>
Date: Mon, 22 Jul 2019 12:36:10 +0300
Message-ID: <156378817069.1087.1302816672037672488.stgit@buzz>
In-Reply-To: <156378816804.1087.8607636317907921438.stgit@buzz>
References: <156378816804.1087.8607636317907921438.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This actually checks that writeback is needed or in progress.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/filemap.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index d9572593e5c7..29f503ffd70b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -618,10 +618,13 @@ int filemap_fdatawait_keep_errors(struct address_space *mapping)
 }
 EXPORT_SYMBOL(filemap_fdatawait_keep_errors);
 
+/* Returns true if writeback might be needed or already in progress. */
 static bool mapping_needs_writeback(struct address_space *mapping)
 {
-	return (!dax_mapping(mapping) && mapping->nrpages) ||
-	    (dax_mapping(mapping) && mapping->nrexceptional);
+	if (dax_mapping(mapping))
+		return mapping->nrexceptional;
+
+	return mapping->nrpages;
 }
 
 int filemap_write_and_wait(struct address_space *mapping)

