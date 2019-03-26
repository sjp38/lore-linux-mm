Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6CE7C10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 10:17:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F65F20866
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 10:17:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F65F20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1515A6B0005; Tue, 26 Mar 2019 06:17:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D91B6B0006; Tue, 26 Mar 2019 06:17:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBB8D6B0007; Tue, 26 Mar 2019 06:17:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 999906B0005
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 06:17:13 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k8so1923822edl.22
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 03:17:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=z5H7a+ndzXrGYDYXch+uDlo9UtGI1GPDeUhAl+HpKIw=;
        b=R+4fRE6q3l/8RBmXj8wNJWu25is/GjBxlKVG7cOnX3iUh11uYn8pQ0MMERk5H5MmX/
         pPCQRF70IyZlPZe1/EJF3+Z3Zr2NcoITa+2rbNAj0Ok4ifs/9d6Nk8jLDv7oTH22X9Fy
         4jCJGNVCSNmqaoQSE4BP5OVX8rsneSgGGZT8+oHmwqzUkkhxPRZVChBGOySVrWALyyUF
         YWOa8LtDaY6Xqg//I7wWiMHcxL+2E8zdjaLPjif4QJeAckvmL/N58BYBo82HnHq/1/OJ
         e3s8ihzlTjz9BnriZBxTRHuHZd0BZ2xTQPCatvczCRcX9QVGrpMGlP/uOxan1AHRbZsU
         9yow==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW4TMdD605FdhCEJTCnfHvfyoGYk7WE1pRWLe4jK5um1XRWHEh+
	/0B+RNyykD4b8rBGkfG4KC2odwhLWd0f6k2GBxVZXSONi4VeEw1z9b680jCL53DXLUfQgFEJXEM
	bbYA0TmpAypZ/exWMA6ocNJgfo5K7hnAxd4G8cWyfpoGsj4j5lfhBl7cSH1ozHHE=
X-Received: by 2002:a17:906:eb87:: with SMTP id mh7mr13061267ejb.152.1553595433180;
        Tue, 26 Mar 2019 03:17:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwl/rVoUaXfLQp5BYU/rd7M837fhAB62xmgCrFo38S31E5GlgSWYhbA/f58d7G4ZyQkf/oF
X-Received: by 2002:a17:906:eb87:: with SMTP id mh7mr13061227ejb.152.1553595432400;
        Tue, 26 Mar 2019 03:17:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553595432; cv=none;
        d=google.com; s=arc-20160816;
        b=tZtXCuLjgJu+dmqwN57G1czK8R5AlRIaVzLjmB8eof5wvgxoP9wJQS11HQ3CDHaM3F
         DssPZxbGFXQ4KkOmjJb0CuC1q/iYCn94WzjHHsXZeEH6kaAOsUDjnAH7FkYEP9deHuoD
         hTkAN706r6oELtOo9Eg/XGZDrZKFL9PxyJaTLUkC93N4wjzEhaBGtK3FuiLHrB7xsJuS
         VxFSkCmbJsqYLfcWMekWJIkw+u4VzUe55BYstvYwit406BeFtpvTB5zO2E4JgxTmk9Hz
         TgLxQ/ZrtUJoAnWRc8XxzpyhNO5v60GfcyIIgHZLxQ0kbhdEIAvSIAwg2T6aIKgWFoSe
         3HTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=z5H7a+ndzXrGYDYXch+uDlo9UtGI1GPDeUhAl+HpKIw=;
        b=G+UgmEoUNlEVc9Gmcte6HRWNvkeB2x3Zlywxct2+3IzLq3O5AXQR0p5HsJfXlBoCFC
         WXftyiDdqsY6nZiD2e41Aad4TPb1a0JIugmMHuOarE8KfQNICwI9uuKa/GXfpoCqHywI
         s9dUYX4OsVOiwsbUGJEIM38hGt05ARNEfszdJckd6FA+1bnCT4V3AVKszGa818Dor9U9
         Je36paOdRhCBeXJPsRUao8oLuolNlKPZ+SeLFZDnkawStuuOG0heRaEBVDG2KEM0Conr
         susIm70RU1DFymMd8lPCVT0sphNhui7TlIaBGlPG0hUIBCbn9Wl8RmSWK5TwGL6Z0o7k
         aG7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r30si5260696edd.248.2019.03.26.03.17.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 03:17:12 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7FC8DAEDB;
	Tue, 26 Mar 2019 10:17:11 +0000 (UTC)
Date: Tue, 26 Mar 2019 11:17:10 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, rppt@linux.ibm.com, osalvador@suse.de,
	willy@infradead.org, william.kucharski@oracle.com
Subject: Re: [PATCH v2 2/4] mm/sparse: Optimize sparse_add_one_section()
Message-ID: <20190326101710.GN28406@dhcp22.suse.cz>
References: <20190326090227.3059-1-bhe@redhat.com>
 <20190326090227.3059-3-bhe@redhat.com>
 <20190326092936.GK28406@dhcp22.suse.cz>
 <20190326100817.GV3659@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326100817.GV3659@MiWiFi-R3L-srv>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-03-19 18:08:17, Baoquan He wrote:
> On 03/26/19 at 10:29am, Michal Hocko wrote:
> > On Tue 26-03-19 17:02:25, Baoquan He wrote:
> > > Reorder the allocation of usemap and memmap since usemap allocation
> > > is much simpler and easier. Otherwise hard work is done to make
> > > memmap ready, then have to rollback just because of usemap allocation
> > > failure.
> > 
> > Is this really worth it? I can see that !VMEMMAP is doing memmap size
> > allocation which would be 2MB aka costly allocation but we do not do
> > __GFP_RETRY_MAYFAIL so the allocator backs off early.
> 
> In !VMEMMAP case, it truly does simple allocation directly. surely
> usemap which size is 32 is smaller. So it doesn't matter that much who's
> ahead or who's behind. However, this benefit a little in VMEMMAP case.

How does it help there? The failure should be even much less probable
there because we simply fall back to a small 4kB pages and those
essentially never fail.

> And this make code a little cleaner, e.g the error handling at the end
> is taken away.
> 
> > 
> > > And also check if section is present earlier. Then don't bother to
> > > allocate usemap and memmap if yes.
> > 
> > Moving the check up makes some sense.
> > 
> > > Signed-off-by: Baoquan He <bhe@redhat.com>
> > 
> > The patch is not incorrect but I am wondering whether it is really worth
> > it for the current code base. Is it fixing anything real or it is a mere
> > code shuffling to please an eye?
> 
> It's not a fixing, just a tiny code refactorying inside
> sparse_add_one_section(), seems it doesn't worsen thing if I got the
> !VMEMMAP case correctly, not quite sure. I am fine to drop it if it's
> not worth. I could miss something in different cases.

Well, I usually prefer to not do micro-optimizations in a code that
really begs for a much larger surgery. There are other people working on
the code and patches like these might get into the way and cuase
conflicts without a very good justification.
-- 
Michal Hocko
SUSE Labs

