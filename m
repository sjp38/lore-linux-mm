Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97BD3C10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 11:10:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39059208E3
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 11:10:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39059208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 903296B0005; Mon,  8 Apr 2019 07:10:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B2C86B0006; Mon,  8 Apr 2019 07:10:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77A6A6B0008; Mon,  8 Apr 2019 07:10:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 555516B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 07:10:16 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id n10so12383708qtk.9
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 04:10:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=5SwtPcNm5BIhPYOvUvJCm7LgrWhar3+GK0KamQKkO+k=;
        b=s60m3Ec6/h7QmkoZE7lJu3WcMmkZUiPAyoTuahQoxT9ZJOeiI4o9Pmrums8xoi2toq
         /UjtK3TVGZQafLYTODiQZ5SHmpgkTrvXT6Id/iAD0/OAjcB1RW6DTQEXwOc9uXPvcAkJ
         ZJujZg5QJP7s0VS+ebVyiHijai45f7B7paSkOF6NdefSszCBGeAh8B8HKv/1f75uAKP1
         i1hCzv3eDHz+FZU7R8BMlUWI8tG2UXFQCFhZSwpV1JmS+qkTdG0ITKoVjVT4WuqLhzgD
         12IU28m3qRGPUbQlcKnzzdGvDYT0SBNwPPoe515B7mKNcKkC/FNQCJpItnQfHba5jk5D
         aNng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mpatocka@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mpatocka@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXZQEh7KfLG4ONNVW1c2PDrQw0MTtT/TdLUnRs0nurXrjuVJDRr
	zN6ByYHHgMrXISTySasylfSx/3BdM/aQCPddEMaWD+2uKn3oqCJr9Q1UAaDnAVVnc8WREXTVeMk
	1CrbN+JQMi3m/NzGVuiT87tOs/04oQdl5UDaI2bXQfUJV5wXbiQkswpALtMGWbf5fmg==
X-Received: by 2002:a05:620a:1597:: with SMTP id d23mr21390239qkk.226.1554721816036;
        Mon, 08 Apr 2019 04:10:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxc2NWF3N/zGtKotbgzmdsMpYZN3GTklq8IGlDFgzRwzS0OQlnXJOfj4gPlds8zbQEoj03o
X-Received: by 2002:a05:620a:1597:: with SMTP id d23mr21390174qkk.226.1554721815091;
        Mon, 08 Apr 2019 04:10:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554721815; cv=none;
        d=google.com; s=arc-20160816;
        b=iooMVPCrlB0MYzhgT4NkwToMwby9JhgNkpiUsM1lwS+xpmgBlHsQLvIufiSEAUP19o
         2nHSzTvLvwAH/jPfOIPHk9FGH1DIN/OA36w3l4yk9Gr1qRqRtIHuVQY+p29AXV4OdwNx
         uS02U43vQnGhBcaKIN06qmT+amoo5P5ol8lyuOzMUnoJQFo99MbNNqbURP3kR3i5OXLn
         RA+lcXSjmwH+Ze8f7OMsQ+QJyETKyo1LnOiNhnxaURuwCbPHs/HYs2QvvLN4h6Et6Ljq
         6k+eHqmPeeQpLUuHPIUBKt5V2C0Y+qtG7WANM1KoHub+NoBsN5RWa0strg8fwqc5N+wh
         MC9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=5SwtPcNm5BIhPYOvUvJCm7LgrWhar3+GK0KamQKkO+k=;
        b=NLrwtfwn/Xw9exE9cqh9eJNJqWSgdYZl1jptOnNnMsFXQnq/4zDqttcczS8s5B8WvW
         KrTkwYFVa76w9/wr6a8tgoSVHb9esDCALoLfI+VGaO6kcQ7axIEklqfjsKNKr3iAWufG
         vw7JgCv2zv70pqEpeVi9gY9MjCPTLvKquMrYHSWU/a8iKjE9cRWA5Ik3/92+g2quUJNI
         b5NSgmk4K3GwrR4FfHwOay8JKjOuIf+x0AUOS8ZxVq15bUmyzBg0o/p3cSCVDWyopZfS
         BlNmFJL65PP2Y0rYLeA+xEHxLMSUN94K0WyEKKAQrwpdQHaRtWvsvIAK6UO83Z6RDGUe
         uN+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mpatocka@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mpatocka@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g10si2067330qkl.87.2019.04.08.04.10.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 04:10:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of mpatocka@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mpatocka@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mpatocka@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 22B8F3082A27;
	Mon,  8 Apr 2019 11:10:14 +0000 (UTC)
Received: from file01.intranet.prod.int.rdu2.redhat.com (file01.intranet.prod.int.rdu2.redhat.com [10.11.5.7])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A1FF866D3E;
	Mon,  8 Apr 2019 11:10:13 +0000 (UTC)
Received: from file01.intranet.prod.int.rdu2.redhat.com (localhost [127.0.0.1])
	by file01.intranet.prod.int.rdu2.redhat.com (8.14.4/8.14.4) with ESMTP id x38BADIx012994;
	Mon, 8 Apr 2019 07:10:13 -0400
Received: from localhost (mpatocka@localhost)
	by file01.intranet.prod.int.rdu2.redhat.com (8.14.4/8.14.4/Submit) with ESMTP id x38BABug012990;
	Mon, 8 Apr 2019 07:10:11 -0400
X-Authentication-Warning: file01.intranet.prod.int.rdu2.redhat.com: mpatocka owned process doing -bs
Date: Mon, 8 Apr 2019 07:10:11 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
X-X-Sender: mpatocka@file01.intranet.prod.int.rdu2.redhat.com
To: Mel Gorman <mgorman@techsingularity.net>
cc: Andrew Morton <akpm@linux-foundation.org>, Helge Deller <deller@gmx.de>,
        "James E.J. Bottomley" <James.Bottomley@hansenpartnership.com>,
        John David Anglin <dave.anglin@bell.net>, linux-parisc@vger.kernel.org,
        linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>,
        Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: Memory management broken by "mm: reclaim small amounts of memory
 when an external fragmentation event occurs"
In-Reply-To: <20190408095224.GA18914@techsingularity.net>
Message-ID: <alpine.LRH.2.02.1904080639570.4674@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1904061042490.9597@file01.intranet.prod.int.rdu2.redhat.com> <20190408095224.GA18914@techsingularity.net>
User-Agent: Alpine 2.02 (LRH 1266 2009-07-14)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Mon, 08 Apr 2019 11:10:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On Mon, 8 Apr 2019, Mel Gorman wrote:

> On Sat, Apr 06, 2019 at 11:20:35AM -0400, Mikulas Patocka wrote:
> > Hi
> > 
> > The patch 1c30844d2dfe272d58c8fc000960b835d13aa2ac ("mm: reclaim small 
> > amounts of memory when an external fragmentation event occurs") breaks 
> > memory management on parisc.
> > 
> > I have a parisc machine with 7GiB RAM, the chipset maps the physical 
> > memory to three zones:
> > 	0) Start 0x0000000000000000 End 0x000000003fffffff Size   1024 MB
> > 	1) Start 0x0000000100000000 End 0x00000001bfdfffff Size   3070 MB
> > 	2) Start 0x0000004040000000 End 0x00000040ffffffff Size   3072 MB
> > (but it is not NUMA)
> > 
> > With the patch 1c30844d2, the kernel will incorrectly reclaim the first 
> > zone when it fills up, ignoring the fact that there are two completely 
> > free zones. Basiscally, it limits cache size to 1GiB.
> > 
> > For example, if I run:
> > # dd if=/dev/sda of=/dev/null bs=1M count=2048
> > 
> > - with the proper kernel, there should be "Buffers - 2GiB" when this 
> > command finishes. With the patch 1c30844d2, buffers will consume just 1GiB 
> > or slightly more, because the kernel was incorrectly reclaiming them.
> > 
> 
> I could argue that the feature is behaving as expected for separate
> pgdats but that's neither here nor there. The bug is real but I have a
> few questions.
> 
> First, if pa-risc is !NUMA then why are separate local ranges
> represented as separate nodes? Is it because of DISCONTIGMEM or something
> else? DISCONTIGMEM is before my time so I'm not familiar with it and

I'm not an expert in this area, I don't know.

> I consider it "essentially dead" but the arch init code seems to setup
> pgdats for each physical contiguous range so it's a possibility. The most
> likely explanation is pa-risc does not have hardware with addressing
> limitations smaller than the CPUs physical address limits and it's
> possible to have more ranges than available zones but clarification would
> be nice.  By rights, SPARSEMEM would be supported on pa-risc but that
> would be a time-consuming and somewhat futile exercise.  Regardless of the
> explanation, as pa-risc does not appear to support transparent hugepages,
> an option is to special case watermark_boost_factor to be 0 on DISCONTIGMEM
> as that commit was primarily about THP with secondary concerns around
> SLUB. This is probably the most straight-forward solution but it'd need
> a comment obviously. I do not know what the distro configurations for
> pa-risc set as I'm not a user of gentoo or debian.

I use Debian Sid, but I compile my own kernel. I uploaded the kernel 
.config here: 
http://people.redhat.com/~mpatocka/testcases/parisc-config.txt

> Second, if you set the sysctl vm.watermark_boost_factor=0, does the
> problem go away? If so, an option would be to set this sysctl to 0 by
> default on distros that support pa-risc. Would that be suitable?

I have tried it and the problem almost goes away. With 
vm.watermark_boost_factor=0, if I read 2GiB data from the disk, the buffer 
cache will contain about 1.8GiB. So, there's still some superfluous page 
reclaim, but it is smaller.


BTW. I'm interested - on real NUMA machines - is reclaiming the file cache 
really a better option than allocating the file cache from non-local node?


> Finally, I'm sure this has been asked before buy why is pa-risc alive?
> It appears a new CPU has not been manufactured since 2005. Even Alpha
> I can understand being semi-alive since it's an interesting case for
> weakly-ordered memory models. pa-risc appears to be supported and active
> for debian at least so someone cares. It's not the only feature like this
> that is bizarrely alive but it is curious -- 32 bit NUMA support on x86,
> I'm looking at you, your machines are all dead since the early 2000's
> AFAIK and anyone else using NUMA on 32-bit x86 needs their head examined.

I use it to test programs for portability to risc.

If one could choose between buying an expensive power system or a cheap 
pa-risc system, pa-risc may be a better choice. The last pa-risc model has 
four cores at 1.1GHz, so it is not completely unuseable.

Mikulas

> -- 
> Mel Gorman
> SUSE Labs
> 

