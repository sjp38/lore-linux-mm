Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 121896B003B
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 10:59:46 -0400 (EDT)
Date: Thu, 27 Jun 2013 16:59:43 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] vmpressure: implement strict mode
Message-ID: <20130627145943.GB24206@dhcp22.suse.cz>
References: <20130626231712.4a7392a7@redhat.com>
 <20130627092616.GB17647@dhcp22.suse.cz>
 <20130627093407.0466ced2@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130627093407.0466ced2@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan@kernel.org, anton@enomsg.org, akpm@linux-foundation.org, kmpark@infradead.org, hyunhee.kim@samsung.com

On Thu 27-06-13 09:34:07, Luiz Capitulino wrote:
> On Thu, 27 Jun 2013 11:26:16 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> > On Wed 26-06-13 23:17:12, Luiz Capitulino wrote:
[...]
> > > +Applications can also choose between two notification modes when
> > > +registering an eventfd for memory pressure events:
> > > +
> > > +When in "non-strict" mode, an eventfd is notified for the specific level
> > > +it's registered for and higher levels. For example, an eventfd registered
> > > +for low level is also going to be notified on medium and critical levels.
> > > +This mode makes sense for applications interested on monitoring reclaim
> > > +activity or implementing simple load-balacing logic. The non-strict mode
> > > +is the default notification mode.
> > > +
> > > +When in "strict" mode, an eventfd is strictly notified for the pressure
> > > +level it's registered for. For example, an eventfd registered for the low
> > > +level event is not going to be notified when memory pressure gets into
> > > +medium or critical levels. This allows for more complex logic based on
> > > +the actual pressure level the system is experiencing.
> > 
> > It would be also fair to mention that there is no guarantee that lower
> > levels are signaled before higher so nobody should rely on seeing LOW
> > before MEDIUM or CRITICAL.
> 
> I think this is implied. Actually, as an user of this interface I didn't
> expect this to happen until I read the code.

That is a difference between the two modes, so let's better be _explicit_
about that. There is some confusion about that, considering the last
discussions. And I am not that surprised because critical memory
pressure should have passed low and medium levels first is not entirely
unreasonable expectation. But this is _not_ how this interface works or
will guarantee to work in future.
 
[...]
> > > diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> > > index 736a601..ba5c17e 100644
> > > --- a/mm/vmpressure.c
> > > +++ b/mm/vmpressure.c
> > > @@ -138,8 +138,16 @@ struct vmpressure_event {
> > >  	struct eventfd_ctx *efd;
> > >  	enum vmpressure_levels level;
> > >  	struct list_head node;
> > > +	unsigned int mode;
> > 
> > You would fill up a hole between level and node if you move it up on
> > 64b. Doesn't matter much but why not do it...
> 
> You want me to respin?

I will leave it to you. This is not anything earth shattering as we
won't have zillions of this structures so saving few bytes doesn't help
us that much and 32b doesn't have to hole.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
