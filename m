Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A751DC43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 18:15:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 518A1217D9
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 18:15:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 518A1217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B34FD8E0002; Sun, 17 Feb 2019 13:15:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABE048E0001; Sun, 17 Feb 2019 13:15:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95EEC8E0002; Sun, 17 Feb 2019 13:15:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F98A8E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 13:15:37 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id l5so6745315wrv.19
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 10:15:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+VaAvo0wOASHN6s7G6edpRkc6irwhy9SOLhwS5Zru8M=;
        b=seINaCXuh8xpHwHRGe4BnAwBrQbLj8ZcBgH1LiyyxCV3//ut2/AXb7UQLnaWLSJtGD
         1OormdddsAZowsjHynhLkF375XaxKTChUFiYLpKnH2Oy6Gbr40EQa97QZ5HDbimxCYZr
         iln1qzmkundAE8CXmJtVsY07sQ8hi/1x8NUSxI/0/069PT5xqcput2m3X/w9ogH9FB4V
         zBsIkqiZtuVhBzEjLwoS4npITopBZ/zT+3q1vlNEMyuytcIL/9MD2b5oy6oovHOXQgfn
         peSiEuFAxnK/ca/kH8WLSvqRpsVh/3A7hkxvSyp7fWqrSGik3IS3v2bxr/LB+Hjc+i0i
         f66Q==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: AHQUAub4ayUCqcJA1JXPTelWtVv3ZePoNZb3qZd5GAWAeMx/fZvc19vg
	q3D05KJtZVsVlghHnup5fSAAWfk1k4Duts9uvDXSoLaqeTyYzZVXS0xH6K8H3KtX5jYLZ54YaLE
	hAzT2KcPF70qiraIHtyz9dJFucbQZcefQZyOUuUwv+idMcWGDQJbw6g12wFo6yqI=
X-Received: by 2002:a1c:f00a:: with SMTP id a10mr13085565wmb.148.1550427336745;
        Sun, 17 Feb 2019 10:15:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZwyKGkrNYtibgStkEITC+XnfLiXSiCgAO9DuJ+Shgi5eJkVLmeZsG3Xq3S0r4zKRhEI+k5
X-Received: by 2002:a1c:f00a:: with SMTP id a10mr13085545wmb.148.1550427335896;
        Sun, 17 Feb 2019 10:15:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550427335; cv=none;
        d=google.com; s=arc-20160816;
        b=O94UJ6qc25OXmpkZmPmExBIHaOEKqE23MnkoVRq5H9tS5SI/phRXf/rHSwuNgFjlOY
         1wWT+bXbwNYnK7ulX31M1OQTDuKIf2rRVVUOfRxuEzsgd4xpkoGS3s8zBBVDjsbd3SiC
         wHm5ALCt4MSHdpDvspo4hb//okKzn0CaVh+b6B5fBvxceDY9zwp0Kqu383UrvVf2bDhB
         i/rHZBuqFGKqRFoJUGpreQiMR8wZGNlBePWbzg3K8jksWfPGDrQzMjD3srbwMRL+W+6c
         +ZHjSNUdNFEFldRmBbf6cCD8F6coaD2+I9BBiqH7lTuvMZUxEfI5v8ton9xBQp/Bv54r
         9UOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=+VaAvo0wOASHN6s7G6edpRkc6irwhy9SOLhwS5Zru8M=;
        b=rYDdBw07kXISY4mJfooBgHr91CZI5VgNej7oqT+vKZ7XH2SYyc+/c6mD9u6ighD/6r
         70aRy9e8ZsawknCNEAYAxHid0IrgD2N5gFtCFdBVnPhD6JX1nzQczhxZeC68SCGEECrW
         NkcCtND7uL8gK/KjXAZELNiBDojkAGJYxEQ1R1eQYmGGpBeEonhVxnvk/t5CzL1BR0dD
         ndshKj3JinXY4DkjfwqzJvE6rYBeQSKHplMv+80ALJoM5q3wr0unGO/g0vPSMzI6UOQY
         KbSpXQRFhEjyLROEbWBaxAAQFlBiwLUqhqwdeP/abVpHamS+NBiAWnUOyF4/R6PzwOVK
         Tc0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id b188si7886765wme.186.2019.02.17.10.15.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Feb 2019 10:15:35 -0800 (PST)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::bf5])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 20D92106F2CBA;
	Sun, 17 Feb 2019 10:15:33 -0800 (PST)
Date: Sun, 17 Feb 2019 10:15:32 -0800 (PST)
Message-Id: <20190217.101532.1280291105433517556.davem@davemloft.net>
To: rppt@linux.ibm.com
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] sparc64: simplify reduce_memory() function
From: David Miller <davem@davemloft.net>
In-Reply-To: <20190217082816.GB1176@rapoport-lnx>
References: <1549963956-28269-1-git-send-email-rppt@linux.ibm.com>
	<20190217082816.GB1176@rapoport-lnx>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Sun, 17 Feb 2019 10:15:33 -0800 (PST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Mike Rapoport <rppt@linux.ibm.com>
Date: Sun, 17 Feb 2019 10:28:17 +0200

> Any comments on this?

Acked-by: David S. Miller <davem@davemloft.net>

