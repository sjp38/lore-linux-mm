Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A8BCC10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:31:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B8562173C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:31:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="mgDX2Ja0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B8562173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A254D8E0003; Tue, 12 Mar 2019 18:31:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FBE38E0002; Tue, 12 Mar 2019 18:31:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EB288E0003; Tue, 12 Mar 2019 18:31:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1D38E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:31:19 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z14so4261935pgu.1
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:31:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/Cn2oGqGJ90QnfA1hQa2tuMcdJ8165hvFAY9n12Rfis=;
        b=IBIQMnEMtUrOqdfcrWRkidbe2+mhnI3oH3mneCO9eAPRZWvHskuPlW87GlTA5XDCha
         n9HVb9MCe8Ohsy2NkR1+Itkc57/U0RHraeP/azXpu3W7INLb+F+BH/UHIU6L9y3a4leI
         AK2XqX+CB9hzPyWgfP+rJHtv9Z0pgcywfJvRNj/CGEp+wnzqfmh4JLH7u8S9T+ttveeX
         +Yl0xfaGZIIY3FtyX/Z0gxpUFXo5ZqJj1inyl/x7/Wh4YKxqf/WD9PZf1lh6C8wfjHPv
         hIpJFFlGJYSWDFtH5qBbPbyxvMmoaUcb5QDg8xg6W3XjNw4matLPfR1GfRCJ6lrRWSEB
         VJ4w==
X-Gm-Message-State: APjAAAVGlir3ojm2BTO3XVbBrxKVAH/DBaUUYN04B26P8H+diEiAjvzq
	6/iy2n7YdQLH0N3m7xMpUaW+G7ngdk9ZdRtZPrGrQ3PyEL5xx+viavqOkjffT0ONNAKVRwazPSW
	yIlYfSmV6dgILRvN31egiXlc6vIa7LVKDFKrNnNnnMtj+rkxP0TRoWxPz4W794Y6ATA==
X-Received: by 2002:a63:cc01:: with SMTP id x1mr16204518pgf.221.1552429878634;
        Tue, 12 Mar 2019 15:31:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWxN8EQAvEiw+2SZ5UilQJ0gETfL3jXgOz4sQ1iEEaT3QoD45rBvNkYF/GysTjnMNsho42
X-Received: by 2002:a63:cc01:: with SMTP id x1mr16204438pgf.221.1552429877446;
        Tue, 12 Mar 2019 15:31:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552429877; cv=none;
        d=google.com; s=arc-20160816;
        b=lcHWuBTGe1x9+sMN4rkT80vg0ESpZuyhDnv3hIPzCVU8kWKORJTr6Cn7zVL0qO48JU
         Cx54Juj7V3KoN/kjniW8pbRGPcFLOhIYoP0W4ImBoVG4nsmy3XNnsbNCCgqZh63ODNMx
         mtRsk74mrMS7WByuZD8c30IC+i/1iG1moL3z6EXD2Mpofz6IVnYt8NfdvA/hThwCP7cA
         8C3lJ2GV3osq0++aoePSgxOvx7LOUube4AzQbC8KmZBRxUJDO2TzYJOwfhWBVWCRvfyb
         RNjDqxAy/OCq32oMPYW8PaSghmbKInQt2SsckYZ9xTUW76jONjzJUfJIT6/ZGx+IFIjM
         9ZFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/Cn2oGqGJ90QnfA1hQa2tuMcdJ8165hvFAY9n12Rfis=;
        b=z8XmSyqxt0K7fji1YtGAAB8+EYKBMKUMc1B9DmZA78mbAnr5fAmCMDbvh3bJfbyZud
         cdceYadBRdrTufuFQ/lpBjPKIRwjo/7StnYOiKHYkWwd19HjBUON0dcP7szHyvP3ijwE
         fpV2O/HYnHdKpK0CueLxl8r5bIHeUVD27G8ERrx5qGw4qjrxvvT5NqKVR38g3kyUMIXd
         HSKbwmKBhV7Q03GzoOEjWT96mh52aJ0kRef1VWy3cLU2vquVpWoc5dhhPS0Iw/f6nFOr
         Mlc3EZqjdDBtGQAVP8+7VWVFhHd4Vmm1vegyaqN8NKeefkU3C7H3kMwtmvu1uzP9/v/v
         bCMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mgDX2Ja0;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w16si5311960pll.113.2019.03.12.15.31.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:31:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=mgDX2Ja0;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from gmail.com (unknown [104.132.1.77])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7197A2077B;
	Tue, 12 Mar 2019 22:31:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552429876;
	bh=E9LjOuH7NlwjEdXrTTN9jNJ+sUFTiiXDJcLC3CteIKM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=mgDX2Ja0bynZtaS+WaK0y1rIkv62DHI1nWFmMJVzq0Ab5gTiYtd3ESuN0la/2mzia
	 ssElYhG4GEHO30ZyTTSfAA+ij6UvykwLWf125Q6r7jfYwZtx7X8+AhTPaf2rYFUvRK
	 scu7n6Pk8F6/V+jQh3VeCW6SbeYVd0gpGU7wmV0E=
Date: Tue, 12 Mar 2019 15:31:15 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com>,
	cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Shakeel Butt <shakeelb@google.com>,
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: KASAN: null-ptr-deref Read in reclaim_high
Message-ID: <20190312223113.GA38846@gmail.com>
References: <0000000000001fd5780583d1433f@google.com>
 <20190311163747.f56cceebd9c2661e4519bdfc@linux-foundation.org>
 <CACT4Y+byKQSOCte3JS9XOnyr+aVSEFtBvLxG2-HUrZX3-82Hcg@mail.gmail.com>
 <20190311232541.db8571d2e3e0ca636785f31f@linux-foundation.org>
 <20190312064300.GB9123@sol.localdomain>
 <CACT4Y+Z1rkS5bf3x9Y+0ke=zZ+mM2F5+vN-JtSQpjD09STRNdw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Z1rkS5bf3x9Y+0ke=zZ+mM2F5+vN-JtSQpjD09STRNdw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Dmitry,

On Tue, Mar 12, 2019 at 09:21:09AM +0100, 'Dmitry Vyukov' via syzkaller-bugs wrote:
> On Tue, Mar 12, 2019 at 7:43 AM Eric Biggers <ebiggers@kernel.org> wrote:
> >
> > On Mon, Mar 11, 2019 at 11:25:41PM -0700, Andrew Morton wrote:
> > > On Tue, 12 Mar 2019 07:08:38 +0100 Dmitry Vyukov <dvyukov@google.com> wrote:
> > >
> > > > On Tue, Mar 12, 2019 at 12:37 AM Andrew Morton
> > > > <akpm@linux-foundation.org> wrote:
> > > > >
> > > > > On Mon, 11 Mar 2019 06:08:01 -0700 syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com> wrote:
> > > > >
> > > > > > syzbot has bisected this bug to:
> > > > > >
> > > > > > commit 29a4b8e275d1f10c51c7891362877ef6cffae9e7
> > > > > > Author: Shakeel Butt <shakeelb@google.com>
> > > > > > Date:   Wed Jan 9 22:02:21 2019 +0000
> > > > > >
> > > > > >      memcg: schedule high reclaim for remote memcgs on high_work
> > > > > >
> > > > > > bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=155bf5db200000
> > > > > > start commit:   29a4b8e2 memcg: schedule high reclaim for remote memcgs on..
> > > > > > git tree:       linux-next
> > > > > > final crash:    https://syzkaller.appspot.com/x/report.txt?x=175bf5db200000
> > > > > > console output: https://syzkaller.appspot.com/x/log.txt?x=135bf5db200000
> > > > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=611f89e5b6868db
> > > > > > dashboard link: https://syzkaller.appspot.com/bug?extid=fa11f9da42b46cea3b4a
> > > > > > userspace arch: amd64
> > > > > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14259017400000
> > > > > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=141630a0c00000
> > > > > >
> > > > > > Reported-by: syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com
> > > > > > Fixes: 29a4b8e2 ("memcg: schedule high reclaim for remote memcgs on
> > > > > > high_work")
> > > > >
> > > > > The following patch
> > > > > memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
> > > > > might have fixed this.  Was it applied?
> > > >
> > > > Hi Andrew,
> > > >
> > > > You mean if the patch was applied during the bisection?
> > > > No, it wasn't. Bisection is very specifically done on the same tree
> > > > where the bug was hit. There are already too many factors that make
> > > > the result flaky/wrong/inconclusive without changing the tree state.
> > > > Now, if syzbot would know about any pending fix for this bug, then it
> > > > would not do the bisection at all. But it have not seen any patch in
> > > > upstream/linux-next with the Reported-by tag, nor it received any syz
> > > > fix commands for this bugs. Should have been it aware of the fix? How?
> > >
> > > memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch was
> > > added to linux-next on Jan 10.  I take it that this bug was hit when
> > > testing the entire linux-next tree, so we can assume that
> > > memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
> > > does not fix it, correct?
> > >
> > > In which case, over to Shakeel!
> > >
> >
> > I don't understand what happened here.  First, the syzbot report doesn't say
> > which linux-next version was tested (which it should), but I get:
> >
> > $ git tag --contains 29a4b8e275d1f10c51c7891362877ef6cffae9e7
> > next-20190110
> > next-20190111
> > next-20190114
> > next-20190115
> > next-20190116
> >
> > That's almost 2 months old, yet this bug was just reported now.  Why?
> 
> Hi Eric,
> 
> This bug was reported on Jan 10:
> https://syzkaller.appspot.com/bug?extid=fa11f9da42b46cea3b4a
> https://groups.google.com/forum/#!msg/syzkaller-bugs/5YkhNUg2PFY/4-B5M7bDCAAJ
> 
> The start revision of the bisection process (provided) is the same
> that was used to create the reproducer. The end revision and bisection
> log are provided in the email.
> 
> How can we improve the format to make it more clear?
> 

syzbot started a new thread rather than sending the bisection result in the
existing thread.  So I thought it was a new bug report, as did everyone else
probably.

- Eric

