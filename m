Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76A33C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 19:45:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25448218D4
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 19:45:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25448218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFD686B0003; Thu, 21 Mar 2019 15:45:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AADB86B0006; Thu, 21 Mar 2019 15:45:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94FBD6B0007; Thu, 21 Mar 2019 15:45:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 36A906B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 15:45:43 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o9so20327edh.10
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 12:45:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=1Wt/aVh2Pkmw5m0alBsyWYs2SHGD24MhweUKR3+0YPM=;
        b=trA68qJ8xCMGLXmF4MQX8Zb25FU2AANo6aBTkdW3247umHI8Gko8QYfY9Uir0CcHdg
         NVFNlWHLhbfYFPEK82uRnu/FvWmyEzkoXVMiXdWY05vNzk2Qh3vveScKQY74zK7wWhKV
         z/+yc1C3JzhZvyZVZGH/3vsHHyaWuT444H2cBu37uDrGBYeZLBPmtcefsXLaS7Uzo1F1
         Y2kEHX2QYZ/0Y8iASdrCX+3fTZrKcADJMQvlhbng2Ri/LY9WGeIv8qGgECckP/v/7udJ
         A7RpyWmsJ2xODPB9M+BdKEGfjJEaMviP3VkFlhFOjVliuYkG/6JyLW+G5fVMdNTYfH9J
         i9Pg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVU0lUK8kc8ORwKhMlmzH0K9cNmZxDdT0fm9euETD/6qw5olfrk
	1NpUILUF2z6qejO6wyQuZc6lL37ESQVs5wuaDmWIIWPWqJ9lCBIVKGlMAD4CFeokHVD/FoemKXA
	tWFYyg4cZxDtOVc32NFmshvRqOjDJJUfPcO7VP6NN+Gx+xbiPAWXOkRjLGf4eaSU=
X-Received: by 2002:a50:b641:: with SMTP id c1mr3562147ede.155.1553197542757;
        Thu, 21 Mar 2019 12:45:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJoRFkTmDB/QoLN5p5O85QHgl2Ref0TpnsS07Y7LKC9kjyZC/l6fMP/wG5YrQ1skbxvEoG
X-Received: by 2002:a50:b641:: with SMTP id c1mr3562115ede.155.1553197541723;
        Thu, 21 Mar 2019 12:45:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553197541; cv=none;
        d=google.com; s=arc-20160816;
        b=sI9TAtlB7pZn5mQdZ6e9hjHAcBZOlpBKTJ5x5Gmw5hvvXBAmxDyrj8jdnBW788MMrC
         6jgnu5DkThG/IrZ20C2JCM9hDClwf0qI09pz+WPB3OXsqPrOb0eotp2Sc58bV1+5lpzl
         6K1Mo34EmhuPBMlVE1kSxj8LuvyDOLdakS5kHLayfFZRUqPaPIz9PcUX2THHrtlEwNH2
         KL4Nu/TqfcVwA9T4ckhiAa9Fz6s428AedUmt9TtgNS7jx0OBNq8gTiZruNbEp/01+Lwe
         uFb38u68enUmNnz9AyvvizycbjfIuFaHwiCHGjPt81NyW4nRtOWGKnlT++vNQP0+5lVE
         XUbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=1Wt/aVh2Pkmw5m0alBsyWYs2SHGD24MhweUKR3+0YPM=;
        b=MrTtmjLypG43NIXo4Nk8Zfw7Pp0AvPcxaWrLOVJSTbSLe36h+3ifXgQzcK3Aww4E22
         HSiV+aJIYfSBlAG4wD1bDPq8ipnCtAuueoXY8omwfhWOhe9X9A453nTXTIqgEwCcUi29
         fWB69WcZ1mwTZSSBT4leVb3oMBTvX0z5Wx4jqb7ug7EvZUgFPfZla6/rrr8U/wb071+c
         nXUxX80SCJPHfm7AxBiz8uWfV0OuQW5ILlnqNLAY5ne1MjtNqg/a/ttK2PXqkeC0YWTG
         dZlQvwiJgHr68MBZfvxBE32foylyUEjm29lZc6d3g5pnsG7xT2hMoCpTOc1yCneBzwcf
         I6uw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j9si1955482ejf.283.2019.03.21.12.45.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 12:45:41 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0AC07AF46;
	Thu, 21 Mar 2019 19:45:41 +0000 (UTC)
Date: Thu, 21 Mar 2019 20:45:39 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mgorman@techsingularity.net, vbabka@suse.cz, akpm@linux-foundation.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH] mm: mempolicy: remove MPOL_MF_LAZY
Message-ID: <20190321194539.GY8696@dhcp22.suse.cz>
References: <1553041659-46787-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190321145745.GS8696@dhcp22.suse.cz>
 <75059b39-dbc4-3649-3e6b-7bdf282e3f53@linux.alibaba.com>
 <20190321165112.GU8696@dhcp22.suse.cz>
 <60ef6b4a-4f24-567f-af2f-50d97a2672d6@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <60ef6b4a-4f24-567f-af2f-50d97a2672d6@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 21-03-19 10:25:08, Yang Shi wrote:
> 
> 
> On 3/21/19 9:51 AM, Michal Hocko wrote:
> > On Thu 21-03-19 09:21:39, Yang Shi wrote:
> > > 
> > > On 3/21/19 7:57 AM, Michal Hocko wrote:
> > > > On Wed 20-03-19 08:27:39, Yang Shi wrote:
> > > > > MPOL_MF_LAZY was added by commit b24f53a0bea3 ("mm: mempolicy: Add
> > > > > MPOL_MF_LAZY"), then it was disabled by commit a720094ded8c ("mm:
> > > > > mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now")
> > > > > right away in 2012.  So, it is never ever exported to userspace.
> > > > > 
> > > > > And, it looks nobody is interested in revisiting it since it was
> > > > > disabled 7 years ago.  So, it sounds pointless to still keep it around.
> > > > The above changelog owes us a lot of explanation about why this is
> > > > safe and backward compatible. I am also not sure you can change
> > > > MPOL_MF_INTERNAL because somebody still might use the flag from
> > > > userspace and we want to guarantee it will have the exact same semantic.
> > > Since MPOL_MF_LAZY is never exported to userspace (Mel helped to confirm
> > > this in the other thread), so I'm supposed it should be safe and backward
> > > compatible to userspace.
> > You didn't get my point. The flag is exported to the userspace and
> > nothing in the syscall entry path checks and masks it. So we really have
> > to preserve the semantic of the flag bit for ever.
> 
> Thanks, I see you point. Yes, it is exported to userspace in some sense
> since it is in uapi header. But, it is never documented and MPOL_MF_VALID
> excludes it. mbind() does check and mask it. It would return -EINVAL if
> MPOL_MF_LAZY or any other undefined/invalid flag is set. See the below code
> snippet from do_mbind():
> 
> ...
> #define MPOL_MF_VALID    (MPOL_MF_STRICT   |     \
>              MPOL_MF_MOVE     |     \
>              MPOL_MF_MOVE_ALL)
> 
> if (flags & ~(unsigned long)MPOL_MF_VALID)
>         return -EINVAL;
> 
> So, I don't think any application would really use the flag for mbind()
> unless it is aimed to test the -EINVAL. If just test program, it should be
> not considered as a regression.

I have overlook that MPOL_MF_VALID doesn't include MPOL_MF_LAZY. Anyway,
my argument still holds that the bit has to be reserved for ever because
it used to be valid at some point of time and not returning EINVAL could
imply you are running on the kernel which supports the flag.
 
> > > I'm also not sure if anyone use MPOL_MF_INTERNAL or not and how they use it
> > > in their applications, but how about keeping it unchanged?
> > You really have to. Because it is an offset of other MPLO flags for
> > internal usage.
> > 
> > That being said. Considering that we really have to preserve
> > MPOL_MF_LAZY value (we cannot even rename it because it is in uapi
> > headers and we do not want to break compilation). What is the point of
> > this change? Why is it an improvement? Yes, nobody is probably using
> > this because this is not respected in anything but the preferred mem
> > policy. At least that is the case from my quick glance. I might be still
> > wrong as it is quite easy to overlook all the consequences. So the risk
> > is non trivial while the benefit is not really clear to me. If you see
> > one, _document_ it. "Mel said it is not in use" is not a justification,
> > with all due respect.
> 
> As I elaborated above, mbind() syscall does check it and treat it as an
> invalid flag. MPOL_PREFERRED doesn't use it either, but just use MPOL_F_MOF
> directly.

As Mel already pointed out. This doesn't really sound like a sound
argument. Say we would remove those few lines of code and preserve the
flag for future reservation of the flag bit. I would bet my head that it
will not be long before somebody just goes and clean it up and remove
because the flag is unused. So you would have to put a note explaining
why this has to be preserved. Maybe the current code is better to
document that. It would be much more sound to remove the code if it was
causing a measurable overhead or a maintenance burden. Is any of that
the case?

-- 
Michal Hocko
SUSE Labs

