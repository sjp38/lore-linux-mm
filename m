Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9B18C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 14:27:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 744A320679
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 14:27:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 744A320679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 162ED6B000C; Fri,  2 Aug 2019 10:27:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 114A86B000D; Fri,  2 Aug 2019 10:27:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1D3F6B000E; Fri,  2 Aug 2019 10:27:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id D0E156B000C
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 10:27:30 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id 41so62228438qtm.4
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 07:27:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=P2Hb3FZglhIdbXiYdjxjKY7R3yX7bFoilggrVili8pk=;
        b=NIBM9WHOGUYp3tMttSEJRQ2ZnCVnrtuYAa9fs42FmxcDEu4Gmx9od1GXifx5RjZ9w/
         scqAwPEPiKKx1YErmKb2XrZsdNMKZCfS2jPEZYFhAzrFIjPf8J3XwRgMW70L2hZA/lv+
         JMKD/jt1EDtYkDZ8NiawE5oXFgUSTpK9gbT57ydAfK1ho1E8d8Nr/iO3J+Ed/rGNp/Yt
         VUCW2a209nZiyAkntsgLr3QQRhDQOlFglQ7p+M+ys4NuPMmBM1xYcJDrgbPDxiy2jxPv
         Uwyp6LFHNQc088c2EC2LlWfOgTxzU+jFGg3rd8V6S1MsGYwxrm7GxK1VG85+SIFpBZr5
         dncg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVz96VV6wsdXDD+EOpghCGNGN6IP5iXfqUiyGbtHzf1Jdc9axP0
	YlLOz8drBdOR9e3k7omriM5Q6hFYjNKsJ3vJlH9uu4iSpFJ97i9glVr551RrFsrX6ZQxmc6nTz3
	RtThf3w5GrBbvJWWvd8jOwCNdORsTA6dgr1KXEkTCiD71lvGNmlFYUIv7S5+JJBTzeQ==
X-Received: by 2002:a0c:9895:: with SMTP id f21mr95618232qvd.123.1564756050548;
        Fri, 02 Aug 2019 07:27:30 -0700 (PDT)
X-Received: by 2002:a0c:9895:: with SMTP id f21mr95618179qvd.123.1564756049911;
        Fri, 02 Aug 2019 07:27:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564756049; cv=none;
        d=google.com; s=arc-20160816;
        b=QWatvn/iVocltsI5sahXfNg4MFFKQVkt9Iueifz4JtCQgHXQG85p4zZcVfs6r8YStv
         A8gsAyvFDpnF4VNVrUBi0JCKvpTXgpjnooxh18CjlbHrhTItNk/T62yMGoAiifS2tInu
         /XzPIZtapeNRkb3yFOdjYzc1F54yqKgk6zsV85mrnVzjTx4O/7hgu6I0MMTIZB7L5nvd
         0e8us63VlKbsOYKtdS+GRxOgJd87johDGIDRfqT769JKDv9IBfFCtPRmcXxlyXchSHzg
         LYmO7cwZPEbYNCWYGF93ikn66JHvnDO/9BYBcK8YjaO9FvOknhdn+OWqAWJa0jazhfd1
         SPUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=P2Hb3FZglhIdbXiYdjxjKY7R3yX7bFoilggrVili8pk=;
        b=R4Rdgclc+ms+4z8vE2aIFJAyfKLLYKktLjQY7vfJTEr+q06dqHOIbu0lCherrfeudl
         uOllG9b6Sbynh8JXl3XNyO0OMp3S+fbg2jbzcruzUHD2G0EfJWQOrW046racrU5cqKmD
         1Rs6AaYWX6MOT6bGfyWcuObptH0UZWMq2mILwss2VsF3AqflL/fhmqWvtW+d1r4l/9wd
         BMshZOkLucmrNDASICL5AjHGGizE+jOOqLnxs/EY+VofKB2QZ4lcsnxkPO1eghElA7O5
         AOWPLVe17eeiKjdH63kdIatOyXr/nFXeJeuDzjCvKAXb+vinnFRc0zMOSEEd8GeWgKYz
         2umA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n16sor97649330qtl.23.2019.08.02.07.27.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Aug 2019 07:27:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqw3KBnCa3P7200Yn0foGxB3Mb3u607NCRK+HftBdUxylQNUOizF39tGc/1MfSlJjVQ6mmiQyA==
X-Received: by 2002:aed:3944:: with SMTP id l62mr96389184qte.34.1564756049676;
        Fri, 02 Aug 2019 07:27:29 -0700 (PDT)
Received: from redhat.com ([147.234.38.1])
        by smtp.gmail.com with ESMTPSA id d20sm30304231qto.59.2019.08.02.07.27.25
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 02 Aug 2019 07:27:28 -0700 (PDT)
Date: Fri, 2 Aug 2019 10:27:21 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
Message-ID: <20190802100414-mutt-send-email-mst@kernel.org>
References: <20190731084655.7024-1-jasowang@redhat.com>
 <20190731084655.7024-8-jasowang@redhat.com>
 <20190731123935.GC3946@ziepe.ca>
 <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802124613.GA11245@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802124613.GA11245@ziepe.ca>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 02, 2019 at 09:46:13AM -0300, Jason Gunthorpe wrote:
> On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
> > > This must be a proper barrier, like a spinlock, mutex, or
> > > synchronize_rcu.
> > 
> > 
> > I start with synchronize_rcu() but both you and Michael raise some
> > concern.
> 
> I've also idly wondered if calling synchronize_rcu() under the various
> mm locks is a deadlock situation.
> 
> > Then I try spinlock and mutex:
> > 
> > 1) spinlock: add lots of overhead on datapath, this leads 0 performance
> > improvement.
> 
> I think the topic here is correctness not performance improvement

The topic is whether we should revert
commit 7f466032dc9 ("vhost: access vq metadata through kernel virtual address")

or keep it in. The only reason to keep it is performance.

Now as long as all this code is disabled anyway, we can experiment a
bit.

I personally feel we would be best served by having two code paths:

- Access to VM memory directly mapped into kernel
- Access to userspace


Having it all cleanly split will allow a bunch of optimizations, for
example for years now we planned to be able to process an incoming short
packet directly on softirq path, or an outgoing on directly within
eventfd.


-- 
MST

