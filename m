Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F2F036B024D
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 14:10:12 -0400 (EDT)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o6MI9xPI014293
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 11:10:02 -0700
Received: from pwj6 (pwj6.prod.google.com [10.241.219.70])
	by kpbe18.cbf.corp.google.com with ESMTP id o6MI9wTW009506
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 11:09:58 -0700
Received: by pwj6 with SMTP id 6so3767732pwj.30
        for <linux-mm@kvack.org>; Thu, 22 Jul 2010 11:09:58 -0700 (PDT)
Date: Thu, 22 Jul 2010 11:09:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 6/6] jbd2: remove dependency on __GFP_NOFAIL
In-Reply-To: <20100722141437.GA14882@thunk.org>
Message-ID: <alpine.DEB.2.00.1007221108360.30080@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com> <alpine.DEB.2.00.1007201943340.8728@chino.kir.corp.google.com> <20100722141437.GA14882@thunk.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ted Ts'o <tytso@mit.edu>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andreas Dilger <adilger@sun.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jul 2010, Ted Ts'o wrote:

> > The kzalloc() in start_this_handle() is failable, so remove __GFP_NOFAIL
> > from its mask.
> 
> Unfortunately, while there is error handling in start_this_handle(),
> there isn't in all of the callers of start_this_handle(), which is why
> the __GFP_NOFAIL is there.  At the moment, if we get an ENOMEM in the
> delayed writeback code paths, for example, it's a disaster; user data
> can get lost, as a result.
> 

I'll change this to

	do {
		new_transaction = kzalloc(sizeof(*new_transaction),
							GFP_NOFS);
	} while (!new_transaction);

in the next phase when I introduce __GFP_KILLABLE (that jbd and jbd2 can't 
use because they are GFP_NOFS).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
