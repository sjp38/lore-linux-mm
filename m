Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 73D5E6B0069
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 04:01:03 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id p18so295283422oic.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 01:01:03 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0182.hostedemail.com. [216.40.44.182])
        by mx.google.com with ESMTPS id d75si15007175ith.69.2016.08.22.01.01.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 01:01:02 -0700 (PDT)
Message-ID: <1471852859.3746.42.camel@perches.com>
Subject: Re: [PATCH 2/2] proc: task_mmu: Reduce output processing cpu time
From: Joe Perches <joe@perches.com>
Date: Mon, 22 Aug 2016 01:00:59 -0700
In-Reply-To: <20160822072414.GB13596@dhcp22.suse.cz>
References: <cover.1471679737.git.joe@perches.com>
	 <2c1ea0d8f35fa5ddea477369b273d6d91c5bf2e2.1471679737.git.joe@perches.com>
	 <20160822072414.GB13596@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Jann Horn <jann@thejh.net>, linux-mm@kvack.org

On Mon, 2016-08-22 at 09:24 +0200, Michal Hocko wrote:
> On Sat 20-08-16 01:00:17, Joe Perches wrote:
> [...]
> > 
> >  static int proc_maps_open(struct inode *inode, struct file *file,
> >  			const struct seq_operations *ops, int psize)
> >  {
> > -	struct proc_maps_private *priv = __seq_open_private(file, ops, psize);
> > +	struct proc_maps_private *priv;
> > +	struct mm_struct *mm;
> > +
> > +	mm = proc_mem_open(inode, PTRACE_MODE_READ);
> > +	if (IS_ERR(mm))
> > +		return PTR_ERR(mm);
> >  
> > +	priv = __seq_open_private_bufsize(file, ops, psize,
> > +					  mm && mm->map_count ?
> > +					  mm->map_count * 0x300 : PAGE_SIZE);
> NAK to this!
>
> Seriously, this just gives any random user access to user
> defined amount of memory which not accounted, not reclaimable and a
> potential consumer of any higher order blocks.

I completely disagree here with your rationale here.

I think you didn't read the code and didn't try it either.

This code is identical to the previous code but it
simply estimates the required output size first.

> Besides that, at least one show_smap output will always fit inside the
> single page and AFAIR (it's been quite a while since I've looked into
> seq_file internals) the buffer grows only when the single show doesn't
> fit in.

It's never been like that as far as I know.

Please read fs/seq_file.c:traverse()

This code starts with a PAGE_SIZE block of memory then if
the complete output doesn't fit, stops, frees that block
of memory, and retries the complete output with a last block
size allocated << 1 and tries again.

> I really do not understand why you insist on code duplication rather
> than reuse but if you really insist then just make this (without the
> above __seq_open_private_bufsize, re-measure and add the results to the
> changelog and repost.

I've tried it, I wish you would.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
