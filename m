Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FEC7C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:59:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5FAF2238C
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:59:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5FAF2238C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5ED648E000E; Wed, 24 Jul 2019 13:59:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 59E9C8E0005; Wed, 24 Jul 2019 13:59:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 466588E000E; Wed, 24 Jul 2019 13:59:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C2AFF8E0005
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:59:01 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l26so30669944eda.2
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:59:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=sdGYzOGLozYXl0ObsR0hxWNUtHpzDtIyu41JyTaHejI=;
        b=m7WTG0/Patp0XcV2cFmFat12qVmDFoTdUzKgsoUoTVf57BsakyavdFJd7C8qU83pg8
         esOZt2ZYIKzV6IZuLGq1tFcULIlPyRyZlZTViS0LGU+W5TsnJ/hd72taR/drUxbTXTd2
         y2u+bkoJH7shswIKi6lN5tEOnfnHcNfygqM4Vxj9ZGlWtblCDJYePFOgQb+84Y6v2gjB
         LQtZMqnH0TxbTnTEWaeWFGqSYuhI6IcxHQCZYVJPN66rk4PatZ8csC8Wu27nP0LmGKnI
         h+QvEFby3zfO271Wym+CW3zzGnnTz7XAibhnn56ZErUVLoJNWE23aGlSZ6AzBRZLbKl9
         QKDA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWQ8ANKgGhOxPktRJgYUgc4fQCVSATR/6FnIOW8gs5zwM4BI2do
	a/plxgpJAawv/ptwwMCQmxnpkNEkCiR9OFId0JVnnKaaJ/dHuaUpHiKAzEFW1XJFEZiMLZmq45T
	bWeSidihWwNfMkMvQ0q4//adbT+8v8+Xi14UTXI7LCxCHwDO1Ep9+reOX44njye0=
X-Received: by 2002:a17:906:5c4a:: with SMTP id c10mr63135204ejr.15.1563991141217;
        Wed, 24 Jul 2019 10:59:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9Xr3fMteJ7Zvz03SDb52gA2NKi0no+WqKu1+kNArqGNvycPDl802SHv3u9NdQ+V2HTDSi
X-Received: by 2002:a17:906:5c4a:: with SMTP id c10mr63135150ejr.15.1563991140154;
        Wed, 24 Jul 2019 10:59:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563991140; cv=none;
        d=google.com; s=arc-20160816;
        b=xc88dDmThCwQ/56WvLhMlejBA3EdCFhdKJ96xiRRYYfP2ngmJ5BP499jGjx1sNi3Lf
         zyCZGCKc5vp/u6AYhajNuJd2NMWCjCl69rE/HYdlK1OTfzA9QGSwNA2aQEwRj8IX2swI
         wVni+aeMw59stt03rU+Q7P7WGhUxAcv6JAuBjkPafxSVCtHnabtBx+eJc6rbI3CI14xG
         zANWPX6jdItkWCKM1JwR4QC38yiVdsuDp7dNgCs8aSmr6McOVNGNzUNZGrxWPqeu7/rY
         t7jDdlRf4hO6aqGEdrlqzYEw+AGGFUun5hbrcnkb1RSoKgHG4ZxHqIn4Uo/2AxvYOC+P
         qvCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=sdGYzOGLozYXl0ObsR0hxWNUtHpzDtIyu41JyTaHejI=;
        b=EdI/J22mTgjIv1mlraWnogKrR42IosO/xVd+i0OMZ1DfBi2l+ixwmW/nu1zjJbGvkb
         vun6k0eVHgVSD+iqj0UPIJvdtYFLCUNrE9QgcKK1/p9Zwm3WirUm/El/VocbGUmoLGLk
         ha8Kp/4lFm0dTorn4FgkceVq7x/+Wlu+au6wzpffHTiqyiXSXoDaBmDAfTN+XUzu3TP2
         vH3X9AdhGvrsVfBnQkHKkzz+LkMCQyj0yro5ZYURuNP5i3snvcF6CrtS0j9+mjrEbqnp
         heBm4As6CkJaNLPmXUhuf+5L7tIW5LPbwrXVWE93PjXPlmdrGOi6SlRXXf9W1RSTM6gG
         9wVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o25si7897618ejd.215.2019.07.24.10.59.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 10:59:00 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4FF3CABD9;
	Wed, 24 Jul 2019 17:58:59 +0000 (UTC)
Date: Wed, 24 Jul 2019 19:58:58 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@lst.de>, Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>
Subject: Re: [PATCH] mm/hmm: replace hmm_update with mmu_notifier_range
Message-ID: <20190724175858.GC6410@dhcp22.suse.cz>
References: <20190723210506.25127-1-rcampbell@nvidia.com>
 <20190724070553.GA2523@lst.de>
 <20190724152858.GB28493@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724152858.GB28493@ziepe.ca>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 24-07-19 12:28:58, Jason Gunthorpe wrote:
> On Wed, Jul 24, 2019 at 09:05:53AM +0200, Christoph Hellwig wrote:
> > Looks good:
> > 
> > Reviewed-by: Christoph Hellwig <hch@lst.de>
> > 
> > One comment on a related cleanup:
> > 
> > >  	list_for_each_entry(mirror, &hmm->mirrors, list) {
> > >  		int rc;
> > >  
> > > -		rc = mirror->ops->sync_cpu_device_pagetables(mirror, &update);
> > > +		rc = mirror->ops->sync_cpu_device_pagetables(mirror, nrange);
> > >  		if (rc) {
> > > -			if (WARN_ON(update.blockable || rc != -EAGAIN))
> > > +			if (WARN_ON(mmu_notifier_range_blockable(nrange) ||
> > > +			    rc != -EAGAIN))
> > >  				continue;
> > >  			ret = -EAGAIN;
> > >  			break;
> > 
> > This magic handling of error seems odd.  I think we should merge rc and
> > ret into one variable and just break out if any error happens instead
> > or claiming in the comments -EAGAIN is the only valid error and then
> > ignoring all others here.
> 
> The WARN_ON is enforcing the rules already commented near
> mmuu_notifier_ops.invalidate_start - we could break or continue, it
> doesn't much matter how to recover from a broken driver, but since we
> did the WARN_ON this should sanitize the ret to EAGAIN or 0
> 
> Humm. Actually having looked this some more, I wonder if this is a
> problem:
> 
> I see in __oom_reap_task_mm():
> 
> 			if (mmu_notifier_invalidate_range_start_nonblock(&range)) {
> 				tlb_finish_mmu(&tlb, range.start, range.end);
> 				ret = false;
> 				continue;
> 			}
> 			unmap_page_range(&tlb, vma, range.start, range.end, NULL);
> 			mmu_notifier_invalidate_range_end(&range);
> 
> Which looks like it creates an unbalanced start/end pairing if any
> start returns EAGAIN?
> 
> This does not seem OK.. Many users require start/end to be paired to
> keep track of their internal locking. Ie for instance hmm breaks
> because the hmm->notifiers counter becomes unable to get to 0.
> 
> Below is the best idea I've had so far..
> 
> Michal, what do you think?

IIRC we have discussed this with Jerome back then when I've introduced
this code and unless I misremember he said the current code was OK.
Maybe new users have started relying on a new semantic in the meantime,
back then, none of the notifier has even started any action in blocking
mode on a EAGAIN bailout. Most of them simply did trylock early in the
process and bailed out so there was nothing to do for the range_end
callback.

Has this changed?
-- 
Michal Hocko
SUSE Labs

