Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A55E4C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 19:48:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54C9B206DF
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 19:48:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54C9B206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA6008E0003; Fri,  8 Mar 2019 14:48:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2DAD8E0002; Fri,  8 Mar 2019 14:48:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F59C8E0003; Fri,  8 Mar 2019 14:48:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6868E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 14:48:51 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id d49so19723779qtd.15
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 11:48:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Fm7oII2sYoGp7vj/cdoeKjPe6Bvpb2uwGf3qNVR/xlM=;
        b=siuKkHR5UD3oQHVu0j1a7yxAmesA2iqjZCNbcQta0zdNxRVcNU+sTG32s2xuJNB0Zf
         MMZ/eymiixPVGtHZ1db+V8eXjwqB9LeTO4cOPw08aAS7j/oxGQ9+q+I/AbLTpoJiLhXF
         pl2HCDboLotYZB6b69JZTpMMs45afThbzCss8m2C+gagDh4is0jC0S9OqZnplhDTd8tE
         ibL2o/i2HUgvDxGjM52rDQ2lw5sSzSz3nuuBa5UwJeo4vvRVvZL1ORnAPh0xEp1z8q+T
         itNm7cEJEvktzKijRM7lKutpVCrb0YPIa/xeqIQW9p1HNWXe2nDBnWfiLEkqHA5eJDCj
         Y9vQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV3gOHy1FuHnMNZ7XpYZu777UEAOXI8QtkOHZwOo3x08gVjO0vF
	TDbFcz4MmLQrNVYiLF0nAa1rlnbFk7Q+vMjQauK2A4prRdgTQO3m8+w7zaJxy6Yr4YeWl3Th2oi
	dYlgpQiuRK+pUNeBKgX4TrmNjmN37/Uh1E/oyHiYsY7y7SFBFXcWihhn3lGlxWW8cNw==
X-Received: by 2002:a37:a7ca:: with SMTP id q193mr15631462qke.102.1552074531108;
        Fri, 08 Mar 2019 11:48:51 -0800 (PST)
X-Google-Smtp-Source: APXvYqy9QU2EIpj8dv4jxmdKaZNeAJd6ceNxGNIfrisnnppESTyK9dW+ZoiSoiBFNaJtNxZpnuVI
X-Received: by 2002:a37:a7ca:: with SMTP id q193mr15631424qke.102.1552074530263;
        Fri, 08 Mar 2019 11:48:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552074530; cv=none;
        d=google.com; s=arc-20160816;
        b=NB4GPyH7bbjvINLIFHVLIrurJHArWQnNDU7dw0pAlxvRcNW6pEwZKNr9LVM7CVQf/S
         ojj5zk79mxIo9Ke6sX5phpHdJfPM39XBGNUky2CaHL7YMRP1ZTJ+WavpontoO0OZH9fI
         ag3H6hz/skjOwmCFy84ha29uRp9xdo9irHiCvysyag4B1zFdicXuw4M8uplfagEeWkpL
         SCXFZy316qrl+GQQspqlpd+cdXHCVFStE90R5Jvh4daQIWyCFPdSLhRaQsJSU0udw/GS
         zHg601F5IXJAPJ3pxeAcrCF1hsOS9y22ja4nR99aXiVPZT8tBh2og76hFeVv23IQnqZs
         9KFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Fm7oII2sYoGp7vj/cdoeKjPe6Bvpb2uwGf3qNVR/xlM=;
        b=hyQeLnPaD+4TwhW4B0CkqH/ZcY5EJCdU3F6l8kiDHt8PYjIxcIAQxj8RfzONOVyJ+i
         HiM0PhZ/q1l+CalO11wJVgdRj+y2SLPFSdaDQwuGBDxEujwLUAr15Vp7XZ4sSyly9tCS
         iBN5aPuqi/6Fr3M1NBohSzIwfy9oTgx9EmHU01amWLHLwFGrAn0JbZFhS5B41fb4bpFO
         N7QxQNjY06E5DVDQad1bVceR7Aq6xYEN4GFL++KKPTGq+ximxabpILtQFGKxoQfT/Zw8
         XyVTkz4lb35ejGN/PxWC/uFyDqPIDa2QDaT/+6iF7aQ4kewdb/Gt7TFxvNvPbIXulF/F
         KV2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f9si5285481qkl.133.2019.03.08.11.48.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 11:48:50 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 473C930B4ACE;
	Fri,  8 Mar 2019 19:48:49 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1DCE01001DDE;
	Fri,  8 Mar 2019 19:48:46 +0000 (UTC)
Date: Fri, 8 Mar 2019 14:48:45 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190308194845.GC26923@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191622.GP23850@redhat.com>
 <e2fad6ed-9257-b53c-394b-bc913fc444c0@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e2fad6ed-9257-b53c-394b-bc913fc444c0@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Fri, 08 Mar 2019 19:48:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Jeson,

On Fri, Mar 08, 2019 at 04:50:36PM +0800, Jason Wang wrote:
> Just to make sure I understand here. For boosting through huge TLB, do 
> you mean we can do that in the future (e.g by mapping more userspace 
> pages to kenrel) or it can be done by this series (only about three 4K 
> pages were vmapped per virtqueue)?

When I answered about the advantages of mmu notifier and I mentioned
guaranteed 2m/gigapages where available, I overlooked the detail you
were using vmap instead of kmap. So with vmap you're actually doing
the opposite, it slows down the access because it will always use a 4k
TLB even if QEMU runs on THP or gigapages hugetlbfs.

If there's just one page (or a few pages) in each vmap there's no need
of vmap, the linearity vmap provides doesn't pay off in such
case.

So likely there's further room for improvement here that you can
achieve in the current series by just dropping vmap/vunmap.

You can just use kmap (or kmap_atomic if you're in preemptible
section, should work from bh/irq).

In short the mmu notifier to invalidate only sets a "struct page *
userringpage" pointer to NULL without calls to vunmap.

In all cases immediately after gup_fast returns you can always call
put_page immediately (which explains why I'd like an option to drop
FOLL_GET from gup_fast to speed it up).

Then you can check the sequence_counter and inc/dec counter increased
by _start/_end. That will tell you if the page you got and you called
put_page to immediately unpin it or even to free it, cannot go away
under you until the invalidate is called.

If sequence counters and counter tells that gup_fast raced with anyt
mmu notifier invalidate you can just repeat gup_fast. Otherwise you're
done, the page cannot go away under you, the host virtual to host
physical mapping cannot change either. And the page is not pinned
either. So you can just set the "struct page * userringpage = page"
where "page" was the one setup by gup_fast.

When later the invalidate runs, you can just call set_page_dirty if
gup_fast was called with "write = 1" and then you clear the pointer
"userringpage = NULL".

When you need to read/write to the memory
kmap/kmap_atomic(userringpage) should work.

In short because there's no hardware involvement here, the established
mapping is just the pointer to the page, there is no need of setting
up any pagetables or to do any TLB flushes (except on 32bit archs if
the page is above the direct mapping but it never happens on 64bit
archs).

Thanks,
Andrea

