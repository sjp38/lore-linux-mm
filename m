Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 601D0C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 15:47:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20D5F206BA
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 15:47:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="ELmtJvi4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20D5F206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B24C16B000E; Wed,  3 Apr 2019 11:47:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AAC256B0010; Wed,  3 Apr 2019 11:47:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94E636B0266; Wed,  3 Apr 2019 11:47:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 74BBD6B000E
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 11:47:49 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id x58so17210140qtc.1
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 08:47:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=4v128Tp+ktDAhV/qENqEBuzjLJBLhHo3lzR/qUMTRlo=;
        b=HwhrM1k+mnBe/7ONDlSPgh5k+/qqdpJzS8V7psHOc2H0PjICn9ehFfnhMNNL7dhFwC
         v0nxGmeDyOp70HAy/Y7dE+07c7rkYHdxknqQXFJwCBnLqROZp1y0vMWaaz2XA8izlqK9
         fvwR1/OIYjDgTd+zG6SqJTTywd9CpQvh8Iexd3+EIEzaWqxzjQmeSXfOiD7qg2Usonk+
         YHZ4UEP/JxGONvX9Y/MJhPp2GF37EbqdTfYV3cnjUbVyXZGqAC69kvJ3ieGUP/VZ7gto
         UvY8PGT3jPXu6yzP53MC5JRGW9pzIpH684dWzrFte9nipiDABGw+cBrYGowuTpGuucuA
         teBA==
X-Gm-Message-State: APjAAAUNRN/kCCGvtOC40l4h+2u5dVpoPl3Lby7qgyhO9SNlSyic+rCe
	j1SxUjyHmGeacSAVTaAZYVWydPQk+rLQEl5oaoykj4QXsk+tnlZdHL3cPwXb4010Ud5/aA4ATBI
	lEyjHO4eEfEHngABWwd7GyjNiaMcWPve2tMhVx0+Reetf1LgB2PetRFhyXoGbpRI=
X-Received: by 2002:ac8:3697:: with SMTP id a23mr623139qtc.18.1554306469280;
        Wed, 03 Apr 2019 08:47:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAmCtPbR/iq76Ul/xnMgJEZsZxlCldEq24I/39iRGoRHnp9GaE2Ks3JqgtZ0QYONhWr0Z2
X-Received: by 2002:ac8:3697:: with SMTP id a23mr623086qtc.18.1554306468634;
        Wed, 03 Apr 2019 08:47:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554306468; cv=none;
        d=google.com; s=arc-20160816;
        b=lYBhKUCyChHMS878lzGv7eplYfXDl5Uk30yvHzW+YBnI54ZFQHwtDiv8hP0MNqY2CS
         4y+BUBbcO6R7PCNtRq4wcnV3mDcQNCo/EV3QyLParNLSvuec+k39lq+ygmtRBf/K6AKK
         Is5y3CFKx/LqdFfg0vjI43/lRcO+rV0ZyTTgZGLIKEVqpNi3UilsXLioDHdEBd5gHSSj
         7uGAzomcagR/lZcbe2xOk+ofJOMZNxhBsW4/XtZcXLQVhmt97USVp5yrmUXT857Nm0O/
         upt7cdWMoZik74UyWXifD4fWSLaSm52OI20P/IqUuflW7m7cOOsbU2PYfgzbppa4nbjy
         B7jA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=4v128Tp+ktDAhV/qENqEBuzjLJBLhHo3lzR/qUMTRlo=;
        b=oqrjtQhwBdvxAAbcJzbhEIY0ikVrdIcYKZpCkMab7b9PImKi9I0adNJ2Q5IJIM3K3Z
         L3cCJVxcW9bEsZHZGBRANzUgncMnXbgkM0F8FKeo+rKp/SQG0EtgmBNle8ZwTJACT5O/
         cygDjFWZ8Hq9W/Cj+pvfBGxcToU8S28mQAFh0YnAzoOM3qsIojPRvRmXmm0+vOAngcrE
         +gMvsbTQdJ5TuYnVIRlNXVceUi1Go10dxoJcc92AeIJoQpgl3Cj1kUTUlN5O7oLEQNi/
         zeP4J+u7HsH7soMCMg+d5tTqnSmYRyIay9xM01SAmzLdXKwP7v1asn1PhJQ1YKTzcZ2g
         2/uw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=ELmtJvi4;
       spf=pass (google.com: domain of 01000169e3e28944-21265887-d95a-4fa8-aa8f-273534da9d3f-000000@amazonses.com designates 54.240.9.31 as permitted sender) smtp.mailfrom=01000169e3e28944-21265887-d95a-4fa8-aa8f-273534da9d3f-000000@amazonses.com
Received: from a9-31.smtp-out.amazonses.com (a9-31.smtp-out.amazonses.com. [54.240.9.31])
        by mx.google.com with ESMTPS id l33si644647qtl.17.2019.04.03.08.47.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Apr 2019 08:47:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169e3e28944-21265887-d95a-4fa8-aa8f-273534da9d3f-000000@amazonses.com designates 54.240.9.31 as permitted sender) client-ip=54.240.9.31;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=ELmtJvi4;
       spf=pass (google.com: domain of 01000169e3e28944-21265887-d95a-4fa8-aa8f-273534da9d3f-000000@amazonses.com designates 54.240.9.31 as permitted sender) smtp.mailfrom=01000169e3e28944-21265887-d95a-4fa8-aa8f-273534da9d3f-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1554306468;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=4v128Tp+ktDAhV/qENqEBuzjLJBLhHo3lzR/qUMTRlo=;
	b=ELmtJvi4GZ7ZoERT1B8Bc9h+UjZOvddW2NHG34cipS9X1c8yoc/mIdBDRKguIqSV
	9fVoiJ+C4U7kGKFFTsHaMk+AX5D+MmyK7xZYsOWxxiancikCL4Ne8dbml6K3x5ZOzAi
	8Sa+08FjtSPbG3Mec1SQZrXGc8Xz58t+APRDSb98=
Date: Wed, 3 Apr 2019 15:47:48 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: "Tobin C. Harding" <tobin@kernel.org>
cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthew Wilcox <willy@infradead.org>, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v5 3/7] slob: Use slab_list instead of lru
In-Reply-To: <20190402230545.2929-4-tobin@kernel.org>
Message-ID: <01000169e3e28944-21265887-d95a-4fa8-aa8f-273534da9d3f-000000@email.amazonses.com>
References: <20190402230545.2929-1-tobin@kernel.org> <20190402230545.2929-4-tobin@kernel.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.03-54.240.9.31
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Acked-by: Christoph Lameter <cl@linux.com>

