Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 827176B006C
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 12:24:59 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id 12so6681383wgh.19
        for <linux-mm@kvack.org>; Wed, 02 Jan 2013 09:24:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <0000013bfbfbb293-ccc455ed-2db6-46e2-8362-dc418bae0def-000000@email.amazonses.com>
References: <alpine.LNX.2.00.1301020153090.18049@eggly.anvils> <0000013bfbfbb293-ccc455ed-2db6-46e2-8362-dc418bae0def-000000@email.amazonses.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 2 Jan 2013 09:24:37 -0800
Message-ID: <CA+55aFyH63agfbf+pYNRGHaprPqAJF=F19GR6ASP_RhoyDGLdA@mail.gmail.com>
Subject: Re: [PATCH 1/2] tmpfs mempolicy: fix /proc/mounts corrupting memory
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, Jan 2, 2013 at 7:57 AM, Christoph Lameter <cl@linux.com> wrote:
> On Wed, 2 Jan 2013, Hugh Dickins wrote:
>
>> @@ -2796,10 +2787,7 @@ int mpol_to_str(char *buffer, int maxlen
>>       case MPOL_BIND:
>>               /* Fall through */
>>       case MPOL_INTERLEAVE:
>> -             if (no_context)
>> -                     nodes = pol->w.user_nodemask;
>> -             else
>> -                     nodes = pol->v.nodes;
>> +             nodes = pol->v.nodes;
>>               break;
>>
>
> no_context was always true. Why is the code from the false branch kept?

no_context is zero in the caller in fs/proc/task_mmu.c, and one in the
mm/shmem.c caller. So it's not always true (for mpol_parse_str() there
is only one caller, and it's always true as Hugh said).

Anyway, I do not know why Hugh took the true case, but I don't really
imagine that it matters. So I'll take these two patches, but it would
be good if you double-checked this, Hugh.

Hugh?

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
