Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A414FC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 08:45:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66F2C20880
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 08:45:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66F2C20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9E188E0063; Thu, 21 Feb 2019 03:45:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4D548E0002; Thu, 21 Feb 2019 03:45:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3C398E0063; Thu, 21 Feb 2019 03:45:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7CBC18E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:45:28 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id a21so10024447eda.3
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 00:45:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YP5Jxr9TuNyxzhFCOOU+GwYUse1p0y0TNHGENlqYo3E=;
        b=Bgn/jFpIZRJKKuwzNiiGt2SpcBLuQPu9H55xKItMR2hDD3HbRDYliQOrqX1x6b/+pf
         6/Nrnr9WKMP+ICB2iwxsoxZpZR2BydMElq95ulZ8VlMWRm2N9mr6ysn8HiETHW9ezAvC
         Dun7ri7wzetZwRUsClmtFtOfcFneSgnMV4rYv2XLuXYfOF6YaXm9zbNziHKDyWGcAY2j
         C/2uBH6BgM50txovxD5bIadrV8U8P0MVamX+0OCi8mbEvxmN4DPxfKtXEWdEuuM5gwyJ
         XSLVYt+uLc9Dcy3367dPUiTchdBRUnaDQumXuP/vSA5IUVgqNzjLsowt3WUGJaDjemNd
         57ag==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubrkud2Px/1w8/Oe1dyKty1R67qkkHVBY0AuZAGbKRMtYW2/7LY
	7GVlghTMoXGwQiil0PNo2nh+k3GaFD1uBtol1A3khCoWhocIMEz50rNrodxouPNOwTBQysUhZyf
	a0DUw/EumsPykUtsguTtoJ3mOOKi5tNPrhIntIjyfEzHx0vgKaYKHdnS0PE3xeZ4=
X-Received: by 2002:a50:ca41:: with SMTP id e1mr5888386edi.73.1550738728045;
        Thu, 21 Feb 2019 00:45:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbBtfO48iTF6qzVq1wiU/pc07ynPcrP7yMnEBa0Nxc3ud90NPSBZPvirZELmQeaTkC09L4/
X-Received: by 2002:a50:ca41:: with SMTP id e1mr5888342edi.73.1550738727218;
        Thu, 21 Feb 2019 00:45:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550738727; cv=none;
        d=google.com; s=arc-20160816;
        b=Cs1+0gC5ouiWR+7nj9cb1j6jyKDTFsifbVY7YXgAIvlISJpjW/2JGB5FAmTUTylojz
         jLy61ye6HmeMbGbFcaiti3rkYSGvosJ2iL8C9t7ax/35N4Ue5AAOir2aYEgiPEVkjixb
         uIO1R9gyiGLFDdFmAOBJXl8TSNmYB1MRLOTQ6hX6D7iA6aFAzArijSB3KJ77gt2r8+6X
         mY2kcVAOGyLZw51DZCP2HF5NXT93RLJLiVdTh521zPbpqkvhOIbyOyIlFmB05DFrAFws
         RuijgPVXUhJVTpWZ+KCUUx3gudh9lg5H5nLs+2axDWGv0DyTvo6Yewq2pboYECjhMsdd
         8swg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YP5Jxr9TuNyxzhFCOOU+GwYUse1p0y0TNHGENlqYo3E=;
        b=uiLPE097v0gk4ZAAhqqVfrvmdPsonTxpvhnDth0ZGII2FZQPUaHLV4pnb+JBHss3SA
         eNqzI7kY5BXic9pXuWqr2Q+ApzHv6Gu4XXfBnCrFUO0pgGCAILyNCScpgu07qEkwib2m
         crljxhAVux9nK6Zgyv8RiCH5VzkYsj+WFebgW6UxHGaALTSIvN9VJG8K1gvzHIhSOMyw
         +IFlqJ4RZotvtDvzTxY0p91l01aM6v6kemQVBFuqkZ6ZcBauftpJGCyz9habOlwkSjXM
         y+mTGbvqiOKXf1Jn1JxOLjgcqHmX09PGBxKiXdFhGE7dSYBx68Edt9MUzJVRe+H0r1EZ
         KG3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n5-v6si4014665ejc.52.2019.02.21.00.45.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 00:45:27 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 77B87AEE8;
	Thu, 21 Feb 2019 08:45:26 +0000 (UTC)
Date: Thu, 21 Feb 2019 09:45:25 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Yue Hu <zbestahu@gmail.com>, akpm@linux-foundation.org,
	rientjes@google.com, joe@perches.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, huyue2@yulong.com
Subject: Re: [PATCH] mm/cma_debug: Check for null tmp in cma_debugfs_add_one()
Message-ID: <20190221084525.GI4525@dhcp22.suse.cz>
References: <20190221040130.8940-1-zbestahu@gmail.com>
 <20190221040130.8940-2-zbestahu@gmail.com>
 <20190221082309.GG4525@dhcp22.suse.cz>
 <20190221083624.GD6397@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190221083624.GD6397@kroah.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 21-02-19 09:36:24, Greg KH wrote:
> On Thu, Feb 21, 2019 at 09:23:09AM +0100, Michal Hocko wrote:
> > On Thu 21-02-19 12:01:30, Yue Hu wrote:
> > > From: Yue Hu <huyue2@yulong.com>
> > > 
> > > If debugfs_create_dir() failed, the following debugfs_create_file()
> > > will be meanless since it depends on non-NULL tmp dentry and it will
> > > only waste CPU resource.
> > 
> > The file will be created in the debugfs root. But, more importantly.
> > Greg (CCed now) is working on removing the failure paths because he
> > believes they do not really matter for debugfs and they make code more
> > ugly. More importantly a check for NULL is not correct because you
> > get ERR_PTR after recent changes IIRC.
> > 
> > > 
> > > Signed-off-by: Yue Hu <huyue2@yulong.com>
> > > ---
> > >  mm/cma_debug.c | 2 ++
> > >  1 file changed, 2 insertions(+)
> > > 
> > > diff --git a/mm/cma_debug.c b/mm/cma_debug.c
> > > index 2c2c869..3e9d984 100644
> > > --- a/mm/cma_debug.c
> > > +++ b/mm/cma_debug.c
> > > @@ -169,6 +169,8 @@ static void cma_debugfs_add_one(struct cma *cma, struct dentry *root_dentry)
> > >  	scnprintf(name, sizeof(name), "cma-%s", cma->name);
> > >  
> > >  	tmp = debugfs_create_dir(name, root_dentry);
> > > +	if (!tmp)
> > > +		return;
> 
> Ick, yes, this patch isn't ok, I've been doing lots of work to rip these
> checks out :)

Btw. I believe that it would help to clarify this stance in the
kerneldoc otherwise these checks will be returning back because the
general kernel development attitude is to check for errors. As I've said
previously debugfs being different is ugly but decision is yours.

-- 
Michal Hocko
SUSE Labs

