Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0A1BC32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 19:14:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9919A2087E
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 19:14:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9919A2087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 396FF6B0007; Fri,  2 Aug 2019 15:14:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3484A6B0008; Fri,  2 Aug 2019 15:14:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2372D6B000A; Fri,  2 Aug 2019 15:14:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C696D6B0007
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 15:14:34 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i44so47598010eda.3
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 12:14:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=TQ6ywqms/DusqrpKwajBSR9clNJZ4MI4yGASzJiOCFA=;
        b=FxIpsZBKaBYjdrM4OireQhSdG8GDmlFc8qZPVfCADaoD+BS6qpW1kSDsfEGo9ZeDdo
         Y+2W71eVk8Z1kGnlniy36dxNtu5HkCLivVMcJZQGZWXCb1+CbeA0DNZR3GbRKSQmY1nG
         6o76pzg0JqsnM4CB5uqOj6OFY3W9fhcK/CQbyOusL9sjkU97/cuk2p258Wd4PutUAjLG
         K0Sfq/163yV2Lrwb3zWhk+yVde08BLaSpYAS4eaO/WAZvAZhs10hjit9NfJarUTb/zZQ
         VTtdOIKc5H5NxUHbx4y+zWtvLGwfxQSokL5kEyyK2yKrIQL6XhglDZfZVTC/aWKEg8Gy
         6uGA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW1ni4XVKeuq8Ay2ZG2iK1BS117HezWEbBbZ6jVrBFCsjXp0duN
	ETCQq99pnEhqJJpoW5ynKDIBegRO/JBZBXj69JcCFF/ZBVrurtu90/j3MQyJ9XgXemBcPl4YbnO
	ymd/jWh2IjPWR6O90IXk70eceNifsbdOpooflycC6EGc/ZRAXVQz0y1wv+VbQmzI=
X-Received: by 2002:a50:a943:: with SMTP id m3mr118312957edc.190.1564773274337;
        Fri, 02 Aug 2019 12:14:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8Q+LVn8otGYFjwQjqDar3zNtLgSqYgRUSlVxXiBqRXmGJzrT6QuePPm+aH2QSCZqgFkFZ
X-Received: by 2002:a50:a943:: with SMTP id m3mr118312901edc.190.1564773273550;
        Fri, 02 Aug 2019 12:14:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564773273; cv=none;
        d=google.com; s=arc-20160816;
        b=aFjBG1ejg/mcZ84rAq0ZqeGepq/mA4f2MFUuByOW01j/Wctln3Zyf1X/R4hKuCC7jv
         2imd6Fb1O+BKP1C1KrQ28KrLKj0PyttYpBweiVikcKZSWtod1lIXnv0ixg9JvvRXl27p
         rWYfvBYsgdcSI4eRCGLeWg0osxu8jV0GnKaWNoTlBqpUGvTKWtLIaKYMKD3nJTWb6Uvz
         iyR7HzwK73Mu2DglX56qjHxRrS3g2t9YT/dIl++bdoYdbZllZ/R1HIt9lQKxum+ewxdo
         vijJlygjoRDuc1zGezMQ0hQXcpXF+eQjavVqLPFZ5bjXMaSHTpWaQ9UDi78/J8cxKnZS
         Z3aw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=TQ6ywqms/DusqrpKwajBSR9clNJZ4MI4yGASzJiOCFA=;
        b=oUuU06yQ4ysHWOtjdZx26jIqsWXR3RjQP3Kus7QcrGlLpfPuViLHAmFRIRmXdh/eag
         IkjoLW7HpRDcfIF6c5zTLkuvvX0jYZI6DcAFmvi7mBbJv1pO3Q57xiUpFLx4cGazJlAt
         WwaXek/Sli+k4GAEvY2pByGnB2zZXjtuoVKgwIdmKWCIucJ1z7ya8p48UQKdV9FsSjSP
         A2gqhB01wDXaDOk03w1vPXXfefKota59X1WfOVTlv3S68XaJYJx0XBKTQiyYHnsTV4TZ
         vluVSbhVgbMGmnlAFn8yFBMoM/oOo0eOn/AYsnx3/GjN+lSINVPTv+pwS171m+6gz9+m
         awcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mh23si22805131ejb.224.2019.08.02.12.14.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 12:14:33 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BAA03AD43;
	Fri,  2 Aug 2019 19:14:32 +0000 (UTC)
Date: Fri, 2 Aug 2019 21:14:30 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Masoud Sharbiani <msharbiani@apple.com>
Cc: gregkh@linuxfoundation.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com,
	linux-mm@kvack.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
Message-ID: <20190802191430.GO6461@dhcp22.suse.cz>
References: <5659221C-3E9B-44AD-9BBF-F74DE09535CD@apple.com>
 <20190802074047.GQ11627@dhcp22.suse.cz>
 <7E44073F-9390-414A-B636-B1AE916CC21E@apple.com>
 <20190802144110.GL6461@dhcp22.suse.cz>
 <5DE6F4AE-F3F9-4C52-9DFC-E066D9DD5EDC@apple.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5DE6F4AE-F3F9-4C52-9DFC-E066D9DD5EDC@apple.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 02-08-19 11:00:55, Masoud Sharbiani wrote:
> 
> 
> > On Aug 2, 2019, at 7:41 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > On Fri 02-08-19 07:18:17, Masoud Sharbiani wrote:
> >> 
> >> 
> >>> On Aug 2, 2019, at 12:40 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >>> 
> >>> On Thu 01-08-19 11:04:14, Masoud Sharbiani wrote:
> >>>> Hey folks,
> >>>> I’ve come across an issue that affects most of 4.19, 4.20 and 5.2 linux-stable kernels that has only been fixed in 5.3-rc1.
> >>>> It was introduced by
> >>>> 
> >>>> 29ef680 memcg, oom: move out_of_memory back to the charge path 
> >>> 
> >>> This commit shouldn't really change the OOM behavior for your particular
> >>> test case. It would have changed MAP_POPULATE behavior but your usage is
> >>> triggering the standard page fault path. The only difference with
> >>> 29ef680 is that the OOM killer is invoked during the charge path rather
> >>> than on the way out of the page fault.
> >>> 
> >>> Anyway, I tried to run your test case in a loop and leaker always ends
> >>> up being killed as expected with 5.2. See the below oom report. There
> >>> must be something else going on. How much swap do you have on your
> >>> system?
> >> 
> >> I do not have swap defined. 
> > 
> > OK, I have retested with swap disabled and again everything seems to be
> > working as expected. The oom happens earlier because I do not have to
> > wait for the swap to get full.
> > 
> 
> In my tests (with the script provided), it only loops 11 iterations before hanging, and uttering the soft lockup message.
> 
> 
> > Which fs do you use to write the file that you mmap?
> 
> /dev/sda3 on / type xfs (rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,noquota)
> 
> Part of the soft lockup path actually specifies that it is going through __xfs_filemap_fault():

Right, I have just missed that.

[...]

> If I switch the backing file to a ext4 filesystem (separate hard drive), it OOMs.
> 
> 
> If I switch the file used to /dev/zero, it OOMs: 
> …
> Todal sum was 0. Loop count is 11
> Buffer is @ 0x7f2b66c00000
> ./test-script-devzero.sh: line 16:  3561 Killed                  ./leaker -p 10240 -c 100000
> 
> 
> > Or could you try to
> > simplify your test even further? E.g. does everything work as expected
> > when doing anonymous mmap rather than file backed one?
> 
> It also OOMs with MAP_ANON. 
> 
> Hope that helps.

It helps to focus more on the xfs reclaim path. Just to be sure, is
there any difference if you use cgroup v2? I do not expect to be but
just to be sure there are no v1 artifacts.
-- 
Michal Hocko
SUSE Labs

