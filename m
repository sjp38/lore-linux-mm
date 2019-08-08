Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5119C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:02:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89DB12186A
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:02:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89DB12186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15A4E6B0007; Thu,  8 Aug 2019 02:02:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10AFF6B0008; Thu,  8 Aug 2019 02:02:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 020D06B000A; Thu,  8 Aug 2019 02:02:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC3506B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 02:02:13 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b33so57517447edc.17
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 23:02:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mMMbJZ3j+NPo4KunwM+dB0OCXYM/A9TaVqSTcJGrnKI=;
        b=LX8VJ1vu27xhEFacJPB5CDGuNAZnNCiQuG2ojDA678bnV1Rc9Yz4zf+zrMAxqDWgm8
         Zdece9PbHCbWmbHelkRXT9lr7NEkiEcDVL7nSjKZsr32vsm0O7Ahaww4YHFxCIoWQJBt
         wY+jHKqupokEunPu2llgDNMvq6F/PKse0P6xj9qWCu6XX9sOQ5lJpy6j/xx2HMRp7M8T
         T7Mew7tReGYd4WxKdsgz8kDCKy9AIuPpIW28wxrjQOYooY8T7WKZ+edUjGdjsrGvs5M5
         WzUIwZNaN6c9zsUC3LML5+zDfYwL1QnUD2S9tPhn47kFjmfv8AQu/jJ+tpwNP/NNPt4R
         jmdw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW2iagYHAB+1+r1E9yqaNZrCOjEgID6hA/9fjIrqC3Qx0q0vQlP
	1jOSyftnsp0zMwtv0v908zc8ndsFVotO163ur3SD8UQ5GfAuNzR36zpHudo3gXRAoLq0g2g0Ljw
	fDSMFGS/cf7+bL1kECw/vlHBBunAx8ruvep6GJrzJ7pi3mtbAX4ImcB1gEwSJtFk=
X-Received: by 2002:a17:906:f211:: with SMTP id gt17mr11640124ejb.263.1565244133217;
        Wed, 07 Aug 2019 23:02:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkjoFy7dWdpyT1talHh/WPIHW/Wyjz3YyvpOVShmsoCzybwu+oiBlijRGmnqwOmiAMnXtq
X-Received: by 2002:a17:906:f211:: with SMTP id gt17mr11640057ejb.263.1565244132353;
        Wed, 07 Aug 2019 23:02:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565244132; cv=none;
        d=google.com; s=arc-20160816;
        b=SLzCiBlAwtjCwDyIwq5kRljjp+IS1XRlZSrm2T5GXT3n8xOhaxsEjAs6juyaomT+Uf
         QECAOCGkNxlLiDLjyi9fltEERs/Qas0HhVVQCegdqM8QSb3I1CDfsY0j6L4SvwHkj9Fc
         MSVC5ylo/0uNHylsKb0wZa0gL12lcxyAlWHhg6a9jKjia3BWV8x0NiRcdIeokslc9YaS
         lHKDhV3cJP2sK8sMcMYykKKId2td2EglnmOm+ae1ui4r45yMjqB0mUVNjyHNkfGt1HyS
         x18mjAYttHzV7nHSL4NOnlKj8M/uFzLFBoZI0yGqRRI8W4KeHQvlr8IKSA9fpxxc8G6s
         74oA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mMMbJZ3j+NPo4KunwM+dB0OCXYM/A9TaVqSTcJGrnKI=;
        b=q4b1snj9ZOJcfNlYl6xhNEDWVTPM8rTb5CPfgp8xJKq+rJeei4t33YJQWO7pMH6rhz
         PMCVVUvek7236kCqOaVLwB+J5fwI9HgbMf1Ld7UrmW8blyn8mOio3EAleDFplpXJ1G6w
         jOVRdjWZdS7HHWApDTA9nQIQHXhlsxF1Zs4+DCPyGjCTf2IZUskhKdvvm+NHcwZ+c3tf
         gZqCXxt6mtu1miRABXASuH3DqoFHE+y3eMIV+XOF8YIO9qsNspyJr1fONE1INCZrluS1
         AZwhbV/qh6/8zl6azkx02VV5tK2o672/BLioW9Y0DjFeI8WysK8FJa7d06I656FqaR2b
         0O1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z26si28392298ejf.145.2019.08.07.23.02.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 23:02:12 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B2659B68F;
	Thu,  8 Aug 2019 06:02:11 +0000 (UTC)
Date: Thu, 8 Aug 2019 08:02:10 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Wei Yang <richardw.yang@linux.intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org,
	kirill.shutemov@linux.intel.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/mmap.c: refine data locality of find_vma_prev
Message-ID: <20190808060210.GE11812@dhcp22.suse.cz>
References: <20190806081123.22334-1-richardw.yang@linux.intel.com>
 <3e57ba64-732b-d5be-1ad6-eecc731ef405@suse.cz>
 <20190807003109.GB24750@richard>
 <20190807075101.GN11812@dhcp22.suse.cz>
 <20190808032638.GA28138@richard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190808032638.GA28138@richard>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 08-08-19 11:26:38, Wei Yang wrote:
> On Wed, Aug 07, 2019 at 09:51:01AM +0200, Michal Hocko wrote:
> >On Wed 07-08-19 08:31:09, Wei Yang wrote:
> >> On Tue, Aug 06, 2019 at 11:29:52AM +0200, Vlastimil Babka wrote:
> >> >On 8/6/19 10:11 AM, Wei Yang wrote:
> >> >> When addr is out of the range of the whole rb_tree, pprev will points to
> >> >> the biggest node. find_vma_prev gets is by going through the right most
> >> >
> >> >s/biggest/last/ ? or right-most?
> >> >
> >> >> node of the tree.
> >> >> 
> >> >> Since only the last node is the one it is looking for, it is not
> >> >> necessary to assign pprev to those middle stage nodes. By assigning
> >> >> pprev to the last node directly, it tries to improve the function
> >> >> locality a little.
> >> >
> >> >In the end, it will always write to the cacheline of pprev. The caller has most
> >> >likely have it on stack, so it's already hot, and there's no other CPU stealing
> >> >it. So I don't understand where the improved locality comes from. The compiler
> >> >can also optimize the patched code so the assembly is identical to the previous
> >> >code, or vice versa. Did you check for differences?
> >> 
> >> Vlastimil
> >> 
> >> Thanks for your comment.
> >> 
> >> I believe you get a point. I may not use the word locality. This patch tries
> >> to reduce some unnecessary assignment of pprev.
> >> 
> >> Original code would assign the value on each node during iteration, this is
> >> what I want to reduce.
> >
> >Is there any measurable difference (on micro benchmarks or regular
> >workloads)?
> 
> I wrote a test case to compare these two methods, but not find visible
> difference in run time.

What is the point in changing this code if it doesn't lead to any
measurable improvement?
-- 
Michal Hocko
SUSE Labs

