Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B7DDC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 08:36:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94341214AF
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 08:36:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="rEpnOzvY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94341214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 136C38E0061; Thu, 21 Feb 2019 03:36:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E7298E0002; Thu, 21 Feb 2019 03:36:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F17778E0061; Thu, 21 Feb 2019 03:36:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id AFA1B8E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:36:29 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id z1so2971430pfz.8
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 00:36:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=OENLB5A16nbt6Kbu7tqpTEQFaWtUeWTrR4fTVLxFwHU=;
        b=YpCoCltAF99riXA2eLQraPCk5s8LERxS6+RSVRTUZb0u3UkiyFo9QKL8O79POaS0AM
         zHNHLr1BmiSG5qiLjGKqpV+ffUIayc7PPd8SBHHtrh4fLXWzmxPj9jJ7qi/GUDyRz5sE
         OiZ/H3dQYmARH4SH6bjA1uOmy+m81dMXCjX/o7uPyCC3sZqtJmh1QrmSg6hRN6X8sC7R
         FEfbPQ9wQAiGVstMxhFKO6cIHAZkXbh/VNZ3hnYuWE50+3qHs3QZ3/Gs+stOFZFAzBkd
         haBJjXqpMh+D1ZwyASgclDrQFV/hMPl1rEfe3reNIv6zKqcvGeGcVd4ez0FQrvrC01gp
         TzJQ==
X-Gm-Message-State: AHQUAuYh7jshJgZ615Y/DzkWg0FS2UkajBhRvJ8j+ipKXQSkj9SvQVgm
	8ju2LUOjuNLRukT+ycTIK+cNfziOeMjxcwc4r4WjCr5LRxHDsbHBfR64LpTWV0lUuW48cGQfaEC
	GHlU8IN52VabrMs5u15hTaBKLke+KkeV9Q0ilhqshfnBn1MjYL3kD2A5cmYC5LyQ=
X-Received: by 2002:a63:f141:: with SMTP id o1mr33986311pgk.134.1550738189282;
        Thu, 21 Feb 2019 00:36:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZxDFY9gwRNykL1ONFyErjh7dgNwnPldmZ6+SJpUoPQbwYuCqaBcPuGtAexCaVV/4gvetJv
X-Received: by 2002:a63:f141:: with SMTP id o1mr33986262pgk.134.1550738188524;
        Thu, 21 Feb 2019 00:36:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550738188; cv=none;
        d=google.com; s=arc-20160816;
        b=klKuDzh1c7rDXYBJ+TnpwZU6tckpSjbudJRa7PQR6tKyNUC5EpYamTh+wC4dUAg3ra
         iJ82KThdy8qdUqoaAKlcQ1l6qfwfZI+mU+FXHFH9MKzZR57uAmsuMT5zgcknD1HmIj2V
         N+1RSjBKP2HITJDsYo7+q6lRHaK1ZCThgTFtUwxwyM35COL975Qzj5N/IPW/YJLO1fzo
         jzoODthPt5/Z9oIqUWWfod1nBRY54iweNpXnFd6sMNRtFkpqZzgt0N4h4Uq7heOdjNav
         JtGp95TPjvU0tpQX84J0k3rw1Tqi3uUVhJ0ZYuaReQbjo6UCYVu4BEwTgc12oqsBJCe1
         FeRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=OENLB5A16nbt6Kbu7tqpTEQFaWtUeWTrR4fTVLxFwHU=;
        b=XV841XhBLNBGe+fQ76xGxsB6GjcK5ib6sdeanxjxE8Iey4rqpt3v/IN/oOomf4+fGB
         ksQ9sXg5RFzn7Suf01+L5o6agAq2AuGmdVExWGtMlu06ZPvM/CSFDGdmWoUKZcgj6xHy
         7W8mxB+vAqwv6BPPX+tUJzyIZdBUfAC9o/15vFV8Yaxt85PArkp5RnAwyPMESM7YiI6B
         boc1w3XpXriysEitP1hSc7sYJsiRpGUmmAduD+ehUO+j3cZ40X1AcPKhWAd/My6XBpWP
         dCahUdmMYmViNF1Mn/eBC7+935UGXxBhcFzV0F1HFE/GadECyZMueyE79rhn5a1qeyle
         N7HA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=rEpnOzvY;
       spf=pass (google.com: domain of srs0=u/6v=q4=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=u/6V=Q4=linuxfoundation.org=gregkh@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id az2si9098730plb.252.2019.02.21.00.36.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 00:36:28 -0800 (PST)
Received-SPF: pass (google.com: domain of srs0=u/6v=q4=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=rEpnOzvY;
       spf=pass (google.com: domain of srs0=u/6v=q4=linuxfoundation.org=gregkh@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=u/6V=Q4=linuxfoundation.org=gregkh@kernel.org"
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A0D6B20842;
	Thu, 21 Feb 2019 08:36:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550738188;
	bh=BLC5WO9lZNuzlf6omeBaA0Qh70h77drVc5zvXoTJsuw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=rEpnOzvYpgGQJzbfFxZIVbAc35BxXy/fA9cad4UXCo7lPMCUjuBdsNuUH7GsS+5aZ
	 Me/ansqbIulB2fjysvYXwgnS1KdeohgMUdzQmmvg/Pf6mC7fzlUAHWMQDRKw9BKgje
	 UkP9kfVNTcX1LqDvgqcu4qfLilepE5b8fwg07yRQ=
Date: Thu, 21 Feb 2019 09:36:24 +0100
From: Greg KH <gregkh@linuxfoundation.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yue Hu <zbestahu@gmail.com>, akpm@linux-foundation.org,
	rientjes@google.com, joe@perches.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, huyue2@yulong.com
Subject: Re: [PATCH] mm/cma_debug: Check for null tmp in cma_debugfs_add_one()
Message-ID: <20190221083624.GD6397@kroah.com>
References: <20190221040130.8940-1-zbestahu@gmail.com>
 <20190221040130.8940-2-zbestahu@gmail.com>
 <20190221082309.GG4525@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190221082309.GG4525@dhcp22.suse.cz>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 09:23:09AM +0100, Michal Hocko wrote:
> On Thu 21-02-19 12:01:30, Yue Hu wrote:
> > From: Yue Hu <huyue2@yulong.com>
> > 
> > If debugfs_create_dir() failed, the following debugfs_create_file()
> > will be meanless since it depends on non-NULL tmp dentry and it will
> > only waste CPU resource.
> 
> The file will be created in the debugfs root. But, more importantly.
> Greg (CCed now) is working on removing the failure paths because he
> believes they do not really matter for debugfs and they make code more
> ugly. More importantly a check for NULL is not correct because you
> get ERR_PTR after recent changes IIRC.
> 
> > 
> > Signed-off-by: Yue Hu <huyue2@yulong.com>
> > ---
> >  mm/cma_debug.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/mm/cma_debug.c b/mm/cma_debug.c
> > index 2c2c869..3e9d984 100644
> > --- a/mm/cma_debug.c
> > +++ b/mm/cma_debug.c
> > @@ -169,6 +169,8 @@ static void cma_debugfs_add_one(struct cma *cma, struct dentry *root_dentry)
> >  	scnprintf(name, sizeof(name), "cma-%s", cma->name);
> >  
> >  	tmp = debugfs_create_dir(name, root_dentry);
> > +	if (!tmp)
> > +		return;

Ick, yes, this patch isn't ok, I've been doing lots of work to rip these
checks out :)

Thanks for catching this Michal.

greg k-h

