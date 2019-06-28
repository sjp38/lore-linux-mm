Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C107C5B579
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 23:34:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1978C2083B
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 23:34:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FuXCRWTA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1978C2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C16F6B0003; Fri, 28 Jun 2019 19:34:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 671348E0003; Fri, 28 Jun 2019 19:34:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55F4D8E0002; Fri, 28 Jun 2019 19:34:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f206.google.com (mail-pg1-f206.google.com [209.85.215.206])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE7D6B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 19:34:21 -0400 (EDT)
Received: by mail-pg1-f206.google.com with SMTP id t2so3907169pgs.21
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 16:34:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KrgrAoIPZ1LQ1VyQOLNmxmRQwkVpu3ldX8C9irBrRvU=;
        b=eHi1mc6tojyJwQYWYLsVwuRFXFa/d59Ln0gZEwoXnY2WGF/ouE33wRieiETUJC5DKs
         pXPnyYHbd7RSoWVS+oUwOmoToYr6IWNUjIRE1rKyLrea5yQ/HHA3IExuN57qH5VRGgP7
         q2sihsNE7I7ffLlO68c1qmlsq8+9O7yv+tzQvtVSDhKr7iKdbPhFotR4OrG4wo6xz2QD
         kVvKGr1PWyTDCn/eYu75j1eGblfmcY4MknvU+kjZQHLujmfsICdjHpR0e812kmu6a0pF
         u6pT5Im2PeOx9evgQ1XUklQXMAecNUEx54JpftwCf9VLMH32h0ZsW0QglFR6iaFH/1Sc
         On2Q==
X-Gm-Message-State: APjAAAWgCL8E/SmKXyS0NOigKAQ7wO0XuK9XyS/9kEePvtsY/gR5yJVf
	IAutoBQaF+dtXtmRowZQz4U8LkLl+79BgmLV4XK7i8F1YHkHyy/Mt7cKlgEEFXoEWsAZGWk4fXL
	ewlAgarAAg4yBFKCE+o8SRpOBpuPg+29EF7T2wU12hvHr8NPVtXrUsQjqvRgimgc=
X-Received: by 2002:a17:902:27e6:: with SMTP id i35mr14499160plg.190.1561764860591;
        Fri, 28 Jun 2019 16:34:20 -0700 (PDT)
X-Received: by 2002:a17:902:27e6:: with SMTP id i35mr14499097plg.190.1561764859668;
        Fri, 28 Jun 2019 16:34:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561764859; cv=none;
        d=google.com; s=arc-20160816;
        b=Sj3lCcVeHN6EPIIjEjjTGvTB8n7p3zvx521wV6+qGB/83Qrd+P5ozqdfFgg8zsUJmu
         EswrADNbAIMuA85owyC3Rg+Dk7ZTyG/6xHYjRhtuUaQBjy9RGHKq5rZ3naI8aVrEVafP
         sLwFn0CiWYG/atKHZLEQ5TfP84byBIrur9Koi2MJjClL6LdwGpcNCexAJg8a1CCSc14q
         unVV9GH3zgw3uBxH9aPI7jRs0G6ABgWxL0sSaX1uDNYS6UzeuZQGw1ZINNQWBbVqV8of
         dCipQdr+A6aHDR7AkxrtVC0N1UZHWvUi6YTgkKOOyAa6UubAb1hgZECjP0PPdONJbqc5
         fyXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=KrgrAoIPZ1LQ1VyQOLNmxmRQwkVpu3ldX8C9irBrRvU=;
        b=KmlBmf9+B5wgj5ID4kEF74fgFlGP7qy+q2E7+VQTPmS+YBAQiAzyV6F9Rcfy8ga9Hb
         fqUpiyUT0PjtZLdEYEQOM9cV5dghWou5yux2WcuBr9rbKoFNP+gGogZRVYhdZTZ5IJej
         NqZopakDZP5jw3GJ4d4qkW1ikVmRikoMaixK3FJT1+f64GETUt4zqSNM1IkTH2r7kSt9
         butSl9BKaXv3dYh4WH1K+rgCv/1yQ4qcOIpCdk3xZvbR4OR3PaT6BGJglqZ84wz6D+sV
         91Cg0l0GvWvifgeqDPixPj545xCgVXWy7u4T5C4wtIqfUTd+rcS3zcOUc4Kps6su88jI
         lqvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FuXCRWTA;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z10sor1547767pgc.70.2019.06.28.16.34.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 16:34:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FuXCRWTA;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=KrgrAoIPZ1LQ1VyQOLNmxmRQwkVpu3ldX8C9irBrRvU=;
        b=FuXCRWTAM+9ahhxbr5qRNj6BgsiLoHnFWtS3E/mbYN3VEM9nacepKLwqukT6/a5DpQ
         8rGhoiGM77FVD5YSg8amgM2e4bGYcfvJ08VPz2iRAFW1jvApJZis32GTE2YhY2CrzFnP
         PC+VYJ7ZGK9aw2KYLwsjRaYWsB5cW7yQMB+9w29z9p5XaMDx2Q4u1ua1sLOdrpFU+b37
         EBXaa+OuUBn754W/1n1g2dWtzETfkn4sIt5Y/iN25C7NyOh3z2jCx+cNqAuK9kol6iOY
         oLXTY+eCtjUWMYBkPYAGHguhSSluwdMytMAf09GCumQXseLeqXfzkVpgpU1EzbNO/C30
         qpYw==
X-Google-Smtp-Source: APXvYqxiEqYGkwyQWFFs2+k+3J5PBRG1DwCuUg4xTvxq530PkTHIrVLX01gAIyt/3/ykcFV26DI/mg==
X-Received: by 2002:a63:5b1d:: with SMTP id p29mr11179249pgb.297.1561764858832;
        Fri, 28 Jun 2019 16:34:18 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id e6sm3320634pfn.71.2019.06.28.16.34.15
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 28 Jun 2019 16:34:17 -0700 (PDT)
Date: Sat, 29 Jun 2019 08:34:13 +0900
From: Minchan Kim <minchan@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Kuo-Hsin Yang <vovoy@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, Sonny Rao <sonnyrao@chromium.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH] mm: vmscan: fix not scanning anonymous pages when
 detecting file refaults
Message-ID: <20190628233413.GA245333@google.com>
References: <20190619080835.GA68312@google.com>
 <20190627184123.GA11181@cmpxchg.org>
 <20190628065138.GA251482@google.com>
 <20190628142252.GA17212@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190628142252.GA17212@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 10:22:52AM -0400, Johannes Weiner wrote:
> Hi Minchan,
> 
> On Fri, Jun 28, 2019 at 03:51:38PM +0900, Minchan Kim wrote:
> > On Thu, Jun 27, 2019 at 02:41:23PM -0400, Johannes Weiner wrote:
> > > On Wed, Jun 19, 2019 at 04:08:35PM +0800, Kuo-Hsin Yang wrote:
> > > > Fixes: 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache workingset transition")
> > > > Signed-off-by: Kuo-Hsin Yang <vovoy@chromium.org>
> > > 
> > > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > > 
> > > Your change makes sense - we should indeed not force cache trimming
> > > only while the page cache is experiencing refaults.
> > > 
> > > I can't say I fully understand the changelog, though. The problem of
> > 
> > I guess the point of the patch is "actual_reclaim" paramter made divergency
> > to balance file vs. anon LRU in get_scan_count. Thus, it ends up scanning
> > file LRU active/inactive list at file thrashing state.
> 
> Look at the patch again. The parameter was only added to retain
> existing behavior. We *always* did file-only reclaim while thrashing -
> all the way back to the two commits I mentioned below.

Yeah, I know it that we did force file relcaim if we have enough file LRU.
What I confused from the description was "actual_reclaim" part.
Thanks for the pointing out, Johannes. I confirmed it kept the old
behavior in get_scan_count.

> 
> > So, Fixes: 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache workingset transition")
> > would make sense to me since it introduces the parameter.
> 
> What is the observable behavior problem that this patch introduced?
> 
> > > forcing cache trimming while there is enough page cache is older than
> > > the commit you refer to. It could be argued that this commit is
> > > incomplete - it could have added refault detection not just to
> > > inactive:active file balancing, but also the file:anon balancing; but
> > > it didn't *cause* this problem.
> > > 
> > > Shouldn't this be
> > > 
> > > Fixes: e9868505987a ("mm,vmscan: only evict file pages when we have plenty")
> > > Fixes: 7c5bd705d8f9 ("mm: memcg: only evict file pages when we have plenty")
> > 
> > That would affect, too but it would be trouble to have stable backport
> > since we don't have refault machinery in there.
> 
> Hm? The problematic behavior is that we force-scan file while file is
> thrashing. We can obviously only solve this in kernels that can
> actually detect thrashing.

What I meant is I thought it's -stable material but in there, we don't have
refault machinery in v3.8.
I agree this patch fixes above two commits you mentioned so we should use it.

