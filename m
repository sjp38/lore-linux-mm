Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id ACF186B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 18:33:17 -0500 (EST)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id oA9NXEwO017697
	for <linux-mm@kvack.org>; Tue, 9 Nov 2010 15:33:14 -0800
Received: from pxi16 (pxi16.prod.google.com [10.243.27.16])
	by wpaz13.hot.corp.google.com with ESMTP id oA9NWe8e029443
	for <linux-mm@kvack.org>; Tue, 9 Nov 2010 15:33:12 -0800
Received: by pxi16 with SMTP id 16so4600pxi.32
        for <linux-mm@kvack.org>; Tue, 09 Nov 2010 15:33:10 -0800 (PST)
Date: Tue, 9 Nov 2010 15:33:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [resend][PATCH 2/4] Revert "oom: deprecate oom_adj tunable"
In-Reply-To: <20101109105801.BC30.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1011091523370.26837@chino.kir.corp.google.com>
References: <20101101030353.607A.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011011232120.6822@chino.kir.corp.google.com> <20101109105801.BC30.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Nov 2010, KOSAKI Motohiro wrote:

> > > > The new tunable added in 2.6.36, /proc/pid/oom_score_adj, is necessary for 
> > > > the units that the badness score now uses.  We need a tunable with a much 
> > > 
> > > Who we?
> > > 
> > 
> > Linux users who care about prioritizing tasks for oom kill with a tunable 
> > that (1) has a unit, (2) has a higher resolution, and (3) is linear and 
> > not exponential.  
> 
> No. Majority user don't care. You only talk about your case. Don't ignore
> end user.
> 

If they don't care, then they won't be using oom_adj, so you're point 
about it's deprecation is irrelevant.

Other users do want a more powerful userspace interface with a unit and 
higher resolution (I am one of them), there's no requirement that those 
users need to be in the majority.

> > Memcg doesn't solve this issue without incurring a 1% 
> > memory cost.
> 
> Look at a real.
> All major distributions has already turn on memcg. End user don't need
> to pay additional cost.
> 

Memcg also has a command-line disabling option to avoid incurring this 1% 
memory cost when you're not going to be using it.

> > No, it doesn't, and you completely and utterly failed to show a single 
> > usecase that broke as a result of this because nobody can currently use 
> > oom_adj for anything other than polarization.  Thus, there's no backwards 
> > compatibility issue.
> 
> No. I showed. 
> 1) Google code search showed some application are using this feature.
> 	http://www.google.com/codesearch?as_q=oom_adj&btnG=Search+Code&hl=ja&as_package=&as_lang=&as_filename=&as_class=&as_function=&as_license=&as_case=
> 

oom_adj isn't removed, it's deprecated.  These users are using a 
deprecated interface and have a few years to convert to using the new 
interface (if it ever is actually removed).

> 2) Not body use oom_adj other than polarization even though there are a few.
>    example, kde are using.
> 	http://www.google.com/codesearch/p?hl=ja#MPJuLvSvNYM/pub/kde/unstable/snapshots/kdelibs.tar.bz2%7CWClmGVN5niU/kdelibs-1164923/kinit/start_kdeinit.c&q=oom_adj%20kde%205
> 
> When you are talking polarization issue, you blind a real. Don't talk your dream.
> 

I don't understand what you're trying to say here, but the current users 
of oom_adj that aren't +15 or -16 (or OOM_DISABLE) are arbitrary based 
relative to other tasks such as +5, +10, etc.  They don't have any 
semantics other than being arbitrarily relative because it doesn't work in 
a linear way or with a scale.

> 3) udev are using this feature. It's one of major linux component and you broke.
> 
> http://www.google.com/codesearch/p?hl=ja#KVTjzuVpblQ/pub/linux/utils/kernel/hotplug/udev-072.tar.bz2%7CwUSE-Ay3lLI/udev-072/udevd.c&q=oom_adj
> 
> You don't have to break our userland. you can't rewrite or deprecate 
> old one. It's used! You can only add orthogonal new knob.
> 

That's incorrect, I didn't break anything by deprecating a tunable for a 
few years.  oom_adj gets converted roughly into an equivalent (but linear) 
oom_score_adj.

Unfortunately for your argument, you can't show a single example of a 
current oom_adj user that has a scientific calculation behind its value 
that is now broken on the linear scale.

> > Yes, I've tested it, and it deprecates the tunable as expected.  A single 
> > warning message serves the purpose well: let users know one time without 
> > being overly verbose that the tunable is deprecated and give them 
> > sufficient time (2 years) to start using the new tunable.  That's how 
> > deprecation is done.
> 
> no sense.
> 
> Why do their application need to rewrite for *YOU*? Okey, you will got
> benefit from your new knob. But NOBDOY use the new one. and People need
> to rewrite their application even though no benefit. 
> 
> Don't do selfish userland breakage!
> 

It's deprecated for a few years so users can gradually convert to the new 
tunable, it wasn't removed when the new one was introduced.  A higher 
resolution tunable that scales linearly with a unit is an advantage for 
Linux (for the minority of users who care about oom killing priority 
beyond the heuristic) and I think a few years is enough time for users to 
do a simple conversion to the new tunable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
