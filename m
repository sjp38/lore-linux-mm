Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id E18A46B008A
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 09:54:44 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id j5so8903553qga.14
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 06:54:44 -0700 (PDT)
Received: from mail-qc0-x22a.google.com (mail-qc0-x22a.google.com [2607:f8b0:400d:c01::22a])
        by mx.google.com with ESMTPS id h7si23810556qan.34.2014.06.09.06.54.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 06:54:44 -0700 (PDT)
Received: by mail-qc0-f170.google.com with SMTP id l6so677452qcy.29
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 06:54:44 -0700 (PDT)
Date: Mon, 9 Jun 2014 09:54:41 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] memcg: Allow hard guarantee mode for low limit
 reclaim
Message-ID: <20140609135441.GA22540@htj.dyndns.org>
References: <20140606144421.GE26253@dhcp22.suse.cz>
 <1402066010-25901-1-git-send-email-mhocko@suse.cz>
 <1402066010-25901-2-git-send-email-mhocko@suse.cz>
 <20140606152914.GA14001@htj.dyndns.org>
 <20140609083042.GB7144@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140609083042.GB7144@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hello,

On Mon, Jun 09, 2014 at 10:30:42AM +0200, Michal Hocko wrote:
> On Fri 06-06-14 11:29:14, Tejun Heo wrote:
> > Why is this necessary?
> 
> It allows user/admin to set the default behavior.

By recomipling the kernel for something which can be trivially
configured post-boot without any difference?  The only thing it'll
achieve is confusing the hell out of people why different kernels show
different behaviors without any userland differences while taxing the
already constrained kernel configuration process more for no gain
whatsoever.

> How do you propose to tell the default then? Only at the runtime?
> I really do not insist on the kconfig. I find it useful for a)
> documentation purpose b) easy way to configure the default.

Please don't ever add Kconfig options like this.  This is uttrely
unnecessary and idiotic.  You don't add completely redundant Kconfig
option for documentation purposes.

> > * Are you sure soft and hard guarantees aren't useful when used in
> >   combination?  If so, why would that be the case?
> 
> This was a call from Google to have per-memcg setup AFAIR. Using
> different reclaim protection on the global case vs. limit reclaim makes
> a lot of sense to me. If this is a major obstacle then I am OK to drop
> it and only have a global setting for now.

Isn't it obvious that what needs to be investigated is why we're
trying to add an interface which is completely different for
guarantees as compared to limits?  Why wouldn't they have a symmetric
interface in the reverse direction as soft/hard limits?  If not, where
does the asymmetry come from?  Thse are the *first* questions which
should come to anyone's mind when [s]he is trying to add configs for a
different type of threshholds and something which must be explicitly
laid out as rationales for the design choices.

> > * We have pressure monitoring interface which can be used for soft
> >   limit pressure monitoring. 
> 
> Which one is that? I only know about oom_control triggered by the hard
> limit pressure.

Weren't you guys planning to use vmpressre notification to find out
about softlimit breach conditions?

> >   How should breaching soft guarantee be
> >   factored into that?  There doesn't seem to be any way of notifying
> >   that at the moment?  Wouldn't we want that to be integrated into the
> >   same mechanism?
> 
> Yes, there is. We have a counter in memory.stat file which tells how
> many times the limit has been breached.

How does the userland find out?  By polling the file every frigging
second?  Note that there actually is an actual asymmetry here which
makes breaching soft guarantee a much more significant event than
breaching soft limit - the former is violation of the configured
objective, the latter is not.  You *need* a way to notify the event.

> > What scares me the most is that you don't even seem to have noticed
> > the asymmetry and are proposing userland-facing interface without
> > actually thinking things through.  This is exactly how we've been
> > getting into trouble.
> 
> This has been discussed up and down for the last _two_ years. I have
> considered other options how to provide a very _useful_ feature users
> are calling for. There is even general consensus among developers that

AFAIR, there hasn't been much discussion about the details of the
interface and the proposed one is almost laughable.  How is this
acceptable as a userland visible API that we need to maintain for the
future?  It's broken on delivery.

> the feature is desirable and that the two modes (soft/hard) memory
> protection are needed. Yet I would _really_ like to hear any
> suggestion to get unstuck. It is far from useful to come and Nack this
> _again_ without providing any alternative suggestions.

I've pointed out two major points where the proposed interface is
evidently deficient and told you why they're so and it's not like the
said deficiencies are anything subtle.  If you can't figure out what
to do next from there on, I don't think I can help you.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
