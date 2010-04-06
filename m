Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 55CC56B01FF
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 17:12:31 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <alpine.LFD.2.00.1004061236290.3487@i5.linux-foundation.org>
References: <alpine.LFD.2.00.1004061236290.3487@i5.linux-foundation.org> <20100406193134.26429.78585.stgit@warthog.procyon.org.uk>
Subject: Re: [PATCH] radix_tree_tag_get() is not as safe as the docs make out
Date: Tue, 06 Apr 2010 22:12:24 +0100
Message-ID: <27737.1270588344@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: dhowells@redhat.com, akpm@linux-foundation.org, npiggin@suse.de, paulmck@linux.vnet.ibm.com, corbet@lwn.net, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@linux-foundation.org> wrote:

> Looks like a reasonable patch, but the one thing you didn't say is whether 
> there is any code that relies on the incorrectly documented behavior?

Sorry, yes.  I've made an assumption in FS-Cache that I can rely on the result
of radix_tree_tag_get() simply by wrapping it in an rcu_read_lock()'d section.
This has proven not to be so, since the BUG_ON() at line 602 in
lib/radix-tree.c triggered.

I was protecting set/clear/delete from each other, but not protecting get from
set/clear/delete.

> How did you find this? Do we need to fix actual code too? The only user 
> seems to be your fscache/page.c thing, and I'm not seeing any locking 
> except for the rcu locking that is apparently not sufficient.

As mentioned above, someone reported a bug in fscache that led me to this:

	https://www.redhat.com/archives/linux-cachefs/2010-April/msg00013.html

I may need to fix fscache, but I wanted to see if anyone would suggest an
alternate patch that would continue to let me make a test without having to
grab the spinlock first.

I'll update the patch to reflect this, whatever the final patch ends up being.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
