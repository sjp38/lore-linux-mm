Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 175A86B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 20:12:24 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id ft15so9048697pdb.35
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 17:12:23 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id sy3si24865724pab.158.2014.06.30.17.12.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 17:12:23 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so9586488pab.29
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 17:12:22 -0700 (PDT)
Date: Mon, 30 Jun 2014 17:10:54 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH mmotm/next] mm: memcontrol: rewrite charge API: fix
 shmem_unuse
In-Reply-To: <20140630160212.46caf9c3d41445b61fece666@linux-foundation.org>
Message-ID: <alpine.LSU.2.11.1406301658430.4898@eggly.anvils>
References: <alpine.LSU.2.11.1406301541420.4349@eggly.anvils> <20140630160212.46caf9c3d41445b61fece666@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 30 Jun 2014, Andrew Morton wrote:
> On Mon, 30 Jun 2014 15:48:39 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
> > -		return 0;
> > +		return -EAGAIN;
> 
> Maybe it's time to document the shmem_unuse_inode() return values.

Oh dear.  I had hoped they would look after themselves.  This one is a
private matter between shmem_unuse_inode and its one caller, just below.

> > +	if (error) {
> > +		if (error != -ENOMEM)
> > +			error = 0;
> >  		mem_cgroup_cancel_charge(page, memcg);
> >  	} else
> >  		mem_cgroup_commit_charge(page, memcg, true);
> 
> If I'm reading this correctly, shmem_unuse() can now return -EAGAIN and
> that can get all the way back to userspace.  `man 2 swapoff' doesn't
> know this...

if (error) {
	if (error != -ENOMEM)
		error = 0;
...
	return error;

So the only values returned from shmem_unuse_inode() to its caller
try_to_unuse() are 0 and -ENOMEM.  Those may get passed back to the
user, but -EAGAIN was just an internal shmem.c detail.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
