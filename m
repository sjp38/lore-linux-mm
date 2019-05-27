Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47464C07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 14:39:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19D202183F
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 14:39:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19D202183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A92766B0280; Mon, 27 May 2019 10:39:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A425A6B0281; Mon, 27 May 2019 10:39:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90B4B6B0282; Mon, 27 May 2019 10:39:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 43B6B6B0280
	for <linux-mm@kvack.org>; Mon, 27 May 2019 10:39:29 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id 18so28344494eds.5
        for <linux-mm@kvack.org>; Mon, 27 May 2019 07:39:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=v9Y90W/G7cOzY2VIpO19XWAD15TolJ0caIspsxJpIHo=;
        b=d1RZy306UsxtNPiT+Tce4loP7NGw+WUxN0gWCqIR2CUbVrkTIzMIQd0pZQLdFA8WRX
         1oDpSfqe0gGN0bJOCV84yjrgQpOjSiOFQuUhwv9Imi29hIsI36iPV6OFz7insGHf3fcU
         5YhTGRDOanTEkhFplBEzAa5uw4T6dfOCiHBv59XT5l4EfDcqauybgSuNhU4gTo5qznXM
         v2jlH/S+Pj7FBFjAzmcrQ0/kGJZ+kbQxFqXfF71QA/VGaeyHJEb7/JIsMOzhC8WMoQkd
         xSFGHN/JcsbAMyzFx+FYaZabifAfhw1HB1UPan4K3p/eupUJPfCWXCN5aWhZZxzIAVas
         Q0bQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXPBoL08x1W1BH5U/lCcZ/Ui04dUAH/J6GK3tQ9f+ZFd+Yk4G74
	pEUFQtpoRJNPfMWhWTtQXxVWzLxmvinEF356ywZORj+XuswXgPidv35a1FddkOGZmFO/9rf0Yia
	QEvogKOdPc3NeIONBXhtCP+54OUyZLkf3CRUiAFTSY4QRnSC+Windk7NXzrUGUgA=
X-Received: by 2002:a17:906:4d57:: with SMTP id b23mr96906306ejv.254.1558967968853;
        Mon, 27 May 2019 07:39:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+XX3WW16srcwzVX4+Dm/PUhhiM0XDfRwYQ0ef4ou8rDIIO+SZVaAyUJgor3Kh6lN1bemj
X-Received: by 2002:a17:906:4d57:: with SMTP id b23mr96906228ejv.254.1558967967912;
        Mon, 27 May 2019 07:39:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558967967; cv=none;
        d=google.com; s=arc-20160816;
        b=gVixBZl7MqEbSn8shG2Hp/EMlKnVrXSZxPAS6WS3AOjaVzPLGqojenDOdGa+E/HX11
         a5CqjN16K4PDbzxMNXxGx6M294rd9jSUtApOJHcMaTE2qfcDfv0DSs3YoNfeOSydIdWs
         2/s06SKOvcshC2z5wI/5umK07bhgs9uv3Kez4p85XxzBpMuhlyAhFwCtq/3X/lNmb97J
         lC3MetYMWv41lFPt7cWDhl3xF72q5nBS1kg0cWd4VVqnhhT2BvcqT8B5w3YrHFUD+Mh1
         UydClNb7QhZo7Z4dEEn5ma7WHDlKqlRyVFWmA+iEnJ5gJ3I24voN9uS9RRIn5Pts0jct
         Hznw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=v9Y90W/G7cOzY2VIpO19XWAD15TolJ0caIspsxJpIHo=;
        b=U87Tj33n+bu7aKaCHcl1u7qQJRMxSmLaPJtqpgHS3ha+InvDZhIy82R3IjGRKfIiRS
         yx2jC7x0C5FzQFkvkh86CibWim3HplxZdkNrL21PkKVHX/2Uy2bPpvgEOJ4ku549Y/0N
         7dbsoHm8I2qZWSuNXgseUN5fn76NJKpgPwdpUoPa0dG1XnCuqhHuzcelIEJp5khUjV39
         QZPyV5TSGLA4YSToey3KFlXnRlwp9x5Ytzk1DxhvaXkx6JM7AYuLH/tI1xSK8tSdWtjF
         Ave/4uWIfjVV+Ia+weqfXfLdyiwSnqVwYCNfKSbCZGrXv2OKQvcuaIM93cBxnXczKhUk
         6DHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w26si903221edw.193.2019.05.27.07.39.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 07:39:27 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 68FD0AEFD;
	Mon, 27 May 2019 14:39:27 +0000 (UTC)
Date: Mon, 27 May 2019 16:39:26 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Roman Gushchin <guro@fb.com>, linux-api@vger.kernel.org
Subject: Re: [PATCH RFC] mm/madvise: implement MADV_STOCKPILE (kswapd from
 user space)
Message-ID: <20190527143926.GF1658@dhcp22.suse.cz>
References: <155895155861.2824.318013775811596173.stgit@buzz>
 <20190527141223.GD1658@dhcp22.suse.cz>
 <20190527142156.GE1658@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527142156.GE1658@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 27-05-19 16:21:56, Michal Hocko wrote:
> On Mon 27-05-19 16:12:23, Michal Hocko wrote:
> > [Cc linux-api. Please always cc this list when proposing a new user
> >  visible api. Keeping the rest of the email intact for reference]
> > 
> > On Mon 27-05-19 13:05:58, Konstantin Khlebnikov wrote:
> [...]
> > > This implements manual kswapd-style memory reclaim initiated by userspace.
> > > It reclaims both physical memory and cgroup pages. It works in context of
> > > task who calls syscall madvise thus cpu time is accounted correctly.
> 
> I do not follow. Does this mean that the madvise always reclaims from
> the memcg the process is member of?

OK, I've had a quick look at the implementation (the semantic should be
clear from the patch descrition btw.) and it goes all the way up the
hierarchy and finally try to impose the same limit to the global state.
This doesn't really make much sense to me. For few reasons.

First of all it breaks isolation where one subgroup can influence a
different hierarchy via parent reclaim.

I also have a problem with conflating the global and memcg states. Does
it really make any sense to have the same target to the global state
as per-memcg? How are you supposed to use this interface to shrink a
particular memcg or for the global situation with a proportional
distribution to all memcgs?

There also doens't seem to be anything about security model for this
operation. There is no capability check from a quick look. Is it really
safe to expose such a functionality for a common user?

Last but not least, I am not really convinced that madvise is a proper
interface. It stretches the API which is address range based and it has
per-process implications.
-- 
Michal Hocko
SUSE Labs

