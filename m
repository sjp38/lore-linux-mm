Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 9ACF26B00D4
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 12:47:36 -0500 (EST)
Date: Fri, 30 Nov 2012 15:47:25 -0200
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [RFC] Add mempressure cgroup
Message-ID: <20121130154725.0a81913c@doriath.home>
In-Reply-To: <20121129012751.GA20525@lizard>
References: <20121128102908.GA15415@lizard>
	<20121128151432.3e29d830.akpm@linux-foundation.org>
	<20121129012751.GA20525@lizard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, aquini@redhat.com, riel@redhat.com

On Wed, 28 Nov 2012 17:27:51 -0800
Anton Vorontsov <anton.vorontsov@linaro.org> wrote:

> On Wed, Nov 28, 2012 at 03:14:32PM -0800, Andrew Morton wrote:
> [...]
> > Compare this with the shrink_slab() shrinkers.  With these, the VM can
> > query and then control the clients.  If something goes wrong or is out
> > of balance, it's the VM's problem to solve.
> > 
> > So I'm thinking that a better design would be one which puts the kernel
> > VM in control of userspace scanning and freeing.  Presumably with a
> > query-and-control interface similar to the slab shrinkers.
> 
> Thanks for the ideas, Andrew.
> 
> Query-and-control scheme looks very attractive, and that's actually
> resembles my "balance" level idea, when userland tells the kernel how much
> reclaimable memory it has. Except the your scheme works in the reverse
> direction, i.e. the kernel becomes in charge.
> 
> But there is one, rather major issue: we're crossing kernel-userspace
> boundary. And with the scheme we'll have to cross the boundary four times:
> query / reply-available / control / reply-shrunk / (and repeat if
> necessary, every SHRINK_BATCH pages). Plus, it has to be done somewhat
> synchronously (all the four stages), and/or we have to make a "userspace
> shrinker" thread working in parallel with the normal shrinker, and here,
> I'm afraid, we'll see more strange interactions. :)

Wouldn't this be just like kswapd?

> But there is a good news: for these kind of fine-grained control we have a
> better interface, where we don't have to communicate [very often] w/ the
> kernel. These are "volatile ranges", where userland itself marks chunks of
> data as "I might need it, but I won't cry if you recycle it; but when I
> access it next time, let me know if you actually recycled it". Yes,
> userland no longer able to decide which exact page it permits to recycle,
> but we don't have use-cases when we actually care that much. And if we do,
> we'd rather introduce volatile LRUs with different priorities, or
> something alike.

I'm new to this stuff so please take this with a grain of salt, but I'm
not sure volatile ranges would be a good fit for our use case: we want to
make (kvm) guests reduce their memory when the host is getting memory
pressure.

Having a notification seems just fine for this purpose, but I'm not sure
how this would work with volatile ranges, as we'd have to mark pages volatile
in advance.

Andrew's idea seems to give a lot more freedom to apps, IMHO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
