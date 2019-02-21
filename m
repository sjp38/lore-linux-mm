Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEA07C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 09:10:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 896CE214AF
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 09:10:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="gUtZMWHC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 896CE214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 367268E0069; Thu, 21 Feb 2019 04:10:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 317EC8E0002; Thu, 21 Feb 2019 04:10:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22D878E0069; Thu, 21 Feb 2019 04:10:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA7578E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 04:10:26 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id x134so21074703pfd.18
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 01:10:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=T4ik6TZRNsyCXHsZQgpTRzJxBcJq5yRLCutFe8tkRyI=;
        b=bBouP3qwPx/+o6PDnSFeozRlqTeRl9tMNexrBGIioxeTS8rX7roVikTVVIya7txeuO
         cJ93tTKQuV/FDTdPeEigdeTqM3JqjtDY5SeIRo6zACcFG3wo/0rAtFcnSu0MfEHgRncA
         4xBcD/ydeZxGyNxXDl/qnOzztHyNr+84Lh0FiDsNVkKhGr72ELlZmHOlyPYVrXkz7hoI
         YVJkgmRRJf+lWwzt7wSA48T3W9W7w3Qp+Vw9ZTg7RbnmVxX9VFnOsuGvV/FieDV85tvi
         sY+cJZPBH6043wmR42/OrfklrsbsM03CTP5pFc7aLosP3edEHyCqiTWyzkAwiISw5pPJ
         Y9xw==
X-Gm-Message-State: AHQUAuY4J4M1HLHtW6dXeioT67FZeqwYO3ha5f5xLBPGy4wO1PINsf05
	udi8+6p90l3U9iZxHyA+aLbEWLxOfA2gf1ytYHH5YWuT7nIZfbqYqFC1RTFU+z2TSiyZzDtbsXN
	Tc2LEY75LCOl/q8nHfExJhmewPApGlPxJykOB2aWJrythPwMhepmvw1SDd8GnyCc=
X-Received: by 2002:a17:902:ba84:: with SMTP id k4mr29350470pls.103.1550740226571;
        Thu, 21 Feb 2019 01:10:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibmufluj+c65l8kgjhcWspOzQrrh+zKp/tr4r/3avkkLwJ4B7oOzaDA+c21wwfXlkO/YLtL
X-Received: by 2002:a17:902:ba84:: with SMTP id k4mr29350425pls.103.1550740225987;
        Thu, 21 Feb 2019 01:10:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550740225; cv=none;
        d=google.com; s=arc-20160816;
        b=KzDXlB9WWXAeGSNcUMpNYRDjhDOo3tQsLQZ8uOJfnFZR/vuQA2SyYA61l0oCyUWAbc
         JrSwhEGmtUaMTQycLefGosKACn6Y8Fb/JE2gV1GQIXn8pI5K//sHgUTFGuiGa6lCDHt1
         DRUc5ewm1jwcSTRU1/JBnTziXhhTVqiVMYwldQzZcNtY3dcUeDSUt88EGJTkUzKWeryB
         Hk4H8sn+s2e6TndbrWgP3WsGJKwYK2bRDxtJsv4vbrN91FEXzh76ea/Smwnnt73qYEy3
         vptwHRIhxmBhUxUDQq4yD6686+GgEhR1Nywtmg/ZhJMmIDrwP7mRoXVeEIRo4QQ1cN7R
         MjEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=T4ik6TZRNsyCXHsZQgpTRzJxBcJq5yRLCutFe8tkRyI=;
        b=HoGki8TQrSE+G6Al0TaJHPJeY6xk7pCmmALV1P7FujT0AmjPI0c3cO768jplTPa2j5
         CpV0LeTggZdnY2l+byUxU1QDW0K5BMwC8wb8Xtsm8ina5/xdQ4g8+gr9995+ULNVwEMi
         liKJfzMxZPz80nuyildo5cE+7SerPLgcECGM14wFWPfvar91yPNCyNohhbP1Bv6yC1Cr
         69g6doNQNqj0YsQD1owIOgITGXJ24V76RUAmwWvWr6QBiNxJRuAOCTSrFtU+b26Lgl7v
         HcY1hJT+z94fIHN0u32M5tVZVtk0v7bxoCg6i58R5eZ2WtgZ6IbeGYIvRFnjoe0t3tFj
         grEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=gUtZMWHC;
       spf=pass (google.com: domain of srs0=u/6v=q4=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=u/6V=Q4=linuxfoundation.org=gregkh@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p5si20527250pgl.180.2019.02.21.01.10.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 01:10:25 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=u/6v=q4=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=gUtZMWHC;
       spf=pass (google.com: domain of srs0=u/6v=q4=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=u/6V=Q4=linuxfoundation.org=gregkh@kernel.org"
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 34CC32086C;
	Thu, 21 Feb 2019 09:10:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550740225;
	bh=Zc/gh5XVtsFlrscEHZAid4fIIgkXtpwjwzxteWVCRis=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=gUtZMWHCxaCg01+EOD2xmRqaLCjOXO6snMc1iP5S/6gwLH8mvp5SlZ3ToAxgBtqU0
	 12ZALVGdjQTcTrZ9NrfVV1OrBK5gHbM7XE+37+0Ox/nL6Mq7jyNXwDthphL680FPWe
	 A+cAitJLZSZFNgXTiscikl6jCJLVsxMUhDWWnSh4=
Date: Thu, 21 Feb 2019 10:10:22 +0100
From: Greg KH <gregkh@linuxfoundation.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yue Hu <zbestahu@gmail.com>, akpm@linux-foundation.org,
	rientjes@google.com, joe@perches.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, huyue2@yulong.com
Subject: Re: [PATCH] mm/cma_debug: Check for null tmp in cma_debugfs_add_one()
Message-ID: <20190221091022.GB11118@kroah.com>
References: <20190221040130.8940-1-zbestahu@gmail.com>
 <20190221040130.8940-2-zbestahu@gmail.com>
 <20190221082309.GG4525@dhcp22.suse.cz>
 <20190221083624.GD6397@kroah.com>
 <20190221084525.GI4525@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190221084525.GI4525@dhcp22.suse.cz>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 09:45:25AM +0100, Michal Hocko wrote:
> On Thu 21-02-19 09:36:24, Greg KH wrote:
> > On Thu, Feb 21, 2019 at 09:23:09AM +0100, Michal Hocko wrote:
> > > On Thu 21-02-19 12:01:30, Yue Hu wrote:
> > > > From: Yue Hu <huyue2@yulong.com>
> > > > 
> > > > If debugfs_create_dir() failed, the following debugfs_create_file()
> > > > will be meanless since it depends on non-NULL tmp dentry and it will
> > > > only waste CPU resource.
> > > 
> > > The file will be created in the debugfs root. But, more importantly.
> > > Greg (CCed now) is working on removing the failure paths because he
> > > believes they do not really matter for debugfs and they make code more
> > > ugly. More importantly a check for NULL is not correct because you
> > > get ERR_PTR after recent changes IIRC.
> > > 
> > > > 
> > > > Signed-off-by: Yue Hu <huyue2@yulong.com>
> > > > ---
> > > >  mm/cma_debug.c | 2 ++
> > > >  1 file changed, 2 insertions(+)
> > > > 
> > > > diff --git a/mm/cma_debug.c b/mm/cma_debug.c
> > > > index 2c2c869..3e9d984 100644
> > > > --- a/mm/cma_debug.c
> > > > +++ b/mm/cma_debug.c
> > > > @@ -169,6 +169,8 @@ static void cma_debugfs_add_one(struct cma *cma, struct dentry *root_dentry)
> > > >  	scnprintf(name, sizeof(name), "cma-%s", cma->name);
> > > >  
> > > >  	tmp = debugfs_create_dir(name, root_dentry);
> > > > +	if (!tmp)
> > > > +		return;
> > 
> > Ick, yes, this patch isn't ok, I've been doing lots of work to rip these
> > checks out :)
> 
> Btw. I believe that it would help to clarify this stance in the
> kerneldoc otherwise these checks will be returning back because the
> general kernel development attitude is to check for errors. As I've said
> previously debugfs being different is ugly but decision is yours.

Yes, I'll be doing that, thanks for the reminder.

greg k-h

