Return-Path: <SRS0=ErOr=VZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6C8AC433FF
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 02:09:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 582A12082E
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 02:09:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 582A12082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A997A8E0003; Sat, 27 Jul 2019 22:09:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A49C08E0002; Sat, 27 Jul 2019 22:09:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 938E58E0003; Sat, 27 Jul 2019 22:09:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D8178E0002
	for <linux-mm@kvack.org>; Sat, 27 Jul 2019 22:09:36 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y24so36303767edb.1
        for <linux-mm@kvack.org>; Sat, 27 Jul 2019 19:09:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=T5NG7H+Fw3EvYTipofhanyPf/n0Pd7u3KK+jC0M71aw=;
        b=AXXsiK5+aQf4LNdvHgNgICbbw2EYOYMv0K/MLhBtD5yOgBpjVjx9PwEOO/gzAKwPzL
         /oS9paXPsTqrto3fcT/zl25V8jR0JVaw7DSbXWixd31SQvUdl0fzeFzwV1ijQL5ZvCgL
         mh3RHSrEL3VunVAP6qmq3Ru7fTIU+qE8mXmqBVSHoQFPdYSUGdlliqG1jA34PiMkwxRz
         iM/9PaPWiEomj8KfXi9Uz7kw+rqKSkif1wr1LKFtGFGiJANeITZkDfsFjFM3yn5OFth4
         9bvhf6BOd9HtK0F+w33q1ygWvnn8hTcr3VREiytNU0KUfETsohv1ZNV7d3H4F0ZjoRtB
         GbiQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAXqEs3IBrqXfbJrjhcFAS9PIrJgktS6STw+od6hmi1iw5/Bjdza
	4r/+FhoKB8CQEsF9xesV/VzQc7oQ+0+Mu7zdavbtvciJgq970BnSW7CnZ+XlYOB/So0PT5yvIIK
	FlqMwVveTe9K6Cw/2yUgVwPzwJBMhiGGglJYYOH3phIRUjLbmI3TChC3SHMhl6LQ=
X-Received: by 2002:a50:b7a7:: with SMTP id h36mr89616554ede.234.1564279775842;
        Sat, 27 Jul 2019 19:09:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZ2iOUQmAa3Pudv0OSFImUYHl5VlBIj2Ebl9KMzOpGFgSN2zXLlG0sXUtPKn9OTiuAzsID
X-Received: by 2002:a50:b7a7:: with SMTP id h36mr89616521ede.234.1564279775025;
        Sat, 27 Jul 2019 19:09:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564279775; cv=none;
        d=google.com; s=arc-20160816;
        b=0LqycLJN5vw0Fq8K0WeOMHpr8YB0c5kLhTD7vdyQaIf37ldVcx+QXeDfon3HXSPv0w
         ZXE06DF6fgBL/SxsQP0+cMCb8vIELAkXyRRWgYYdRbqyJVf3JwFc18sCsn44zjFQDaDu
         uQ1uiPa5ZhuKV6WrsIIA/S+tcsOODNqaM0baYRaCU0i7eNJRZxikdDjRPbqPnZrzkPuA
         nl0VYUXAx//LMcCMcmwYLUunrzwy9RcKBNMkPBDwkozVNaUEGytWrgGTPAJF4ot+LSoq
         hhlfKAWcSa24kvXA/huuMAG78dAsCmEgr+IWkk8Soi9WM5vGSPLC5grQBxRsebA1mdFu
         LwUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=T5NG7H+Fw3EvYTipofhanyPf/n0Pd7u3KK+jC0M71aw=;
        b=bhfbCk8yZJ6giMgsXgY05c/0LTtUTa2eMEusLG1/vOkBRoEoI3wJFzYNQfzf+CGxgg
         tA0C1jrrsoKXZE6S8Gj0prRvPtt52pXuBP5P1fCzQTF1A5eJJMQg1NYb7SGyI9rPUmK6
         QlCRXvQJgfj9I7A12s5sSJJM4VhlSbMlx+kUlJppzcNpU+kj551/HqWE0iQD9MT9Mmf/
         DUYE14rw+4nC2o3XmEXlq0I1gXzusxsa9VamRUXHu42sJ6OpfOH6dGAEwS6C6KU80fqm
         ABPIuqWkk7oS8TT2MpHgtPYSYnYSR7NMOsxT9IHiGshJgOXiCO7zVLHlO7kONlzr9o7l
         kGIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id nq5si13100846ejb.124.2019.07.27.19.09.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Jul 2019 19:09:34 -0700 (PDT)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::d71])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 21B09126598C3;
	Sat, 27 Jul 2019 19:09:30 -0700 (PDT)
Date: Sat, 27 Jul 2019 19:09:29 -0700 (PDT)
Message-Id: <20190727.190929.2229738632787796180.davem@davemloft.net>
To: matorola@gmail.com
Cc: ldv@altlinux.org, hch@lst.de, khalid.aziz@oracle.com,
 torvalds@linux-foundation.org, akpm@linux-foundation.org,
 sparclinux@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
From: David Miller <davem@davemloft.net>
In-Reply-To: <CADxRZqw0oCpw=wKUrFTOJF1dUKrCU6k5MQXj3tVGachu4zPcgw@mail.gmail.com>
References: <CADxRZqx-jEnm4U8oe=tJf5apbvcMuw5OYZUN8h4G68sXFvDsmQ@mail.gmail.com>
	<20190724.131324.1545677795217357026.davem@davemloft.net>
	<CADxRZqw0oCpw=wKUrFTOJF1dUKrCU6k5MQXj3tVGachu4zPcgw@mail.gmail.com>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Sat, 27 Jul 2019 19:09:30 -0700 (PDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Anatoly Pugachev <matorola@gmail.com>
Date: Thu, 25 Jul 2019 21:33:24 +0300

> http://u164.east.ru/kernel/
> 
> there's vmlinuz-5.3.0-rc1 kernel and archive 5.3.0-rc1-modules.tar.gz
> of /lib/modules/5.3.0-rc1/
> this is from oracle sparclinux LDOM , compiled with 7.4.0 gcc

Please, I really really need the unstripped kernel image with all the
symbols.  This vmlinuz file is stripped already.  The System.map does
not serve as a replacement.

Thank you.

