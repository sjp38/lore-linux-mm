Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id AACC4280257
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 08:26:33 -0400 (EDT)
Received: by wgqq4 with SMTP id q4so87263268wgq.1
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 05:26:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x1si14956793wif.27.2015.07.03.05.26.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 03 Jul 2015 05:26:32 -0700 (PDT)
Date: Fri, 3 Jul 2015 14:26:27 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 36/51] writeback: implement bdi_for_each_wb()
Message-ID: <20150703122627.GK23329@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-37-git-send-email-tj@kernel.org>
 <20150701072757.GW7252@quack.suse.cz>
 <20150702022226.GH26440@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150702022226.GH26440@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Wed 01-07-15 22:22:26, Tejun Heo wrote:
> On Wed, Jul 01, 2015 at 09:27:57AM +0200, Jan Kara wrote:
> > > +#define bdi_for_each_wb(wb_cur, bdi, iter, start_blkcg_id)		\
> > > +	for ((iter)->next_id = (start_blkcg_id);			\
> > > +	     ({	(wb_cur) = !(iter)->next_id++ ? &(bdi)->wb : NULL; }); )
> > > +
> > 
> > This looks quite confusing. Won't it be easier to understand as:
> > 
> > struct wb_iter {
> > } __attribute__ ((unused));
> > 
> > #define bdi_for_each_wb(wb_cur, bdi, iter, start_blkcg_id) \
> >   if (((wb_cur) = (!start_blkcg_id ? &(bdi)->wb : NULL)))
> 
> But then break or continue wouldn't work as expected.  It can get
> really confusing when it's wrapped by an outer loop.

That's a good point. Thanks for explanation. Maybe add a comment like:
/*
 * We use use this seemingly complicated 'for' loop so that 'break' and
 * 'continue' continue to work as expected.
 */

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
