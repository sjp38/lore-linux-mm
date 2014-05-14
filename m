Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 79D346B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 12:15:37 -0400 (EDT)
Received: by mail-qc0-f171.google.com with SMTP id x13so3165888qcv.2
        for <linux-mm@kvack.org>; Wed, 14 May 2014 09:15:37 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id 2si1095818qah.228.2014.05.14.09.15.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 14 May 2014 09:15:36 -0700 (PDT)
Message-ID: <537396A2.9090609@cybernetics.com>
Date: Wed, 14 May 2014 12:15:30 -0400
From: Tony Battersby <tonyb@cybernetics.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] File Sealing & memfd_create()
References: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com> <alpine.LSU.2.11.1405132118330.4401@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1405132118330.4401@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: David Herrmann <dh.herrmann@gmail.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Kristian Hogsberg <krh@bitplanet.net>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>

Hugh Dickins wrote:
> Checking page counts in a GB file prior to sealing does not appeal at
> all: we'd be lucky ever to find them all accounted for.

Here is a refinement of that idea: during a seal operation, iterate over
all the pages in the file and check their refcounts.  On any page that
has an unexpected extra reference, allocate a new page, copy the data
over to the new page, and then replace the page having the extra
reference with the newly-allocated page in the file.  That way you still
get zero-copy on pages that don't have extra references, and you don't
have to fail the seal operation if some of the pages are still being
referenced by something else.

The downside of course is the extra memory usage and memcpy overhead if
something is holding extra references to the pages.  So whether this is
a good approach depends on:

*) Whether extra page references would happen frequently or infrequently
under various kernel configurations and usage scenarios.  I don't know
enough about the mm system to answer this myself.

*) Whether or not the extra memory usage and memcpy overhead could be
considered a DoS attack vector by someone who has found a way to add
extra references to the pages intentionally.

Tony Battersby

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
