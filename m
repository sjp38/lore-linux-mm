Return-Path: <SRS0=rDiK=SJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E41F1C282DD
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 07:32:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E1C3213F2
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 07:32:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E1C3213F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66BBE6B0007; Sun,  7 Apr 2019 03:32:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 618EC6B0008; Sun,  7 Apr 2019 03:32:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E1346B000A; Sun,  7 Apr 2019 03:32:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0415B6B0007
	for <linux-mm@kvack.org>; Sun,  7 Apr 2019 03:32:26 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id f67so6497146wme.3
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 00:32:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ys4nKRaGHNzvdeI0rolP5xnjE1OJiSMtRHTzPdnA+Jg=;
        b=kzlytZUmL+pp6lLty/bfsh4HW+CZGWD9NeYD0x4391uz+qESpV0yIX/zVh8T4IAgyq
         z/c5YcI80s6EBLkRinuq4mKm//SlTWec+wmWp2pbV0vI30GPoL+HLvm0lYGTwSp/f3/h
         z3sZVfdbgehsJ7CAZJXAJjYYxwHfiIctrDBGsdOmTIDyciO65BOuVrm0sfm8lsZECN2K
         LgzCnbKu5tdeAZQCiz38m748+Qe7qqxodkdb7FI/zBkdhQQJB4T7IeXCxDY4CRuOa2Ix
         UOAiSTT4fyd5xni5Ux/DPnUhwWH584SK8pDSn+OgOMkbDr8DHk/KrnSuB/JgqF6+GW3G
         zIKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWyfgV3YJoo0AWJx86Ix4pBIrFWGPWRiPAZUYr4vSF2cFU8vPWD
	JXrjAU4Rri7wwht7ByJXPTORikw6WYywfrQQoioGwg5I93WHwDnJECKritApRTeAoU1z3D/6VjJ
	IGWEx5OTh4Nu+pESzAIJvPbl7jpbV21UyKMmljSWgcA4oLapYuHWpibLjRz6Vfe88vQ==
X-Received: by 2002:adf:9c91:: with SMTP id d17mr13604438wre.285.1554622345388;
        Sun, 07 Apr 2019 00:32:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGpP3zDa1Ehmlv3fSxtNOYBb1tVSFV0z8+PWoHIICDW7hzzki0TZ8cRI+zY21MYYJ6eWMx
X-Received: by 2002:adf:9c91:: with SMTP id d17mr13604402wre.285.1554622344558;
        Sun, 07 Apr 2019 00:32:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554622344; cv=none;
        d=google.com; s=arc-20160816;
        b=H67B+ztA5zFytFIZDZVHee1HwWKuqELwO5YDLQQrExJ3paRp6SxbZDeHL9RhawY2Ub
         ylurJKo44RCn9oejleongrAg8VylDbzjEmthLImwqI6s+kc2WqFAsj52AxuFoIRD7ipW
         HH/lpWmmBQW1a2FAn/RLZSOkEWZ/e1Mj2msqltRVJUHHFcYrACymXvl8egifKRfX81P3
         KKLaxpenyNk4f8cj3QepFPrabzgLCrI8tKDPF4LkLQM1e5Ncfo8lxZjKTiaklCfXfNBK
         kS7JsEuMBweLnOG+gCME6I+c/oleHP7e8WKebsNu8ixhDxJ6dGDo9+egqBV2DxK4BzuP
         5mNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ys4nKRaGHNzvdeI0rolP5xnjE1OJiSMtRHTzPdnA+Jg=;
        b=Ivgk5CPwKu1a5HIkzuD8zikvDEANGw/C1m2PTAqWEoKXDTSb2NO2nnBFcHFZVn1K+i
         dpv6+69/4Hgh5D+y06th6ISfj+h7R2TdXZNosqHtipLjCNVw/FasKuyCcps3ItlpnqMm
         vFtae6zveprG2y0h8r3I4ozj5GhAwE6zyxgym+zvZhf7kzeR94Zt/LnQWLd5A4QpDu0+
         sKvfVVJ3JbZnND0eYhPSK4vf/gW998TBrlJH7Ae+dwk+V47VjkDRuI4y04Atd/buL08F
         W35QTRPnSgJIfS4mvvAlLBrLUepheXoFBeByJNTV9sH7aG1NUe1WhuVPBFOcT3KIPesx
         vKXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id o8si4238402wmh.76.2019.04.07.00.32.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 00:32:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id AA9A068B02; Sun,  7 Apr 2019 09:32:13 +0200 (CEST)
Date: Sun, 7 Apr 2019 09:32:13 +0200
From: Christoph Hellwig <hch@lst.de>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>,
	cluster-devel <cluster-devel@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Jan Kara <jack@suse.cz>, linux-mm@kvack.org
Subject: Re: gfs2 iomap dealock, IOMAP_F_UNBALANCED
Message-ID: <20190407073213.GA9509@lst.de>
References: <20190321131304.21618-1-agruenba@redhat.com> <20190328165104.GA21552@lst.de> <CAHc6FU49oBdo8mAq7hb1greR+B1C_Fpy5JU7RBHfRYACt1S4wA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHc6FU49oBdo8mAq7hb1greR+B1C_Fpy5JU7RBHfRYACt1S4wA@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[adding Jan and linux-mm]

On Fri, Mar 29, 2019 at 11:13:00PM +0100, Andreas Gruenbacher wrote:
> > But what is the requirement to do this in writeback context?  Can't
> > we move it out into another context instead?
> 
> Indeed, this isn't for data integrity in this case but because the
> dirty limit is exceeded. What other context would you suggest to move
> this to?
> 
> (The iomap flag I've proposed would save us from getting into this
> situation in the first place.)

Your patch does two things:

 - it only calls balance_dirty_pages_ratelimited once per write
   operation instead of once per page.  In the past btrfs did
   hacks like that, but IIRC they caused VM balancing issues.
   That is why everyone now calls balance_dirty_pages_ratelimited
   one per page.  If calling it at a coarse granularity would
   be fine we should do it everywhere instead of just in gfs2
   in journaled mode
 - it artifically reduces the size of writes to a low value,
   which I suspect is going to break real life application

So I really think we need to fix this properly.  And if that means
that you can't make use of the iomap batching for gfs2 in journaled
mode that is still a better option.  But I really think you need
to look into the scope of your flush_log and figure out a good way
to reduce that as solve the root cause.

