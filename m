Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB256B025F
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 09:57:31 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o80so147526029wme.1
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 06:57:31 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id h11si4136898wmd.58.2016.08.04.06.57.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 06:57:30 -0700 (PDT)
Date: Thu, 4 Aug 2016 14:57:12 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] fs:Fix kmemleak leak warning in getname_flags about
 working on unitialized memory
Message-ID: <20160804135712.GK2356@ZenIV.linux.org.uk>
References: <1470260896-31767-1-git-send-email-xerofoify@gmail.com>
 <df8dd6cd-245d-0673-0246-e514b2a67fc2@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <df8dd6cd-245d-0673-0246-e514b2a67fc2@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Nicholas Krause <xerofoify@gmail.com>, akpm@linux-foundation.org, msalter@redhat.com, kuleshovmail@gmail.com, david.vrabel@citrix.com, vbabka@suse.cz, ard.biesheuvel@linaro.org, jgross@suse.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Aug 04, 2016 at 09:18:19PM +0900, Tetsuo Handa wrote:
> On 2016/08/04 6:48, Nicholas Krause wrote:
> > This fixes a kmemleak leak warning complaining about working on
> > unitializied memory as found in the function, getname_flages. Seems
> > that we are indeed working on unitialized memory, as the filename
> > char pointer is never made to point to the filname structure's result
> > member for holding it's name, fix this by using memcpy to copy the
> > filname structure pointer's, name to the char pointer passed to this
> > function.
> > 
> > Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> > ---
> >  fs/namei.c         | 1 +
> >  mm/early_ioremap.c | 1 +
> >  2 files changed, 2 insertions(+)
> > 
> > diff --git a/fs/namei.c b/fs/namei.c
> > index c386a32..6b18d57 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -196,6 +196,7 @@ getname_flags(const char __user *filename, int flags, int *empty)
> >  		}
> >  	}
> >  
> > +	memcpy((char *)result->name, filename, len);
> 
> This filename is a __user pointer. Reading with memcpy() is not safe.

Don't feed the troll.  On all paths leading to that place we have
        result->name = kname;
        len = strncpy_from_user(kname, filename, EMBEDDED_NAME_MAX);
or
                result->name = kname;
                len = strncpy_from_user(kname, filename, PATH_MAX);
with failure exits taken if strncpy_from_user() returns an error, which means
that the damn thing has already been copied into.

FWIW, it looks a lot like buggered kmemcheck; as usual, he can't be bothered
to mention which kernel version would it be (let alone how to reproduce it
on the kernel in question), but IIRC davej had run into some instrumentation
breakage lately.

Again, don't feed the troll - you are only inviting an "improved" version
of that garbage, just as pointless.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
