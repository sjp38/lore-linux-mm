Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 5DEB56B0044
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 06:15:11 -0500 (EST)
Received: by mail-vb0-f41.google.com with SMTP id l22so3844644vbn.14
        for <linux-mm@kvack.org>; Fri, 14 Dec 2012 03:15:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121214072755.GR4939@ZenIV.linux.org.uk>
References: <3b624af48f4ba4affd78466b73b6afe0e2f66549.1355463438.git.luto@amacapital.net>
 <20121214072755.GR4939@ZenIV.linux.org.uk>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 14 Dec 2012 03:14:50 -0800
Message-ID: <CALCETrVw9Pc1sUZBL=wtLvsnBnkW5LAO5iu-i=T2oMOdwQfjHg@mail.gmail.com>
Subject: Re: [PATCH] mm: Downgrade mmap_sem before locking or populating on mmap
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, J??rn Engel <joern@logfs.org>

On Thu, Dec 13, 2012 at 11:27 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Thu, Dec 13, 2012 at 09:49:43PM -0800, Andy Lutomirski wrote:
>> This is a serious cause of mmap_sem contention.  MAP_POPULATE
>> and MCL_FUTURE, in particular, are disastrous in multithreaded programs.
>>
>> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
>> ---
>>
>> Sensible people use anonymous mappings.  I write kernel patches :)
>>
>> I'm not entirely thrilled by the aesthetics of this patch.  The MAP_POPULATE case
>> could also be improved by doing it without any lock at all.  This is still a big
>> improvement, though.
>
> Wait a minute.  get_user_pages() relies on ->mmap_sem being held.  Unless
> I'm seriously misreading your patch it removes that protection.  And yes,
> I'm aware of execve-related exception; it's in special circumstances -
> bprm->mm is guaranteed to be not shared (and we need to rearchitect that
> area anyway, but that's a separate story).

Unless I completely screwed up the patch, ->mmap_sem is still held for
read (it's downgraded from write).  It's just not held for write
anymore.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
