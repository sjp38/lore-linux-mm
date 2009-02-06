Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 55C106B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 20:44:04 -0500 (EST)
Date: Fri, 6 Feb 2009 02:44:00 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Patch] mmu_notifiers destroyed by __mmu_notifier_release()
	retain extra mm_count.
Message-ID: <20090206014400.GM14011@random.random>
References: <20090205172303.GB8559@sgi.com> <alpine.DEB.1.10.0902051427280.13692@qirst.com> <20090205200214.GN8577@sgi.com> <alpine.DEB.1.10.0902051844390.17441@qirst.com> <20090206013805.GL14011@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090206013805.GL14011@random.random>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Robin Holt <holt@sgi.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 06, 2009 at 02:38:05AM +0100, Andrea Arcangeli wrote:
> It all boils down if unregister is mandatory or not. If it's mandatory

Oh I just found I documented it too!! ;)

/*
 * Must not hold mmap_sem nor any other VM related lock when calling
 * this registration function. Must also ensure mm_users can't go down
 * to zero while this runs to avoid races with mmu_notifier_release,
 * so mm has to be current->mm or the mm should be pinned safely such
 * as with get_task_mm(). If the mm is not current->mm, the mm_users
 * pin should be released by calling mmput after mmu_notifier_register
 * returns. mmu_notifier_unregister must be always called to
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 * unregister the notifier. mm_count is automatically pinned to allow
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 * mmu_notifier_unregister to safely run at any time later, before or 
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* after exit_mmap. ->release will always be called before exit_mmap
 * frees the pages.
 */

So in short the current code has no bugs and the fact you have to call
unregister is intentional. Not patch required unless you request to
change API. If you don't call unregister mm will be leaked,
simply. For a moment I thought unregister wasn't mandatory because at
some point in one of the dozen versions of the api it wasn't, but in
the end I thought having an mm_count auto-pinning leaving no window
for corrupted mmu_notifier list was preferable ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
