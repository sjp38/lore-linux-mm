Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f51.google.com (mail-qe0-f51.google.com [209.85.128.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0506B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 19:39:16 -0500 (EST)
Received: by mail-qe0-f51.google.com with SMTP id 1so2204621qee.24
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 16:39:16 -0800 (PST)
Received: from mail-ve0-x230.google.com (mail-ve0-x230.google.com [2607:f8b0:400c:c01::230])
        by mx.google.com with ESMTPS id j1si4008503qer.77.2013.12.13.16.39.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 16:39:15 -0800 (PST)
Received: by mail-ve0-f176.google.com with SMTP id oz11so1900987veb.35
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 16:39:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131211150522.4b853323e8b82f342f81b64d@linux-foundation.org>
References: <1386066977-17368-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	<20131203143841.11b71e387dc1db3a8ab0974c@linux-foundation.org>
	<529EE811.5050306@linux.vnet.ibm.com>
	<20131204004125.a06f7dfc.akpm@linux-foundation.org>
	<529EF0FB.2050808@linux.vnet.ibm.com>
	<20131204134838.a048880a1db9e9acd14a39e4@linux-foundation.org>
	<20131211224917.GF1163@quack.suse.cz>
	<20131211150522.4b853323e8b82f342f81b64d@linux-foundation.org>
Date: Fri, 13 Dec 2013 16:39:10 -0800
Message-ID: <CA+55aFy-e-uok1K9mSNTYS4bJJfHkxXofY7T1UVWgHOyXuE84A@mail.gmail.com>
Subject: Re: [PATCH RFC] mm readahead: Fix the readahead fail in case of empty
 numa node
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Dec 11, 2013 at 3:05 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> But I'm really struggling to think up an implementation!  The current
> code looks only at the caller's node and doesn't seem to make much
> sense.  Should we look at all nodes?  Hard to say without prior
> knowledge of where those pages will be coming from.

I really think we want to put an upper bound on the read-ahead, and
I'm not convinced we need to try to be excessively clever about it. We
also probably don't want to make it too expensive to calculate,
because afaik this ends up being called for each file we open when we
don't have pages in the page cache yet.

The current function seems reasonable on a single-node system. Let's
not kill it entirely just because it has some odd corner-case on
multi-node systems.

In fact, for all I care, I think it would be perfectly ok to just use
a truly stupid hard limit ("you can't read-ahead more than 16MB" or
whatever).

What we do *not* want to allow is to have people call "readahead"
functions and basically kill the machine because you now have a
unkillable IO that is insanely big. So I'd much rather limit it too
much than too little. And on absolutely no sane IO susbsystem does it
make sense to read ahead insane amounts.

So I'd rather limit it to something stupid and small, than to not
limit things at all.

Looking at the interface, for example, the natural thing to do for the
"readahead()" system call, for example, is to just give it a size of
~0ul, and let the system limit things, becaue limiting things in useer
space is just not reasonable.

So I really do *not* think it's fine to just remove the limit entirely.

          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
