Return-Path: <SRS0=dvGr=TS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A0F0C04AB4
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 01:33:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B6C621880
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 01:33:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="qUY01mlS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B6C621880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADC166B0006; Fri, 17 May 2019 21:33:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8B7B6B0008; Fri, 17 May 2019 21:33:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9544F6B000A; Fri, 17 May 2019 21:33:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 721216B0006
	for <linux-mm@kvack.org>; Fri, 17 May 2019 21:33:52 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id z7so8220841qtq.13
        for <linux-mm@kvack.org>; Fri, 17 May 2019 18:33:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=sX2gtiM1F/1BEzdGKla5dDrkWxKhhFTMd4O/Z6SAzBo=;
        b=hZQBTVeDa2b6whh9yxPr+WCDb0SBImJwfBT59ZuYs1lRbDImJIRiQQViw8zRkxBMQ9
         BoNTU2oUb4PWYoM2sF4kzqvzaww4FOSDS9XyyYrayAVmvTSB0LVimD7iyw1yMCjy2S/n
         rh4YHr0Sk8jrfoEp00cK0KO14RN9StP97GHHFW1nrf88hmuE9c0bzQjkB47ux4hox0ro
         lL6ouRGorkak1SVof/ICoR6nP4dLcaD0UQ+j5tdq1T8tkxGQkNuXgJ2sPpzSF/COXjT8
         aQSEbRYln4iux37mv3DhsMU2lrJ206yf5Neba9OxtQdHgub+GT5NQ0Je7N+GV51S6vDn
         Kxqg==
X-Gm-Message-State: APjAAAUMSCl2YLhR7fRxxwbDVCRP+J3/j7b6qTkbgqIMqU+HlqX71iYK
	qRKSC//FdKQ1iT6YMUhD9hJfB5UhY7a9eybyrUNxt+7La4EfpBwM6b4loAR1h/Y1X2LcWnzo6cN
	LxUJghN4P1aoUZg5lSZFAmTXVGcbpiQRDiWxiFDhh8wsiMMN68Bio0FVVbP8Xg2LdNg==
X-Received: by 2002:a0c:ff0c:: with SMTP id w12mr41490859qvt.28.1558143232165;
        Fri, 17 May 2019 18:33:52 -0700 (PDT)
X-Received: by 2002:a0c:ff0c:: with SMTP id w12mr41490819qvt.28.1558143231206;
        Fri, 17 May 2019 18:33:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558143231; cv=none;
        d=google.com; s=arc-20160816;
        b=eRxU3FBNASqJ/DIecq6/QYVwMrGR5IkuMg2VyIgzWAUzQ+OT7X5ruZqXPgnheNYlBM
         aUH4FGPO5ES1vL/qC6j6hMb/BhjFnV5KPMYLAaEMSEYOWHZabce3OYw+lEyaMppzHlEH
         Bz7q4pkFgh8qx6wPP3T23yxzdcvcIuP/ipMLDdx6NCc8EUcji6VnhUeKEqYgoAgf+blj
         FCHq+waktcavXT8XkBEx4VIWwT2wnxI3gpXJ7LmIG/cdFzPjX8ws6CNlIJmqkmwLxTEq
         qyD9H/6G3VbyLsJCPGmONljJSDneG9KQy88Nd/8kqCK6hfnPtZ1E2JaKugnhkyXf4Ssk
         1U0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=sX2gtiM1F/1BEzdGKla5dDrkWxKhhFTMd4O/Z6SAzBo=;
        b=OmSm0TMbugITxkgD5tXkjiTcCEty1x8oQj1njfA+M7U7S6KrF0eoOE6C6Zro8L/hiM
         vRqzzxehPTttGMQuF0aA0txuUDrsXHHf7JNiqNlTL1PZMJaRZS7T3FV1wfJiZFv8IZKu
         hPC5GZjYpgJp0ctzfavosHHBzcbIFWg6BVkWDyLm2Fw80MOy43h2LLmkWihw5To9fUIZ
         AO+rVVZO1CzzG6kSnOis4jhGAJt9U7A9nxId1bRh0cAEapM8190WbcXOuR68TxsUL3X+
         YfxeEzeJpajQTzSeunXqNAtVkI2ATR8UhrU9e86lDnt4mKzZAO3bi/2ZwMNoEf6jtM4Q
         jXZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=qUY01mlS;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z27sor4784129qkg.35.2019.05.17.18.33.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 18:33:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=qUY01mlS;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=sX2gtiM1F/1BEzdGKla5dDrkWxKhhFTMd4O/Z6SAzBo=;
        b=qUY01mlSmX4DbsPDMJaYgJn3Q/drbMkfzs7GJn39QrYDuj43qSb92iwS/7+dfV4fsA
         0E8GL5YXkNLl9QevERwZcDsUAahh7V23GHEc/jHP/nvE1FZj5aNfpsurZLUN4ZiGXEJ/
         kEGUkzJ+KOKblkBelAf19+5XJ3k0XULDRxrpj2mX4ZCwtT2ZBYUMR0dBeAsyWuZJQaWX
         7G4Sw6HuNpB8ZG8ZF69Ylb2U1935CrzrJkcIIgF0d3O/0dSo/MsxvOblfCa25GbkuF5l
         FtduQ6ojspDQKSXBdEZqZ/+4SZgnNdMSP3FQ17kAMAVk3BPNG8wNhbPTRYDyYt+rrFxq
         Z90w==
X-Google-Smtp-Source: APXvYqwf0oihuMDsTfVgR6ZJ1VQoL7rw3UIuUWL4s1dxZcgaqafC88Kcarb02I8LUJo8ZbVVwPDEsQ==
X-Received: by 2002:a05:620a:1232:: with SMTP id v18mr48607219qkj.27.1558143230592;
        Fri, 17 May 2019 18:33:50 -0700 (PDT)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id z29sm5166322qkg.19.2019.05.17.18.33.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 17 May 2019 18:33:49 -0700 (PDT)
Date: Fri, 17 May 2019 21:33:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, tj@kernel.org,
	guro@fb.com, dennis@kernel.org, chris@chrisdown.name,
	cgroups mailinglist <cgroups@vger.kernel.org>, linux-mm@kvack.org
Subject: Re: + mm-consider-subtrees-in-memoryevents.patch added to -mm tree
Message-ID: <20190518013348.GA6655@cmpxchg.org>
References: <20190212224542.ZW63a%akpm@linux-foundation.org>
 <20190213124729.GI4525@dhcp22.suse.cz>
 <20190516175655.GA25818@cmpxchg.org>
 <20190516180932.GA13208@dhcp22.suse.cz>
 <20190516193943.GA26439@cmpxchg.org>
 <20190517123310.GI6836@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190517123310.GI6836@dhcp22.suse.cz>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 02:33:10PM +0200, Michal Hocko wrote:
> On Thu 16-05-19 15:39:43, Johannes Weiner wrote:
> > On Thu, May 16, 2019 at 08:10:42PM +0200, Michal Hocko wrote:
> > > On Thu 16-05-19 13:56:55, Johannes Weiner wrote:
> > > > On Wed, Feb 13, 2019 at 01:47:29PM +0100, Michal Hocko wrote:
> [...]
> > > > > FTR: As I've already said here [1] I can live with this change as long
> > > > > as there is a larger consensus among cgroup v2 users. So let's give this
> > > > > some more time before merging to see whether there is such a consensus.
> > > > > 
> > > > > [1] http://lkml.kernel.org/r/20190201102515.GK11599@dhcp22.suse.cz
> > > > 
> > > > It's been three months without any objections.
> > > 
> > > It's been three months without any _feedback_ from anybody. It might
> > > very well be true that people just do not read these emails or do not
> > > care one way or another.
> > 
> > This is exactly the type of stuff that Mel was talking about at LSFMM
> > not even two weeks ago. How one objection, however absurd, can cause
> > "controversy" and block an effort to address a mistake we have made in
> > the past that is now actively causing problems for real users.
> > 
> > And now after stalling this fix for three months to wait for unlikely
> > objections, you're moving the goal post. This is frustrating.
> 
> I see your frustration but I find the above wording really unfair. Let me
> remind you that this is a considerable user visible change in the
> semantic and that always has to be evaluated carefuly. A change that would
> clearly regress anybody who rely on the current semantic. This is not an
> internal implementation detail kinda thing.
> 
> I have suggested an option for the new behavior to be opt-in which
> would be a regression safe option. You keep insisting that we absolutely
> have to have hierarchical reporting by default for consistency reasons.
> I do understand that argument but when I weigh consistency vs. potential
> regression risk I rather go a conservative way. This is a traditional
> way how we deal with semantic changes like this. There are always
> exceptions possible and that is why I wanted to hear from other users of
> cgroup v2, even from those who are not directly affected now.

I have acknowledged this concern in previous discussions. But the rule
is "don't break userspace", not "never change behavior". We do allow
the latter when it's highly unlikely that anyone would mind and the
new behavior is a much better default for current and future users.

Let me try to make the case for exactly this:

- Adoption data suggests that cgroup2 isn't really used yet. RHEL8 was
  just released with cgroup1 per default. Fedora is currently debating
  a switch. None of the other distros default to cgroup2. There is an
  article on the lwn frontpage *right now* about Docker planning on
  switching to cgroup2 in the near future. Kubernetes is on
  cgroup1. Android is on cgroup1. Shakeel agrees that Facebook is
  probably the only serious user of cgroup2 right now. The cloud and
  all mainstream container software is still on cgroup1.

- Using this particular part of the interface is a fairly advanced
  step in the cgroup2 adoption process. We've been using cgroup2 for a
  while and we've only now started running into this memory.events
  problem as we're enhancing our monitoring and automation
  infrastructure. If we're the only serious deployment, and we just
  started noticing it, what's the chance of regressing someone else?

- Violating expectations costs users time and money either way, but
  the status quo is much more costly: somebody who expects these
  events to be local could see events that did occur at an
  unexpectedly higher level of the tree. But somebody who expects
  these events to be hierarchical will miss real events entirely!

  Now, for an alarm and monitoring infrastructure, what is worse: to
  see occurring OOM kills reported at a tree level you don't expect?
  Or to *miss* occurring OOM kills that you're trying to look out for?

  Automatic remediation might not be as clear-cut, but for us, and I
  would assume many others, an unnecessary service restart or failover
  would have a shorter downtime than missing a restart after a kill.

- The status quo is more likely to violate expectations, given how the
  cgroup2 interface as a whole is designed.

  We have seen this in practice: memory.current is hierarchical,
  memory.stat is hierarchical, memory.pressure is hierarchical - users
  expect memory.events to be hierarchical. This misunderstanding has
  already cost us time and money.

  Chances are, even if there were other users of memory.events, that
  they're using the interface incorrectly and haven't noticed yet,
  rather than relying on the inconsistency.

  It's not a hypothetical, we have seen this with our fleet customers.

So combining what we know about

1. the current adoption rate
2. likely user expectations
3. the failure mode of missing pressure and OOM kill signals

means that going with the conservative option and not fixing this
inconsistency puts pretty much all users that will ever use this
interface at the risk of pain, outages and wasted engineering hours.

Making the fix available but opt-in has the same result for everybody
that isn't following this thread/patch along.

All that to protect an unlikely existing cgroup2 user from something
they are even less likely have noticed, let alone rely on.

This sounds like a terrible trade-off to me. I don't think it's a
close call in this case.

I understand that we have to think harder and be more careful with
changes like this. The bar *should* be high. But in this case, there
doesn't seem to be a real risk of regression for anybody, while the
risk of the status quo causing problems is high and happening. These
circumstances should be part of the decision process.

