Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id EC44F6B002B
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 11:13:06 -0500 (EST)
Received: by mail-vb0-f41.google.com with SMTP id l22so4361180vbn.14
        for <linux-mm@kvack.org>; Fri, 14 Dec 2012 08:13:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121214144927.GS4939@ZenIV.linux.org.uk>
References: <3b624af48f4ba4affd78466b73b6afe0e2f66549.1355463438.git.luto@amacapital.net>
 <20121214072755.GR4939@ZenIV.linux.org.uk> <CALCETrVw9Pc1sUZBL=wtLvsnBnkW5LAO5iu-i=T2oMOdwQfjHg@mail.gmail.com>
 <20121214144927.GS4939@ZenIV.linux.org.uk>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 14 Dec 2012 08:12:45 -0800
Message-ID: <CALCETrUS7baKF7cdbrqX-o2qdeo1Uk=7Z4MHcxHMA3Luh+Obdw@mail.gmail.com>
Subject: Re: [PATCH] mm: Downgrade mmap_sem before locking or populating on mmap
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, J??rn Engel <joern@logfs.org>

On Fri, Dec 14, 2012 at 6:49 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Fri, Dec 14, 2012 at 03:14:50AM -0800, Andy Lutomirski wrote:
>
>> > Wait a minute.  get_user_pages() relies on ->mmap_sem being held.  Unless
>> > I'm seriously misreading your patch it removes that protection.  And yes,
>> > I'm aware of execve-related exception; it's in special circumstances -
>> > bprm->mm is guaranteed to be not shared (and we need to rearchitect that
>> > area anyway, but that's a separate story).
>>
>> Unless I completely screwed up the patch, ->mmap_sem is still held for
>> read (it's downgraded from write).  It's just not held for write
>> anymore.
>
> Huh?  I'm talking about the call of get_user_pages() in aio_setup_ring().
> With your patch it's done completely outside of ->mmap_sem, isn't it?

Oh, /that/ call to get_user_pages.  That would qualify as screwing up...

Since dropping and reacquiring mmap_sem there is probably a bad idea
there, I'll rework this and post a v2.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
