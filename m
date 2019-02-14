Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FC83C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 08:33:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00D0E2229F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 08:33:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00D0E2229F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CE5E8E0003; Thu, 14 Feb 2019 03:33:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67CFA8E0001; Thu, 14 Feb 2019 03:33:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56E408E0003; Thu, 14 Feb 2019 03:33:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F274E8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 03:33:53 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id 39so2188596edq.13
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 00:33:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AmZ0SDSAcbZTq8rw8naCi8bajIWyxiwx9StC5GvhDJc=;
        b=Jg4+np0IhkO/5dRaKI1XAl79jGyfdfI9bJrP4yUB+1aLznD99iovJOkOQQl2hCZcmt
         xoqt+USftuRxlksb3iOxsMrzosv7qRicFTGBRMGB+I/MNP0fvRHBSvTeOdJxar1B9Fd2
         upnU07oGJBh/mfRrjoP0GCk2+UqXIZk6zlD4K5SvjwhM1M+hUZGj8LHXJhwYqrPOILVa
         WEFQMl4M2PuhUQqhIjUovHQcj/Ih/00fcgBLghT/1wAhY/sZ1CuOq4JvnihOz8N03hpQ
         rYYBppmQJq5MZzERh9B5aR6+a1NnGbWhnA7A9frrtBAe4AxGJJafdXTN4BVy3nwJzt5s
         ofyw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYWJ8q3tD+9SBbMPQbq7DcknkAqK/ViVo92M0S04kyE7p6dJ1kd
	RKTW3mrLSJFSYEk1sedWwxWz3IWcBhcJEjtjp+di9SEr17nnw8Pg1I8OGbCVhzsmBYr9pqJ+oL2
	IiMlWCERWDF61250SjMl8YSZKGYbQmNn1TS5QtwBRv5cwN+ZCt7Lis6EIATqBIsw=
X-Received: by 2002:a50:c8c9:: with SMTP id k9mr2148032edh.6.1550133233447;
        Thu, 14 Feb 2019 00:33:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZQ+/FVYodrNMLgL/P9xEaCDqjSsh7KncBdlcr6NwgCUvR+DBubdcY9xXJj9yoqOoayD9WO
X-Received: by 2002:a50:c8c9:: with SMTP id k9mr2147977edh.6.1550133232460;
        Thu, 14 Feb 2019 00:33:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550133232; cv=none;
        d=google.com; s=arc-20160816;
        b=eJT6JfXc7//RFexlBKwI1WBnnjjAjhyH5RSs2OdNLinWnpSEjBUIwDSYbLssPgPHBs
         ToL5nztM/W4K9qnEWYRz45KBCbebwRzsUSwFXv3ednF2K5Xr0Q87XIEAgLfwzoVBJTYa
         jhnEZmec8o947Eb1LSR0GQYSjKf7VVacbVuoRGBbbyOKEcl0XCbTVKKapFuiM9VcJcVY
         AKToJKXd4jyRosyhw2QPGJcN1ihad1FTxJCUu1XKdzHrt48eUOyMN54mEBBZmacBV/KO
         8da8+CfpHGdBe3tG5Ti4hq85oSpRwWwfenVYMIQgYqS0tl8qTClKQr6IUHDei03hutw0
         HLig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AmZ0SDSAcbZTq8rw8naCi8bajIWyxiwx9StC5GvhDJc=;
        b=YMWwZfZ8kWQmICRihp3So7zDM3GuywsEE0SwrnmCAyThnijpqdgQHwizhN2iynrVv3
         LLXTltD4mA4iX1uk45G1gDJZyi7/K5SFmLZfNPn2N4CvsUf23qQ9EhAuROw3KfHM5vey
         OQEYm3HtQ3e/k5vdhHbhhW+QiPskNMXQDaF41OV3bKkayhpqbTI7uS5LGn2etmxgL7UR
         dWRelIWqwSuAXgb6sgCNgLNqDkM3MiiMyHm4IvvfoT+uFpJdWQMc5T54D5DAnXhh8JXo
         1HkWm3Ff/Tap8mvtujf2PeyC4V3+UyCRGD3ojaAEpXIh7yFk1nZWaYov3JFk+oAe4a6r
         BHXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f14si768289eja.65.2019.02.14.00.33.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 00:33:52 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DAF7FACA2;
	Thu, 14 Feb 2019 08:33:51 +0000 (UTC)
Date: Thu, 14 Feb 2019 09:33:50 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: keith.busch@intel.com, keescook@chromium.org,
	dave.hansen@linux.intel.com, dan.j.williams@intel.com,
	linux-mm@kvack.org
Subject: Re: + mm-shuffle-default-enable-all-shuffling.patch added to -mm tree
Message-ID: <20190214083350.GY4525@dhcp22.suse.cz>
References: <20190206200254.bcdZQ%akpm@linux-foundation.org>
 <20190212085428.GP15609@dhcp22.suse.cz>
 <20190212134622.9e685e9a955915d1a058ea99@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212134622.9e685e9a955915d1a058ea99@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-02-19 13:46:22, Andrew Morton wrote:
> On Tue, 12 Feb 2019 09:54:28 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Wed 06-02-19 12:02:54, Andrew Morton wrote:
> > > From: Dan Williams <dan.j.williams@intel.com>
> > > Subject: mm/shuffle: default enable all shuffling
> > > 
> > > Per Andrew's request arrange for all memory allocation shuffling code to
> > > be enabled by default.
> > > 
> > > The page_alloc.shuffle command line parameter can still be used to disable
> > > shuffling at boot, but the kernel will default enable the shuffling if the
> > > command line option is not specified.
> > > 
> > > Link: http://lkml.kernel.org/r/154943713572.3858443.11206307988382889377.stgit@dwillia2-desk3.amr.corp.intel.com
> > > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > > Cc: Kees Cook <keescook@chromium.org>
> > > Cc: Michal Hocko <mhocko@suse.com>
> > > Cc: Dave Hansen <dave.hansen@linux.intel.com>
> > > Cc: Keith Busch <keith.busch@intel.com>
> > > 
> > > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > 
> > I hope this is mmotm only thing and even then, is this really
> > something we want for linux-next? There are people doing testing and
> > potentially performance testing on that tree. Do we want to invalidate
> > all that work? I can see some argument about a testing coverage but do
> > we really need it for the change like this? The randomization is quite
> > simple to review and I assume Dan has given this good testing before
> > submition.
> 
> Please see the mailing list discussion.  Without this patch the feature
> is likely to end up in mainline with next to no testing other than Dan's.

Isn't that the case for most of the functionality behind CONFIG_$FOO
that doesn't get enabled by default?

It is not that I care too much but I find this way of argumentation
strange. It is the submitter to make sure the feature is tested properly
and reviewers should make sure the overall design and implementation
makes sense. I do not see reason why all users of linux-next should be a
guinea pigs without knowing that.
-- 
Michal Hocko
SUSE Labs

