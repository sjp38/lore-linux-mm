Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 29E9C6B0044
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 11:15:56 -0400 (EDT)
Date: Mon, 8 Oct 2012 11:15:52 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: mpol_to_str revisited.
Message-ID: <20121008151552.GA10881@redhat.com>
References: <20121008150949.GA15130@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121008150949.GA15130@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, bhutchings@solarflare.com, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Oct 08, 2012 at 11:09:49AM -0400, Dave Jones wrote:
 > Last month I sent in 80de7c3138ee9fd86a98696fd2cf7ad89b995d0a to remove
 > a user triggerable BUG in mempolicy.
 > 
 > Ben Hutchings pointed out to me that my change introduced a potential leak
 > of stack contents to userspace, because none of the callers check the return value.
 > 
 > This patch adds the missing return checking, and also clears the buffer beforehand.
 > 
 > Reported-by: Ben Hutchings <bhutchings@solarflare.com>
 > Cc: stable@kernel.org
 > Signed-off-by: Dave Jones <davej@redhat.com>
 > 
 > --- 
 > unanswered question: why are the buffer sizes here different ? which is correct?

A further unanswered question is how the state got so screwed up that we hit that
default case at all.  Looking at the original report: https://lkml.org/lkml/2012/9/6/356
What's in RAX looks suspiciously like left-over slab poison.

If pol->mode was poisoned, that smells like we have a race where policy is getting freed
while another process is reading it.

Am I missing something, or is there no locking around that at all ?

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
