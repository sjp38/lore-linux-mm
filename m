Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id DC6C46B0072
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 15:13:46 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id fb1so7242997pad.17
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 12:13:46 -0800 (PST)
Received: from psmtp.com ([74.125.245.118])
        by mx.google.com with SMTP id oy2si12402638pbc.99.2013.11.19.12.13.44
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 12:13:45 -0800 (PST)
Date: Tue, 19 Nov 2013 12:13:33 -0800
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] Expose sysctls for enabling slab/file_cache interleaving
Message-ID: <20131119201333.GD19762@tassilo.jf.intel.com>
References: <1384822222-28795-1-git-send-email-andi@firstfloor.org>
 <20131119104203.GB18872@dhcp22.suse.cz>
 <20131119184200.GD29695@two.firstfloor.org>
 <20131119191135.GA8634@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131119191135.GA8634@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 19, 2013 at 08:11:35PM +0100, Michal Hocko wrote:
> On Tue 19-11-13 19:42:00, Andi Kleen wrote:
> > On Tue, Nov 19, 2013 at 11:42:03AM +0100, Michal Hocko wrote:
> > > On Mon 18-11-13 16:50:22, Andi Kleen wrote:
> > > [...]
> > > > diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
> > > > index cc1b01c..10966f5 100644
> > > > --- a/include/linux/cpuset.h
> > > > +++ b/include/linux/cpuset.h
> > > > @@ -72,12 +72,14 @@ extern int cpuset_slab_spread_node(void);
> > > >  
> > > >  static inline int cpuset_do_page_mem_spread(void)
> > > >  {
> > > > -	return current->flags & PF_SPREAD_PAGE;
> > > > +	return (current->flags & PF_SPREAD_PAGE) ||
> > > > +		sysctl_spread_file_cache;
> > > >  }
> > > 
> > > But this might break applications that explicitly opt out from
> > > spreading.
> > 
> > What do you mean? There's no such setting at the moment.
> > 
> > They can only enable it.
> 
> cpuset_update_task_spread_flag allows disabling both flags. You can do
> so for example via cpuset cgroup controller.

Ok.

So you're saying it should look up the cpuset. I'm reluctant do 
that. It would make this path quite a bit more expensive.

Is it really a big problem to override that setting with
the global sysctl. Seems like sensible semantics for me.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
