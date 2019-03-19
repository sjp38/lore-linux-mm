Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDBBBC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 13:52:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6278C2085A
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 13:52:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="gwxkMPxz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6278C2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EA546B0003; Tue, 19 Mar 2019 09:52:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09DC96B0006; Tue, 19 Mar 2019 09:52:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA79D6B0007; Tue, 19 Mar 2019 09:52:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 757AF6B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 09:52:43 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id w11so16240950iom.20
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 06:52:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=jsfKp09Yioy1UBUpxcVVheydY08Ch0hjKGYCdU+3zyg=;
        b=UHwoEr8Q9qdhFmCZ/QEok+mSIp7oQEZ/fmo/9LWpopgK//UfDnhk7Rsk0RJ3DRdvIH
         ryEvTAR2WrwPZ7gsalbSN+BxVQmHvS/Yr7ekjKSYnYk+E7TsxWi/ylR7YxU5cVnwd+Qb
         SpkMPu0gmqbJBOrVwYo+5D2KTiu7iO3mYxBvXvCpLPNkUS9N6prqdC8kpDX7b6sR1Z2f
         J1wjxq7iQMjYKD3PAOLxMuk7Y0ozsCvTCc96LrJgAM80zBVjTboD5VPftq9EtAvQKPQz
         OSWFuL5IrHkmvKWm4iTc6tnSollk2Rbfn9jk7pemk6LTSbgFgKCe+ySYI/J9EmaPLFUH
         8U8A==
X-Gm-Message-State: APjAAAX2yhMhgig+IsV4kJV3m/UVabLa2Bk9JTCxGK5EZ8nYkngPbhk2
	kbyNV93ee7FFbvXYZUCwhKVtJ3LEcdW1Ix4xQ8KgX4R9qc9nndB+EkRaEfgPbRHFSEnvY/r8eic
	lNgIAqZPxLsUG2oILemi7BNUBRHRti6CXwB6rZK6HNqKhHDZU2G09cn7h4rQT66S0+Q==
X-Received: by 2002:a24:3a4e:: with SMTP id m75mr1460066itm.23.1553003563099;
        Tue, 19 Mar 2019 06:52:43 -0700 (PDT)
X-Received: by 2002:a24:3a4e:: with SMTP id m75mr1460003itm.23.1553003561911;
        Tue, 19 Mar 2019 06:52:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553003561; cv=none;
        d=google.com; s=arc-20160816;
        b=ZjumuQKR1UOqU/b1vuJeXngbzQEIz2mGEvhOPyvC4ptaqZrnaTd3nM8ks6qm1MRp4o
         PjK3I8SmI+jpfYWrJuKDiA0Pu5r8c8wY2Jt6wmD+f6VTWC0CNfS4zsTfwAi8ozXHBZBr
         XScDgGsZQz3R/qSM4KrNWd59DOBoPVFNEA9GozKo6ViiyL9UMmNuPpXyuTxCtSyvC4Oj
         dtF6tXWiK1GMQeh03MqqtPWSyGyGLhp7JyvD/0q7kBhEaZN8hTbO8418GkFgVFfriLtE
         NEKR9f3hbz47BtroUTAyUEV8DG0clRIS/CX1QBn9QnvBqcG9oltnDTLvEEnwrwjLfVe9
         JO4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=jsfKp09Yioy1UBUpxcVVheydY08Ch0hjKGYCdU+3zyg=;
        b=dlQ9kY2MFQcwMhWwCkNqzQ3xi/5IL3W1c1e2cvcoDvVFw3uRahpnvNjriyasPna1Ov
         ppZLFtzExWyrqV4dpq8BLFT6Wahp15DOIdCPGJSz7o4FOc3Ib4+BdlZbSy0Gh4LrnJzz
         mvQzOyW7xFn6RJBmw7CPHC7hMRK51JwG6/7a7VccGu/iLiE+SQUMZMwwhZmh99krLwtI
         zleCP5lk9QGh/PIO53nF8JqLHh5smGnxLfQYdEtaR1HhmwzbxEhvctmbXDpbmWT4j0I+
         ilbN1KT23rZi8aVDA3ju1oDFpQzz3HnLFi2SSVlNQcb5pMVQ1SdXXFlOPgGJR6D2B6lU
         C78g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gwxkMPxz;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n17sor4985101iom.112.2019.03.19.06.52.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 06:52:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gwxkMPxz;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jsfKp09Yioy1UBUpxcVVheydY08Ch0hjKGYCdU+3zyg=;
        b=gwxkMPxzOwXcSXsjIZ5qH5uHJGNOTtlRQU6KIDHxbagTUvQsOxwr9ZVuB8umMbtdC6
         wFparzy6CmXYARh8p9OLMTxGxJEUtpl+EcAipMUMMzCdVCnVcRfL0uSX7+m35T75Wu83
         VDJI9eGRAoxXvEJgQOvFm+xyw0V9QL6bsrJUpuH8LO7+XW+j6lYeC+bS0A5FBxdX+E86
         Ltdu4DUUaXsAWiiFURwIa3o4thVJh5NKn+///aPEIouOj2b8Txj/eELXai98W+e+BaYz
         Q/tdtoEoNGzoXGtY4zQERQNiOEkL/NlJqX6ypH+eUCx0lYQlWCdbGA+pTBZYHhA8pogD
         nwfQ==
X-Google-Smtp-Source: APXvYqzc47rJNfqOpUG68KO6cKD2G064gCBBagBhqdbHA8G1gHXWkEWFbseKEGCT5DmyqnKtdxjcf1nTnuANVu51DSo=
X-Received: by 2002:a5d:834a:: with SMTP id q10mr1406490ior.271.1553003561331;
 Tue, 19 Mar 2019 06:52:41 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000001fd5780583d1433f@google.com> <20190311163747.f56cceebd9c2661e4519bdfc@linux-foundation.org>
 <CACT4Y+byKQSOCte3JS9XOnyr+aVSEFtBvLxG2-HUrZX3-82Hcg@mail.gmail.com>
 <20190311232541.db8571d2e3e0ca636785f31f@linux-foundation.org>
 <CACT4Y+Y0JdB-=yLLchw8icokn11iH2-XYoLJEOFKm6F88fJ3WQ@mail.gmail.com>
 <20190312225044.GB38846@gmail.com> <CACT4Y+a775wdkjQcsZTLG_Jr4k2gSXnOQF6ZTJDPOc-kvPG9Xw@mail.gmail.com>
 <20190313181649.GA10169@gmail.com>
In-Reply-To: <20190313181649.GA10169@gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 19 Mar 2019 14:52:28 +0100
Message-ID: <CACT4Y+aHBB7U+Rkng7ufsG4doSzV_M1ijbMA1RErjquoNf-aUA@mail.gmail.com>
Subject: Re: KASAN: null-ptr-deref Read in reclaim_high
To: Eric Biggers <ebiggers@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com>, 
	Cgroups <cgroups@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, Shakeel Butt <shakeelb@google.com>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Vladimir Davydov <vdavydov.dev@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 7:16 PM Eric Biggers <ebiggers@kernel.org> wrote:
>
> On Wed, Mar 13, 2019 at 09:24:21AM +0100, 'Dmitry Vyukov' via syzkaller-bugs wrote:
> > On Tue, Mar 12, 2019 at 11:50 PM Eric Biggers <ebiggers@kernel.org> wrote:
> > >
> > > On Tue, Mar 12, 2019 at 09:33:44AM +0100, 'Dmitry Vyukov' via syzkaller-bugs wrote:
> > > > On Tue, Mar 12, 2019 at 7:25 AM Andrew Morton <akpm@linux-foundation.org> wrote:
> > > > >
> > > > > On Tue, 12 Mar 2019 07:08:38 +0100 Dmitry Vyukov <dvyukov@google.com> wrote:
> > > > >
> > > > > > On Tue, Mar 12, 2019 at 12:37 AM Andrew Morton
> > > > > > <akpm@linux-foundation.org> wrote:
> > > > > > >
> > > > > > > On Mon, 11 Mar 2019 06:08:01 -0700 syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com> wrote:
> > > > > > >
> > > > > > > > syzbot has bisected this bug to:
> > > > > > > >
> > > > > > > > commit 29a4b8e275d1f10c51c7891362877ef6cffae9e7
> > > > > > > > Author: Shakeel Butt <shakeelb@google.com>
> > > > > > > > Date:   Wed Jan 9 22:02:21 2019 +0000
> > > > > > > >
> > > > > > > >      memcg: schedule high reclaim for remote memcgs on high_work
> > > > > > > >
> > > > > > > > bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=155bf5db200000
> > > > > > > > start commit:   29a4b8e2 memcg: schedule high reclaim for remote memcgs on..
> > > > > > > > git tree:       linux-next
> > > > > > > > final crash:    https://syzkaller.appspot.com/x/report.txt?x=175bf5db200000
> > > > > > > > console output: https://syzkaller.appspot.com/x/log.txt?x=135bf5db200000
> > > > > > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=611f89e5b6868db
> > > > > > > > dashboard link: https://syzkaller.appspot.com/bug?extid=fa11f9da42b46cea3b4a
> > > > > > > > userspace arch: amd64
> > > > > > > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14259017400000
> > > > > > > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=141630a0c00000
> > > > > > > >
> > > > > > > > Reported-by: syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com
> > > > > > > > Fixes: 29a4b8e2 ("memcg: schedule high reclaim for remote memcgs on
> > > > > > > > high_work")
> > > > > > >
> > > > > > > The following patch
> > > > > > > memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
> > > > > > > might have fixed this.  Was it applied?
> > > > > >
> > > > > > Hi Andrew,
> > > > > >
> > > > > > You mean if the patch was applied during the bisection?
> > > > > > No, it wasn't. Bisection is very specifically done on the same tree
> > > > > > where the bug was hit. There are already too many factors that make
> > > > > > the result flaky/wrong/inconclusive without changing the tree state.
> > > > > > Now, if syzbot would know about any pending fix for this bug, then it
> > > > > > would not do the bisection at all. But it have not seen any patch in
> > > > > > upstream/linux-next with the Reported-by tag, nor it received any syz
> > > > > > fix commands for this bugs. Should have been it aware of the fix? How?
> > > > >
> > > > > memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch was
> > > > > added to linux-next on Jan 10.  I take it that this bug was hit when
> > > > > testing the entire linux-next tree, so we can assume that
> > > > > memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
> > > > > does not fix it, correct?
> > > > > In which case, over to Shakeel!
> > > >
> > > > Jan 10 is exactly when this bug was reported:
> > > > https://groups.google.com/forum/#!msg/syzkaller-bugs/5YkhNUg2PFY/4-B5M7bDCAAJ
> > > > https://syzkaller.appspot.com/bug?extid=fa11f9da42b46cea3b4a
> > > >
> > > > We don't know if that patch fixed the bug or not because nobody tested
> > > > the reproducer with that patch.
> > > >
> > > > It seems that the problem here is that nobody associated the fix with
> > > > the bug report. So people looking at open bug reports will spend time
> > > > again and again debugging this just to find that this was fixed months
> > > > ago. syzbot also doesn't have a chance to realize that this is fixed
> > > > and bisection is not necessary anymore. It also won't confirm/disprove
> > > > that the fix actually fixes the bug because even if the crash will
> > > > continue to happen it will look like the old crash just continues to
> > > > happen, so nothing to notify about.
> > > >
> > > > Associating fixes with bug reports solves all these problems for
> > > > humans and bots.
> > > >
> > >
> > > I think syzbot needs to be more aggressive about invalidating old bug reports on
> > > linux-next, e.g. automatically invalidate linux-next bugs that no longer occur
> > > after a few weeks even if there is a reproducer.  Patches get added, changed,
> > > and removed in linux-next every day.  Bugs that syzbot runs into on linux-next
> > > are often obvious enough that they get reported by other people too, resulting
> > > in bugs being fixed or dropped without people ever seeing the syzbot report.
> > > How do you propose that people associate fixes with syzbot reports when they
> > > never saw the syzbot report in the first place?
> > >
> > > This is a problem on mainline too, of course.  But we *know* it's a more severe
> > > problem on linux-next, and that a bug like this that only ever happened on
> > > linux-next and stopped happening 2 months ago, is much less likely to be
> > > relevant than a bug in mainline.  Kernel developers don't have time to examine
> > > every single syzbot report so you need to help them out by reducing the noise.
> >
> > Please file an issue for this at https://github.com/google/syzkaller/issues
>
> I filed https://github.com/google/syzkaller/issues/1054

Thanks.

> > I also wonder how does this work for all other kernel bugs reports?
> > syzbot is not the only one reporting kernel bugs and we don't want to
> > invent new rules here.
>
> Well, I think you already know the answer to that.  There's no unified bug
> tracking system for all kernel subsystems, so in the worst case bugs/features
> just get ignored until someone cares to bring it up again.  I know you want to
> change that, but the larger problem is that there aren't enough people able and
> funded to do the work.  For the kernel overall (some subsystems are better, OFC)
> there so many low-quality, duplicate, or irrelevant reports/requests that no one
> can keep up.  That means maintainers have to focus on the highest priority

Interesting point in "distributed" kernel testing versus "the" kernel testing.
Obviously if we have 50 dispersed testing efforts we do get tons of
duplicates. And these reports are of low quality because nobody wants
to invest into 1/50-th of testing with unclear future nor duplicate
work 50x. This results in tons of unproductive work for everybody.
E.g. all the work on syzbot bisection. All of this was already done
multiple times. And I am sure Linus already explained everything he
explains to me multiple times before. But this still does not get us
anywhere because it's just syzbot, so does not benefit anything else
and Linus will need to explain the same again and again...

> reports/requests, such as the ones that are clearly relevant and get continued
> discussion, vs. some random problem someone had 2 years ago.  Just putting stuff
> on a bug tracker does not magically make people work on it.
>
> I think the reality is that until people can actually be funded to immediately
> analyze every syzbot report, syzbot needs to be designed to help developers
> focus on the reports most likely to still be actual bugs.  That means
> automatically closing bugs where the crash is no longer occurring, especially if
> it was on linux-next; and sending reminders if the crash is still occurring.
> >
> > Also note that what happens now may be not representative of what will
> > happen in a steady mode later. Now syzbot bisects old bugs accumulated
> > over 1+ year. Later if it reports a bug, it should bisect sooner. So
> > all of what happens in this bug report won't take place.
> >
>
> Sure, but I think there will continue to be syzbot reports that the relevant
> people either don't see, or don't have time or expertise to look into.  This is
> especially true when the same bug is filed as many different bug reports.
>
> - Eric

