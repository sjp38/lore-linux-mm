Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 048916B0032
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 13:09:20 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id bi5so2659128pad.18
        for <linux-mm@kvack.org>; Fri, 28 Jun 2013 10:09:20 -0700 (PDT)
Date: Fri, 28 Jun 2013 10:09:17 -0700
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH v2] vmpressure: implement strict mode
Message-ID: <20130628170917.GA12610@teo>
References: <20130626231712.4a7392a7@redhat.com>
 <20130627150231.2bc00e3efcd426c4beef894c@linux-foundation.org>
 <20130628000201.GB15637@bbox>
 <20130627173433.d0fc6ecd.akpm@linux-foundation.org>
 <20130628005852.GA8093@teo>
 <20130627181353.3d552e64.akpm@linux-foundation.org>
 <20130628043411.GA9100@teo>
 <20130628050712.GA10097@teo>
 <20130628100027.31504abe@redhat.com>
 <20130628165722.GA12271@teo>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20130628165722.GA12271@teo>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, kmpark@infradead.org, hyunhee.kim@samsung.com

On Fri, Jun 28, 2013 at 09:57:22AM -0700, Anton Vorontsov wrote:
> On Fri, Jun 28, 2013 at 10:00:27AM -0400, Luiz Capitulino wrote:
> > On Thu, 27 Jun 2013 22:07:12 -0700
> > Anton Vorontsov <anton@enomsg.org> wrote:
> > 
> > > On Thu, Jun 27, 2013 at 09:34:11PM -0700, Anton Vorontsov wrote:
> > > > ... we can add the strict mode and deprecate the
> > > > "filtering" -- basically we'll implement the idea of requiring that
> > > > userspace registers a separate fd for each level.
> > > 
> > > Btw, assuming that more levels can be added, there will be a problem:
> > > imagine that an app hooked up onto low, med, crit levels in "strict"
> > > mode... then once we add a new level, the app will start missing the new
> > > level events.
> > 
> > That's how it's expected to work, because on strict mode you're notified
> > for the level you registered for. So apps registering for critical, will
> > still be notified on critical just like before.
> 
> Suppose you introduce a new level, and the system hits this level. Before,
> the app would receive at least some notification for the given memory load
> (i.e. one of the old levels), with the new level introduced in the kernel,
> the app will receive no events at all. This makes a serious behavioural
> change in the app (read: it'll break it).

Btw, why exactly you need the strict mode? Why 'medium' won't work for the
load-balancing? If you want some special logic for the critical level in
addition to the load-balancing, then you can hook into medium and critical
in the current scheme, and it will be an equivalent, except that you will
still be receiving 'medium' events, which you can filter out in userland.

You don't even need additional syscalls -- you don't have to read from the
medium-level eventfd if poll() returned events from the critical-level
eventfd.

So, I would now argue that the current scheme is perfectly OK and can do
everything you can do with the "strict" one, except that the old one is
better, as it handles backwards-compatibility in a nice way. :)

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
