Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id F0A816B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 21:07:30 -0500 (EST)
Received: by werf1 with SMTP id f1so3292783wer.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 18:07:29 -0800 (PST)
Date: Wed, 21 Dec 2011 06:07:23 +0400
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: Android low memory killer vs. memory pressure notifications
Message-ID: <20111221020723.GA5214@oksana.dev.rtsoft.ru>
References: <20111219025328.GA26249@oksana.dev.rtsoft.ru>
 <20111219121255.GA2086@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1112191110060.19949@chino.kir.corp.google.com>
 <20111220145654.GA26881@oksana.dev.rtsoft.ru>
 <alpine.DEB.2.00.1112201322170.22077@chino.kir.corp.google.com>
 <20111221002853.GA11504@oksana.dev.rtsoft.ru>
 <4EF132EA.7000300@am.sony.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4EF132EA.7000300@am.sony.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frank Rowand <frank.rowand@am.sony.com>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Arve =?utf-8?B?SGrDuG5uZXbDpWc=?= <arve@android.com>, Rik van Riel <riel@redhat.com>, Pavel Machek <pavel@ucw.cz>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, John Stultz <john.stultz@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, tbird20d@gmail.com

On Tue, Dec 20, 2011 at 05:14:18PM -0800, Frank Rowand wrote:
[...]
> >>> Hm, assuming that metadata is no longer an issue, why do you think avoiding
> >>> cgroups would be a good idea?
> >>>
> >>
> >> It's helpful for certain end users, particularly those in the embedded 
> >> world, to be able to disable as many config options as possible to reduce 
> >> the size of kernel image as much as possible, so they'll want a minimal 
> >> amount of kernel functionality that allows such notifications.  Keep in 
> >> mind that CONFIG_CGROUP_MEM_RES_CTLR is not enabled by default because of 
> >> this (enabling it, CONFIG_RESOURCE_COUNTERS, and CONFIG_CGROUPS increases 
> >> the size of the kernel text by ~1%),
> > 
> > So for 2MB kernel that's about 20KB of an additional text... This seems
> > affordable, especially as a trade-off for the things that cgroups may
> > provide.
> 
> A comment from http://lkml.indiana.edu/hypermail/linux/kernel/1102.1/00412.html:
> 
> "I care about 5K. (But honestly, I don't actively hunt stuff less than
> 10K in size, because there's too many of them to chase, currently)."

I have just tried to turn off CGROUPS on my qemu test kernels:

$ diff -u cgroups no_cgroups 
    text           data     bss     dec     hex filename
-3869810         465976  565248 4901034  4ac8aa vmlinux
+3806374         460544  540672 4807590  495ba6 vmlinux

So, that's actually ~60KB. Which is serious. memcontrol.o text size
is about 23KB.

And my cgroups setup was just this:

$ cat .config | grep CGRO
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_CGROUP_MEM_RES_CTLR=y
# CONFIG_CGROUP_PERF is not set
# CONFIG_CGROUP_SCHED is not set
# CONFIG_BLK_CGROUP is not set

:-(

> > The fact is, for desktop and server Linux, cgroups slowly becomes a
> > mandatory thing. And the reason for this is that cgroups mechanism
> > provides some very useful features (in an extensible way, like plugins),
> > i.e. a way to manage and track processes and its resources -- which is the
> > main purpose of cgroups.
> 
> And for embedded and for real-time, some of us do not want cgroups to be
> a mandatory thing.  We want it to remain configurable.  My personal
> interest is in keeping the latency of certain critical paths (especially
> in the scheduler) short and consistent.

Much thanks for your input! That would be quite strong argument for going
with /dev/mem_notify approach. Do you have any specific numbers how cgroups
makes scheduler latencies worse?

Thanks!

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
