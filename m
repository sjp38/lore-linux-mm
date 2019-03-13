Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBBBBC10F03
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:16:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70EE72146E
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:16:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="URSa0zmo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70EE72146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D9508E0004; Wed, 13 Mar 2019 14:16:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 089CA8E0001; Wed, 13 Mar 2019 14:16:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE1028E0004; Wed, 13 Mar 2019 14:16:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id ACD5C8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 14:16:54 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id m17so3145232pgk.3
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:16:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=nWlRgW+0+Za5z77KKGiij4P47yj0qUjVTn19Cpp/GDM=;
        b=VaLQ/urP8c4IRdRDEE1/1zgtEHQFVr3QIW5dcjVB11lYane2AB5XSo4WanOudQ7CCE
         +AKprkAaQzZgMDRAJj4yuCFhD5nlxUr1GXS93CeESJ/yAddpsLy6H06/G7xfZbpnCtay
         72AnMdKzlX7WXx7dpwtRd5GYSuRM9Dtg6PGV9cF3Vx9mDbsO/paqJkuKamO/yh4h73uf
         kZ9ywCPVj2IE+BZWWVF592XL2QKiR7z9GZTHVmnfKlTgRm+mZ5X5FMPC7oFRLtG1jcWu
         o/9CYk8KsAlobo+ueaSRTqSjj+F1Nk0rwBNWHM5BBy9SuG9NaC3WeQQHQI8/lRZ1d7Sy
         YpKA==
X-Gm-Message-State: APjAAAWPvD1eDZq2r6RV7syX6f1P6jRuUi58a/HFOGqboHrpRRvri+MU
	zdob3zT7fJNh3IMW0mobYe7d2PYHIl+ZxGSxxZBQO1OGLfLPpO4RlLqsCKEcyP/TOIEUwe8iMel
	QT08y+TdEcnO69GQA40jYEKRhoeneiLdOQQYo7oewuUjC8T/5b9NZOMkImS5hq9iD6g==
X-Received: by 2002:a62:5e46:: with SMTP id s67mr45171318pfb.126.1552501014167;
        Wed, 13 Mar 2019 11:16:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNYsu0xlo9yrRbHkrME+oVSbN/FtFweUf8FUgcCSOugaLrjcNioj4lW9FHl1OjxgEq6iUs
X-Received: by 2002:a62:5e46:: with SMTP id s67mr45171234pfb.126.1552501012849;
        Wed, 13 Mar 2019 11:16:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552501012; cv=none;
        d=google.com; s=arc-20160816;
        b=QuxagvATBQxK80Y0mDTPBvg1yE8GV3sbojtxT9v9VU3eorD48QGp5dZpcEbzoio/M8
         /Kiggu7l2PBunx/4MyBi+OZBHfxTlhqM9DLwgmDlWi7WQ1OW+tXgmyNZdaHdIlH5LBJQ
         4Q5KQFSwkcx/t5u8SoxTJSXJCez7s9oTIrJd2B4D1v4sGWH+uqWciPxZIFiHGir9gmmC
         H3YPcqzwLFd7M8+qdyxdDMCiKMBOt0DyYJZ9Zr6p/tAcbH8T1M7FvUdWCELnF8kxAqpc
         mCa2vdSSwRFj7EmoLS79mblUrlV66SPAloNbTvU+CUwL1fXGyRq+B+kuGMbWxmY7fdhI
         02Eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=nWlRgW+0+Za5z77KKGiij4P47yj0qUjVTn19Cpp/GDM=;
        b=yH/6ATAzkQ2EzgmICRvF5x3Z2+oQJp2uuOCBxgsVig5wKXJGGwEWMPBL60rmFYccv4
         RLA54FoXv/SRdGMPAXCzvHwl3m2Vrfs7Df+xOUvdt7TqbWJgBkBR6r9vM/BjK518em/V
         y/Po9aafIYWw44TAKuEVmW/7N2qhonWfR4Q94jv6cvAooWvBqcvIB/25x/ruaZD2YSQe
         zFad84NhGkR6HGi7rUP2ypdyV/37SsykAh29hX3rHPjElnmdP1hMRqoYzbXVjsIoDIL3
         vhIJIcESt6lvd0tc4p7FR2S2ZikLNT+MiDs5XrJHXHnwUOvKSn5usiAvSrQgFOdr0nAg
         3KKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=URSa0zmo;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 189si10312932pgb.412.2019.03.13.11.16.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 11:16:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=URSa0zmo;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from gmail.com (unknown [104.132.1.77])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id ED92D21019;
	Wed, 13 Mar 2019 18:16:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552501012;
	bh=NBYWGtH9wtv5Jk1W5+17+1saO++Uar9ct/F9yhKpQZI=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=URSa0zmoebEWbGHKSEkWGzRrbEVoDmXu2HYX/iZre+2OIfJ8Rf6ZF4hULmOBmCzx+
	 dy74dBbaK4VuhVexHIJ4umpIejOh8BVmW5+BNhz6omfDdr4ANQpGl2fOdpBKYGgRlo
	 MrjBkIn1xE6P5zCFYEdVXhM1b2i+eQ/vGeSNGcRo=
Date: Wed, 13 Mar 2019 11:16:50 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com>,
	Cgroups <cgroups@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Shakeel Butt <shakeelb@google.com>,
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: KASAN: null-ptr-deref Read in reclaim_high
Message-ID: <20190313181649.GA10169@gmail.com>
References: <0000000000001fd5780583d1433f@google.com>
 <20190311163747.f56cceebd9c2661e4519bdfc@linux-foundation.org>
 <CACT4Y+byKQSOCte3JS9XOnyr+aVSEFtBvLxG2-HUrZX3-82Hcg@mail.gmail.com>
 <20190311232541.db8571d2e3e0ca636785f31f@linux-foundation.org>
 <CACT4Y+Y0JdB-=yLLchw8icokn11iH2-XYoLJEOFKm6F88fJ3WQ@mail.gmail.com>
 <20190312225044.GB38846@gmail.com>
 <CACT4Y+a775wdkjQcsZTLG_Jr4k2gSXnOQF6ZTJDPOc-kvPG9Xw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+a775wdkjQcsZTLG_Jr4k2gSXnOQF6ZTJDPOc-kvPG9Xw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 09:24:21AM +0100, 'Dmitry Vyukov' via syzkaller-bugs wrote:
> On Tue, Mar 12, 2019 at 11:50 PM Eric Biggers <ebiggers@kernel.org> wrote:
> >
> > On Tue, Mar 12, 2019 at 09:33:44AM +0100, 'Dmitry Vyukov' via syzkaller-bugs wrote:
> > > On Tue, Mar 12, 2019 at 7:25 AM Andrew Morton <akpm@linux-foundation.org> wrote:
> > > >
> > > > On Tue, 12 Mar 2019 07:08:38 +0100 Dmitry Vyukov <dvyukov@google.com> wrote:
> > > >
> > > > > On Tue, Mar 12, 2019 at 12:37 AM Andrew Morton
> > > > > <akpm@linux-foundation.org> wrote:
> > > > > >
> > > > > > On Mon, 11 Mar 2019 06:08:01 -0700 syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com> wrote:
> > > > > >
> > > > > > > syzbot has bisected this bug to:
> > > > > > >
> > > > > > > commit 29a4b8e275d1f10c51c7891362877ef6cffae9e7
> > > > > > > Author: Shakeel Butt <shakeelb@google.com>
> > > > > > > Date:   Wed Jan 9 22:02:21 2019 +0000
> > > > > > >
> > > > > > >      memcg: schedule high reclaim for remote memcgs on high_work
> > > > > > >
> > > > > > > bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=155bf5db200000
> > > > > > > start commit:   29a4b8e2 memcg: schedule high reclaim for remote memcgs on..
> > > > > > > git tree:       linux-next
> > > > > > > final crash:    https://syzkaller.appspot.com/x/report.txt?x=175bf5db200000
> > > > > > > console output: https://syzkaller.appspot.com/x/log.txt?x=135bf5db200000
> > > > > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=611f89e5b6868db
> > > > > > > dashboard link: https://syzkaller.appspot.com/bug?extid=fa11f9da42b46cea3b4a
> > > > > > > userspace arch: amd64
> > > > > > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14259017400000
> > > > > > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=141630a0c00000
> > > > > > >
> > > > > > > Reported-by: syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com
> > > > > > > Fixes: 29a4b8e2 ("memcg: schedule high reclaim for remote memcgs on
> > > > > > > high_work")
> > > > > >
> > > > > > The following patch
> > > > > > memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
> > > > > > might have fixed this.  Was it applied?
> > > > >
> > > > > Hi Andrew,
> > > > >
> > > > > You mean if the patch was applied during the bisection?
> > > > > No, it wasn't. Bisection is very specifically done on the same tree
> > > > > where the bug was hit. There are already too many factors that make
> > > > > the result flaky/wrong/inconclusive without changing the tree state.
> > > > > Now, if syzbot would know about any pending fix for this bug, then it
> > > > > would not do the bisection at all. But it have not seen any patch in
> > > > > upstream/linux-next with the Reported-by tag, nor it received any syz
> > > > > fix commands for this bugs. Should have been it aware of the fix? How?
> > > >
> > > > memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch was
> > > > added to linux-next on Jan 10.  I take it that this bug was hit when
> > > > testing the entire linux-next tree, so we can assume that
> > > > memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
> > > > does not fix it, correct?
> > > > In which case, over to Shakeel!
> > >
> > > Jan 10 is exactly when this bug was reported:
> > > https://groups.google.com/forum/#!msg/syzkaller-bugs/5YkhNUg2PFY/4-B5M7bDCAAJ
> > > https://syzkaller.appspot.com/bug?extid=fa11f9da42b46cea3b4a
> > >
> > > We don't know if that patch fixed the bug or not because nobody tested
> > > the reproducer with that patch.
> > >
> > > It seems that the problem here is that nobody associated the fix with
> > > the bug report. So people looking at open bug reports will spend time
> > > again and again debugging this just to find that this was fixed months
> > > ago. syzbot also doesn't have a chance to realize that this is fixed
> > > and bisection is not necessary anymore. It also won't confirm/disprove
> > > that the fix actually fixes the bug because even if the crash will
> > > continue to happen it will look like the old crash just continues to
> > > happen, so nothing to notify about.
> > >
> > > Associating fixes with bug reports solves all these problems for
> > > humans and bots.
> > >
> >
> > I think syzbot needs to be more aggressive about invalidating old bug reports on
> > linux-next, e.g. automatically invalidate linux-next bugs that no longer occur
> > after a few weeks even if there is a reproducer.  Patches get added, changed,
> > and removed in linux-next every day.  Bugs that syzbot runs into on linux-next
> > are often obvious enough that they get reported by other people too, resulting
> > in bugs being fixed or dropped without people ever seeing the syzbot report.
> > How do you propose that people associate fixes with syzbot reports when they
> > never saw the syzbot report in the first place?
> >
> > This is a problem on mainline too, of course.  But we *know* it's a more severe
> > problem on linux-next, and that a bug like this that only ever happened on
> > linux-next and stopped happening 2 months ago, is much less likely to be
> > relevant than a bug in mainline.  Kernel developers don't have time to examine
> > every single syzbot report so you need to help them out by reducing the noise.
> 
> Please file an issue for this at https://github.com/google/syzkaller/issues

I filed https://github.com/google/syzkaller/issues/1054

> 
> I also wonder how does this work for all other kernel bugs reports?
> syzbot is not the only one reporting kernel bugs and we don't want to
> invent new rules here.

Well, I think you already know the answer to that.  There's no unified bug
tracking system for all kernel subsystems, so in the worst case bugs/features
just get ignored until someone cares to bring it up again.  I know you want to
change that, but the larger problem is that there aren't enough people able and
funded to do the work.  For the kernel overall (some subsystems are better, OFC)
there so many low-quality, duplicate, or irrelevant reports/requests that no one
can keep up.  That means maintainers have to focus on the highest priority
reports/requests, such as the ones that are clearly relevant and get continued
discussion, vs. some random problem someone had 2 years ago.  Just putting stuff
on a bug tracker does not magically make people work on it.

I think the reality is that until people can actually be funded to immediately
analyze every syzbot report, syzbot needs to be designed to help developers
focus on the reports most likely to still be actual bugs.  That means
automatically closing bugs where the crash is no longer occurring, especially if
it was on linux-next; and sending reminders if the crash is still occurring.

> 
> Also note that what happens now may be not representative of what will
> happen in a steady mode later. Now syzbot bisects old bugs accumulated
> over 1+ year. Later if it reports a bug, it should bisect sooner. So
> all of what happens in this bug report won't take place.
> 

Sure, but I think there will continue to be syzbot reports that the relevant
people either don't see, or don't have time or expertise to look into.  This is
especially true when the same bug is filed as many different bug reports.

- Eric

