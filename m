Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A6A9C10F14
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 19:44:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8EE420863
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 19:44:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="kiI+V52P";
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="kiI+V52P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8EE420863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DAA06B0007; Mon,  8 Apr 2019 15:44:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 387066B000A; Mon,  8 Apr 2019 15:44:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2779D6B000C; Mon,  8 Apr 2019 15:44:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 043D86B0007
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 15:44:54 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id x9so11521289ybj.7
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 12:44:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:message-id:subject
         :from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=j17EOXVZnJSo277VgSbgc+6AY/HTOrI6slDiaQqALKY=;
        b=IYD7hzLCaSgwLMtamiDY0BHOEV19LUOIYlmyEa4MZa6ogOlGfY2CdZoIReig/KineZ
         iUIpNUgSiwuZRZWYIT6zTVFvO/bPfacRNB/z1PzxdY2pUAq47sUewbqqNEXZyb3mx0F7
         G4LciWNO1L4A+psGSAQ996cwyheLb9BviVzk/IQhsDHQkpGyuIMsP4veYiknWZuw0dha
         brAeO8zH/AKtoPd3iUdkJ4o1xNKf7TjSjVpy/edgUdiUuOc5M5mZ23t8+3QscD7N0lbq
         lASoNd4cheIMgpT5Qf6Rjq2LFGE3a+/8aKRTF/zAS5YfuTDsVP51AzhRe6MSYhLJynx6
         GfnA==
X-Gm-Message-State: APjAAAXc0cBfqDv/SGrtPA0O8yn7IxxHhghgVRY9AeQLBP5S3rK5m5YO
	MCnUhHN+yCS7HECDICcI582FKx4l+6uUmtXDTCHiuS6M1Y/+sw9kYiV2ugnvGXiCs5oMeQqxLlb
	OFtWEOqnQ+DqQOPg5BGyon/DxtqAQhkMKMLqLfOT7VATkqt1qj3Tk+VmwNsDGklDH1A==
X-Received: by 2002:a81:4fcb:: with SMTP id d194mr25731069ywb.171.1554752693636;
        Mon, 08 Apr 2019 12:44:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWtLEb/zh9KQ9MtpWkhdLy5jkCW4ZZ6K0T0AFyEEoAlqv1ZNuGhGnhv3UOE33a4Ke/0BAJ
X-Received: by 2002:a81:4fcb:: with SMTP id d194mr25731013ywb.171.1554752692796;
        Mon, 08 Apr 2019 12:44:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554752692; cv=none;
        d=google.com; s=arc-20160816;
        b=oeCz6JwJ+uU27bTYGJ8qgLAy2qf0q7qkaI6QSFIgHwcsgQC1X4H1W0f3sRY8C9TwLO
         OMBSdLohAt6YtxlqF+VgoYVC7LwGBoCuv1tdieKE5SxM2NpMAJCAgGZcOeGzSUmZ6cVR
         u0KErRSMarNc+WU8GJeMUaLwJY5EScJ4sz4CNcgBKW0ONlCYfq7poCwXBhSrYHMPdhqg
         dBeEjdnvc4VnTMz67rPPYofnFupcPpLgJzsPu0GxcrKTeD1uHgzQvMX3sASxuxjmMVM7
         CpdjuqvN4pzbIkVbERn1o2QfG05/17Y+oDvnx3gLLx+982Zm9Pmd51sPf93QsQauKOzd
         AT7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature:dkim-signature;
        bh=j17EOXVZnJSo277VgSbgc+6AY/HTOrI6slDiaQqALKY=;
        b=Y4ekuBV5VOpgZieem9W5WYhyzEKG0Wn4KbY0KQssnwYhkkxqmTFg3F7MSjWki4J/nV
         +8x/o2+W4+J7lAahFfwQoH3JsTCuzo90WXihpKqCC9Cqc4WVnUfyjOyMeuY+JN/5gcVR
         OddioQ4bwGBVsOcAcfYtnDmHH+GvZsr6GhjmcF8pY6sSDIGf9DTJCUH5bnAaxT04CAz5
         kwQR5BMcBCIL/jhJZmZrkKXHrlsPCU6uhcmRqie9wT5GBc3cTUFRZnMUO+Md0Hu0oQUp
         zEcA8i0o5jMjuOuiyB5vWQNIUMfrDbdofdV1k9AZBTW95T5rbR8h8iR6rVzWkalr6KAl
         1kng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=fail header.i=@hansenpartnership.com header.s=20151216 header.b=kiI+V52P;
       dkim=fail header.i=@hansenpartnership.com header.s=20151216 header.b=kiI+V52P;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id g8si1720045ybo.375.2019.04.08.12.44.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 08 Apr 2019 12:44:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=fail header.i=@hansenpartnership.com header.s=20151216 header.b=kiI+V52P;
       dkim=fail header.i=@hansenpartnership.com header.s=20151216 header.b=kiI+V52P;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id 904368EE0ED;
	Mon,  8 Apr 2019 12:44:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1554752690;
	bh=lyWACdjW8xXzOPzGVObCfEmFjzL6duzlAMiIgLxC8o0=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=kiI+V52PeJKs9CJMKxxWogJp0itLjuVeEQGJvWOFMNeOCNs33jKwG7kplrTaHiO51
	 vQ4O12gJapy3f8aXXr3p7N5LqLSpdevFhigmDJuScehSeaDlcNqmgWD7cbiB0IpoBm
	 b1nh4lURJ22jePI8DpSA92sPyFKK4XVSdwHtgFek=
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id jbt7uxPM6yKR; Mon,  8 Apr 2019 12:44:50 -0700 (PDT)
Received: from [172.16.10.48] (unknown [63.64.162.234])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id B2FFB8EE062;
	Mon,  8 Apr 2019 12:44:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1554752690;
	bh=lyWACdjW8xXzOPzGVObCfEmFjzL6duzlAMiIgLxC8o0=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=kiI+V52PeJKs9CJMKxxWogJp0itLjuVeEQGJvWOFMNeOCNs33jKwG7kplrTaHiO51
	 vQ4O12gJapy3f8aXXr3p7N5LqLSpdevFhigmDJuScehSeaDlcNqmgWD7cbiB0IpoBm
	 b1nh4lURJ22jePI8DpSA92sPyFKK4XVSdwHtgFek=
Message-ID: <1554752688.3634.6.camel@HansenPartnership.com>
Subject: Re: Memory management broken by "mm: reclaim small amounts of
 memory when an external fragmentation event occurs"
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Helge Deller <deller@gmx.de>, Mel Gorman <mgorman@techsingularity.net>, 
	Mikulas Patocka <mpatocka@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, John David Anglin
	 <dave.anglin@bell.net>, linux-parisc@vger.kernel.org, linux-mm@kvack.org, 
	Vlastimil Babka
	 <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan
	 <zi.yan@cs.rutgers.edu>
Date: Mon, 08 Apr 2019 12:44:48 -0700
In-Reply-To: <1aca1299-8713-3d54-7c5e-adf791509987@gmx.de>
References: 
	<alpine.LRH.2.02.1904061042490.9597@file01.intranet.prod.int.rdu2.redhat.com>
	 <20190408095224.GA18914@techsingularity.net>
	 <1554733749.3137.6.camel@HansenPartnership.com>
	 <1aca1299-8713-3d54-7c5e-adf791509987@gmx.de>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-04-08 at 17:22 +0200, Helge Deller wrote:
> On 08.04.19 16:29, James Bottomley wrote:
> > On Mon, 2019-04-08 at 10:52 +0100, Mel Gorman wrote:
> > > First, if pa-risc is !NUMA then why are separate local ranges
> > > represented as separate nodes? Is it because of DISCONTIGMEM or
> > > something else? DISCONTIGMEM is before my time so I'm not
> > > familiar with it and I consider it "essentially dead" but the
> > > arch init code seems to setup pgdats for each physical contiguous
> > > range so it's a possibility. The most likely explanation is pa-
> > > risc does not have hardware with addressing limitations smaller
> > > than the CPUs physical address limits and it's possible to have
> > > more ranges than available zones but clarification would be nice.
> > 
> > Let me try, since I remember the ancient history.  In the early
> > days, there had to be a single mem_map array covering all of
> > physical memory.  Some pa-risc systems had huge gaps in the
> > physical memory; I think one gap was somewhere around 1GB, so this
> > lead us to wasting huge amounts of space in mem_map on non-existent 
> > memory.  What CONFIG_DISCONTIGMEM did was allow you to represent
> > this discontinuity on a non-NUMA system using numa nodes, so we
> > effectively got one node per discontiguous range.  It's hacky, but
> > it worked.  I thought we finally got converted to sparsemem by the
> > NUMA people, but I can't find the commit.
> 
> James, you tried once:
> https://patchwork.kernel.org/patch/729441/

Ah, so what I was remembering as someone else's problem was, in fact,
my problem?  Hey, I should bottle my memory recall algorithms and sell
them as executive training courses.

> It seems we better should move over to sparsemem now?

I think so.  The basics of the patch likely apply and hopefully in the
intervening 8 years some of the problems I identified have been fixed.

James

