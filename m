Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AF82C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 06:49:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44FA120651
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 06:49:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44FA120651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C47BD6B000C; Fri, 12 Apr 2019 02:49:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF71C6B0010; Fri, 12 Apr 2019 02:49:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABF536B0266; Fri, 12 Apr 2019 02:49:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C3266B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 02:49:30 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w27so4396808edb.13
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 23:49:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vcC0p1eYOkRoPCvdhVvwcnSkYONL/aPAGugJOllM2GU=;
        b=fJ0bNisKZjW9a7pxK/Xm6PbMs94svHRJPzo5gDh61ZUBAdPIu8T1Zu+8GlRQvC6IYK
         GRi89Itho3EaaWs2UaoxY34bdlK9+HEGIwFYDGksxj9oSlWkaT29ubSTwgJqh6WhNnfv
         +yaotx5kkoQabwuCCOqm73N1xNRhR845IQI7IUO8g67dvlepbq6ccvI04HamVBVspvWv
         WV418KbqY4406Wc/wJmzIFX0fepBD4VZSdndKtYkbu5+7UKLHrkQ4eUk2qT+Pn74SKIL
         gMwIT/N2Mt0svKhSNkyKk/zsOlDebomxnJmAMa1JOd3QbxvnsH3aDZcGrOdu3tHmuHMg
         XM7w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUR/f954fyf0HeSlaHRY+MTh0Ef1uRCf/f0UGSgtLCXknWfeTHj
	L5q9Z1IIi05rWQGukmrV+4OD4vvNwjzETr3uyCl4MKb1CentyNR5qU6v16Q2XALiPmHwTBhV9lU
	xCdCum739gc0uzk+E8Gf7bNFlYXFhK1aH1nKIEJRQeTovVKZs80O9B3syfdagwn0=
X-Received: by 2002:a17:906:e202:: with SMTP id gf2mr29256040ejb.55.1555051769880;
        Thu, 11 Apr 2019 23:49:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxiK4e/t8XWmI9wAuYCny3wuevgZdH+Dypwfgo9HU6KXiyvc9lnmLbLqg/oLBgI0fgftCBH
X-Received: by 2002:a17:906:e202:: with SMTP id gf2mr29255993ejb.55.1555051768882;
        Thu, 11 Apr 2019 23:49:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555051768; cv=none;
        d=google.com; s=arc-20160816;
        b=s1FS8opjrYfPL8yRT74TryksCr2t6MJa25YJriwSHXtwq1gkLviBtlnRnwGH6nkfqC
         +OKnV/x+5CLD/aL+c9xESzBw3f2wBJTeE7yxHnwd5bfBedJl0/gmSX/XyN3PH//0YH9d
         5qdl4LMIn+a4LT0k7kH/3EQ4cQHhdxqG446hj5DUg7rzosTe29EQsmSmcRHi0cSjftAD
         DxiWFFYKg8GU8q74WY3I6u93I7FeY2C4B6z0Fk8ZRCM0YcMCG6lKXU945qiRTQ/l6A4D
         G/C4gnFhMuuXnLxx9G1pK+uWaeh14qB0VAZ6IUWhUIsklyQHPBMZ43L9pv8sLM17SxJw
         Ysew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vcC0p1eYOkRoPCvdhVvwcnSkYONL/aPAGugJOllM2GU=;
        b=mi8qJ2C0YodnUX5ENCR5U9MpNRCXTh8xJwBpvMFDfHlyQAbxyDhoCCJ4R03xbDbS2w
         8hCVFB1/KBbOpcWH4GJAJ6OrQxeGduhVW7R6NW9DJnziDm42aKDYPP4BhlMNlf7jRsOJ
         2rVpdigpGygwzR5sLmzDyGvKgGGNep6Ez8m5L04IASmki+ygxoJ5iL5DNReFYqQgJ55o
         yB3Yd6DPCfIELgFNdgiEnZZ479mXpmwigvxwsixanOyUaj6KnjMbI4xRBq1796UjMqnt
         OLMgFhx04wgBE387I0tKWg8QdLPybHbK9Epttdap2zOOOmfA01by0gCCFwl1q8LtDqH5
         e6ag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y23si5890712ejo.107.2019.04.11.23.49.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 23:49:28 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BB344ADD9;
	Fri, 12 Apr 2019 06:49:27 +0000 (UTC)
Date: Fri, 12 Apr 2019 08:49:25 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Daniel Colascione <dancol@google.com>
Cc: Matthew Wilcox <willy@infradead.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>, yuzhoujian@didichuxing.com,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Shakeel Butt <shakeelb@google.com>,
	Christian Brauner <christian@brauner.io>,
	Minchan Kim <minchan@kernel.org>, Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Jann Horn <jannh@google.com>, linux-mm <linux-mm@kvack.org>,
	lsf-pc@lists.linux-foundation.org,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-team <kernel-team@android.com>
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
Message-ID: <20190412064925.GB13373@dhcp22.suse.cz>
References: <20190411014353.113252-1-surenb@google.com>
 <20190411014353.113252-3-surenb@google.com>
 <20190411153313.GE22763@bombadil.infradead.org>
 <CAJuCfpGQ8c-OCws-zxZyqKGy1CfZpjxDKMH__qAm5FFXBcnWOw@mail.gmail.com>
 <CAKOZuetFU4tXE27bxA86zzDfNSCbw83p8fPxfkQ_d_Em0C04Sg@mail.gmail.com>
 <20190411173649.GF22763@bombadil.infradead.org>
 <CAKOZuet8-en+tMYu_QqVCxmkak44T7MnmRgfJBot0+P_A+Qzkw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuet8-en+tMYu_QqVCxmkak44T7MnmRgfJBot0+P_A+Qzkw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-04-19 10:47:50, Daniel Colascione wrote:
> On Thu, Apr 11, 2019 at 10:36 AM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > On Thu, Apr 11, 2019 at 10:33:32AM -0700, Daniel Colascione wrote:
> > > On Thu, Apr 11, 2019 at 10:09 AM Suren Baghdasaryan <surenb@google.com> wrote:
> > > > On Thu, Apr 11, 2019 at 8:33 AM Matthew Wilcox <willy@infradead.org> wrote:
> > > > >
> > > > > On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> > > > > > Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> > > > > > pidfd_send_signal() syscall to allow expedited memory reclaim of the
> > > > > > victim process. The usage of this flag is currently limited to SIGKILL
> > > > > > signal and only to privileged users.
> > > > >
> > > > > What is the downside of doing expedited memory reclaim?  ie why not do it
> > > > > every time a process is going to die?
> > > >
> > > > I think with an implementation that does not use/abuse oom-reaper
> > > > thread this could be done for any kill. As I mentioned oom-reaper is a
> > > > limited resource which has access to memory reserves and should not be
> > > > abused in the way I do in this reference implementation.
> > > > While there might be downsides that I don't know of, I'm not sure it's
> > > > required to hurry every kill's memory reclaim. I think there are cases
> > > > when resource deallocation is critical, for example when we kill to
> > > > relieve resource shortage and there are kills when reclaim speed is
> > > > not essential. It would be great if we can identify urgent cases
> > > > without userspace hints, so I'm open to suggestions that do not
> > > > involve additional flags.
> > >
> > > I was imagining a PI-ish approach where we'd reap in case an RT
> > > process was waiting on the death of some other process. I'd still
> > > prefer the API I proposed in the other message because it gets the
> > > kernel out of the business of deciding what the right signal is. I'm a
> > > huge believer in "mechanism, not policy".
> >
> > It's not a question of the kernel deciding what the right signal is.
> > The kernel knows whether a signal is fatal to a particular process or not.
> > The question is whether the killing process should do the work of reaping
> > the dying process's resources sometimes, always or never.  Currently,
> > that is never (the process reaps its own resources); Suren is suggesting
> > sometimes, and I'm asking "Why not always?"
> 
> FWIW, Suren's initial proposal is that the oom_reaper kthread do the
> reaping, not the process sending the kill. Are you suggesting that
> sending SIGKILL should spend a while in signal delivery reaping pages
> before returning? I thought about just doing it this way, but I didn't
> like the idea: it'd slow down mass-killing programs like killall(1).
> Programs expect sending SIGKILL to be a fast operation that returns
> immediately.

I was thinking about this as well. And SYNC_SIGKILL would workaround the
current expectations of how quick the current implementation is. The
harder part would what is the actual semantic. Does the kill wait until
the target task is TASK_DEAD or is there an intermediate step that would
we could call it end of the day and still have a reasonable semantic
(e.g. the original pid is really not alive anymore).
-- 
Michal Hocko
SUSE Labs

