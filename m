Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CFDFC4740A
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:16:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E67542168B
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 09:16:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="ronRdJi2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E67542168B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 882DF6B0003; Tue, 10 Sep 2019 05:16:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 859E56B0008; Tue, 10 Sep 2019 05:16:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 770316B000A; Tue, 10 Sep 2019 05:16:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0149.hostedemail.com [216.40.44.149])
	by kanga.kvack.org (Postfix) with ESMTP id 564D36B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 05:16:27 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id C60456898
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:16:26 +0000 (UTC)
X-FDA: 75918455172.24.coal56_8f83458dde955
X-HE-Tag: coal56_8f83458dde955
X-Filterd-Recvd-Size: 5434
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 09:16:26 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id c19so16310619edy.10
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 02:16:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=So7xGEH+BMu4Cmi8/o4Tvt2NsS5FGolcX6sEtWgNC0A=;
        b=ronRdJi2C02VhhJUQoBvrvkdjEj9VZp6F/5OVMp/Tvq5efLXBnWTmpct2yAdWjw8vz
         MNK4D3AdTEVHu1HPXiyCfQH23vA5XGHpBWvLYDACfhfFSPZZjyXZOoZbJocqpJG7z4Z0
         wzdqhh8s3hog4Bz3Ltk37/j6PRajE8ldhKKILb8ujQyEAcXfuC5111cvqi6bXaE2ASYu
         FSN8NvbcjTDCYiWOxXFSRvZuNWk9YQPRwpU1g1iU0FvRYWuf0RzzIgckHJGAW3MjOHtS
         /69dyzoTUQg0CPNtMVjuMmd0biCJpjrd4GYRPmrvMKNgyaMWkD5xo9pMu/GYXhk+baIt
         U6QQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=So7xGEH+BMu4Cmi8/o4Tvt2NsS5FGolcX6sEtWgNC0A=;
        b=oQ6AFoaGllqN/8HAuFqI7QhWSNX191krAGbXRIKtdNDDst7gLh0DYg8bEN+fWSHxOp
         /lqY2UQ3+0yJq8eNxfwDTmJvNujT1sOUeAx/174O6mAfTm2OknIjxvjifstt/vTRIJiZ
         ggUkvfhrHBVRBWChhsIyERSSFXX+wjPBVudbIznE3LMYnjug55Q5uXgHFuqOCM851gxu
         YrKWpjWzd4Ahx8cT3P1uyAqpMqJRjxQWuBOq1zNeIO+TXflgiyuANjNF9ZTmOpNmJSr9
         jZa/Ndps4XGFstu7szduhpvJrM8FhgwVOkEAIk+YGD80xIgpluuSKdCXuWOgmIULd9jU
         7YQA==
X-Gm-Message-State: APjAAAW7fmD3RKWKIz0W40oUx990ozMZFGqUcG4u3S4khEpgQWmq8/pc
	HQb4Sxf6aQrFtzKZF25GmNlSZg==
X-Google-Smtp-Source: APXvYqxHBjTDGATRfQdbsKxUN6wcTweHctBP2RCdTije64kGWl+/NnSqzCFEB1FWYrnsfc0H8uUK7w==
X-Received: by 2002:a50:eb93:: with SMTP id y19mr22422147edr.65.1568106984968;
        Tue, 10 Sep 2019 02:16:24 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id c1sm3415525edr.37.2019.09.10.02.16.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Sep 2019 02:16:24 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 6A440102FF1; Tue, 10 Sep 2019 12:16:24 +0300 (+03)
Date: Tue, 10 Sep 2019 12:16:24 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Yu Zhao <yuzhao@google.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: avoid slub allocation while holding list_lock
Message-ID: <20190910091624.3knf6mzorkki67nb@box.shutemov.name>
References: <20190909061016.173927-1-yuzhao@google.com>
 <20190909160052.cxpfdmnrqucsilz2@box>
 <e5e25aa3-651d-92b4-ac82-c5011c66a7cb@I-love.SAKURA.ne.jp>
 <20190909213938.GA53078@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190909213938.GA53078@google.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 09, 2019 at 03:39:38PM -0600, Yu Zhao wrote:
> On Tue, Sep 10, 2019 at 05:57:22AM +0900, Tetsuo Handa wrote:
> > On 2019/09/10 1:00, Kirill A. Shutemov wrote:
> > > On Mon, Sep 09, 2019 at 12:10:16AM -0600, Yu Zhao wrote:
> > >> If we are already under list_lock, don't call kmalloc(). Otherwise we
> > >> will run into deadlock because kmalloc() also tries to grab the same
> > >> lock.
> > >>
> > >> Instead, allocate pages directly. Given currently page->objects has
> > >> 15 bits, we only need 1 page. We may waste some memory but we only do
> > >> so when slub debug is on.
> > >>
> > >>   WARNING: possible recursive locking detected
> > >>   --------------------------------------------
> > >>   mount-encrypted/4921 is trying to acquire lock:
> > >>   (&(&n->list_lock)->rlock){-.-.}, at: ___slab_alloc+0x104/0x437
> > >>
> > >>   but task is already holding lock:
> > >>   (&(&n->list_lock)->rlock){-.-.}, at: __kmem_cache_shutdown+0x81/0x3cb
> > >>
> > >>   other info that might help us debug this:
> > >>    Possible unsafe locking scenario:
> > >>
> > >>          CPU0
> > >>          ----
> > >>     lock(&(&n->list_lock)->rlock);
> > >>     lock(&(&n->list_lock)->rlock);
> > >>
> > >>    *** DEADLOCK ***
> > >>
> > >> Signed-off-by: Yu Zhao <yuzhao@google.com>
> > > 
> > > Looks sane to me:
> > > 
> > > Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > 
> > 
> > Really?
> > 
> > Since page->objects is handled as bitmap, alignment should be BITS_PER_LONG
> > than BITS_PER_BYTE (though in this particular case, get_order() would
> > implicitly align BITS_PER_BYTE * PAGE_SIZE). But get_order(0) is an
> > undefined behavior.
> 
> I think we can safely assume PAGE_SIZE is unsigned long aligned and
> page->objects is non-zero.

I think it's better to handle page->objects == 0 gracefully. It should not
happen, but this code handles situation that should not happen.

-- 
 Kirill A. Shutemov

