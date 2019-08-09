Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FF07C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 18:02:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E0492189D
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 18:02:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E0492189D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE5E96B0292; Fri,  9 Aug 2019 14:02:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A955D6B02A2; Fri,  9 Aug 2019 14:02:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95F2F6B02B9; Fri,  9 Aug 2019 14:02:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 46D646B0292
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 14:02:48 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z2so1768035ede.2
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 11:02:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SylYOqXBMDBSLKzlDi3P8vwpHHjx+aWEZwfXRR/kCl4=;
        b=WEhLyMggGVqX2DrPR/NbldWvSAj2sA0evy0omaP5ERwB9GvOX8Y7FSMvLNVPTl0it0
         /NDhgOrTIbHEvtnaXLbaCNP6+HyjUJwJriWpGlSgdlRyF/PsbIk0E6g2sRbZshjPi9I7
         nNsGvhFIjcl9YR0m4BswuaE+ZqyLb/9DNb91xj9stbGyaOEG7EXgA1vjRhV/3pT5XeA5
         DQWqEou6WzzmGb7SY71S5A/t8hi5BGh11rQDVqPpC04dTbFXiLiwshzLQPa5eKd0BKpB
         tyVSmFhah7+erj4WhneZ+BUPy3eRrSlEMkwFzY0aMuDusUnSiicFXCt0UCiklZW4usHo
         eoMA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXkH+hhaBV56WJ627I92RbYDqgaNN7bj3XVs3w2R7uNpeQRW2Pc
	lk4x9UMpNhxYEQwyqfAcNCV71rTw7F0ZM+N5YdFQgEPECnFoaZEDYKEIsZ7Lk/9J5HuShhjjCY0
	Wjcl0UP2MDj5A8dKsoptPgesL9d8iGblRKQavsbbIKMYRUmzfDhkPFvb7feLMWEw=
X-Received: by 2002:a17:906:a952:: with SMTP id hh18mr19695655ejb.289.1565373767835;
        Fri, 09 Aug 2019 11:02:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw137AK/j3XBKLvpQJD4Yx+9jJdhJmqg9zrdnzUDVRLGbrp6BTu329bCgra+WPyXtZvtHtQ
X-Received: by 2002:a17:906:a952:: with SMTP id hh18mr19695586ejb.289.1565373767051;
        Fri, 09 Aug 2019 11:02:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565373767; cv=none;
        d=google.com; s=arc-20160816;
        b=ErriycVnFAgrjxPMIJ+6fCrmXlW5uZw06+RyfDJ0SivtSdd6mSHxfpmnbSB/HV94Xn
         zcnnZaFDvRA2QhMR7yubnaDDJTsp/hPyd6nWeIG7wfjVBDoNlAHnn/ROoI4YR/CdTkli
         CPKiI7C7M2kZGn+T1gVIy0ZNmop5rphQV3e8eKk2pzLHxYvDWpN+RWWi9752Jc3NWzQO
         N59OOM6dxQ2u4CcYZmHd72ISLfmjJIt0z3/tpQVSq4MQWiYQNvtNF4zBW0qGKAZyhmui
         1xFN5UVV1dzMPpoZcJo0pU7kISyEzKEkwyD7a3aXgGHwGtnefGMp6UuOooRccf98r3qD
         YOWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SylYOqXBMDBSLKzlDi3P8vwpHHjx+aWEZwfXRR/kCl4=;
        b=IauTobUe4p11xFIsB73vwI5rw4zLoXvTl20IZ+iOsEiEI46M9T3s2RNwO66dkebVl9
         mT/DbQAaXyDs9WmBKrK+/bxsRBncjv51A8KIa0Z49VLdnTNC0aT6hS3SiZsfV20ExVmD
         19n9Fs3gFLHfpzIqjAlc48CT3pAJMbvJ43Ciatxx6TfLPLjxXYRlusw6B/1GuiLO5y7S
         dYCwUXfshFIcDmoOJCf0NTa5xwY0Nc+wOJlOpWBEEcVVU0WwWeSbsqEKxC9DNx+ZXR0v
         EecjS6LpScwKQiegTeYM4phZ28EXKHpkdTW+y07ugmpvczUATO/Vkw5s+TcimnSi8BqJ
         tRsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s25si33909318eja.243.2019.08.09.11.02.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 11:02:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 25050AF89;
	Fri,  9 Aug 2019 18:02:46 +0000 (UTC)
Date: Fri, 9 Aug 2019 20:02:38 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, vbabka@suse.cz,
	rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RESEND PATCH 1/2 -mm] mm: account lazy free pages separately
Message-ID: <20190809180238.GS18351@dhcp22.suse.cz>
References: <1565308665-24747-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190809083216.GM18351@dhcp22.suse.cz>
 <1a3c4185-c7ab-8d6f-8191-77dce02025a7@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1a3c4185-c7ab-8d6f-8191-77dce02025a7@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 09-08-19 09:19:13, Yang Shi wrote:
> 
> 
> On 8/9/19 1:32 AM, Michal Hocko wrote:
> > On Fri 09-08-19 07:57:44, Yang Shi wrote:
> > > When doing partial unmap to THP, the pages in the affected range would
> > > be considered to be reclaimable when memory pressure comes in.  And,
> > > such pages would be put on deferred split queue and get minus from the
> > > memory statistics (i.e. /proc/meminfo).
> > > 
> > > For example, when doing THP split test, /proc/meminfo would show:
> > > 
> > > Before put on lazy free list:
> > > MemTotal:       45288336 kB
> > > MemFree:        43281376 kB
> > > MemAvailable:   43254048 kB
> > > ...
> > > Active(anon):    1096296 kB
> > > Inactive(anon):     8372 kB
> > > ...
> > > AnonPages:       1096264 kB
> > > ...
> > > AnonHugePages:   1056768 kB
> > > 
> > > After put on lazy free list:
> > > MemTotal:       45288336 kB
> > > MemFree:        43282612 kB
> > > MemAvailable:   43255284 kB
> > > ...
> > > Active(anon):    1094228 kB
> > > Inactive(anon):     8372 kB
> > > ...
> > > AnonPages:         49668 kB
> > > ...
> > > AnonHugePages:     10240 kB
> > > 
> > > The THPs confusingly look disappeared although they are still on LRU if
> > > you are not familair the tricks done by kernel.
> > Is this a fallout of the recent deferred freeing work?
> 
> This series follows up the discussion happened when reviewing "Make deferred
> split shrinker memcg aware".

OK, so it is a pre-existing problem. Thanks!

> David Rientjes suggested deferred split THP should be accounted into
> available memory since they would be shrunk when memory pressure comes in,
> just like MADV_FREE pages. For the discussion, please refer to:
> https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg2010115.html

Thanks for the reference.

> 
> > 
> > > Accounted the lazy free pages to NR_LAZYFREE, and show them in meminfo
> > > and other places.  With the change the /proc/meminfo would look like:
> > > Before put on lazy free list:
> > The name is really confusing because I have thought of MADV_FREE immediately.
> 
> Yes, I agree. We may use a more specific name, i.e. DeferredSplitTHP.
> 
> > 
> > > +LazyFreePages: Cleanly freeable pages under memory pressure (i.e. deferred
> > > +               split THP).
> > What does that mean actually? I have hard time imagine what cleanly
> > freeable pages mean.
> 
> Like deferred split THP and MADV_FREE pages, they could be reclaimed during
> memory pressure.
> 
> If you just go with "DeferredSplitTHP", these ambiguity would go away.

I have to study the code some more but is there any reason why those
pages are not accounted as proper THPs anymore? Sure they are partially
unmaped but they are still THPs so why cannot we keep them accounted
like that. Having a new counter to reflect that sounds like papering
over the problem to me. But as I've said I might be missing something
important here.

-- 
Michal Hocko
SUSE Labs

