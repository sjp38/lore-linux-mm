Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id kAUAeHpS003564
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 02:40:17 -0800
Received: from nf-out-0910.google.com (nfcm18.prod.google.com [10.48.114.18])
	by zps78.corp.google.com with ESMTP id kAUAeDDK023523
	for <linux-mm@kvack.org>; Thu, 30 Nov 2006 02:40:13 -0800
Received: by nf-out-0910.google.com with SMTP id m18so2774887nfc
        for <linux-mm@kvack.org>; Thu, 30 Nov 2006 02:40:12 -0800 (PST)
Message-ID: <6599ad830611300240x388ef00s60183bc3a105ed2a@mail.gmail.com>
Date: Thu, 30 Nov 2006 02:40:12 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to userspace
In-Reply-To: <456EAF4D.5000804@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061129030655.941148000@menage.corp.google.com>
	 <456E8A74.5080905@yahoo.com.au>
	 <6599ad830611292357q745eb2f8y1ad9d4fb5a85c41d@mail.gmail.com>
	 <456E95C4.5020809@yahoo.com.au>
	 <6599ad830611300039m334e276i9cb3141cc5358d00@mail.gmail.com>
	 <456E9C90.4020909@yahoo.com.au>
	 <6599ad830611300106w5f5deb60q6d83a684fd679d06@mail.gmail.com>
	 <456EA28C.8070508@yahoo.com.au>
	 <6599ad830611300145gae22510te7eaa63edf539ad1@mail.gmail.com>
	 <456EAF4D.5000804@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On 11/30/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
> I know it doesn't do what you want. It is an example of using page
> migration under a higher level API, which I thought is what you
> wanted to see.

I'd been talking about the possibility of doing "try to move all
memory from this node to this other set of nodes"; that wasn't an
example of such an API.

>
> Now you're talking about physical nodes as well, which is definitely
> a problem you get when mixing the two.
>
> But there is no reason why you shouldn't be able to specify physical
> nodes, while also altering the reservation. Even if that does mean
> hiding the fake nodes from the cpuset interface.

I think it should be possible to expose the real numa topology via the
fake topology (e.g. all fake nodes on the same real node appear to be
fairly close together, compared to any fake nodes on a different real
node). So I don't think it's necessary to have a separate abstraction
for fake vs physical nodes.

>
> >> If it is exporting any kind of implementation details, then it needs
> >> to be justified with a specific user that can't be implemented in a
> >> better way, IMO.
> >
> >
> > It's not really exporting any more implementation details than the
> > existing cpusets API (i.e. explicitly binding a job to a set of nodes
> > chosen by userspace). The only true exposed implementation detail is
> > the "priority" value from try_to_free_pages, and that could be
> > abstracted away as a value in some range 0-N where 0 means "try very
> > hard" and N means "hardly try at all", and it wouldn't have to be
> > directly linked to the try_to_free_pages() priority.
>
> Or the fact that memory reservation is implemented with nodes.

Right, but to me that's a pretty fundamental design decision, rather
than an implementation detail.

> I'm
> still not convinced that idea is the best way to export memory
> control to userspace, regardless of whether it is quick and easy to
> develop (or even deploy, at google).

Maybe not the best way for all memory control, but it has certain big
advantages, such as leveraging the existing numa support, and not
requiring additional per-page overhead or LRU complexity.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
