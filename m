Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4CEF28D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 07:26:27 -0400 (EDT)
Date: Tue, 19 Apr 2011 13:25:06 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Bugme-new] [Bug 33682] New: mprotect got stuck when THP is
 "always" enabled
Message-ID: <20110419112506.GB5641@random.random>
References: <bug-33682-10286@https.bugzilla.kernel.org/>
 <20110418230651.54da5b82.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110418230651.54da5b82.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, bugs@casparzhang.com

On Mon, Apr 18, 2011 at 11:06:51PM -0700, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).

Ok.

/dev/zero mapped with MAP_PRIVATE is special as it doesn't set vm_ops
but is vm_file backed. The page fault code only checks the vm_ops
being NULL to decide if to use THP or not (it doesn't check
vm_file). But then the huge_memory.c code also checks vm_file (like in
vma_adjust_trans_huge). So I think what's going on in the special case
of /dev/zero MAP_PRIVATE is that we could have THP enabled on a
filebacked vma (but no vm_ops backed) that doesn't fully enable all
operations necessary to be safe like vma_adjust_trans_huge because
vm_file being set. To let /dev/zero to use THP safely I guess we can
remove the vm_file checks and only use the vm_ops checks across
huge_memory.c/huge_mm.h or to add add "!vma->vm_ops && !vma->vm_file"
to the page fault so THP isn't used. The former is more risky than
adding the vm_file check in the page fault path but it'd match more
closely what do_anonymous_page does, so I'm thinking what are the
implications of removing vm_file across the huge_memory.c/huge_mm.h. I
didn't manage to reboot into a fixed kernel to test yet... I'll let
you know the results after some testing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
