Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 0452D6B002B
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 22:21:16 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so515413dad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 19:21:16 -0800 (PST)
Date: Wed, 14 Nov 2012 19:21:14 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
In-Reply-To: <20121107114321.GA32265@shutemov.name>
Message-ID: <alpine.DEB.2.00.1211141910050.14414@chino.kir.corp.google.com>
References: <20121107105348.GA25549@lizard> <20121107112136.GA31715@shutemov.name> <CAOJsxLHY+3ZzGuGX=4o1pLfhRqjkKaEMyhX0ejB5nVrDvOWXNA@mail.gmail.com> <20121107114321.GA32265@shutemov.name>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Pekka Enberg <penberg@kernel.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Wed, 7 Nov 2012, Kirill A. Shutemov wrote:

> > > Sorry, I didn't follow previous discussion on this, but could you
> > > explain what's wrong with memory notifications from memcg?
> > > As I can see you can get pretty similar functionality using memory
> > > thresholds on the root cgroup. What's the point?
> > 
> > Why should you be required to use cgroups to get VM pressure events to
> > userspace?
> 
> Valid point. But in fact you have it on most systems anyway.
> 
> I personally don't like to have a syscall per small feature.
> Isn't it better to have a file-based interface which can be used with
> normal file syscalls: open()/read()/poll()?
> 

I agree that eventfd is the way to go, but I'll also add that this feature 
seems to be implemented at a far too coarse of level.  Memory, and hence 
memory pressure, is constrained by several factors other than just the 
amount of physical RAM which vmpressure_fd is addressing.  What about 
memory pressure caused by cpusets or mempolicies?  (Memcg has its own 
reclaim logic and its own memory thresholds implemented on top of eventfd 
that people already use.)  These both cause high levels of reclaim within 
the page allocator whereas there may be an abundance of free memory 
available on the system.

I don't think we want several implementations of memory pressure 
notifications, so a more generic and flexible interface is going to be 
needed and I think it can't be done in an extendable way through this 
vmpressure_fd syscall.  Unfortunately, I think that means polling on a 
per-thread notifier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
