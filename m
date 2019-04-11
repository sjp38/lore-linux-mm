Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B36BC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 13:39:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5042F217F4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 13:39:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5042F217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E38B36B0008; Thu, 11 Apr 2019 09:39:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE7E26B000C; Thu, 11 Apr 2019 09:39:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFDD46B000D; Thu, 11 Apr 2019 09:39:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 830796B0008
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 09:39:58 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z29so245857edb.4
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 06:39:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Xsut/nkXa5uMJ0dzfXSgZJrHB7zNL3vkS73rFy9THI0=;
        b=No97P5Y4iZqMAnGOm7oGpxR12Iv26pl9KAB18aj7WaxS/FhQzZkXtF5ASRwoK8sWEd
         O+5yO4WkHAodWjeu4GDi0DLg9A82ANh2dlfXkd26LMzBz57eLx/d5HtD/bR9Gk0Wf0Dp
         zyn4LS/OARb5WxN6JY5R5yxSZ5BV47D0XXZ2ts4Md07qjyNZ9k4d6txuIYbeZLI9BHmu
         azhA3J9VJp7okW7FjpBIp+riZQF+zK20Rtk1AeH2R9tnqsBa0zH2TiaBtU4KPdoqseJQ
         ajaiHQDmHTVOoDni/NfiMI5JaEw9drhyp/IQnWaMS1r1FfQf4/Vn+mG2EESJMWNn7s/4
         DDEQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVJImjgd3neZByNsAHGPX7jUOpcZRb8xQpGqP/VCX4kfAhldtij
	DDaliknDqMoQGMoXXKNLqyh4xLDgYEUpf6kAUCUVUZok5p0GzDaQAE1SAQ3ensapZvHWRRQ24Tb
	/Yo8GVyfNN5AXFkSaEfSLoawQWhbPF/eKL++26AW5G7OkMkSSHQTyjxC9bt97AW8=
X-Received: by 2002:a50:90e4:: with SMTP id d33mr31950688eda.265.1554989998090;
        Thu, 11 Apr 2019 06:39:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynpD8e+o4P7gFzfU9XK4t90NNX921xaE1EGlx9WfVujpcqBxBJ1hd1YF8SvyDugTrME/Ao
X-Received: by 2002:a50:90e4:: with SMTP id d33mr31950616eda.265.1554989996930;
        Thu, 11 Apr 2019 06:39:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554989996; cv=none;
        d=google.com; s=arc-20160816;
        b=hVZDF5wT08xzL7/S1qtjPcz9cr8Q1QFhkBxFM0wUoE+GtnTeyybJcFfP3LS9Gvra5z
         M9wXyVo1pA0wQk6U3TUnHZ6mGBJXXLx9xFxsfK88gGY7p7WMDYEV9vYGxSmrlpdl4MgJ
         CniB9LbPBSLSGyaVI0+Nc/2lyWPd8rcKK7vOprObhbGHBijt86wQmnvFEJ5DVZUIKms0
         NcDu3vLXpmCOUwLNmhDb9RDvdhUkxAq312yt0K324OVCKUxXyaupq4gXJS/vCceg0znU
         xo6dfAej+mTrNwOwP5eMA1U2i4Vk0DUfkqtPHGh2HVgCpsmaMbUWpDOCzhVJTnVwvUmA
         KGJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Xsut/nkXa5uMJ0dzfXSgZJrHB7zNL3vkS73rFy9THI0=;
        b=Dl0sj+YZ+5wk5ucpDEsBGlGcfwrMMdcf+j+cS70VeLmtyfYRNkEF7vy7/WhL9sTytO
         DvftfW4mu+2VB3aMHgmhzya4clxuW4hjpKBJV/j04UNbjz0tUYeZ8dfyju1hzTvkNFLv
         cslSHuTDQlRzucpWTac5KNGMBwpVZ59ZrTE0p/bIjGhLf14x+IfQeKciXg+q5KlGI/Bx
         4n+fOs8Xh5F0+3HOp4pnMk/HAdto0liWs8Sdri+87yw1Xn78esazg+IL1xAc+X2Bq/gT
         EhmMzUFQQsleBda2zhljIdwgsithQFzsZh5mCTcQ7K7we19xzkEy3kxtayHT7E0s/Jh1
         mg4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p32si4328428edd.373.2019.04.11.06.39.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 06:39:56 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 69BBDAD38;
	Thu, 11 Apr 2019 13:39:56 +0000 (UTC)
Date: Thu, 11 Apr 2019 15:39:55 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	shaoyafang@didiglobal.com
Subject: Re: [PATCH] mm/memcg: add allocstall to memory.stat
Message-ID: <20190411133300.GX10383@dhcp22.suse.cz>
References: <1554983991-16769-1-git-send-email-laoar.shao@gmail.com>
 <20190411122659.GW10383@dhcp22.suse.cz>
 <CALOAHbD7PwABb+OX=2JHzcTTLhv_-o8Wxk7hX-0+M5ZNUtokhA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbD7PwABb+OX=2JHzcTTLhv_-o8Wxk7hX-0+M5ZNUtokhA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-04-19 20:41:32, Yafang Shao wrote:
> On Thu, Apr 11, 2019 at 8:27 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Thu 11-04-19 19:59:51, Yafang Shao wrote:
> > > The current item 'pgscan' is for pages in the memcg,
> > > which indicates how many pages owned by this memcg are scanned.
> > > While these pages may not scanned by the taskes in this memcg, even for
> > > PGSCAN_DIRECT.
> > >
> > > Sometimes we need an item to indicate whehter the tasks in this memcg
> > > under memory pressure or not.
> > > So this new item allocstall is added into memory.stat.
> >
> > We do have memcg events for that purpose and those can even tell whether
> > the pressure is a result of high or hard limit. Why is this not
> > sufficient?
> >
> 
> The MEMCG_HIGH and MEMCG_LOW may not be tiggered by the tasks in this
> memcg neither.
> They all reflect the memory status of a memcg, rather than tasks
> activity in this memcg.

I do not follow. Can you give me an example when does this matter? I
thought it is more important to see that there is a reclaim activity
for a specific memcg as you account for that memcg.
If you want to see/measure a reclaim imposed latency on a task then
the counter doesn't make so much sense as you have no way to match that
to a task. We have tracepoints for that purpose.
-- 
Michal Hocko
SUSE Labs

