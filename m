Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FA75C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 13:29:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F07BA2085A
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 13:29:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F07BA2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6297C8E0005; Thu, 14 Mar 2019 09:29:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D5D18E0001; Thu, 14 Mar 2019 09:29:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C60E8E0005; Thu, 14 Mar 2019 09:29:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E490E8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:29:35 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x98so61200ede.18
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 06:29:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nFpdPCQaKLK0dq74m+bV6z4BoOvqlx1plnm6YIxgwkg=;
        b=Uw2sy2VT8HRqQwvejAhnizwp/ucBTPblo1LtJrt0NggazGHwHMEqsoiSyDlu/+mHFo
         hmgc8z8/LWHoAO9rQ6j1hPRwWmUkrjZJMZcNm4YNfGmeK8sxG6ecmOTMh+ZSknJShuHI
         4FbEjXps4f7oFwRBWP7KlBlZq8z45+bz8//XI7087liheH7Tul8/s5bde+v4MgldLAw+
         OZHm95bOhOZ6ydG0Fbprd7dtSlG0auKbfKaUPC9L7x+3k3bXGcTU7CCzpfer1gl+oZqJ
         /AOWl2ylC90tqxuMMQZ5UoSVjSZv3+pocvp99KJSDihy3riu7SLsxwROXEoyNOXKZ2z/
         BN4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAVuFZDa4OLdoLaEsaE7Jd06ZH4Q/arEeineHzMlyMGmJ7j7ISne
	imMnXouP/sfJYCAQHlB/ZjDCYPzITLu5eFYi1HEqupFwPjcufVqQGpcaohgAYBN1jLhe0Yg6vRm
	F2BCv0/7kvILyHlfH96ji5i9TjfGoA8xy/Meg2E62JOYBTkB6fcHInZMFu6RU5tNAsQ==
X-Received: by 2002:a50:b493:: with SMTP id w19mr12069405edd.11.1552570175494;
        Thu, 14 Mar 2019 06:29:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyExLsSX7mWwzji/CANrrQRqTXTv9SpFBwIrAejfgXhk7Ry4zuJNndCV+/w1BXxsMPtNILP
X-Received: by 2002:a50:b493:: with SMTP id w19mr12069357edd.11.1552570174578;
        Thu, 14 Mar 2019 06:29:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552570174; cv=none;
        d=google.com; s=arc-20160816;
        b=0qk47uhFvXNlFMMJGWe4Ryu/P5agHJn/aEJelv/EJKm2hBe1Eg4QBeyZchX1bGdfKB
         h292m2VngyMoXQiFGkpdFwcc63QtxTnayoI789/JvidwojUDUfWVmopHuXdZghU//HMS
         4Ht6PncJCyS1LfmyS++7NSr1j0t4WFgxKcdKXAXTXlSETDrfaxT+uzdCSX6hWp1+YFZ3
         VAl4zaxnAYubQe/svkOgqiUXIcADgAVsfjMQn2oHyc2LiVtZg7LykJvJ+Ywb3Z6F3jCH
         X43d1psugobWJa1qvr2kLLZDlMMndxJfZDc3TNJvQlDugs9HEZUH0O07WoXORsxOka07
         IK3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nFpdPCQaKLK0dq74m+bV6z4BoOvqlx1plnm6YIxgwkg=;
        b=mq+nmuWomtfvjBqTTNiMkNcz8slNccC046+3g1MQazhy8VQ7zrN+T+IIgzeJJcXE4Q
         5IWJ2wHQHBzW+8ezZN3gxbo077E4n2K64XdCuuy3T+UnwhQnhw+VtFNdR9oR7KS+hAx6
         dSFLzIGtYi3MlnJgfIFEf+8ADjTSj+FWH/07Wy9ZfFvS5R2nnprGnluiEsS+TtjR1rjy
         ++T6CdGSvc2DOXabLceo2t6jlHoQROAhXj9gMCTCFU6ls8Lkm5JGDvYMGWNIZkShW85j
         /sJCZsOS5qCZjCyDSzz26eXk9vt580NDTWlwjAFMi+Hm1pp+P2k9hd33BbzbJu+rzmiP
         R5hA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k30si1941854edb.244.2019.03.14.06.29.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 06:29:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 00EEDAFBB;
	Thu, 14 Mar 2019 13:29:34 +0000 (UTC)
Date: Thu, 14 Mar 2019 14:29:33 +0100
From: Michal Hocko <mhocko@suse.com>
To: Takashi Iwai <tiwai@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2] mm, page_alloc: disallow __GFP_COMP in
 alloc_pages_exact()
Message-ID: <20190314132933.GL7473@dhcp22.suse.cz>
References: <20190314093944.19406-1-vbabka@suse.cz>
 <20190314094249.19606-1-vbabka@suse.cz>
 <20190314101526.GH7473@dhcp22.suse.cz>
 <1dc997a3-7573-7bd5-9ce6-3bfbf77d1194@suse.cz>
 <20190314113626.GJ7473@dhcp22.suse.cz>
 <s5hd0mtsm84.wl-tiwai@suse.de>
 <20190314120939.GK7473@dhcp22.suse.cz>
 <s5ha7hxsikl.wl-tiwai@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <s5ha7hxsikl.wl-tiwai@suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 14-03-19 14:15:38, Takashi Iwai wrote:
> On Thu, 14 Mar 2019 13:09:39 +0100,
> Michal Hocko wrote:
> > 
> > On Thu 14-03-19 12:56:43, Takashi Iwai wrote:
> > > On Thu, 14 Mar 2019 12:36:26 +0100,
> > > Michal Hocko wrote:
> > > > 
> > > > On Thu 14-03-19 11:30:03, Vlastimil Babka wrote:
[...]
> > > > > I initially went with 2 as well, as you can see from v1 :) but then I looked at
> > > > > the commit [2] mentioned in [1] and I think ALSA legitimaly uses __GFP_COMP so
> > > > > that the pages are then mapped to userspace. Breaking that didn't seem good.
> > > > 
> > > > It used the flag legitimately before because they were allocating
> > > > compound pages but now they don't so this is just a conversion bug.
> > > 
> > > We still use __GFP_COMP for allocation of the sound buffers that are
> > > also mmapped to user-space.  The mentioned commit above [2] was
> > > reverted later.
> > 
> > Yes, I understand that part. __GFP_COMP makes sense on a comound page.
> > But if you are using alloc_pages_exact then the flag doesn't make sense
> > because split out should already do what you want. Unless I am missing
> > something.
> 
> The __GFP_COMP was taken as a sort of workaround for the problem wrt
> mmap I already forgot.  If it can be eliminated, it's all good.

Without __GFP_COMP you would get tail pages which are not setup properly
AFAIU. With alloc_pages_exact you should get an "array" of head pages
which are properly reference counted. But I might misunderstood the
original problem which __GFP_COMP tried to solve.

-- 
Michal Hocko
SUSE Labs

