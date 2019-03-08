Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94F7AC10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 20:06:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F9F7205F4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 20:06:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F9F7205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE38A8E0003; Fri,  8 Mar 2019 15:06:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D69768E0002; Fri,  8 Mar 2019 15:06:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C315E8E0003; Fri,  8 Mar 2019 15:06:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 95A848E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 15:06:20 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id f70so16907558qke.8
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 12:06:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=urry7l0E7LSuz7+R+azwX9gal89I/pOQEBU66nT3q3E=;
        b=Nt1v/BEsMXScsYb9bfexluyen8alI5gRNzHj19bSl5ZsyaeExK7dgrG80MQgNO/ya3
         IG46SUgMIkKvCRExR5nREZJFwQ26iEZyK65rQO1JbUe+NTkMEAdsnsDGW/LlBBghHw15
         CuFYc5xAlzYCSSfuDphisS0+LSW82ew9EH1te6zhMKRTgizZGUSvkCZKIXjwQLxRwRja
         d8YfNCOzDetjoxVdnDCYoSRQsuWZA4iXs2/Y8uGHxvsqtouylGiCHUDK3BC7dbrm8MXn
         tg+ipkIeLvQgY7NBGyuTqTiAVI8+mzKGHHCs8maFj60/068OeBfffnEsPvhdkR0lLAgk
         IbVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW/T9NZGRjL5QYI35U5ld/DDOqq9bK9TXnVPJloMyTbxcGyAesT
	Y8Q2c25vHB+0AXqQsEqurcD8wsU0QCCY7UVQ6reJYKDDlMEOdsPQOyugEORD6scgwJ5ybGSL+Rf
	IP7WfkokwFTB0pFcYZppRSfQrlTqVOOTGiCdXiKpDMddu4bDaHDywL+oCbGdWFZ/VtA==
X-Received: by 2002:ae9:e211:: with SMTP id c17mr15970468qkc.290.1552075580360;
        Fri, 08 Mar 2019 12:06:20 -0800 (PST)
X-Google-Smtp-Source: APXvYqxZ5od1glmhEHuD6iBDU173oo+x/CmSFJlevXz1kWVWhxOUz1jntFk4hJPNQG35vTUJzVJ6
X-Received: by 2002:ae9:e211:: with SMTP id c17mr15970421qkc.290.1552075579587;
        Fri, 08 Mar 2019 12:06:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552075579; cv=none;
        d=google.com; s=arc-20160816;
        b=oZD8iiE2QJhuxTJFD9KzUu3SDZEUs7pFu1JrM0PIDQcveJoUh5pJRj9IilOXiC77wh
         lYNW5owniMEBZpmfY0KIlpYfJPLUouu/XaSvfCyCABGcZ/e00k9tG6qq3JvhFAblYmAE
         ZI/t6pGdsvQfK5v0poSRLnfbroXxi6hd8Gs54twCAW7yNrhjAGQ63aJ1oOfQzKV3wnLN
         EV8YYmzMJb69YZ9NE/wwmLRJxD1aTd7CSLOtvtzZmFoIYuLHxtqliSSMNFdFbdMuvT6c
         Sji6baow8voSXxFqxFerfJJgTEadkIu7Slg1HQ//bThbFkC9PHvU291XLSfHFLS+hbqA
         7+Cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=urry7l0E7LSuz7+R+azwX9gal89I/pOQEBU66nT3q3E=;
        b=S2O6s4vN+ubaKP7nU0YC8njYJWtzkvs4nSDC80vIfGb2w7+uZszFk/RbPFSgk1Mvlk
         +px1/r4Irg5eIeNVBW3bmJMI17RL174jibirdxRPY3kltdu1nnaiEwt/2PlvQypXHusT
         ZXlXEZPvDtBNWiWoPE8sCZnHyvfD2kHFJrnXAxEUPjzW8WbUAT0KCSy2SZihvVkcSfZX
         HVul5eR+dIKJhFgwKx/353Uw6KmtmZpcxb3nJ2lXLajjGNGB2eAx7pm9OqHC044uIn0Z
         Nnu2DeYvLbe3GANWyNjhvdjQSxqa+jrKl3RW1AQJWuH+XWBqLLQ+KHvTdpq66bx+OsAv
         traw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z12si550335qvg.5.2019.03.08.12.06.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 12:06:19 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AA65D318A5E9;
	Fri,  8 Mar 2019 20:06:18 +0000 (UTC)
Received: from redhat.com (ovpn-124-248.rdu2.redhat.com [10.10.124.248])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id F3DC8600C1;
	Fri,  8 Mar 2019 20:06:12 +0000 (UTC)
Date: Fri, 8 Mar 2019 15:06:11 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	peterx@redhat.com, linux-mm@kvack.org
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190308200609.GA6969@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191622.GP23850@redhat.com>
 <e2fad6ed-9257-b53c-394b-bc913fc444c0@redhat.com>
 <20190308194845.GC26923@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190308194845.GC26923@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Fri, 08 Mar 2019 20:06:18 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 02:48:45PM -0500, Andrea Arcangeli wrote:
> Hello Jeson,
> 
> On Fri, Mar 08, 2019 at 04:50:36PM +0800, Jason Wang wrote:
> > Just to make sure I understand here. For boosting through huge TLB, do 
> > you mean we can do that in the future (e.g by mapping more userspace 
> > pages to kenrel) or it can be done by this series (only about three 4K 
> > pages were vmapped per virtqueue)?
> 
> When I answered about the advantages of mmu notifier and I mentioned
> guaranteed 2m/gigapages where available, I overlooked the detail you
> were using vmap instead of kmap. So with vmap you're actually doing
> the opposite, it slows down the access because it will always use a 4k
> TLB even if QEMU runs on THP or gigapages hugetlbfs.
> 
> If there's just one page (or a few pages) in each vmap there's no need
> of vmap, the linearity vmap provides doesn't pay off in such
> case.
> 
> So likely there's further room for improvement here that you can
> achieve in the current series by just dropping vmap/vunmap.
> 
> You can just use kmap (or kmap_atomic if you're in preemptible
> section, should work from bh/irq).
> 
> In short the mmu notifier to invalidate only sets a "struct page *
> userringpage" pointer to NULL without calls to vunmap.
> 
> In all cases immediately after gup_fast returns you can always call
> put_page immediately (which explains why I'd like an option to drop
> FOLL_GET from gup_fast to speed it up).

By the way this is on my todo list, i want to merge HMM page snapshoting
with gup code which means mostly allowing to gup_fast without taking a
reference on the page (so without FOLL_GET). I hope to get to that some-
time before summer.

> 
> Then you can check the sequence_counter and inc/dec counter increased
> by _start/_end. That will tell you if the page you got and you called
> put_page to immediately unpin it or even to free it, cannot go away
> under you until the invalidate is called.
> 
> If sequence counters and counter tells that gup_fast raced with anyt
> mmu notifier invalidate you can just repeat gup_fast. Otherwise you're
> done, the page cannot go away under you, the host virtual to host
> physical mapping cannot change either. And the page is not pinned
> either. So you can just set the "struct page * userringpage = page"
> where "page" was the one setup by gup_fast.
> 
> When later the invalidate runs, you can just call set_page_dirty if
> gup_fast was called with "write = 1" and then you clear the pointer
> "userringpage = NULL".
> 
> When you need to read/write to the memory
> kmap/kmap_atomic(userringpage) should work.
> 
> In short because there's no hardware involvement here, the established
> mapping is just the pointer to the page, there is no need of setting
> up any pagetables or to do any TLB flushes (except on 32bit archs if
> the page is above the direct mapping but it never happens on 64bit
> archs).

Agree. The vmap is probably overkill if you only have a handfull of
them kmap will be faster.

Cheers,
Jérôme

