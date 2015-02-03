Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id B57196B0038
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 04:57:27 -0500 (EST)
Received: by mail-la0-f52.google.com with SMTP id ge10so49855912lab.11
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 01:57:27 -0800 (PST)
Received: from mail-la0-x22b.google.com (mail-la0-x22b.google.com. [2a00:1450:4010:c03::22b])
        by mx.google.com with ESMTPS id l4si11348258lbp.82.2015.02.03.01.57.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 01:57:26 -0800 (PST)
Received: by mail-la0-f43.google.com with SMTP id pn19so3773624lab.2
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 01:57:25 -0800 (PST)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH 2/5] mm/page_alloc.c: Pull out init code from build_all_zonelists
References: <1422921016-27618-1-git-send-email-linux@rasmusvillemoes.dk>
	<1422921016-27618-3-git-send-email-linux@rasmusvillemoes.dk>
	<alpine.DEB.2.10.1502021624090.667@chino.kir.corp.google.com>
Date: Tue, 03 Feb 2015 10:57:23 +0100
In-Reply-To: <alpine.DEB.2.10.1502021624090.667@chino.kir.corp.google.com>
	(David Rientjes's message of "Mon, 2 Feb 2015 16:25:25 -0800 (PST)")
Message-ID: <871tm7jp18.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vishnu Pratap Singh <vishnu.ps@samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 03 2015, David Rientjes <rientjes@google.com> wrote:

> On Tue, 3 Feb 2015, Rasmus Villemoes wrote:
>
>> Pulling the code protected by if (system_state == SYSTEM_BOOTING) into
>> its own helper allows us to shrink .text a little. This relies on
>> build_all_zonelists already having a __ref annotation. Add a comment
>> explaining why so one doesn't have to track it down through git log.
>> 
>
> I think we should see the .text savings in the changelog to decide whether 
> we want a __ref function (granted, with comment) calling an __init 
> function in the source code.

Well, the real saving comes in 3/5, (mm/mm_init.c: Mark
mminit_verify_zonelist as __init), where one saves about 400
bytes. I originally did just that, while still adding a comment to
build_all_zonelists to explain both the old and new cause of __ref.

Then I noticed that cpuset_init_current_mems_allowed is also only called
from build_all_zonelists and could thus also be __init. But then the
__ref would cover two __init functions, both defined elsewhere, so I
thought it would be a little cleaner to make these calls from a single
__init function defined very close to its user. That it also happens to
shave a few bytes from build_all_zonelists is just gravy. A better
commit log would have been something like

  Pulling the code protected by if (system_state == SYSTEM_BOOTING) into
  its own helper allows us to shrink .text by a few bytes. But more
  importantly, this provides a (somewhat) clean way of annotating
  mminit_verify_zonelist and cpuset_init_current_mems_allowed with
  __init, thus saving around 450 bytes of .text.

  This relies on build_all_zonelists already having a __ref
  annotation. Add a comment explaining both uses so one doesn't have to
  track it down through git log.

Rasmus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
