Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EDE7C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:34:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AF8D2175B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:34:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AF8D2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9B7D6B000A; Fri, 14 Jun 2019 11:34:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4ADE6B000D; Fri, 14 Jun 2019 11:34:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 913A96B000E; Fri, 14 Jun 2019 11:34:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 40D1F6B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:34:58 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id w11so1192643wrl.7
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 08:34:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=p5HPLsx5lGEzdsjUNVY6MwJ1i1v8fmWkK7CMd5k1P9c=;
        b=g8RPO//7MIcPhRW5eXt4TSJQhIosRZIr7qi5yn/j/hP1ZMOKXCKtic0DMJczsxeM0F
         rnRjjzcs6PKGUqTXSrM9jSxiznqROR2gt3VyaZ5PE/S0F8bkoaZyG9Sb6mPizg1g8s07
         Prc+GKxq0zTDsXd99XjvaUwBI7yD8l+h5nv/UHnorJXL68QtQ8EHRwlYBZtxvBIqgjRE
         H0jWBU3Y3n+XrbmLwsWdWkYciKtbZihhe8N5MnPAPLCzGwsxDBPFXPnEt3Dvf02KSeDi
         OYGQd42gqzOCasZ03ZGImfDZFngAhf33e4saM6GJJ3mdglOq0YtXpSdMY86b0nbMeJXd
         T9bg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUbtgN1ahCedmnTxMKl/IVigwwkS9/NfX/g0r5ARCATOaQkwhi0
	trEDyoR/PvnElCdvDhWxbYb/ZLls6rIPawhIHHXm18KCsVODaRoWvmnuQQmvivZciJ1DbspSItb
	vScOCnbZmvk7Qzvy4FNvW0IJV7r31g7ht1goto40mo9TWSUcxNXUAVc7LnycyM8/y/w==
X-Received: by 2002:adf:f60b:: with SMTP id t11mr8865899wrp.332.1560526497779;
        Fri, 14 Jun 2019 08:34:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyx0qR62RCb9fvlXiLpk1AT9VOu2OkCa1qLnzX8EZmjsXCp3W+Nh8j4V7P2Q7+qmRXZAO7A
X-Received: by 2002:adf:f60b:: with SMTP id t11mr8865861wrp.332.1560526497100;
        Fri, 14 Jun 2019 08:34:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560526497; cv=none;
        d=google.com; s=arc-20160816;
        b=QuCEh/B09x9AA/FeEe8hKZZgqPtl1IaYTxwfOTucMdgQWWfjB5xN7zJpVVlaQrSlwa
         ssH2kZr4sCIPKQAGgpJidPevBPFxEvKw3vKszQGXg9yd/enlcpnr6mYjM6kyQlDin17Y
         C2Edp/vPVnyTlsinHWoY3NhbfIJxYtmCt6KCu8y/p72F0IQ+qTrszyhIpCjSPjyHilLu
         8IyxS+RSSfv9HaVD1yoHeYJAwNT9ZWKWIbfyC2jyGMlc+UQxTGLIc0pkF7kQAsbE88ya
         L9yLw6DkG2eK6b7qx+URY2PrViMILrY/r8KrEcRo+VFIOdHu0nZX8AlSnbHqdwRLOgze
         HfKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=p5HPLsx5lGEzdsjUNVY6MwJ1i1v8fmWkK7CMd5k1P9c=;
        b=ChreGPm1HFAmS5rM5P42f1rN3qy8IvzSxV4li2j6b99UiaLmQlTtxLOWoJI8ptytDn
         01UemWQSfVw9B9Er5dMwh3/8xmMORprSqgIDUdLuyTdA/MzkDQ/O2SJc/cWiyTlr+ub9
         hlA5Ze1m0AIJKR9HmOGvTAsf2qqwBX/FQmphwxwZxlt3ht6+p/MbNRuhsh50TjoscHGA
         9Y2uVECP3EclhEicq04tqtHlr97uZpB3HBzBx7cGQ546OIlsnSZHdLUOsV06jiFAsCon
         5QZV9gWxQUL149BgK9m2RKRjXQz/mKXWQlZ003spf5v/yG4ktqlfNveKOwHAdObu7BTE
         F5XQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id y1si2609815wrs.259.2019.06.14.08.34.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 08:34:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id DF91968AFE; Fri, 14 Jun 2019 17:34:28 +0200 (CEST)
Date: Fri, 14 Jun 2019 17:34:28 +0200
From: Christoph Hellwig <hch@lst.de>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>, David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Ian Abbott <abbotti@mev.co.uk>,
	H Hartley Sweeten <hsweeten@visionengravers.com>,
	devel@driverdev.osuosl.org, linux-s390@vger.kernel.org,
	Intel Linux Wireless <linuxwifi@intel.com>,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	intel-gfx@lists.freedesktop.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	"moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>,
	linux-media@vger.kernel.org
Subject: Re: [PATCH 12/16] staging/comedi: mark as broken
Message-ID: <20190614153428.GA10008@lst.de>
References: <20190614134726.3827-1-hch@lst.de> <20190614134726.3827-13-hch@lst.de> <20190614140239.GA7234@kroah.com> <20190614144857.GA9088@lst.de> <20190614153032.GD18049@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614153032.GD18049@kroah.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 05:30:32PM +0200, Greg KH wrote:
> On Fri, Jun 14, 2019 at 04:48:57PM +0200, Christoph Hellwig wrote:
> > On Fri, Jun 14, 2019 at 04:02:39PM +0200, Greg KH wrote:
> > > Perhaps a hint as to how we can fix this up?  This is the first time
> > > I've heard of the comedi code not handling dma properly.
> > 
> > It can be fixed by:
> > 
> >  a) never calling virt_to_page (or vmalloc_to_page for that matter)
> >     on dma allocation
> >  b) never remapping dma allocation with conflicting cache modes
> >     (no remapping should be doable after a) anyway).
> 
> Ok, fair enough, have any pointers of drivers/core code that does this
> correctly?  I can put it on my todo list, but might take a week or so...

Just about everyone else.  They just need to remove the vmap and
either do one large allocation, or live with the fact that they need
helpers to access multiple array elements instead of one net vmap,
which most of the users already seem to do anyway, with just a few
using the vmap (which might explain why we didn't see blowups yet).

