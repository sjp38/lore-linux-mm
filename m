Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id DF3536B0069
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 04:30:18 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id i64so133051093ith.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 01:30:18 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0150.hostedemail.com. [216.40.44.150])
        by mx.google.com with ESMTPS id y140si18447489iof.226.2016.08.22.01.30.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 01:30:18 -0700 (PDT)
Message-ID: <1471854614.3746.46.camel@perches.com>
Subject: Re: [PATCH 2/2] proc: task_mmu: Reduce output processing cpu time
From: Joe Perches <joe@perches.com>
Date: Mon, 22 Aug 2016 01:30:14 -0700
In-Reply-To: <1471852859.3746.42.camel@perches.com>
References: <cover.1471679737.git.joe@perches.com>
	 <2c1ea0d8f35fa5ddea477369b273d6d91c5bf2e2.1471679737.git.joe@perches.com>
	 <20160822072414.GB13596@dhcp22.suse.cz>
	 <1471852859.3746.42.camel@perches.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jann Horn <jann@thejh.net>, linux-mm@kvack.org

On Mon, 2016-08-22 at 01:00 -0700, Joe Perches wrote:
> On Mon, 2016-08-22 at 09:24 +0200, Michal Hocko wrote:
> > On Sat 20-08-16 01:00:17, Joe Perches wrote:
[]
> > > static int proc_maps_open(struct inode *inode, struct file *file,
> > >  			const struct seq_operations *ops, int psize)
> > >  {
> > > -	struct proc_maps_private *priv = __seq_open_private(file, ops, psize);
> > > +	struct proc_maps_private *priv;
> > > +	struct mm_struct *mm;
> > > +
> > > +	mm = proc_mem_open(inode, PTRACE_MODE_READ);
> > > +	if (IS_ERR(mm))
> > > +		return PTR_ERR(mm);
> > >  
> > > +	priv = __seq_open_private_bufsize(file, ops, psize,
> > > +					  mm && mm->map_count ?
> > > +					  mm->map_count * 0x300 : PAGE_SIZE);
> > NAK to this!
> > 
> > Seriously, this just gives any random user access to user
> > defined amount of memory which not accounted, not reclaimable and a
> > potential consumer of any higher order blocks.
> I completely disagree here with your rationale here.

And with further review and your comment above, I withdraw this patch.
cheers, Joe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
