Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 610226B024D
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 10:11:44 -0400 (EDT)
Date: Fri, 23 Jul 2010 10:10:54 -0400
From: Ted Ts'o <tytso@mit.edu>
Subject: Re: [patch 6/6] jbd2: remove dependency on __GFP_NOFAIL
Message-ID: <20100723141054.GE13090@thunk.org>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1007201943340.8728@chino.kir.corp.google.com>
 <20100722141437.GA14882@thunk.org>
 <alpine.DEB.2.00.1007221108360.30080@chino.kir.corp.google.com>
 <20100722230935.GB16373@thunk.org>
 <alpine.DEB.2.00.1007221618001.4856@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1007221618001.4856@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andreas Dilger <adilger@sun.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 04:24:23PM -0700, David Rientjes wrote:
> 
> I didn't think about converting the existing GFP_NOFS | __GFP_NOFAIL 
> callers into the do-while loop above until you mentioned it, thanks.  I'll 
> send patches to do that shortly.

Here's what I'm planning on queueing for the next merge window, along
with patches to ext4 to use jbd2__journal_start(..., GFP_KERNEL) in
places where we can afford to fail.  After doing some analysis, the
places where we can afford to fail are also the places where we can
use GFP_KERNEL instead of GFP_NOFS, so conveniently, I'm using the
lack of __GFP_FS to indicate that we should do the retry loop in
start_this_handle().  I also added the congestion_wait() call since
there's no point busy-looping the CPU while we're waiting for pages to
get swapped or paged out.

Comments would be appreciated.

    	      	    	    	      	     - Ted
