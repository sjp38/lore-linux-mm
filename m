Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CC25C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:31:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58D502173C
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:31:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58D502173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2F8D6B0006; Wed, 17 Apr 2019 09:31:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F057B6B0007; Wed, 17 Apr 2019 09:31:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1A916B0008; Wed, 17 Apr 2019 09:31:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9592A6B0006
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 09:31:33 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id u16so2905707edq.18
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 06:31:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=H5U7r/BbJ+yPKkuAGNouWstB2Nsa5JBZOUxPtu7YJWY=;
        b=LxCkrtuxopGveEUsFphLAtxVeYMaL6jmlwiGXVHwr33Zxfpf45BaXCJOVbCeNY8JkQ
         5XPyWOSWftJPWYhSUAtKDMvcYZLhRiqfxJVBnd9o6o5vwfjMRuCXwyfjuKOT+aurgjO6
         i35HG5KcsxUdnvrtUfwd0WDIUpOnvJLaGkBW+2WqnwR0i6jl0C2jXGciwq32aiaFjkTF
         bbfG6YoDlJsBZu1xcPxUR+iGLY5pA/3s43HwmAfo2yeAka5Cxt4Hr182wdALH43ShBNI
         Jf5wb8/OmYeKHDMdaryZyje1xe1b72TiLiXi6P8EKX8BNFzovXgaVrZJ7vZu8VG+XXfV
         T3Ww==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV6IMyK5Csd2oxP4p68qZiPgxf2H6+T17sCm6TAYlWC8t4ve0wU
	94dtRTEyIEK3zjkiKmo/Vgx00tzjlknYRR0TLASsgbAiEQ76Zk7ry+uaMbmGNgcMTINXKooqELU
	8vwE/4ZONG/kf8ovz8wDH//SUFb0YW8wc3bIUqVmnAn4gP6LCFx5ghj58y6LzrMY=
X-Received: by 2002:a17:906:3e48:: with SMTP id t8mr43261869eji.145.1555507893140;
        Wed, 17 Apr 2019 06:31:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZh1J1Nl4TDNWaTvl5bk1EwaEPgWog0HvBTsCnB1edtwQw1QeLzxhQQErZTB92Paujnk+s
X-Received: by 2002:a17:906:3e48:: with SMTP id t8mr43261830eji.145.1555507892339;
        Wed, 17 Apr 2019 06:31:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555507892; cv=none;
        d=google.com; s=arc-20160816;
        b=XMK9K2hxWA0fPvzs5ZbXiwPZaiWFFVzKQYnWzwsmxwJbfVX6l4sVaT+xPbcii2M7xi
         ACf+x/4YNi3PnvheJICTRbvYWD6dUNfS7VTCYtQp8xXHKFNiVCU266PgqBMyked1c9Dg
         pBSG4UjZXzhBdEc95cDO9HPa+n/L5GyBxcJFM4H8h5mDVqoz/ETbN592mbm+ujAqOHcw
         aVGDv59WZrygSBL73Hva3tleF/vPzQ0PVfpiIJLqAOo5aRXAeQeIzxFqq8RNXvoAs128
         qzRhMWYwpGEY/WXdNW+9G6EB/uqV1Mr1BTHUcqBQi5pByPbjPV7VMmKH7Jg2tNes9asv
         M/mQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=H5U7r/BbJ+yPKkuAGNouWstB2Nsa5JBZOUxPtu7YJWY=;
        b=IgP9qI+P8jWO/lLzmUTC/J3LCoWJ3yIlfzjuu30Fgv2MlS0Dd6nZFxwYyuAnM0q48O
         WiwShg6HTV5atgHjDLJRMEcwO0CukQeh8wf1V85Oc4RVvFXbMIHE8m/0Mwr9XKB+IjQC
         BiV+GLYolurlVbeh7UtNGg49Zsj5kyFG3qsa9prA31gN+awNUMtE18gKRrKcqrqot4aU
         30WN2ZS88SYuAMgKyifQ0LQEgRU1q0CqYKSdGsrlt1JFze9RuNmec1askJ4GVlXxtVuX
         hj5TPVReRlGWl55vAAZsnl5c11y66jgc4UBVZ7fggNxRrlqHnfdn91lr6HaxV1kQe4H2
         9G3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j19si3237538ejn.199.2019.04.17.06.31.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 06:31:32 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E052EB136;
	Wed, 17 Apr 2019 13:31:31 +0000 (UTC)
Date: Wed, 17 Apr 2019 15:31:31 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: Re: [PATCH v1 1/4] mm/memory_hotplug: Release memory resource after
 arch_remove_memory()
Message-ID: <20190417133131.GK5878@dhcp22.suse.cz>
References: <20190409100148.24703-1-david@redhat.com>
 <20190409100148.24703-2-david@redhat.com>
 <20190417131258.GI5878@dhcp22.suse.cz>
 <ae4cc790-8d9b-39ad-d29c-d8bd290da165@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ae4cc790-8d9b-39ad-d29c-d8bd290da165@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 17-04-19 15:24:47, David Hildenbrand wrote:
> On 17.04.19 15:12, Michal Hocko wrote:
> > On Tue 09-04-19 12:01:45, David Hildenbrand wrote:
> >> __add_pages() doesn't add the memory resource, so __remove_pages()
> >> shouldn't remove it. Let's factor it out. Especially as it is a special
> >> case for memory used as system memory, added via add_memory() and
> >> friends.
> >>
> >> We now remove the resource after removing the sections instead of doing
> >> it the other way around. I don't think this change is problematic.
> >>
> >> add_memory()
> >> 	register memory resource
> >> 	arch_add_memory()
> >>
> >> remove_memory
> >> 	arch_remove_memory()
> >> 	release memory resource
> >>
> >> While at it, explain why we ignore errors and that it only happeny if
> >> we remove memory in a different granularity as we added it.
> > 
> > OK, I agree that the symmetry is good in general and it certainly makes
> > sense here as well. But does it make sense to pick up this particular
> > part without larger considerations of add vs. remove apis? I have a
> > strong feeling this wouldn't be the only thing to care about. In other
> > words does this help future changes or it is more likely to cause more
> > code conflicts with other features being developed right now?
> 
> I am planning to
> 
> 1. factor out memory block device handling, so features like sub-section
> add/remove are easier to add internally. Move it to the user that wants
> it. Clean up all the mess we have right now due to supporting memory
> block devices that span several sections.
> 
> 2. Make sure that any arch_add_pages() and friends clean up properly if
> they fail instead of indicating failure but leaving some partially added
> memory lying around.
> 
> 3. Clean up node handling regarding to memory hotplug/unplug. Especially
> don't allow to offline/remove memory spanning several nodes etc.

Yes, this all sounds sane to me.

> IOW, in order to properly clean up memory block device handling and
> prepare for more changes people are interested in (e.g. sub-section add
> of device memory), this is the right thing to do. The other parts are
> bigger changes.

This would be really valuable to have in the cover. Beause there is so
much to clean up in this mess but making random small cleanups without a
larger plan tends to step on others toes more than being useful.
-- 
Michal Hocko
SUSE Labs

