Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id BB27B6B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 01:59:42 -0500 (EST)
Received: by mail-gg0-f178.google.com with SMTP id 21so68022ggh.23
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 22:59:41 -0800 (PST)
Date: Thu, 21 Feb 2013 22:55:52 -0800
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH v2] memcg: Add memory.pressure_level events
Message-ID: <20130222065552.GA26194@lizard.gateway.2wire.net>
References: <20130219044012.GA23356@lizard.sbx00618.mountca.wayport.net>
 <20130220001743.GE16950@blaptop>
 <CAOS58YOPjcH_pFFhPLJEAdaLkm5FoOy9mG2i-PkWAcb7O6V_Kw@mail.gmail.com>
 <20130221230425.GA22792@lizard.fhda.edu>
 <20130221235608.GH16950@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20130221235608.GH16950@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, Orna Agmon Ben-Yehuda <ladypine@gmail.com>, Muli Ben-Yehuda <mulix@mulix.org>

On Fri, Feb 22, 2013 at 08:56:08AM +0900, Minchan Kim wrote:
> [...] The my point is that you have a plan to support? Why I have a
> question is that you said your goal is to replace lowmemory killer

In short: yes, of course, if the non-memcg interface will be in demand.

> but android don't have enabled CONFIG_MEMCG as you know well
> so they should enable it for using just notifier? or they need another hack to
> connect notifier to global thing?

A hack is not an option for me. :-) My final goal is to switch Android to
use the notifier without need for hacks/external patches or
drivers/staging.

But my current goal is to make the most generic case work, and do this in
the most correct way. That is, vmpressure + MEMCG. Once I accomplish this,
I can then think of any niche needs (such as Android).

There will be two possibilities for Android:

1. Obviously, turn on CONFIG_MEMCG. We need to measure its effect on real
   devices, and see if it makes sense. (Plus, maybe there are other uses
   for MEMCG on Android?)

or

2. Implement /sys/fs/cgroups/memory/memory.pressure_level interface
   without MEMCG. Doing this will be really easy as we'll already have
   vmpressure() core, and Android has CROUPS=y. But I do expect some
   discussion like 'why don't you fix memcg instead?'. We'll have to
   answer this question by looking back at '1.'

Also note that cgroups vmpressure notifiers were tried by QEMU folks, and
it seemed to be useful:

   http://lists.gnu.org/archive/html/qemu-devel/2012-12/msg02821.html 

So, nowadays it is not only about Android. Some time ago I also got an
email from Orna Agmon Ben-Yehuda, who suggested to use vmpressure stuff
with 'memcached' (but I didn't find time to actually try it, so far. :(
Thanks for the email, btw!).

So it is useful with or without MEMCG, and if we will really need to
support vmpressure without MEMCG, I will have to implement the support in
addition to MEMCG case, yes.

Thanks,

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
