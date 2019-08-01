Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA67EC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:54:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AEEE206B8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:54:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kam.mff.cuni.cz header.i=@kam.mff.cuni.cz header.b="l+MW6Rd3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AEEE206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kam.mff.cuni.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A135D8E002D; Thu,  1 Aug 2019 11:54:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C25C8E0001; Thu,  1 Aug 2019 11:54:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B1F08E002D; Thu,  1 Aug 2019 11:54:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 409198E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 11:54:37 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id s18so35676427wru.16
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 08:54:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=GU7+iDu/nK46PLF4K/D+X5Kf5BcQEh/YuFAbSeHeWNw=;
        b=Hoj+1CAZw/TSSPliZlPf6awQPYzdOAyc+oM+VEUf0wSrYT6E9FGatuFwqF4xTBArZt
         QHATJHxndytDLlFVh1SnSns3e9XRBr3k/PyvHcK4WDb1Et7H4ecczH2iauNpGpTqesWT
         BJbEfmaVe563Eu4AF+cWwSABnVE6+ukfZNglD+WZ2R8ncH4bRMBUYtsyMMA8Xlh0mGDF
         DcL9znoNp6ze07UkaTL3vbwWWeDx/7g6qrq4RlruSQOqvcNOEiG+gd/i+Vmfh23hQefH
         I7KHUV6cei8DY4tilHimuHvLGy3TTo6o7p+ZXBy1ok7h5/hXXovBf746TCh1kInvJhZy
         DVTQ==
X-Gm-Message-State: APjAAAUSjTYSdlB4Ltl/i0C/UV73Dy98NfUOViFJQfHklnWFPJsCdw9z
	ah1XNlhmnyWmuYXMfFOdiAqt4DDBM7Cgjm7ibh24jZV9wm3qK9pz3j9krqsgMjHT00QrHXht4hh
	OhZIzZBh3gRGOzg8fh7kooYeYxbTD7fpzjc61NjL+FoYrFj0tme/FZZqmegyKBwVO/w==
X-Received: by 2002:adf:e790:: with SMTP id n16mr123144592wrm.120.1564674876775;
        Thu, 01 Aug 2019 08:54:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZH7+L8XMCUSyRrvqBIrWLvsbUXrPlPe2hdZazJXbS7iPIo8r67/Ap3Fvez6rmg4Bnfi2A
X-Received: by 2002:adf:e790:: with SMTP id n16mr123144547wrm.120.1564674875985;
        Thu, 01 Aug 2019 08:54:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564674875; cv=none;
        d=google.com; s=arc-20160816;
        b=zFdyaejrtbWFJ0eR6Z8a0rfS9/z2nQHFG5ChV3ty5nJYmni1ZgAgQjSII6oOEXJUNw
         c+3iQwBIr/bPz/fRvk3oRZmHU+hIll9I7Ugy9Dwe1y/oMMZjUn9JMAmIhc4Gr7XfcUM7
         Bnt4WPzKINEMSlXtHHZihadR/76h+2ddRAkPhU/LZQdSNpHCjF1nxkb+OjAsqTNca3NE
         G5l0NTazg+NfgJBrHtyMC+P8iT6nnj8Ty/MQ792uH92O5DiH/tTauo0twV3wH2+7N8lC
         FhG8RkhDkRE6MVEDZr45GWgFY8uAuYMTkGs8SNRqyN9zWgN2/v9ifXigLSQqtHnV+7wL
         ivsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=GU7+iDu/nK46PLF4K/D+X5Kf5BcQEh/YuFAbSeHeWNw=;
        b=Z0ssTZ3su4dWtS/leQpQQJgXJGJfbWRxS1Vk85aQmW7JYHA4ZU1ipBnlmx0Zhnxmbg
         +Eug53DBSGB75oA95ma9P9StacRuOhDSaqYjNq6ZS6xgwhiXIgqkTFC2Sufk0fN5OtNh
         /kuMXbGwOs8rxsMNfXOF/SLTtVeP0cqkkQDVsT2ka+RtS1u8Yq0AuUMlqx4PSZymQiVC
         yRFbxEKO+DVr7axmuuuQ1Z7ZXne+QsnxQGvxxPIcSQhLW6Uisg8XxFiW1EzqcuOkBRaK
         IBfcvehtTeNRCqzZ+ErOitLS7IoFPFABHK36dfc6hsBd2/VOvMJSBLgbFbdFEnBlqBhl
         gnnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kam.mff.cuni.cz header.s=gen1 header.b=l+MW6Rd3;
       spf=pass (google.com: best guess record for domain of had@kam.mff.cuni.cz designates 195.113.20.16 as permitted sender) smtp.mailfrom=had@kam.mff.cuni.cz;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kam.mff.cuni.cz
Received: from nikam.ms.mff.cuni.cz (nikam.ms.mff.cuni.cz. [195.113.20.16])
        by mx.google.com with ESMTPS id t7si66298991wrr.322.2019.08.01.08.54.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 01 Aug 2019 08:54:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of had@kam.mff.cuni.cz designates 195.113.20.16 as permitted sender) client-ip=195.113.20.16;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kam.mff.cuni.cz header.s=gen1 header.b=l+MW6Rd3;
       spf=pass (google.com: best guess record for domain of had@kam.mff.cuni.cz designates 195.113.20.16 as permitted sender) smtp.mailfrom=had@kam.mff.cuni.cz;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kam.mff.cuni.cz
Received: from campbell.kam.mff.cuni.cz (campbell.kam.mff.cuni.cz [195.113.17.233])
	by nikam.ms.mff.cuni.cz (Postfix) with ESMTP id 7F190280D66;
	Thu,  1 Aug 2019 17:54:34 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kam.mff.cuni.cz;
	s=gen1; t=1564674874;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=GU7+iDu/nK46PLF4K/D+X5Kf5BcQEh/YuFAbSeHeWNw=;
	b=l+MW6Rd3/PIe6D8Dh8fADFE63RqDL5NyRHd8uO7bK3Pl7lI/KlwN0xNJlMjHU+LSN8pUfX
	fiSFMYVOWTCKnfDFHuPWb0nyafqzfIgqFVhFP34KxOAZBHX+spZ9Jlt+H9kL09wPfq9RsS
	gukaWQJk9x2D3J09ZQw5itO2nA9OH0E=
Received: by campbell.kam.mff.cuni.cz (Postfix, from userid 3081)
	id 75DD2940CF5; Thu,  1 Aug 2019 17:54:34 +0200 (CEST)
Date: Thu, 1 Aug 2019 17:54:34 +0200
From: Jan Hadrava <had@kam.mff.cuni.cz>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	wizards@kam.mff.cuni.cz, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Shakeel Butt <shakeelb@google.com>
Subject: Re: [BUG]: mm/vmscan.c: shrink_slab does not work correctly with
 memcg disabled via commandline
Message-ID: <20190801155434.2dftso2wuggfuv7a@kam.mff.cuni.cz>
References: <20190801134250.scbfnjewahbt5zui@kam.mff.cuni.cz>
 <20190801140610.GM11627@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190801140610.GM11627@dhcp22.suse.cz>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 04:06:10PM +0200, Michal Hocko wrote:
> On Thu 01-08-19 15:42:50, Jan Hadrava wrote:
> > There seems to be a bug in mm/vmscan.c shrink_slab function when kernel is
> > compilled with CONFIG_MEMCG=y and it is then disabled at boot with commandline
> > parameter cgroup_disable=memory. SLABs are then not getting shrinked if the
> > system memory is consumed by userspace.
> 
> This looks similar to http://lkml.kernel.org/r/1563385526-20805-1-git-send-email-yang.shi@linux.alibaba.com
> although the culprit commit has been identified to be different. Could
> you try it out please? Maybe we need more fixes.

Yes, it is same. So my report is duplicate and I'm just bad in searching the
archives, sorry.

Just to be sure, i run my tests and patch proposed in the original thread
solves my issue in all four affected stable releases:

> > This issue is present in linux-stable 4.19 and all newer lines.
> >     (tested on git tags v5.3-rc2 v5.2.5 v5.1.21 v4.19.63)

And culprit commit is in fact also the same: b0dedc49a2da introduces one issue
in one place and aeed1d325d42 (culprit according to original thread) moves it
few lines up:

> > Git bisect is pointing to commit:
> > 	b0dedc49a2daa0f44ddc51fbf686b2ef012fccbf
(...)
> > Following commit aeed1d325d429ac9699c4bf62d17156d60905519
> > deletes conditional continue (and so it fixes the problem). But it is creating
> > similar issue few lines earlier:

