Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A26C8C7618F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 20:26:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B4C022ADA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 20:26:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="OSSRdZkS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B4C022ADA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0D306B0003; Fri, 26 Jul 2019 16:26:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBE928E0003; Fri, 26 Jul 2019 16:26:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD39B8E0002; Fri, 26 Jul 2019 16:26:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A5DBE6B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 16:26:51 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id l11so12313641pgc.14
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 13:26:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=IE5eJowpyCcGnZE2pKcSc9umsrWgUqBG7zCK+NjEKK4=;
        b=Zn1LjrXi/tRHcEcLz4UqlNDNXxH3pDiDrIcmPWKCkq09hrseiiTXP8xLyzrBpuYMVj
         itjbxD6AwoR7/3X8OXJlzc7cThcBmvkUk8Jn6ZwrtfCUzMD9TFOD1IF4s+Jkkii8qPoF
         0/pmN0yPsihQJvhTLWRq001LvePl61SrjGqhdrPKYs3pMWr4dBG78d0WeBNlHLjAXAh2
         aT5GGMfQ+yzWmJFgKSuVwXTWNhMQXXZl1EZgnxM05NxTLOVYQz4jZX03yEi9n9b56YtZ
         M4WKkUSvciYWF5m4k6EQhveD6cSFI1JPPpzWwcf2L5XodydjuQjJyVdluK8Pe1KYpxGZ
         7NcQ==
X-Gm-Message-State: APjAAAXM1bAp1wHkkBBzGlJbqURWez4daLgIzz9w7UhoBQMuMP9BjXoB
	AlLWaBz+BC85HgVwLf9afkoggLrUu9jRNsPo4/lVA5SL0Oq5OYcSI5tSwFkz8YKe9GMid1HX+WH
	3paTveezH1CWtMejuNnPrJqfxcL/iJYDeYW9damQw81cvi9/g3UB5rZNMklzFM8z1Nw==
X-Received: by 2002:a62:764d:: with SMTP id r74mr25107535pfc.110.1564172811255;
        Fri, 26 Jul 2019 13:26:51 -0700 (PDT)
X-Received: by 2002:a62:764d:: with SMTP id r74mr25107499pfc.110.1564172810612;
        Fri, 26 Jul 2019 13:26:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564172810; cv=none;
        d=google.com; s=arc-20160816;
        b=09N6bSkcsnPZLPnuC/CE9xc8RcuIyxdAwh5psykN4FoBKXDhi9xebxI/YW0JquB92l
         l8oVpuAL9FoYrVVadOqFO2X+79zhQpflCAIu/TwBzU+1goJNtEEVxIlYwjlA+vu15F+7
         7e2r/JHWTe9khaDsXa05GqJ7T2t44ASVKAVGSw4tM5Kkc+rovlGnxs5SRqyALbGCxFQk
         tbL9d1cD42VgPO4MUHgi2aYx1tHxDUstsLoG/QR8qXVfgWZ1X6/Nsjqz8SuaCGy54xlS
         KcFD6jGu2QhJLoCkvob1NVt3aM0UE9jWFQuACgHvSbtNS0ONWGyA1iiWKTtsqTTkuUqc
         1GeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=IE5eJowpyCcGnZE2pKcSc9umsrWgUqBG7zCK+NjEKK4=;
        b=RDP1/89+nD/eeFCU/h3YRBKCqXIckakdC1v0T0RL/GZ/qwdOu8v124oB1DxgP43UkV
         81GvzIwb3uOiN+RZt1iMTN2yp39lQWfR0AB3pdTU0y0NAv5EidJTrrft6IcmLcXYARDR
         3xN2FsqtM/g+cDEmwMVytQWw8Z2iC7/wWyuN+TwF3mZXJAuCsgm7iDefLZ2lWDYW3Pw8
         f02SZ7PvsdaKL1W9QD5eXSus78Znne004RZiiV8RVatf5XpNdpIoXCLmrKCLJoQWzPcR
         ynLkqYJGyz/U9VzC5xAbm9mtgwYLXSHVMV2IUa0iNiLoFpcFRzbvFk1Li8Dki1lEG54H
         immg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=OSSRdZkS;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g71sor64043014pje.16.2019.07.26.13.26.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 13:26:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=OSSRdZkS;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=IE5eJowpyCcGnZE2pKcSc9umsrWgUqBG7zCK+NjEKK4=;
        b=OSSRdZkSZXg6M+b9FWF3a1q+TiPSBp244enRgIGdVZjUu/SD8K8PRf3KqpHJ6cYWhk
         n3RevHiDEbDWb3xewyJUfr/5dEQwWqMIwnEbk87NSvS9caP8hIT7G5fh4UfLVUxKM38z
         JNXY9crOfbFD7ctsGRXt2fiHSx0KEPhd66l6Y=
X-Google-Smtp-Source: APXvYqwxNJxyl8AMaL5MbjN3DCH0CGh1VKzKZSR7IsnpnOEC6DeGs6F8TvHMF+yBHu4tkJDhVOJeUA==
X-Received: by 2002:a17:90a:4f0e:: with SMTP id p14mr96514100pjh.40.1564172810042;
        Fri, 26 Jul 2019 13:26:50 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id f19sm77269906pfk.180.2019.07.26.13.26.48
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 26 Jul 2019 13:26:49 -0700 (PDT)
Date: Fri, 26 Jul 2019 16:26:47 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: sspatil@google.com
Cc: linux-kernel@vger.kernel.org, adobriyan@gmail.com,
	akpm@linux-foundation.org, bgregg@netflix.com, chansen3@cisco.com,
	dancol@google.com, fmayer@google.com, joaodias@google.com,
	corbet@lwn.net, keescook@chromium.org, kernel-team@android.com,
	linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com,
	rppt@linux.ibm.com, minchan@kernel.org, namhyung@google.com,
	guro@fb.com, sfr@canb.auug.org.au, surenb@google.com,
	tkjos@google.com, vdavydov.dev@gmail.com, vbabka@suse.cz,
	wvw@google.com, sspatil+mutt@google.com
Subject: Re: [PATCH v3 2/2] doc: Update documentation for page_idle virtual
 address indexing
Message-ID: <20190726202647.GA213712@google.com>
References: <20190726152319.134152-1-joel@joelfernandes.org>
 <20190726152319.134152-2-joel@joelfernandes.org>
 <20190726201710.GA144547@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190726201710.GA144547@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 01:17:10PM -0700, sspatil@google.com wrote:
> Thanks Joel, just a couple of nits for the doc inline below. Other than that,
> 
> Reviewed-by: Sandeep Patil <sspatil@google.com>

Thanks!

> I'll plan on making changes to Android to use this instead of the pagemap +
> page_idle. I think it will also be considerably faster.

Cool, glad to know.

> On Fri, Jul 26, 2019 at 11:23:19AM -0400, Joel Fernandes (Google) wrote:
> > This patch updates the documentation with the new page_idle tracking
> > feature which uses virtual address indexing.
> > 
> > Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> > ---
> >  .../admin-guide/mm/idle_page_tracking.rst     | 43 ++++++++++++++++---
> >  1 file changed, 36 insertions(+), 7 deletions(-)
> > 
> > diff --git a/Documentation/admin-guide/mm/idle_page_tracking.rst b/Documentation/admin-guide/mm/idle_page_tracking.rst
> > index df9394fb39c2..1eeac78c94a7 100644
> > --- a/Documentation/admin-guide/mm/idle_page_tracking.rst
> > +++ b/Documentation/admin-guide/mm/idle_page_tracking.rst
> > @@ -19,10 +19,14 @@ It is enabled by CONFIG_IDLE_PAGE_TRACKING=y.
> >  
> >  User API
> >  ========
> > +There are 2 ways to access the idle page tracking API. One uses physical
> > +address indexing, another uses a simpler virtual address indexing scheme.
> >  
> > -The idle page tracking API is located at ``/sys/kernel/mm/page_idle``.
> > -Currently, it consists of the only read-write file,
> > -``/sys/kernel/mm/page_idle/bitmap``.
> > +Physical address indexing
> > +-------------------------
> > +The idle page tracking API for physical address indexing using page frame
> > +numbers (PFN) is located at ``/sys/kernel/mm/page_idle``.  Currently, it
> > +consists of the only read-write file, ``/sys/kernel/mm/page_idle/bitmap``.
> >  
> >  The file implements a bitmap where each bit corresponds to a memory page. The
> >  bitmap is represented by an array of 8-byte integers, and the page at PFN #i is
> > @@ -74,6 +78,31 @@ See :ref:`Documentation/admin-guide/mm/pagemap.rst <pagemap>` for more
> >  information about ``/proc/pid/pagemap``, ``/proc/kpageflags``, and
> >  ``/proc/kpagecgroup``.
> >  
> > +Virtual address indexing
> > +------------------------
> > +The idle page tracking API for virtual address indexing using virtual page
> > +frame numbers (VFN) is located at ``/proc/<pid>/page_idle``. It is a bitmap
> > +that follows the same semantics as ``/sys/kernel/mm/page_idle/bitmap``
> > +except that it uses virtual instead of physical frame numbers.
> > +
> > +This idle page tracking API does not need deal with PFN so it does not require
> 
> s/need//
> 
> > +prior lookups of ``pagemap`` in order to find if page is idle or not. This is
> 
> s/in order to find if page is idle or not//

Fixed both, thank you! Will send out update soon.

thanks,

 - Joel

