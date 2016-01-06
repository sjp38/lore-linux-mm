Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 117F66B0005
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 14:43:41 -0500 (EST)
Received: by mail-qg0-f44.google.com with SMTP id b35so180910569qge.0
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 11:43:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 2si98045086qgi.13.2016.01.06.11.43.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 11:43:40 -0800 (PST)
Date: Wed, 6 Jan 2016 20:43:31 +0100
From: Mateusz Guzik <mguzik@redhat.com>
Subject: Re: [PATCH 2/2] proc read mm's {arg,env}_{start,end} with mmap
 semaphore taken.
Message-ID: <20160106194329.GB14492@mguzik>
References: <1452056549-10048-1-git-send-email-mguzik@redhat.com>
 <1452056549-10048-3-git-send-email-mguzik@redhat.com>
 <CAKeScWjvz7Bja6wMw5euWNWYdZ5_ikEdgR1Qk77pcCFajHmbeQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAKeScWjvz7Bja6wMw5euWNWYdZ5_ikEdgR1Qk77pcCFajHmbeQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.linux@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexey Dobriyan <adobriyan@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jarod Wilson <jarod@redhat.com>, Jan Stancek <jstancek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>

On Wed, Jan 06, 2016 at 03:14:22PM +0530, Anshuman Khandual wrote:
> On Wed, Jan 6, 2016 at 10:32 AM, Mateusz Guzik <mguzik@redhat.com> wrote:
> > Only functions doing more than one read are modified. Consumeres
> > happened to deal with possibly changing data, but it does not seem
> > like a good thing to rely on.
> 
> There are no other functions which might be reading mm-> members without
> having a lock ? Why just deal with functions with more than one read ?

Ideally all functions would read stuff with some kind of lock.

However, if only one field is read, the lock does not change anything.
Similarly, if multiple fields are read, but are not used for
calculations against each other, the lock likely does not change
anything, so there is no rush here.

Using mmap_sem in all places may or may not be possible as it is, and
even if it is possible it may turn out to be wasteful and maybe
something else should be derived for protection of said fields (maybe a
seq counter?).

That said, patches here only deal with one actual I found and patch up
consumers which had the most potential for trouble. Patching everything
in some way definitely sounds like a good idea and I may get around to
that.

-- 
Mateusz Guzik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
