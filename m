Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id kAU7vYFE010600
	for <linux-mm@kvack.org>; Wed, 29 Nov 2006 23:57:34 -0800
Received: from nf-out-0910.google.com (nfcm19.prod.google.com [10.48.114.19])
	by zps37.corp.google.com with ESMTP id kAU7vOvQ000684
	for <linux-mm@kvack.org>; Wed, 29 Nov 2006 23:57:24 -0800
Received: by nf-out-0910.google.com with SMTP id m19so3020709nfc
        for <linux-mm@kvack.org>; Wed, 29 Nov 2006 23:57:23 -0800 (PST)
Message-ID: <6599ad830611292357q745eb2f8y1ad9d4fb5a85c41d@mail.gmail.com>
Date: Wed, 29 Nov 2006 23:57:23 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 1/1] Expose per-node reclaim and migration to userspace
In-Reply-To: <456E8A74.5080905@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20061129030655.941148000@menage.corp.google.com>
	 <20061129033826.268090000@menage.corp.google.com>
	 <456D23A0.9020008@yahoo.com.au>
	 <6599ad830611291357w34f9427bje775dfefcd000dfa@mail.gmail.com>
	 <456E8A74.5080905@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On 11/29/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
> Yes, but when you migrate tasks between these containers, or when you
> create/destroy them, then why can't you do the migration at that time?

?

The migration that I'm envisaging is going to occur when either:

- we're trying to move a job to a different real numa node because,
say, a new job has started that needs the whole of a node to itself,
and we need to clear space for it.

- we're trying to compact the memory usage of a job, when it has
plenty of free space in each of its nodes, and we can fit all the
memory into a smaller set of nodes.

Neither of these are tied to create/destroy time or moving processes
in/out of jobs (in fact we'd not be planning to move processes between
jobs - once a process is in a job it would stay there, although I
realise other people would have different requirements).

> > I don't think it would - keeping as much of the code as possible in
> > userspace makes development and deployment much faster. We don't
> > really have any higher-level APIs at this point - just userspace
> > middleware manipulating cpusets.
>
> We can't use that as an argument for the upstream kernel, but I
> would believe that it is a good choice for google.
>

I would have thought that providing userspace just enough hooks to do
what it needs to do, and not mandating higher-level constructs is
exactly the philosophy of the linux kernel. Hence, e.g. providing
efficient building blocks like sendfile and a threaded network stack,
faster therading with NPTL and a very limited static-file webserver
(TUX, even though it's not in the mainline) and leaving the complex
bits of webserving to userspace.

Things like deciding which containers should be using which nodes, and
directing the kernel appropriately, is the job of userspace, not
kernelspace, since there are lots of possible ways of making those
decisions.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
