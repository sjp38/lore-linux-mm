Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 662866B006C
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 18:14:34 -0500 (EST)
Date: Wed, 28 Nov 2012 15:14:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] Add mempressure cgroup
Message-Id: <20121128151432.3e29d830.akpm@linux-foundation.org>
In-Reply-To: <20121128102908.GA15415@lizard>
References: <20121128102908.GA15415@lizard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Wed, 28 Nov 2012 02:29:08 -0800
Anton Vorontsov <anton.vorontsov@linaro.org> wrote:

> The main characteristics are the same to what I've tried to add to vmevent
> API:
> 
>   Internally, it uses Mel Gorman's idea of scanned/reclaimed ratio for
>   pressure index calculation. But we don't expose the index to the
>   userland. Instead, there are three levels of the pressure:
> 
>   o low (just reclaiming, e.g. caches are draining);
>   o medium (allocation cost becomes high, e.g. swapping);
>   o oom (about to oom very soon).
> 
>   The rationale behind exposing levels and not the raw pressure index
>   described here: http://lkml.org/lkml/2012/11/16/675

This rationale is central to the overall design (and is hence central
to the review).  It would be better to include it in the changelogs
where it can be maintained, understood and discussed.


I see a problem with it:


It blurs the question of "who is in control".  We tell userspace "hey,
we're getting a bit tight here, please do something".  And userspace
makes the decision about what "something" is.  So userspace is in
control of part of the reclaim function and the kernel is in control of
another part.  Strange interactions are likely.

Also, the system as a whole is untestable by kernel developers - it
puts the onus onto each and every userspace developer to develop, test
and tune his application against a particular kernel version.

And the more carefully the userspace developer tunes his application,
the more vulnerable he becomes to regressions which were caused by
subtle changes in the kernel's behaviour.


Compare this with the shrink_slab() shrinkers.  With these, the VM can
query and then control the clients.  If something goes wrong or is out
of balance, it's the VM's problem to solve.

So I'm thinking that a better design would be one which puts the kernel
VM in control of userspace scanning and freeing.  Presumably with a
query-and-control interface similar to the slab shrinkers.

IOW, we make the kernel smarter and make userspace dumber.  Userspace
just sits there and does what the kernel tells it to do.

This gives the kernel developers the ability to tune and tweak (ie:
alter) userspace's behaviour *years* after that userspace code was
written.

Probably most significantly, this approach has a really big advantage:
we can test it.  Once we have defined that userspace query/control
interface we can write a compliant userspace test application then fire
it up and observe the overall system behaviour.  We can fix bugs and we
can tune it.  This cannot be done with your proposed interface because
we just don't know what userspace will do in response to changes in the
exposed metric.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
