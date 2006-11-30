Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id kAU9jqlC028498
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 09:45:52 GMT
Received: from ug-out-1314.google.com (ugeo2.prod.google.com [10.66.166.2])
	by spaceape11.eur.corp.google.com with ESMTP id kAU9jo8C023569
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 09:45:50 GMT
Received: by ug-out-1314.google.com with SMTP id o2so1867680uge
        for <linux-mm@kvack.org>; Thu, 30 Nov 2006 01:45:50 -0800 (PST)
Message-ID: <6599ad830611300145gae22510te7eaa63edf539ad1@mail.gmail.com>
Date: Thu, 30 Nov 2006 01:45:49 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to userspace
In-Reply-To: <456EA28C.8070508@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061129030655.941148000@menage.corp.google.com>
	 <456D23A0.9020008@yahoo.com.au>
	 <6599ad830611291357w34f9427bje775dfefcd000dfa@mail.gmail.com>
	 <456E8A74.5080905@yahoo.com.au>
	 <6599ad830611292357q745eb2f8y1ad9d4fb5a85c41d@mail.gmail.com>
	 <456E95C4.5020809@yahoo.com.au>
	 <6599ad830611300039m334e276i9cb3141cc5358d00@mail.gmail.com>
	 <456E9C90.4020909@yahoo.com.au>
	 <6599ad830611300106w5f5deb60q6d83a684fd679d06@mail.gmail.com>
	 <456EA28C.8070508@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On 11/30/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> >> AFAIK they do that in their higher level APIs (at least HPC numa does).
> >
> >
> > Could you point me at an example?
>
> kernel/cpuset.c:cpuset_migrate_mm

No, that doesn't really do what we want. It basically just calls
do_migrate_pages, which has the drawbacks of:

- it has no way to try to migrate memory from one source node to
multiple destination nodes.

- it doesn't (as far as I can tell) migrate unmapped file pages in the
page cache.

- it scans every page table entry of every mm in the process. If your
nodes are relatively small compared to your processes, this is likely
to be much more heavyweight than just trying to migrate each page in a
node. (I realise that there are some unsolved implementation issues
with migrating pages whilst not holding an mmap_sem of an mm that's
mapping them; that's something that we would need to solve)

>
> How about "try to change the memory reservation charge of this
> 'container' from xMB to yMB"? Underneath that API, your fakenode
> controller would do the node reclaim and consolidation stuff --
> but it could be implemented completely differently in the case of
> a different type of controller.

How would it make decisions such as which node to free up (e.g.
userspace might have a strong preference for keeping a job on one
particular real node, or moving it to a different one.) I think that
policy decisions like this belong in userspace, in the same way that
the existing cpusets API provides a way to say "this cpuset uses these
nodes" rather than "this cpuset should have N nodes".

If the API was expressive enough to say "try to shrink this cpuset by
X MB, with amount Y of effort, trying to evict nodes in the priority
order A,B,C" that might be a good start.

>
> >> The cpusets code is definitely similar to what memory resource control
> >> needs. I don't think that a resource control API needs to be tied to
> >> such granular, hard limits as the fakenodes code provides though. But
> >> maybe I'm wrong and it really would be acceptable for everyone.
> >
> >
> > Ah. This isn't intended to be specifically a "resource control API".
> > It's more intended to be an API that could be useful for certain kinds
> > of resource control, but could also be generically useful.
>
> If it is exporting any kind of implementation details, then it needs
> to be justified with a specific user that can't be implemented in a
> better way, IMO.

It's not really exporting any more implementation details than the
existing cpusets API (i.e. explicitly binding a job to a set of nodes
chosen by userspace). The only true exposed implementation detail is
the "priority" value from try_to_free_pages, and that could be
abstracted away as a value in some range 0-N where 0 means "try very
hard" and N means "hardly try at all", and it wouldn't have to be
directly linked to the try_to_free_pages() priority.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
