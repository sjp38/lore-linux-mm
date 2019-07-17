Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBFD7C76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 14:34:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FE9921743
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 14:34:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FE9921743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33F676B0006; Wed, 17 Jul 2019 10:34:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CA458E0001; Wed, 17 Jul 2019 10:34:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 191296B000A; Wed, 17 Jul 2019 10:34:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E39E96B0006
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 10:34:37 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id l14so20237008qke.16
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 07:34:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=snhado8UeJvK9GDImP7KcCYqkSIDBILBMhnuVhXLe+o=;
        b=VT++VIxIWp6hSjrxKow4qaZn9OSMVN/sJYIeC4nFyzjkISxCiEuDqwxDx0LWkQxvf7
         a1eE0JlBQ6Qc2ti80M9WsGJLk7tM/ycDbSdswdoYIQvbrCnT0sJthp7x/PqqX7r1j3N5
         oj0MYlgBliG2pfllGLDOaoK5TMXDS7J9CG3Wp5Y5eVkjxNAFuSTHYkegmR38E7LiKxFv
         /FmLVCibj9oqiYYGnIv0YztQIG5ShSYVcPERX0RXC+wGnkWHUexd5+gqiCl7XEfzS6Cn
         Zy53gSEiyaOkK31YBRyd7tFse4gDG/x4Hj7T6dBmdCVxm92WAXdG83CIc+7POOrKbDqN
         mHAw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVwu6Zwy/pt2E5vwU3yo4TIZHMF2Y+MxNCwTU5I+zl7W+GhcRMJ
	MpYYUpGAAbJYw0OBwtmbUgW/BF/eXw+RE5ur2q08VBT3LuKa7eSHMFOWxbO9kRZTPWGQ27ILTU4
	L6hdHfmoYmE553mQbvt4ioVIQLD96K3tDbAX39JgAz2rR1qLLf4e54F0ZZRS0B+tpEw==
X-Received: by 2002:a37:62ca:: with SMTP id w193mr24430499qkb.363.1563374077693;
        Wed, 17 Jul 2019 07:34:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrtcEmrLwRJN4JzoZxfOP276lr8hQCq/Mj6e5y3kWf8XJw31iUCKSLmTWk7u0cFd3n4bqi
X-Received: by 2002:a37:62ca:: with SMTP id w193mr24430459qkb.363.1563374077047;
        Wed, 17 Jul 2019 07:34:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563374077; cv=none;
        d=google.com; s=arc-20160816;
        b=ol6tJRpA/sHYf4IBpWSETlmhW9E5rQkPAe3n07k1cTlLre/vhY9VHtzZyCk2HD/Zgp
         rbtS30wNOdLdWeGT9Pn3gEIouXcldxAXs+o+3e8ZG2toFiNgbry/lnUBHTelA2rekOkG
         ayPeDhr3NJHRzpiKgjnNzkwU5Y4UMRBfPfxnJPXmn1TERF612JxRHOw9jQhs95easS7S
         uzw1nAHQfrFPf8qor7VxBbWhyAywOg2uYQVjZPp6oMYQBLeyuFjlk7XvHc+oVLhllGPk
         2NrHZSjVHvm5mHdO660igvey97PolIHPMtmm60x1/sZ+wCQ8GIfbOJm6al9y0Yj2G5Ot
         MTLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=snhado8UeJvK9GDImP7KcCYqkSIDBILBMhnuVhXLe+o=;
        b=k/hBuBqoAC57rAzGl3u0I01+codVr42PR5uHzTkwBP/DD+kut6jokku0TTpsC3MitK
         ZX4zvUA/aRIUX2Xt+ltp+vvWSn5VA4yK6FjpaJRulxljHJhyDO8Zm2HT6pp9cqkdl7Hu
         5aWXnjASxALk1MaHKzONCnhl7fnQsF6uN/yZ1DH4Rv/cVcrx8lbYDbEcS9TJP7xUPeW0
         Q4UUHPUKD4elB+JefjifCszOmSE5ZoJUqJpTDzPCr18iWAuIXja//b0pcse2cTrMu4fo
         VPObPcZnLuNaAJHTLPTtLLPOZ3AtlQwfCzDYiqODmzR/rm9PijrDdJm0SXChIHYEmbIU
         7UQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i11si15102225qke.264.2019.07.17.07.34.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 07:34:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2B22A8553A;
	Wed, 17 Jul 2019 14:34:36 +0000 (UTC)
Received: from redhat.com (ovpn-125-71.rdu2.redhat.com [10.10.125.71])
	by smtp.corp.redhat.com (Postfix) with SMTP id 654AF19C59;
	Wed, 17 Jul 2019 14:34:16 +0000 (UTC)
Date: Wed, 17 Jul 2019 10:34:15 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, wei.w.wang@intel.com,
	Nitesh Narayan Lal <nitesh@redhat.com>,
	kvm list <kvm@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com,
	Rik van Riel <riel@surriel.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	lcapitulino@redhat.com, Andrea Arcangeli <aarcange@redhat.com>,
	Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Subject: Re: use of shrinker in virtio balloon free page hinting
Message-ID: <20190717103208-mutt-send-email-mst@kernel.org>
References: <20190717071332-mutt-send-email-mst@kernel.org>
 <959237f9-22cc-1e57-e07d-b8dc3ddf9ed6@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <959237f9-22cc-1e57-e07d-b8dc3ddf9ed6@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Wed, 17 Jul 2019 14:34:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 04:10:47PM +0200, David Hildenbrand wrote:
> On 17.07.19 13:20, Michael S. Tsirkin wrote:
> > Wei, others,
> > 
> > ATM virtio_balloon_shrinker_scan will only get registered
> > when deflate on oom feature bit is set.
> > 
> > Not sure whether that's intentional.  Assuming it is:
> > 
> > virtio_balloon_shrinker_scan will try to locate and free
> > pages that are processed by host.
> > The above seems broken in several ways:
> > - count ignores the free page list completely
> > - if free pages are being reported, pages freed
> >   by shrinker will just get re-allocated again
> 
> Trying to answer your questions (not sure if I fully understood what you
> mean)
> 
> virtio_balloon_shrinker_scan() will not be called due to inflation
> requests (balloon_page_alloc()). It will be called whenever the system
> is OOM, e.g., when starting a new application.
> 
> I assume you were expecting the shrinker getting called due to
> balloon_page_alloc(). however, that is not the case as we pass
> "__GFP_NORETRY".

Right but it's possible we exhaust all memory, then
someone else asks for a single page and that invokes
the shrinker.

> 
> To test, something like:
> 
> 1. Start a VM with
> 
> -device virtio-balloon-pci,deflate-on-oom=true
> 
> 2. Inflate the balloon, e.g.,
> 
> QMP: balloon 1024
> QMP: info balloon
> -> 1024
> 
> See how "MemTotal" in /proc/meminfo in the guest won't change
> 
> 3. Run a workload that exhausts memory in the guest (OOM).
> 
> See how the balloon was automatically deflated
> 
> QMP: info balloon
> -> Something bigger than 1024
> 
> 
> Not sure if it is broken, last time I played with it, it worked, but
> that was ~1-2 years ago.
> 
> -- 
> 
> Thanks,
> 
> David / dhildenb

Sorry I was unclear.  The question was about
VIRTIO_BALLOON_F_FREE_PAGE_HINT specifically.

-- 
MST

