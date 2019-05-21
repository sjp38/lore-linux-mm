Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B5CFC04AAC
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 00:33:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D15A42173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 00:33:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D15A42173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 603846B0003; Mon, 20 May 2019 20:33:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B3CE6B0005; Mon, 20 May 2019 20:33:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A3116B0006; Mon, 20 May 2019 20:33:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 112E36B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 20:33:26 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r5so27721044edd.21
        for <linux-mm@kvack.org>; Mon, 20 May 2019 17:33:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iqyrGdY5nUcJTAoyQ9D67Ht+r/DpYjgGax4vpXQLUXw=;
        b=hWtq3JhkRDjaTwL4ECasWMEXcHWCJhmfwz9x7HIjTue5CtvMBVAgL5ge5YWfxXtUBw
         4zJxQPmk6vce46CZvhUPuDxFlcluTMOgqo4ZfJhGhez6hi4FluLh0PzSZk5wwdj7hH6k
         1LDstPMg7l2Ioi8rBDTdnwDhv36pLaMad+KMeCABFX1nI3tUTVDXJP9gWoNzfQLRrIc6
         z6cbliUQlfOFh9hfTiHXWE0XUbd8BIzy2fm2Ocv/B0wZ4pNqTYMh4RgL0cUhsSyIlCXZ
         8OWzBtL+KYZLCW6/yWPtPlYRx7xNpqr3NF3kx9PakGKa8WouggXLPmvq1nRHqR/hTU19
         z3mg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAVt05I0MSJdYUdhiTCxrtuuyAjMVWB2Pbfbc9T6Q/+i+BbvOwE3
	t9Yf41Oqz88gKwG5lltXfLBe5XQAOSQ8JoAanBl6w3TlbzlFLmsckf2PCuqjpSkcFBi+vL4oYPr
	DG/n2zy96oZvUSJyEbGW+7PRAespirzccW30ua+aVUxOx+NGaEqWnOvC5G2X/21U=
X-Received: by 2002:a17:906:6a1a:: with SMTP id o26mr20463311ejr.265.1558398805641;
        Mon, 20 May 2019 17:33:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHdYVPrYHYBhKFeUU/qizNeOu6j0zXDlzW+BCHCiqHRv8mNO57Q2cS+8Y+pY8eSh9RqJfs
X-Received: by 2002:a17:906:6a1a:: with SMTP id o26mr20463272ejr.265.1558398804805;
        Mon, 20 May 2019 17:33:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558398804; cv=none;
        d=google.com; s=arc-20160816;
        b=E3rrLpJfPQ2Z7VR2G0LWVgGzGm6DsGZF7tkRrMC0amnM+lOentu6I1WhLwn0WGZsl9
         djf3etItVDGWf6jJ2dmEVZE8y4PrXyReqvVwRJEVLif2rh56vwNnki5Y9KChgzXRGzyv
         UlB7a7cKnGY5iyesQVtEDQubU5ANRJmR5apTeMFXdBEdd9z9C5Lutv0kdheMAnVdK4hC
         yRPd5yiv9O/oeP5gCRNl0BJe+YSiKGrPtpPGgDRjAGylqB3nbc6q7oQS4MfLUvPkJUN0
         LnJeiQ+hALylm4uBnp4a+iZNqhcAUDZah488/YsGD/non2COEC4ug1Wu6gEFynvYQYnn
         P8XA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=iqyrGdY5nUcJTAoyQ9D67Ht+r/DpYjgGax4vpXQLUXw=;
        b=X+GYjRY913uOloF5OUkU0RQU7sFNfkAeiKWWHA+ldMJYz7TOTqMZFjY/fBqd9lvq+B
         JcAFH4pDZ2eycyRgkyHkeduy65SC+qH/VcD3wSJ5M+trD2YKv9TmcJsFVh1NQ1SOyP1O
         PNRk3kIR+PLoLtbMpN+RxFJWYsk5PU8Mu/WG4WBLk/NgdbkFoHw7saSIch+CjcpNPP9k
         KPVjTb7CfkNqvgpjcbNqc86fOlfy9Mg0oySJ83uKrak85JYVGHpBwJZPRt2qS6MI+5tA
         xtXkBgmL3GlHVTGmLj1oMj2G218JP9RlXDxENgO2Vhs0EoOWRBEy/0S/+ZjUCi2mCyDt
         MFyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id b58si3473850ede.285.2019.05.20.17.33.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 17:33:24 -0700 (PDT)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (50-78-161-185-static.hfc.comcastbusiness.net [50.78.161.185])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id B81BD1400F7CA;
	Mon, 20 May 2019 17:33:20 -0700 (PDT)
Date: Mon, 20 May 2019 20:33:20 -0400 (EDT)
Message-Id: <20190520.203320.621504228022195532.davem@davemloft.net>
To: rick.p.edgecombe@intel.com
Cc: linux-kernel@vger.kernel.org, peterz@infradead.org, linux-mm@kvack.org,
 mroos@linux.ee, mingo@redhat.com, namit@vmware.com, luto@kernel.org,
 bp@alien8.de, netdev@vger.kernel.org, dave.hansen@intel.com,
 sparclinux@vger.kernel.org
Subject: Re: [PATCH v2] vmalloc: Fix issues with flush flag
From: David Miller <davem@davemloft.net>
In-Reply-To: <3e7e674c1fe094cd8dbe0c8933db18be1a37d76d.camel@intel.com>
References: <c6020a01e81d08342e1a2b3ae7e03d55858480ba.camel@intel.com>
	<20190520.154855.2207738976381931092.davem@davemloft.net>
	<3e7e674c1fe094cd8dbe0c8933db18be1a37d76d.camel@intel.com>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Mon, 20 May 2019 17:33:21 -0700 (PDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Date: Tue, 21 May 2019 00:20:13 +0000

> This behavior shouldn't happen until modules or BPF are being freed.

Then that would rule out my theory.

The only thing left is whether the permissions are actually set
properly.  If they aren't we'll take an exception when the BPF program
is run and I'm not %100 sure that kernel execute permission violations
are totally handled cleanly.

