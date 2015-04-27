Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4F2736B006C
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 12:31:14 -0400 (EDT)
Received: by ykec202 with SMTP id c202so20291520yke.2
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 09:31:14 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id s5si30649431vdh.96.2015.04.27.09.31.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 27 Apr 2015 09:31:13 -0700 (PDT)
Date: Mon, 27 Apr 2015 11:31:11 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150427161504.GV5561@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.11.1504271123390.29515@gentwo.org>
References: <20150424150829.GA3840@gmail.com> <alpine.DEB.2.11.1504241052240.9889@gentwo.org> <20150424164325.GD3840@gmail.com> <alpine.DEB.2.11.1504241148420.10475@gentwo.org> <20150424171957.GE3840@gmail.com> <alpine.DEB.2.11.1504241353280.11285@gentwo.org>
 <20150424192859.GF3840@gmail.com> <alpine.DEB.2.11.1504241446560.11700@gentwo.org> <20150425114633.GI5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504271004240.28895@gentwo.org> <20150427161504.GV5561@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Mon, 27 Apr 2015, Paul E. McKenney wrote:

> I would instead look on this as a way to try out use of hardware migration
> hints, which could lead to hardware vendors providing similar hints for
> node-to-node migrations.  At that time, the benefits could be provided
> all the functionality relying on such migrations.

Ok that sounds good. These "hints" could allow for the optimization of the
page migration logic.

> > Well yes that works with read-only mappings. Maybe we can special case
> > that in the page migration code? We do not need migration entries if
> > access is read-only actually.
>
> So you are talking about the situation only during the migration itself,
> then?  If there is no migration in progress, then of course there is
> no problem with concurrent writes because the cache-coherence protocol
> takes care of things.  During migration of a given page, I agree that
> marking that page read-only on both sides makes sense.

This is sortof what happens in the current migration scheme. In the page
tables the regular entries are replaced by migration ptes and the page is
therefore inaccessible. Any access is then trapped until the page
contentshave been moved to the new location. Then the migration pte is
replaced by a real pte again that allows full access to the page. At that
point the processes that have been put to sleep because they attempted an
access to that page are woken up.

The current scheme may be improvied on by allowing read access to the page
while migration is in process. If we would change the migration entries to
allow read access then the readers would not have to be put to sleep. Only
writers would have to be put to sleep until the migration is complete.

> > And I agree that latency-sensitive applications might not tolerate
> the page being read-only, and thus would want to avoid migration.
> Such applications would of course instead rely on placing the memory.

Thats why we have the ability to switch off these automatism and that is
why we are trying to keep the OS away from certain processors.

But this is not the only concern here. The other thing is to make this fit
into existing functionaly as cleanly as possible. So I think we would be
looking at gradual improvements in the page migration logic as well as
in the support for mapping external memory via driver mmap calls, DAX
and/or RDMA subsystem functionality. Those two areas of functionality need
to work together better in order to provide a solution for your use cases.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
