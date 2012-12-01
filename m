Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 6EFC16B004D
	for <linux-mm@kvack.org>; Sat,  1 Dec 2012 03:04:50 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so899078pad.14
        for <linux-mm@kvack.org>; Sat, 01 Dec 2012 00:04:49 -0800 (PST)
Date: Sat, 1 Dec 2012 00:01:31 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [RFC] Add mempressure cgroup
Message-ID: <20121201080131.GB21747@lizard.sbx14280.paloaca.wayport.net>
References: <20121128102908.GA15415@lizard>
 <20121128151432.3e29d830.akpm@linux-foundation.org>
 <20121129012751.GA20525@lizard>
 <20121130154725.0a81913c@doriath.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20121130154725.0a81913c@doriath.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, aquini@redhat.com, riel@redhat.com

Hi Luiz,

Thanks for your email!

On Fri, Nov 30, 2012 at 03:47:25PM -0200, Luiz Capitulino wrote:
[...]
> > But there is one, rather major issue: we're crossing kernel-userspace
> > boundary. And with the scheme we'll have to cross the boundary four times:
> > query / reply-available / control / reply-shrunk / (and repeat if
> > necessary, every SHRINK_BATCH pages). Plus, it has to be done somewhat
> > synchronously (all the four stages), and/or we have to make a "userspace
> > shrinker" thread working in parallel with the normal shrinker, and here,
> > I'm afraid, we'll see more strange interactions. :)
> 
> Wouldn't this be just like kswapd?

Sure, this is similar, but only for indirect reclaim (obviously).

How we'd do this for the direct reclaim I have no idea, honestly, with
Andrew's idea it must be all synchronous, so playing ping-pong with
userland during the direct reclaim will be hard.

So, the best thing to do with the direct recaim, IMHO, is just send a
notification.

> > But there is a good news: for these kind of fine-grained control we have a
> > better interface, where we don't have to communicate [very often] w/ the
> > kernel. These are "volatile ranges", where userland itself marks chunks of
> > data as "I might need it, but I won't cry if you recycle it; but when I
> > access it next time, let me know if you actually recycled it". Yes,
> > userland no longer able to decide which exact page it permits to recycle,
> > but we don't have use-cases when we actually care that much. And if we do,
> > we'd rather introduce volatile LRUs with different priorities, or
> > something alike.
> 
> I'm new to this stuff so please take this with a grain of salt, but I'm
> not sure volatile ranges would be a good fit for our use case: we want to
> make (kvm) guests reduce their memory when the host is getting memory
> pressure.

Yes, for this kind of things you want a simple notification.

I wasn't saying that volatile ranges must be a substitute for
notifications, quite the opposite: I was saying that you can do volatile
ranges in userland by using "userland-shrinker".

It can be even wrapped into a library, with the same mmap() libc
interface. But it will be inefficient.

Thanks,
Anton.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
