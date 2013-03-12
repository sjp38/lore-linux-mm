Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id D672A6B0006
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 19:01:37 -0400 (EDT)
Date: Tue, 12 Mar 2013 16:01:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 1/2] mm: limit growth of 3% hardcoded other user
 reserve
Message-Id: <20130312160136.b0f09ca7b1b4f2efe01f6617@linux-foundation.org>
In-Reply-To: <20130306235201.GA1421@localhost.localdomain>
References: <20130306235201.GA1421@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Shewmaker <agshew@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, simon.jeons@gmail.com, ric.masonn@gmail.com

On Wed, 6 Mar 2013 18:52:01 -0500 Andrew Shewmaker <agshew@gmail.com> wrote:

> Add user_reserve_pages knob.
> 
> Limit the growth of the memory reserved for other user
> processes to min(3% current process, user_reserve_pages).
> 
> user_reserve_pages defaults to min(3% free pages, 128MB)
> I arrived at 128MB by taking that max VSZ of sshd, login, 
> bash, and top ... then adding the RSS of each.
> 
> This only affects OVERCOMMIT_NEVER mode.

Can we have a more complete changelog, please?  One which describes, at
great length, *why* we're doing this.  Describe the problems you
observed, the possible means of addressing them, why this means is
considered best, etc.

Also, there has been considerable discussion over this patchset and it
is good to update the changelogs to reflect that discussion.  Partly
because other people will be asking the same questions when they see
the patches and partly so that reviewers can understand how earlier
objections/suggestions were addressed.  Assume that your audience
has not read this email thread!

>From a quick read of the code, it appears that the root-cant-log-in
problem was addressed by simply leaving it up to the administrator,
yes?  If the administrator sets user_reserve_pages or
admin_reserve_pages to zero then they risk hitting the root-cant-log-in
problem, yes?  If so then I guess this is an OK approach, but we should
clearly describe the risks in the documentation.

Finally, I am allergic to exported interfaces which deal in "pages". 
Because PAGE_SIZE can vary by a factor of 16 depending upon config (ie:
architecture).  The risk is that a setup script which works nicely on
4k x86_64 will waste memory when executed on a 64k PAGE_SIZE powerpc
box.  A smart programmer will recognize this and will adapt the setting
using getpagesize(2), but if we define these things in "bytes" rather
than "pages" then dumb programmers can use it too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
