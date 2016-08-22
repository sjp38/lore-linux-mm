Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A2B996B0069
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 08:09:40 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p85so73077191lfg.3
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 05:09:40 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id w192si15937886wmd.82.2016.08.22.05.09.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 05:09:39 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id i138so13131902wmf.3
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 05:09:38 -0700 (PDT)
Date: Mon, 22 Aug 2016 14:09:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] proc: task_mmu: Reduce output processing cpu time
Message-ID: <20160822120937.GK13596@dhcp22.suse.cz>
References: <cover.1471679737.git.joe@perches.com>
 <2c1ea0d8f35fa5ddea477369b273d6d91c5bf2e2.1471679737.git.joe@perches.com>
 <20160822072414.GB13596@dhcp22.suse.cz>
 <1471852859.3746.42.camel@perches.com>
 <1471854614.3746.46.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1471854614.3746.46.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jann Horn <jann@thejh.net>, linux-mm@kvack.org

On Mon 22-08-16 01:30:14, Joe Perches wrote:
> On Mon, 2016-08-22 at 01:00 -0700, Joe Perches wrote:
> > On Mon, 2016-08-22 at 09:24 +0200, Michal Hocko wrote:
> > > On Sat 20-08-16 01:00:17, Joe Perches wrote:
> []
> > > > static int proc_maps_open(struct inode *inode, struct file *file,
> > > >  			const struct seq_operations *ops, int psize)
> > > >  {
> > > > -	struct proc_maps_private *priv = __seq_open_private(file, ops, psize);
> > > > +	struct proc_maps_private *priv;
> > > > +	struct mm_struct *mm;
> > > > +
> > > > +	mm = proc_mem_open(inode, PTRACE_MODE_READ);
> > > > +	if (IS_ERR(mm))
> > > > +		return PTR_ERR(mm);
> > > >  
> > > > +	priv = __seq_open_private_bufsize(file, ops, psize,
> > > > +					  mm && mm->map_count ?
> > > > +					  mm->map_count * 0x300 : PAGE_SIZE);
> > > NAK to this!
> > > 
> > > Seriously, this just gives any random user access to user
> > > defined amount of memory which not accounted, not reclaimable and a
> > > potential consumer of any higher order blocks.
> > I completely disagree here with your rationale here.
> 
> And with further review and your comment above, I withdraw this patch.

So you've made me look into that code. I can imagine how it is easy to
to get confused here. The important part is that m->count is reset after
each ->show(). So traverse() same as seq_read only grows the buffer if
a single show doesn't fit in.

That being said, should I repost my rebased patches or do you plan to
repost your patch? I do not want spam people with another version if
you do not like it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
