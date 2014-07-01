Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9A6396B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 20:34:50 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so9574340pab.30
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 17:34:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id yn4si24977467pac.38.2014.06.30.17.34.49
        for <linux-mm@kvack.org>;
        Mon, 30 Jun 2014 17:34:49 -0700 (PDT)
Date: Mon, 30 Jun 2014 17:34:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH mmotm/next] mm: memcontrol: rewrite charge API: fix
 shmem_unuse
Message-Id: <20140630173428.5ebeed18.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.11.1406301658430.4898@eggly.anvils>
References: <alpine.LSU.2.11.1406301541420.4349@eggly.anvils>
	<20140630160212.46caf9c3d41445b61fece666@linux-foundation.org>
	<alpine.LSU.2.11.1406301658430.4898@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 30 Jun 2014 17:10:54 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:

> On Mon, 30 Jun 2014, Andrew Morton wrote:
> > On Mon, 30 Jun 2014 15:48:39 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
> > > -		return 0;
> > > +		return -EAGAIN;
> > 
> > Maybe it's time to document the shmem_unuse_inode() return values.
> 
> Oh dear.  I had hoped they would look after themselves.  This one is a
> private matter between shmem_unuse_inode and its one caller, just below.

Well, readers of shmem_unuse_inode() won't know that unless we tell them.


> > > +	if (error) {
> > > +		if (error != -ENOMEM)
> > > +			error = 0;
> > >  		mem_cgroup_cancel_charge(page, memcg);
> > >  	} else
> > >  		mem_cgroup_commit_charge(page, memcg, true);
> > 
> > If I'm reading this correctly, shmem_unuse() can now return -EAGAIN and
> > that can get all the way back to userspace.  `man 2 swapoff' doesn't
> > know this...
> 
> if (error) {
> 	if (error != -ENOMEM)
> 		error = 0;
> ...
> 	return error;
> 
> So the only values returned from shmem_unuse_inode() to its caller
> try_to_unuse() are 0 and -ENOMEM.  Those may get passed back to the
> user, but -EAGAIN was just an internal shmem.c detail.

OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
