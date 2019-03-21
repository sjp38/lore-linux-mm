Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 518C7C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 16:51:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDF6921902
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 16:51:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDF6921902
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 675A76B0003; Thu, 21 Mar 2019 12:51:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FE716B0006; Thu, 21 Mar 2019 12:51:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EDE66B0007; Thu, 21 Mar 2019 12:51:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E9D3D6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 12:51:15 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id p5so2478318edh.2
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 09:51:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8tYYCz7Qc2gsDI1XTaiG904X0geSQApHfgt/URsxWCU=;
        b=nanCuDu9taUaZT2UpPnToE1Ld2CKU7CaeT/amo8cvOwLtVaqnhetDk0W+rnrpdvCI4
         nXlbuG4V4qwWkTzkKQJfl2b6N2GxypzL2dtpSx8x4++H7kT6GJ98EJdPlXHjOzhMnbp6
         g6BgWeKsnTQt4nNEmWdB3v8KzzzkOR0G0T72R9jbMDDUTKIw5hAOJ/OyzZ05v7fj44dJ
         zPEwwTnbES4zg13ElS4+HetEL54ukEDKVGmmM/oyNxHiHGbUyJLhdUGH3DKV+pVGOFBu
         NXtUOQIC9DllvAosf+pghfyjLMj2sUki6B/FN5ThbvClzS5v9SY9m77ZvD0B9GBn185k
         z/ew==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVQ61ZX3AiHAgue3sXIxmV5VweMyJdja6hRGA7aWzhC/ibQbCpk
	yupUfmuwiLjwnWZatIPe2dEk03ZJlN0mZWxYcjvtQMu6LRFbcijIvYPPIP0RGTuo0Nmdto4MDag
	gc9i3XIn8IgRFb7UrsPD0d4dSXDxZf/BxZdfAvf6VsY4nwx5rDhCnTq4BD5n0IBE=
X-Received: by 2002:a50:f4b7:: with SMTP id s52mr3249853edm.260.1553187075505;
        Thu, 21 Mar 2019 09:51:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjvmMfThviX2FgSADeyNMHvmf61Yv52WZRhJz9TrV1Liksq421VnBPLIlNeZNno6oQNKbh
X-Received: by 2002:a50:f4b7:: with SMTP id s52mr3249806edm.260.1553187074498;
        Thu, 21 Mar 2019 09:51:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553187074; cv=none;
        d=google.com; s=arc-20160816;
        b=PqOX3scYVSxpOjpvMgVtEXg1F98ET+0eJPKpQeW6aPLQ/fULDHQyAkEpJIT3cqwXwA
         zbEy2GFm8DW0P7xLU7c3TGezyaAmNRctUC8NLiHKfgBEd41GeNDaQ1X7ZEXnZ2F3+4W1
         542WQkwu0y2HlW6Ja9Xo592U+wNI4QZhMuu5Wy/d1Lr6uu4WEvfYVdfAUq08oE4bwOMd
         AFaG9tZHft5st/0wLOJGQljOkjnNex2lKS6D24TX1BR1jF/LzaSsnWym1n5eIlT6w+PX
         9FjB3Bz3e+d+arackKNiZvCwxBmp3idZfGkgckZJ8x99wC9206BqaQergn/dRfeHRU5B
         vo0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8tYYCz7Qc2gsDI1XTaiG904X0geSQApHfgt/URsxWCU=;
        b=cjlUY0p07fARYAofq+yEEXrx99d6w52HuRes/ox/jCDqxznd7qJNIVAP4oBN0pNJ36
         wKV4zH0fZ1G0Vpdn0cf21PYMNneWjFrq8qBlVjIqeSnkE/LrhSx8zOVSo2ctGcnaBcxL
         FryyZi/E4WTK2ny1gCLFTkPxiQRGLwiXRgPS0C3SRtWDiBiFVQbS2eBzcoqBOcLGmORE
         L4zEseoN91YhhvkwZKCmqk8U2mS7p0yyq3TG08LM4zroXCJz87kv4a1VrqIdE4Tmi9/O
         g0kwkv47ryzYu7hR5hl+9I+aI+iNt19qEPDaySdFbY/s98ceBv8RbbanowzsnznmkYmX
         1C4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g21si1477685eda.45.2019.03.21.09.51.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 09:51:14 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B4C8DAFAE;
	Thu, 21 Mar 2019 16:51:13 +0000 (UTC)
Date: Thu, 21 Mar 2019 17:51:12 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mgorman@techsingularity.net, vbabka@suse.cz, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH] mm: mempolicy: remove MPOL_MF_LAZY
Message-ID: <20190321165112.GU8696@dhcp22.suse.cz>
References: <1553041659-46787-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190321145745.GS8696@dhcp22.suse.cz>
 <75059b39-dbc4-3649-3e6b-7bdf282e3f53@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <75059b39-dbc4-3649-3e6b-7bdf282e3f53@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 21-03-19 09:21:39, Yang Shi wrote:
> 
> 
> On 3/21/19 7:57 AM, Michal Hocko wrote:
> > On Wed 20-03-19 08:27:39, Yang Shi wrote:
> > > MPOL_MF_LAZY was added by commit b24f53a0bea3 ("mm: mempolicy: Add
> > > MPOL_MF_LAZY"), then it was disabled by commit a720094ded8c ("mm:
> > > mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now")
> > > right away in 2012.  So, it is never ever exported to userspace.
> > > 
> > > And, it looks nobody is interested in revisiting it since it was
> > > disabled 7 years ago.  So, it sounds pointless to still keep it around.
> > The above changelog owes us a lot of explanation about why this is
> > safe and backward compatible. I am also not sure you can change
> > MPOL_MF_INTERNAL because somebody still might use the flag from
> > userspace and we want to guarantee it will have the exact same semantic.
> 
> Since MPOL_MF_LAZY is never exported to userspace (Mel helped to confirm
> this in the other thread), so I'm supposed it should be safe and backward
> compatible to userspace.

You didn't get my point. The flag is exported to the userspace and
nothing in the syscall entry path checks and masks it. So we really have
to preserve the semantic of the flag bit for ever.

> I'm also not sure if anyone use MPOL_MF_INTERNAL or not and how they use it
> in their applications, but how about keeping it unchanged?

You really have to. Because it is an offset of other MPLO flags for
internal usage.

That being said. Considering that we really have to preserve
MPOL_MF_LAZY value (we cannot even rename it because it is in uapi
headers and we do not want to break compilation). What is the point of
this change? Why is it an improvement? Yes, nobody is probably using
this because this is not respected in anything but the preferred mem
policy. At least that is the case from my quick glance. I might be still
wrong as it is quite easy to overlook all the consequences. So the risk
is non trivial while the benefit is not really clear to me. If you see
one, _document_ it. "Mel said it is not in use" is not a justification,
with all due respect.

> Thanks,
> Yang
> 
> > 
> > > Cc: Mel Gorman <mgorman@techsingularity.net>
> > > Cc: Michal Hocko <mhocko@suse.com>
> > > Cc: Vlastimil Babka <vbabka@suse.cz>
> > > Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> > > ---
> > > Hi folks,
> > > I'm not sure if you still would like to revisit it later. And, I may be
> > > not the first one to try to remvoe it. IMHO, it sounds pointless to still
> > > keep it around if nobody is interested in it.
> > > 
> > >   include/uapi/linux/mempolicy.h |  3 +--
> > >   mm/mempolicy.c                 | 13 -------------
> > >   2 files changed, 1 insertion(+), 15 deletions(-)
> > > 
> > > diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
> > > index 3354774..eb52a7a 100644
> > > --- a/include/uapi/linux/mempolicy.h
> > > +++ b/include/uapi/linux/mempolicy.h
> > > @@ -45,8 +45,7 @@ enum {
> > >   #define MPOL_MF_MOVE	 (1<<1)	/* Move pages owned by this process to conform
> > >   				   to policy */
> > >   #define MPOL_MF_MOVE_ALL (1<<2)	/* Move every page to conform to policy */
> > > -#define MPOL_MF_LAZY	 (1<<3)	/* Modifies '_MOVE:  lazy migrate on fault */
> > > -#define MPOL_MF_INTERNAL (1<<4)	/* Internal flags start here */
> > > +#define MPOL_MF_INTERNAL (1<<3)	/* Internal flags start here */
> > >   #define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
> > >   			 MPOL_MF_MOVE     | 	\
> > > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > > index af171cc..67886f4 100644
> > > --- a/mm/mempolicy.c
> > > +++ b/mm/mempolicy.c
> > > @@ -593,15 +593,6 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
> > >   	qp->prev = vma;
> > > -	if (flags & MPOL_MF_LAZY) {
> > > -		/* Similar to task_numa_work, skip inaccessible VMAs */
> > > -		if (!is_vm_hugetlb_page(vma) &&
> > > -			(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE)) &&
> > > -			!(vma->vm_flags & VM_MIXEDMAP))
> > > -			change_prot_numa(vma, start, endvma);
> > > -		return 1;
> > > -	}
> > > -
> > >   	/* queue pages from current vma */
> > >   	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
> > >   		return 0;
> > > @@ -1181,9 +1172,6 @@ static long do_mbind(unsigned long start, unsigned long len,
> > >   	if (IS_ERR(new))
> > >   		return PTR_ERR(new);
> > > -	if (flags & MPOL_MF_LAZY)
> > > -		new->flags |= MPOL_F_MOF;
> > > -
> > >   	/*
> > >   	 * If we are using the default policy then operation
> > >   	 * on discontinuous address spaces is okay after all
> > > @@ -1226,7 +1214,6 @@ static long do_mbind(unsigned long start, unsigned long len,
> > >   		int nr_failed = 0;
> > >   		if (!list_empty(&pagelist)) {
> > > -			WARN_ON_ONCE(flags & MPOL_MF_LAZY);
> > >   			nr_failed = migrate_pages(&pagelist, new_page, NULL,
> > >   				start, MIGRATE_SYNC, MR_MEMPOLICY_MBIND);
> > >   			if (nr_failed)
> > > -- 
> > > 1.8.3.1
> > > 

-- 
Michal Hocko
SUSE Labs

