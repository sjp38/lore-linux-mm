Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 04CE06B02A3
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 19:24:34 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id o6MNOUdo020886
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 16:24:30 -0700
Received: from pwj7 (pwj7.prod.google.com [10.241.219.71])
	by hpaq5.eem.corp.google.com with ESMTP id o6MNORRn015684
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 16:24:28 -0700
Received: by pwj7 with SMTP id 7so4104176pwj.36
        for <linux-mm@kvack.org>; Thu, 22 Jul 2010 16:24:27 -0700 (PDT)
Date: Thu, 22 Jul 2010 16:24:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 6/6] jbd2: remove dependency on __GFP_NOFAIL
In-Reply-To: <20100722230935.GB16373@thunk.org>
Message-ID: <alpine.DEB.2.00.1007221618001.4856@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com> <alpine.DEB.2.00.1007201943340.8728@chino.kir.corp.google.com> <20100722141437.GA14882@thunk.org> <alpine.DEB.2.00.1007221108360.30080@chino.kir.corp.google.com>
 <20100722230935.GB16373@thunk.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ted Ts'o <tytso@mit.edu>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andreas Dilger <adilger@sun.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jul 2010, Ted Ts'o wrote:

> > I'll change this to
> > 
> > 	do {
> > 		new_transaction = kzalloc(sizeof(*new_transaction),
> > 							GFP_NOFS);
> > 	} while (!new_transaction);
> > 
> > in the next phase when I introduce __GFP_KILLABLE (that jbd and jbd2 can't 
> > use because they are GFP_NOFS).
> 
> OK, I can carry a patch which does this in the ext4 tree to push to
> linus when the merge window opens shortly, since the goal is you want
> to get rid of __GFP_NOFAIL altogether, right?
> 

Yup, I was trying to do the removal in two phases.

First, remove __GFP_NOFAIL from callers that don't seem to need it.  I 
found that they were actually needed in some cases such as jbd, jbd2, and 
sparc although the reason was specific to those subsystems at a higher 
level and their error handling was actually unused code since __GFP_NOFAIL 
cannot return NULL.

Second, replace __GFP_NOFAIL with __GFP_KILLABLE which converts existing 
users of __GFP_NOFAIL into the do-while loop above and adding 
__GFP_KILLABLE for allocations allowing __GFP_FS which does memory 
compaction for order > 0, direct reclaim, and the oom killer but does not 
retry the allocation.  That would be the responsibility of the caller.  
This ends up removing several branches from the page allocator.

I didn't think about converting the existing GFP_NOFS | __GFP_NOFAIL 
callers into the do-while loop above until you mentioned it, thanks.  I'll 
send patches to do that shortly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
