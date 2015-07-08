Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1B0F56B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 19:28:33 -0400 (EDT)
Received: by igrv9 with SMTP id v9so211729295igr.1
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 16:28:32 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id x12si3964285ici.80.2015.07.08.16.28.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 16:28:32 -0700 (PDT)
Received: by igau2 with SMTP id u2so76232867iga.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 16:28:32 -0700 (PDT)
Date: Wed, 8 Jul 2015 16:28:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2 2/3] mm, oom: organize oom context into struct
In-Reply-To: <20150702060111.GB3989@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1507081624440.16585@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1506181555350.13736@chino.kir.corp.google.com> <alpine.DEB.2.10.1507011435150.14014@chino.kir.corp.google.com> <alpine.DEB.2.10.1507011436080.14014@chino.kir.corp.google.com> <20150702060111.GB3989@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2 Jul 2015, Michal Hocko wrote:

> On Wed 01-07-15 14:37:14, David Rientjes wrote:
> > The force_kill member of struct oom_control isn't needed if an order of
> > -1 is used instead.  This is the same as order == -1 in
> > struct compact_control which requires full memory compaction.
> > 
> > This patch introduces no functional change.
> 
> But it obscures the code and I really dislike this change as pointed out
> previously.
> 

The oom killer is often called at the end of a very lengthy stack since 
memory allocation itself can be called deep in the stack.  Thus, reducing 
the amount of memory, even for a small lil bool, is helpful.  This is 
especially true when other such structs, struct compact_control, does the 
exact same thing by using order == -1 to mean explicit compaction.

I'm personally tired of fixing stack overflows and you're arguing against 
"obscurity" that even occurs in other parts of the mm code.  
oc->force_kill has no reason to exist, and thus it's removed in this patch 
and for good reason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
