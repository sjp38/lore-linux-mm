Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id F2B876B0031
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 09:29:45 -0400 (EDT)
Date: Tue, 2 Jul 2013 15:29:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] vmpressure: implement strict mode
Message-ID: <20130702132942.GH16815@dhcp22.suse.cz>
References: <20130627181353.3d552e64.akpm@linux-foundation.org>
 <20130628043411.GA9100@teo>
 <20130628050712.GA10097@teo>
 <20130628100027.31504abe@redhat.com>
 <20130628165722.GA12271@teo>
 <20130628170917.GA12610@teo>
 <20130628144507.37d28ed9@redhat.com>
 <20130628185547.GA14520@teo>
 <20130628154402.4035f2fa@redhat.com>
 <20130629005637.GA16068@teo>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130629005637.GA16068@teo>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kmpark@infradead.org, hyunhee.kim@samsung.com

On Fri 28-06-13 17:56:37, Anton Vorontsov wrote:
> On Fri, Jun 28, 2013 at 03:44:02PM -0400, Luiz Capitulino wrote:
> > > Why can't you use poll() and demultiplex the events? Check if there is an
> > > event in the crit fd, and if there is, then just ignore all the rest.
> > 
> > This may be a valid workaround for current kernels, but application
> > behavior will be different among kernels with a different number of
> > events.
> 
> This is not a workaround, this is how poll works, and this is kinda
> expected... But not that I had this plan in mind when I was designing the
> current scheme... :)

One thing I found strict mode useful is that a poll based implementation
would be PITA without kernel help. First the timing is nothing you can
rely on. There might be arbitrary timeout between two eventfd_signal
calls. So you would see Medium while critical is waiting for being
scheduled.
Kernel might help here though and signal from the highest event down to
lower ones. The core issue would stay though. What is a tolerable period
when an event is considered separate one?

That being said I think both modes make sense and they cover different
usecases.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
