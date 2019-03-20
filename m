Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D8F1C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:44:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6C44217F9
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 00:44:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="PlP4+RjH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6C44217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F2E76B0003; Tue, 19 Mar 2019 20:44:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A2E66B0006; Tue, 19 Mar 2019 20:44:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B7BC6B0007; Tue, 19 Mar 2019 20:44:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6506B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 20:44:27 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id s87so15299836qks.23
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:44:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=l7GGzMPK2ZJjVEBw3exJiICCgYRKwnNAiKS5bg6nqGs=;
        b=gWj+7S6N9KiTVG7mGFTbMHqYBEvqX06euJrON9Hds2xg0LqdC+xWJFePNnkKLt6oG9
         E/xDXpK7HDodxdC83iSsweLqE3n3VgZZ4vtpACMUsVyDa1KBa4HJ2TjhlKCYYerS1oBd
         hwTDi/Cto4zEOrK8Obg5+ug9kqscqY4y+SvfC2Qje/ksBF52AgMlrK3U9aLSziohLNgW
         UCmmJmxDd5HJ+ZZUDIdskC2qc+jIcVEZBwm+5GAR087UCy2vvvr2Pr33dEU7nBQmv/jA
         wJlFAdvHMvFbs6fpD5GzrSpzwAZwCa9Vz5UlXlMmmyWShBoMhvTn0VbmoRqKhDjZIs8g
         F9jA==
X-Gm-Message-State: APjAAAWtBAAPcZobGQJzcTG64owACDcLt73y0AK8VsEe0Zq5KF0AMXjl
	N4eL5zaqgnwF09FxFeacxhbi42/nLZt9jQ4OSEVTGs2M1uWn64wtYK0wQH1EreLDAK0pwn9Qr7Q
	GK3SUwQnVLzNbRLAp/LctsaGgSJcBoDU9jgrxH0zhQWwvMVJiEpgmqpAjcHovEVM=
X-Received: by 2002:a37:6812:: with SMTP id d18mr4434809qkc.28.1553042667015;
        Tue, 19 Mar 2019 17:44:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLVv9K8NY1NpceIZqx2+SuYWdwohFGg+H9o/uOthPID02mmXffuLhFprhuY4W6o/rYnUMK
X-Received: by 2002:a37:6812:: with SMTP id d18mr4434779qkc.28.1553042666390;
        Tue, 19 Mar 2019 17:44:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553042666; cv=none;
        d=google.com; s=arc-20160816;
        b=qgBwoJrd8K2YHRU4AgVuHsOHEsLxX1NdL2mdNImNGDuCXDjbPFOJrk7drkT4hhMcc1
         9ztTsH272LhGLMfj4J/agYbfyFesnU46NF3/4KgleNYoun0d00HSBbHeMx9D9XYuLuLb
         fTgRQ6+svqd01KP9PqoIxap21S7ZVYrRqOzYxG4aC6GMXiW6oV8BFa3qdRzqBggBcLuU
         3a2iy1f/TrIL6DAUl9GuCUDsNlyXro8nD/TBIn8lGkogf0G372FFLRrZtiF3tOtxpUR7
         nfEEnki0+8/NUl/dg4TpiIdi/CoKDb1HA1OgNSXYFK7pgTP8SWwAR7t5QNhcnSvJ5k54
         Qosw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=l7GGzMPK2ZJjVEBw3exJiICCgYRKwnNAiKS5bg6nqGs=;
        b=vKO9OLbh0niC3mra6N8K7dr8MJvSRshYetSAE8P1+fFqvPxAgWQPrSDoyrJYwA33rs
         X+Y4mfWRNM9DiuEnRHHs3HxwvIghCf7Ok37LuqOtHLwrE2bf+pXgxoo0mL2UKDWRi+GC
         cvTMTWaPe8V5reJQwZ+eI0YfCm3syxSBidvXroF5omZCYQTGe1WQDpsuz5rcCuSwnW8B
         N3Vij9rewMU+k7pwLpNKfPGgjgbr2inOcCXPpbDGZKQkl4r0f/yd07cVBCJNUVUamJ0C
         qTfpTcPC6Ru5Qw3SuQjYsIslpBWzgZGyU3RordQwp/czidhBpfwlNz7k8CCbFb6nBSBa
         SGjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=PlP4+RjH;
       spf=pass (google.com: domain of 01000169988e707d-e6a091d6-b04f-4774-89b0-61f985885ac8-000000@amazonses.com designates 54.240.9.46 as permitted sender) smtp.mailfrom=01000169988e707d-e6a091d6-b04f-4774-89b0-61f985885ac8-000000@amazonses.com
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id y143si250611qka.178.2019.03.19.17.44.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Mar 2019 17:44:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169988e707d-e6a091d6-b04f-4774-89b0-61f985885ac8-000000@amazonses.com designates 54.240.9.46 as permitted sender) client-ip=54.240.9.46;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=PlP4+RjH;
       spf=pass (google.com: domain of 01000169988e707d-e6a091d6-b04f-4774-89b0-61f985885ac8-000000@amazonses.com designates 54.240.9.46 as permitted sender) smtp.mailfrom=01000169988e707d-e6a091d6-b04f-4774-89b0-61f985885ac8-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1553042665;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=l7GGzMPK2ZJjVEBw3exJiICCgYRKwnNAiKS5bg6nqGs=;
	b=PlP4+RjHhS99d2viVKcqtgP13+3ae9Tceh7+ncOi1pmU/SV90eao0W6UVO4C/ysv
	bNKfYHD0TzHglvVEcijO11H/eX6miTYFt0JcCQdbZNOfnu9WN5xAD9dT4X/tJTX14dv
	btQifloIUFWP1UlOx8StJAo3W4BZdudfSoVgoHeA=
Date: Wed, 20 Mar 2019 00:44:25 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Vlastimil Babka <vbabka@suse.cz>
cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, 
    David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>, 
    Matthew Wilcox <willy@infradead.org>, 
    "Darrick J . Wong" <darrick.wong@oracle.com>, 
    Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@kernel.org>, 
    linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, 
    linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Subject: Re: [RFC 2/2] mm, sl[aou]b: test whether kmalloc() alignment works
 as expected
In-Reply-To: <20190319211108.15495-3-vbabka@suse.cz>
Message-ID: <01000169988e707d-e6a091d6-b04f-4774-89b0-61f985885ac8-000000@email.amazonses.com>
References: <20190319211108.15495-1-vbabka@suse.cz> <20190319211108.15495-3-vbabka@suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.20-54.240.9.46
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Mar 2019, Vlastimil Babka wrote:

> Quick and dirty init test that kmalloc() alignment works as expected for
> power-of-two sizes after the previous patch.

There is already an allocator testing function in mm/slub.c. Can you
generalize it or portions and put the into mm/slab_common.c?

