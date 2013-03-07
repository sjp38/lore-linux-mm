Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 5B8D46B0006
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 16:49:45 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id 10so2100096ied.30
        for <linux-mm@kvack.org>; Wed, 13 Mar 2013 13:49:44 -0700 (PDT)
Date: Wed, 6 Mar 2013 20:55:53 -0500
From: Andrew Shewmaker <agshew@gmail.com>
Subject: Re: [PATCH v5 1/2] mm: limit growth of 3% hardcoded other user
 reserve
Message-ID: <20130307015553.GA5495@localhost.localdomain>
References: <20130306235201.GA1421@localhost.localdomain>
 <20130312160136.b0f09ca7b1b4f2efe01f6617@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130312160136.b0f09ca7b1b4f2efe01f6617@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, simon.jeons@gmail.com, ric.masonn@gmail.com

On Tue, Mar 12, 2013 at 04:01:36PM -0700, Andrew Morton wrote:
> On Wed, 6 Mar 2013 18:52:01 -0500 Andrew Shewmaker <agshew@gmail.com> wrote:
> 
> > Add user_reserve_pages knob.
> > 
> > Limit the growth of the memory reserved for other user
> > processes to min(3% current process, user_reserve_pages).
> > 
> > user_reserve_pages defaults to min(3% free pages, 128MB)
> > I arrived at 128MB by taking that max VSZ of sshd, login, 
> > bash, and top ... then adding the RSS of each.
> > 
> > This only affects OVERCOMMIT_NEVER mode.
> 
> Can we have a more complete changelog, please?  One which describes, at
> great length, *why* we're doing this.  Describe the problems you
> observed, the possible means of addressing them, why this means is
> considered best, etc.
> 
> Also, there has been considerable discussion over this patchset and it
> is good to update the changelogs to reflect that discussion.  Partly
> because other people will be asking the same questions when they see
> the patches and partly so that reviewers can understand how earlier
> objections/suggestions were addressed.  Assume that your audience
> has not read this email thread!
> 
> From a quick read of the code, it appears that the root-cant-log-in
> problem was addressed by simply leaving it up to the administrator,
> yes?  If the administrator sets user_reserve_pages or
> admin_reserve_pages to zero then they risk hitting the root-cant-log-in
> problem, yes?  If so then I guess this is an OK approach, but we should
> clearly describe the risks in the documentation.
> 
> Finally, I am allergic to exported interfaces which deal in "pages". 
> Because PAGE_SIZE can vary by a factor of 16 depending upon config (ie:
> architecture).  The risk is that a setup script which works nicely on
> 4k x86_64 will waste memory when executed on a 64k PAGE_SIZE powerpc
> box.  A smart programmer will recognize this and will adapt the setting
> using getpagesize(2), but if we define these things in "bytes" rather
> than "pages" then dumb programmers can use it too.

I'll get right on a version with an interface that uses kbytes, and 
I'll put a lot more detail in the changelog. I'll also document how 
I'm testing.

As long as  admin_reserve_pages is set to at least 8MB for 
OVERCOMMIT_GUESS or above 128MB for OVERCOMMIT_NEVER, I was able to 
log in as root and kill processes. The root-cant-log-in problem 
cannot be hit if user_reserve_pages is set to 0 because that 
reserve only exists in OVERCOMMIT_NEVER mode.

Should I enforce a minimum for the admin reserve? 8MB/128MB for the 
overcommit guess/never modes? I was hesitant to do that since my 
numbers are based a full-featured distro's versions of login, bash,
etc. A more svelte distro based on BusyBox might want different 
minimums.

I have a question concerning the variable names. Might a person 
looking at the source be confused why admin_reserve_kbytes and 
user_reserve_kbytes are not included in totalreserve_pages? Should 
I use a word other than "reserve" in the names, like "safetynet"? 
I can't think of anything better. Maybe it isn't a concern, but 
I didn't want to cause confusion.

Thanks for the feedback!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
