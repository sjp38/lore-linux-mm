Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2273DC0650E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 07:37:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E33652133F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 07:37:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E33652133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A25A6B0003; Thu,  4 Jul 2019 03:37:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 720AC8E0003; Thu,  4 Jul 2019 03:37:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C1D68E0001; Thu,  4 Jul 2019 03:37:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 093FD6B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 03:37:35 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c27so3272098edn.8
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 00:37:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=NPbcT7fNZKxE9QIwn5p/+MnGQ2etLcnd4JIXTlUCZm4=;
        b=h19uokjQYsFReML3Juw1sfZkfkeUtWtzxg5AFDtiERFX3MmoV+aN5m6IH0leKWQvsp
         RIB0k1YrtHrQIx7A3wCbx8p4QQxjb30x0SXltJbu5djg841aK+YnCZeCOeTxdN9eUuRY
         ierMVH8rSIUyitB5AY9qIwxrtwi8DrE78HTxp8oY57nUq2QCySIJfdGrcayayMLBhmx8
         cVUq9Cm1NvEtEP53dfp++GFYljojdZCegQtf6Lsa3HEL8rP8G25pGcwp4ungSNH6Ao5L
         Nc9zl/XnFW+Ml6JxXKx2FEZn3AhQ9SRQJaR4o5DWVNp3LWYIPd2T0lxdK3q3GGVfF3HB
         WgDg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXs0ErK11zfJnbOvOdvRxOM2uvMOckyn5E+peCxjSOCSOQR2wXi
	y6d7Pt3XrYCEmMr+2SvseVPPa7bycmAtX0MbPf7S4ICaMkATYEvvJLdlhsLn32rXb++kTRh9scl
	xejXpqh9koweQWed7kpqfLX3GzIoRVcOCr+sOP7QMTcx2D1KmTlZREJ0x4ev6I+0=
X-Received: by 2002:a50:b1db:: with SMTP id n27mr47613131edd.62.1562225854539;
        Thu, 04 Jul 2019 00:37:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwna+G+JWkbfvdAEkKMFdEqTI5fgfHJ02IWRVo6PCDE5rS6LxUcxlLp7+NxKp+fl6+wFDJ8
X-Received: by 2002:a50:b1db:: with SMTP id n27mr47613064edd.62.1562225853646;
        Thu, 04 Jul 2019 00:37:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562225853; cv=none;
        d=google.com; s=arc-20160816;
        b=xAvyrPSKANqKQ3E5b/JqGWwO4mTaRiUem/ksFdPOk7dqVc+L24V3IcbNxBmQrdn5OX
         yXxYBFCflcFIG5TwRI6J33CUch12JzajwELwYQMm6IS7Zr8lJvjv1i9W6pqz5DOWoGGp
         NjvwZlVe5c0rKj2wuiznjs3UXSH/A1at2RIm4FgmcvzSNn7ajYMD694TyCLsP2nYoE8U
         N05xt572u5ryGSlubfZoKBRgxd3JBNW3lXHqEb6oI6UCEQmJUv0tus+RmKy3uQkuVZtM
         fndJCWG+J2DElB0QG4c8u82WF8h3TpEqDXRfHxgsZJZTam+Trwd9iuj1iEof/5dMWEZV
         adOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=NPbcT7fNZKxE9QIwn5p/+MnGQ2etLcnd4JIXTlUCZm4=;
        b=touuKdmrRvthm2i1ZhAEBncsZxBA3RPpkXWzTo6DFuive/dTkrw//+lwyuKU+getj2
         sSg4NBnFSo/wB87L8NJcqxVbTDw9Clr/wqnw/UUyxZb9Ad9a9Y3UImgLZb74irJO07mH
         8ITK39LqlpkKeiXCHuAHMv7TTJKYVT+NXUsHA2PyhX67yyZyljjFiI8Ol0Nn09dwnf4Y
         HBkTstSixGS73T5WnOXubRcUDfKcDyJnxxTPPc13HkyzuflbjOrnMV8Tt3WmkvvTtyXB
         FMpgR6RUJGq83qXend2PpjxMzPFvtLBx6h78OM6XagLQboXohhA8TcqSdl3gSqIJL2gE
         AqZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id um8si3285220ejb.373.2019.07.04.00.37.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 00:37:33 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5CBB9AD7F;
	Thu,  4 Jul 2019 07:37:32 +0000 (UTC)
Date: Thu, 4 Jul 2019 09:37:30 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm, slab: Extend slab/shrink to shrink all the memcg
 caches
Message-ID: <20190704073730.GA5620@dhcp22.suse.cz>
References: <20190702183730.14461-1-longman@redhat.com>
 <20190702130318.39d187dc27dbdd9267788165@linux-foundation.org>
 <78879b79-1b8f-cdfd-d4fa-610afe5e5d48@redhat.com>
 <20190702143340.715f771192721f60de1699d7@linux-foundation.org>
 <c29ff725-95ba-db4d-944f-d33f5f766cd3@redhat.com>
 <20190703155314.GT978@dhcp22.suse.cz>
 <ca6147ca-25be-cba6-a7b9-fcac6d21345d@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ca6147ca-25be-cba6-a7b9-fcac6d21345d@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 03-07-19 12:16:09, Waiman Long wrote:
> On 7/3/19 11:53 AM, Michal Hocko wrote:
> > On Wed 03-07-19 11:21:16, Waiman Long wrote:
> >> On 7/2/19 5:33 PM, Andrew Morton wrote:
> >>> On Tue, 2 Jul 2019 16:44:24 -0400 Waiman Long <longman@redhat.com> wrote:
> >>>
> >>>> On 7/2/19 4:03 PM, Andrew Morton wrote:
> >>>>> On Tue,  2 Jul 2019 14:37:30 -0400 Waiman Long <longman@redhat.com> wrote:
> >>>>>
> >>>>>> Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
> >>>>>> file to shrink the slab by flushing all the per-cpu slabs and free
> >>>>>> slabs in partial lists. This applies only to the root caches, though.
> >>>>>>
> >>>>>> Extends this capability by shrinking all the child memcg caches and
> >>>>>> the root cache when a value of '2' is written to the shrink sysfs file.
> >>>>> Why?
> >>>>>
> >>>>> Please fully describe the value of the proposed feature to or users. 
> >>>>> Always.
> >>>> Sure. Essentially, the sysfs shrink interface is not complete. It allows
> >>>> the root cache to be shrunk, but not any of the memcg caches. 
> >>> But that doesn't describe anything of value.  Who wants to use this,
> >>> and why?  How will it be used?  What are the use-cases?
> >>>
> >> For me, the primary motivation of posting this patch is to have a way to
> >> make the number of active objects reported in /proc/slabinfo more
> >> accurately reflect the number of objects that are actually being used by
> >> the kernel.
> > I believe we have been through that. If the number is inexact due to
> > caching then lets fix slabinfo rather than trick around it and teach
> > people to do a magic write to some file that will "solve" a problem.
> > This is exactly what drop_caches turned out to be in fact. People just
> > got used to drop caches because they were told so by $random web page.
> > So really, think about the underlying problem and try to fix it.
> >
> > It is true that you could argue that this patch is actually fixing the
> > existing interface because it doesn't really do what it is documented to
> > do and on those grounds I would agree with the change.
> 
> I do think that we should correct the shrink file to do what it is
> designed to do to include the memcg caches as well.
> 
> 
> >  But do not teach
> > people that they have to write to some file to get proper numbers.
> > Because that is just a bad idea and it will kick back the same way
> > drop_caches.
> 
> The /proc/slabinfo file is a well-known file that is probably used
> relatively extensively. Making it to scan through all the per-cpu
> structures will probably cause performance issues as the slab_mutex has
> to be taken during the whole duration of the scan. That could have
> undesirable side effect.

Please be more specific with some numbers ideally. Also if collecting
data is too expensive, why cannot we simply account cached objects count
in pcp manner?

> Instead, I am thinking about extending the slab/objects sysfs file to
> also show the number of objects hold up by the per-cpu structures and
> thus we can get an accurate count by subtracting it from the reported
> active objects. That will have a more limited performance impact as it
> is just one kmem cache instead of all the kmem caches in the system.
> Also the sysfs files are not as commonly used as slabinfo. That will be
> another patch in the near future.

Both are root only and once it is widespread that slabinfo doesn't
provide precise data you can expect tools will try to fix that by adding
another file(s) and we are back to square one, no? In other words
slabinfo

-- 
Michal Hocko
SUSE Labs

