Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7096A6B0387
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 09:11:47 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id x4so9239964wme.3
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 06:11:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v103si10478691wrc.210.2017.02.24.06.11.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Feb 2017 06:11:46 -0800 (PST)
Date: Fri, 24 Feb 2017 15:11:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] staging, android: remove lowmemory killer from the tree
Message-ID: <20170224141144.GI19161@dhcp22.suse.cz>
References: <20170222120121.12601-1-mhocko@kernel.org>
 <CANcMJZBNe10dtK8ANtLSWS3UXeePhndN=S5otADhQdfQKOAhOw@mail.gmail.com>
 <CA+_MTtzj9z3JEH528iTjAuNivKo9tNzAx9dwpAJo6U5kgf636g@mail.gmail.com>
 <855e929a-a891-a435-8f75-3674d8a3e96d@sonymobile.com>
 <20170224122830.GG19161@dhcp22.suse.cz>
 <9ffdcc79-12d4-00c5-182c-498b8ca951cc@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9ffdcc79-12d4-00c5-182c-498b8ca951cc@sonymobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sonymobile.com>
Cc: Martijn Coenen <maco@google.com>, John Stultz <john.stultz@linaro.org>, Greg KH <gregkh@linuxfoundation.org>, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Riley Andrews <riandrews@android.com>, devel@driverdev.osuosl.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Todd Kjos <tkjos@google.com>, Android Kernel Team <kernel-team@android.com>, Rom Lemarchand <romlem@google.com>, Tim Murray <timmurray@google.com>

On Fri 24-02-17 14:16:34, peter enderborg wrote:
> On 02/24/2017 01:28 PM, Michal Hocko wrote:
[...]
> > Yeah, I strongly believe that the chosen approach is completely wrong.
> > Both in abusing the shrinker interface and abusing oom_score_adj as the
> > only criterion for the oom victim selection.
> 
> No one is arguing that shrinker is not problematic. And would be great
> if it is removed from lmk.  The oom_score_adj is the way user-space
> tells the kernel what the user-space has as prio. And android is using
> that very much. It's a core part.

Is there any documentation which describes how this is done?

> I have never seen it be used on
> other linux system so what is the intended usage of oom_score_adj? Is
> this really abusing?

oom_score_adj is used to _adjust_ the calculated oom score. It is not a
criterion on its own, well, except for the extreme sides of the range
which are defined to enforce resp. disallow selecting the task. The
global oom killer calculates the oom score as a function of the memory
consumption. Your patch simply ignores the memory consumption (and uses
pids to sort tasks with the same oom score which is just mind boggling)
and that is what I call the abuse. The oom score calculation might
change in future, of course, but all consumers of the oom_score_adj
really have to agree on the base which is adjusted by this tunable
otherwise you can see a lot of unexpected behavior.

I would even argue that nobody outside of mm/oom_kill.c should really
have any business with this tunable.  You can of course tweak the value
from the userspace and help to chose a better oom victim this way but
that is it.

Anyway, I guess we are getting quite off-topic here.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
