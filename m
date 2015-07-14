Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7504E280257
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 14:11:43 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so18439014igb.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 11:11:43 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id s17si2014558igr.61.2015.07.14.11.11.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 14 Jul 2015 11:11:43 -0700 (PDT)
Date: Tue, 14 Jul 2015 13:11:42 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] mm/slub: disable merging after enabling debug in
 runtime
In-Reply-To: <20150714131705.21442.99279.stgit@buzz>
Message-ID: <alpine.DEB.2.11.1507141304430.28065@east.gentwo.org>
References: <20150714131704.21442.17939.stgit@buzz> <20150714131705.21442.99279.stgit@buzz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue, 14 Jul 2015, Konstantin Khlebnikov wrote:

> Enabling debug in runtime breaks creation of new kmem caches:
> they have incompatible flags thus cannot be merged but unique
> names are taken by existing caches.

What breaks?

Caches may already have been merged and thus the question is what to do
about a cache that has multiple aliases if a runtime option is requested.
The solution that slub implements is to only allow a limited number of
debug operations to be enabled. Those then will appear to affect all
aliases of course.

Creating additional caches later may create additional
aliasing which will then restrict what options can be changed.

Other operations are also restricted depending on the number of objects
stored in a cache. A cache with zero objects can be easily reconfigured.
If there are objects then modifications that impact object size are not
allowed anymore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
