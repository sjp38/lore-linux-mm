Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B870CC4CECD
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 15:52:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D4462186A
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 15:52:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="BjuKfMTA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D4462186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9E7E6B0005; Mon, 16 Sep 2019 11:52:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4E1D6B0006; Mon, 16 Sep 2019 11:52:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C641F6B0007; Mon, 16 Sep 2019 11:52:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0150.hostedemail.com [216.40.44.150])
	by kanga.kvack.org (Postfix) with ESMTP id A72346B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 11:52:53 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 1B80E181AC9AE
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 15:52:53 +0000 (UTC)
X-FDA: 75941227026.26.money17_191f9977ca457
X-HE-Tag: money17_191f9977ca457
X-Filterd-Recvd-Size: 2113
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com [54.240.9.46])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 15:52:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1568649171;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=5vsv823iDPGFqRA288qUAJ1tOsFdw0E0KGwM0/qQ2Ps=;
	b=BjuKfMTADiwEeMWyIpJEGOUsDVO+rsGwaTH3gqgSOxtgsdvECTqZ3/s3cCfM2LB+
	9k7BvUnLTxAQiKLKaXJuhqBKWNu8xCfgQzHeyQBETbfEXUJXAY9POhufCvxdlRNn44g
	PQau6lgBseHE0pEXOwrqhJg1UafuqcFBpQPGmXpY=
Date: Mon, 16 Sep 2019 15:52:51 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Pengfei Li <lpf.vector@gmail.com>
cc: akpm@linux-foundation.org, vbabka@suse.cz, penberg@kernel.org, 
    rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, guro@fb.com
Subject: Re: [PATCH v5 7/7] mm, slab_common: Modify kmalloc_caches[type][idx]
 to kmalloc_caches[idx][type]
In-Reply-To: <20190916144558.27282-8-lpf.vector@gmail.com>
Message-ID: <0100016d3ac6d132-891c437f-2aeb-41de-84d8-aec48bc20ee4-000000@email.amazonses.com>
References: <20190916144558.27282-1-lpf.vector@gmail.com> <20190916144558.27282-8-lpf.vector@gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.09.16-54.240.9.46
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000005, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Sep 2019, Pengfei Li wrote:

> KMALLOC_NORMAL is the most frequently accessed, and kmalloc_caches[]
> is initialized by different types of the same size.
>
> So modifying kmalloc_caches[type][idx] to kmalloc_caches[idx][type]
> will benefit performance.


Why would that increase performance? Using your scheme means that the
KMALLOC_NORMAL pointers are spread over more cachelines. Since
KMALLOC_NORMAL is most frequently accessed this would cause
a performance regression.


