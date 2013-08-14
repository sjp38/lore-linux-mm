Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id E843B6B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 16:50:44 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id bv4so1363394qab.20
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 13:50:43 -0700 (PDT)
Date: Wed, 14 Aug 2013 16:50:29 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v8] mm: make lru_add_drain_all() selective
Message-ID: <20130814205029.GN28628@htj.dyndns.org>
References: <20130814200748.GI28628@htj.dyndns.org>
 <201308142029.r7EKTMRw023404@farm-0002.internal.tilera.com>
 <20130814134430.50cb8d609643620b00ab3705@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130814134430.50cb8d609643620b00ab3705@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Metcalf <cmetcalf@tilera.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Hello,

On Wed, Aug 14, 2013 at 01:44:30PM -0700, Andrew Morton wrote:
> > +static bool need_activate_page_drain(int cpu)
> > +{
> > +	return pagevec_count(&per_cpu(activate_page_pvecs, cpu)) != 0;
> > +}
> 
> static int need_activate_page_drain(int cpu)
> {
> 	return pagevec_count(&per_cpu(activate_page_pvecs, cpu));
> }
> 
> would be shorter and faster.  bool rather sucks that way.  It's a
> performance-vs-niceness thing.  I guess one has to look at the call
> frequency when deciding.

"!= 0" can be dropped but I'm fairly sure the compiler would be able
to figure out that the type conversion can be skipped.  It's a trivial
optimization.

> > +			schedule_work_on(cpu, work);
> > +			cpumask_set_cpu(cpu, &has_work);
> > +		}
> > +	}
> > +
> > +	for_each_cpu(cpu, &has_work)
> 
> for_each_online_cpu()?

That would lead to flushing work items which aren't used and may not
have been initialized yet, no?

> > +		flush_work(&per_cpu(lru_add_drain_work, cpu));
> > +
> > +	put_online_cpus();
> > +	mutex_unlock(&lock);
> >  }
> 

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
