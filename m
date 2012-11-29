Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 9D8CF6B0089
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 20:31:12 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so10715577pbc.14
        for <linux-mm@kvack.org>; Wed, 28 Nov 2012 17:31:12 -0800 (PST)
Date: Wed, 28 Nov 2012 17:27:51 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [RFC] Add mempressure cgroup
Message-ID: <20121129012751.GA20525@lizard>
References: <20121128102908.GA15415@lizard>
 <20121128151432.3e29d830.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20121128151432.3e29d830.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Wed, Nov 28, 2012 at 03:14:32PM -0800, Andrew Morton wrote:
[...]
> Compare this with the shrink_slab() shrinkers.  With these, the VM can
> query and then control the clients.  If something goes wrong or is out
> of balance, it's the VM's problem to solve.
> 
> So I'm thinking that a better design would be one which puts the kernel
> VM in control of userspace scanning and freeing.  Presumably with a
> query-and-control interface similar to the slab shrinkers.

Thanks for the ideas, Andrew.

Query-and-control scheme looks very attractive, and that's actually
resembles my "balance" level idea, when userland tells the kernel how much
reclaimable memory it has. Except the your scheme works in the reverse
direction, i.e. the kernel becomes in charge.

But there is one, rather major issue: we're crossing kernel-userspace
boundary. And with the scheme we'll have to cross the boundary four times:
query / reply-available / control / reply-shrunk / (and repeat if
necessary, every SHRINK_BATCH pages). Plus, it has to be done somewhat
synchronously (all the four stages), and/or we have to make a "userspace
shrinker" thread working in parallel with the normal shrinker, and here,
I'm afraid, we'll see more strange interactions. :)

But there is a good news: for these kind of fine-grained control we have a
better interface, where we don't have to communicate [very often] w/ the
kernel. These are "volatile ranges", where userland itself marks chunks of
data as "I might need it, but I won't cry if you recycle it; but when I
access it next time, let me know if you actually recycled it". Yes,
userland no longer able to decide which exact page it permits to recycle,
but we don't have use-cases when we actually care that much. And if we do,
we'd rather introduce volatile LRUs with different priorities, or
something alike.

So, we really don't need the full-fledged userland shrinker, since we can
just let the in-kernel shrinker do its job. If we work with the
bytes/pages granularity it is just easier (and more efficient in terms of
communication) to do the volatile ranges.

For the pressure notifications use-cases, we don't even know bytes/pages
information: "activity managers" are separate processes looking after
overall system performance.

So, we're not trying to make userland too smart, quite the contrary: we
realized that for this interface we don't want to mess with the bytes and
pages, and that's why we cut this stuff down to only three levels. Before
this, we were actually trying to count bytes, we did not like it and we
ran away screaming.

OTOH, your scheme makes volatile ranges unneeded, since a thread might
register a shrinker hook and free stuff by itself. But again, I believe
this involves more communication with the kernel.

Thanks,
Anton.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
