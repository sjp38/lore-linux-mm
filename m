Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 575F9C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:13:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBAB12083B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 20:13:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBAB12083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F4D46B0006; Wed, 24 Jul 2019 16:13:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97EE76B0007; Wed, 24 Jul 2019 16:13:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 845996B0008; Wed, 24 Jul 2019 16:13:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32FB36B0006
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 16:13:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f3so30797647edx.10
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:13:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VtKkVz80qm0Iv68/rRnuoudh2oFw8A5KLuJT1TVUcag=;
        b=aYtqw1MlZ8qnZtaTaYnCeXlne3QP5muCAcHlq4KNI8FPAl86pyB6/icF3z+kuiOE6C
         NaFOOFvgENpExhqyWEJc4pbrx7nvqWSa40x1HBaySitinu1IVMDXI1za8ioFcEqyjN4z
         ftcy/d1Sx7YQVbMJl++WWykiAbRub617BZySISwoBztuFl/RXujaoiBUJrFej5OQMJuH
         pV0XT29bX39doUufbslXq02ZT069fLXKDEBMoZk6tLrwExewe3FYi4m9iglOPuh8XTZD
         j4BmV1UHRO/wnUXUiN16InB+BPZhe6riDWHnSb9tSQhuKxvqDDeTnGT1BjLnxCHeMpRu
         2KyA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAV4oDL48XKEj1V0hskSijnhk4dfefB1/SFW3wZyCKQpFgjUo1kO
	5CndhWMKqs1k/Zc9CJZdloWD2ciNR6obyId9ViPQMmbDDB3Jj9Smm+6cftMuLN/qP6DsTraDhIm
	IW1DpI2KVOvC+YgUtIqa+jeQ0Z4cy7S6uSRTuV4c/j3YX+EGCJZbLzMOcbAWGe88=
X-Received: by 2002:a17:906:af86:: with SMTP id mj6mr19288042ejb.157.1563999207762;
        Wed, 24 Jul 2019 13:13:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLwK6Y9l/btjc08RkxZ7RSNnVZhUyPYANWMXootZEVhxb3Ib2Ylliow1sKsP6Oo3BAkIJr
X-Received: by 2002:a17:906:af86:: with SMTP id mj6mr19287972ejb.157.1563999207051;
        Wed, 24 Jul 2019 13:13:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563999207; cv=none;
        d=google.com; s=arc-20160816;
        b=xIQP0QnvQMg1ABo4J2SqU3UCFBNZOXk2EPRIwIoP7NFntEgitg7l3JGYSrrnxf7tNT
         o4v/ukJgbdsWAzV2lz1fdjJjRm/q3pgPLPwyW840sZJu0y7uO8QIFm3bedXkj3993H/+
         E6XiVxe2VPHpjfev+BtN5zzseLkhFN8MO78jkfnrkA4CpZ8X/RYWMahfX4Pb6GyEIzPG
         fIpbxcIf5N9bGYJo8mU0tSjc9n1ywLYNE+3M/fg/X8FJIF2XHThP6GvhBLaDv9Z2sHYg
         s2a4eHGbMkBqsHwIYTCA3FWr9h6cZuolQjKg/9dtHICvPs8bd91pBn/C8bPaJ2K5wmj1
         yizA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=VtKkVz80qm0Iv68/rRnuoudh2oFw8A5KLuJT1TVUcag=;
        b=lWeLhyi2C535pAoau5qoQZCBls6OenPKPWfR2vVaDIYmGR2SSWS2+S5MbA//DtjOs4
         jliYCWa8AdOQu8wotyVNLHoIifgHAVedoqkcyhrnjnq2diXwfjnSuIi0r3Y6tOTsrYlI
         lapj+HdrwIoTzpRcSs41wbdzT+fm7hyMobuIhCUX+QkTY79aRoL30bhSHvCR/Wv+8NUT
         QcPbn34aAFh7SBAI1DmanQ/PAR65K+Iq/ER2doDTNAPsCH1KDzij9K3HwedZvd4BfM6v
         mOAfId5gxk0PBnXJMtTb0qNR2pyjegXk6zadAVvlEbuGYQ2vI1dvAYVajsVhBqqK6ZnC
         nQ5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id 2si11340378edu.19.2019.07.24.13.13.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 13:13:26 -0700 (PDT)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::d71])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 85A5B15431990;
	Wed, 24 Jul 2019 13:13:24 -0700 (PDT)
Date: Wed, 24 Jul 2019 13:13:24 -0700 (PDT)
Message-Id: <20190724.131324.1545677795217357026.davem@davemloft.net>
To: matorola@gmail.com
Cc: ldv@altlinux.org, hch@lst.de, khalid.aziz@oracle.com,
 torvalds@linux-foundation.org, akpm@linux-foundation.org,
 sparclinux@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
From: David Miller <davem@davemloft.net>
In-Reply-To: <CADxRZqx-jEnm4U8oe=tJf5apbvcMuw5OYZUN8h4G68sXFvDsmQ@mail.gmail.com>
References: <20190717215956.GA30369@altlinux.org>
	<20190718.141405.1070121094691581998.davem@davemloft.net>
	<CADxRZqx-jEnm4U8oe=tJf5apbvcMuw5OYZUN8h4G68sXFvDsmQ@mail.gmail.com>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Wed, 24 Jul 2019 13:13:24 -0700 (PDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Anatoly Pugachev <matorola@gmail.com>
Date: Wed, 24 Jul 2019 22:32:17 +0300

> the first test where it was discovered was done on my test LDOM named
> ttip, hardware (hypervisor) is T5-2 server, running under Solaris 11.4
> OS.
> ttip LDOM is debian sparc64 unstable , so with almost all the latest
> software (gcc 8.3.0, binutils 2.32.51.20190707-1, debian GLIBC
> 2.28-10, etc..)
> 
> For another test, i also installed LDOM with oracle sparc linux
> https://oss.oracle.com/projects/linux-sparc/ , but I've to install a
> more fresh version of gcc on it first, since system installed gcc 4.4
> is too old for a git kernel (linux-2.6/Documentation/Changes lists gcc
> 4.6 as a minimal version), so I choose to install gcc-7.4.0 to /opt/
> (leaving system installed gcc 4.4 under /usr/bin). Compiled and
> installed git kernel version, i.e. last tag 5.3.0-rc1 and ran the
> test. Kernel still produced oops.

I suspect, therefore, that we have a miscompile.

Please put your unstripped vmlinux image somewhere so I can take a closer
look.

Thank you.

