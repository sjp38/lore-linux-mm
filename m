Received: from westrelay03.boulder.ibm.com (westrelay03.boulder.ibm.com [9.17.195.12])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j04Hex9g082350
	for <linux-mm@kvack.org>; Tue, 4 Jan 2005 12:40:59 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay03.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j04Hex7j367998
	for <linux-mm@kvack.org>; Tue, 4 Jan 2005 10:40:59 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j04HexLw018490
	for <linux-mm@kvack.org>; Tue, 4 Jan 2005 10:40:59 -0700
Subject: Re: process page migration
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <41DAD2AF.80604@sgi.com>
References: <41D99743.5000601@sgi.com>	<1104781061.25994.19.camel@localhost>
	 <41D9A7DB.2020306@sgi.com> <20050104.234207.74734492.taka@valinux.co.jp>
	 <41DAD2AF.80604@sgi.com>
Content-Type: text/plain
Date: Tue, 04 Jan 2005 09:40:56 -0800
Message-Id: <1104860456.7581.21.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>, Rick Lindsley <ricklind@us.ibm.com>, "Matthew C. Dobson [imap]" <colpatch@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-01-04 at 11:30 -0600, Ray Bryant wrote:
> My thinking on this was to update the mempolicy after page migration.
> This works for my purposes since my plan is to
> 
> (1)  suspend the process via SIGSTOP
> (2)  update the mempolicy
> (3)  migrate the process's pages
> (4)  migrate the process to the new cpu via set_schedaffinity()
> (5)  resume the process via SIGCONT
> 
> These steps are to be performed via a user space program that implements
> the actual migration function; the (2)-(4) are just the system calls that
> implement this.  This keeps some of the function (i. e. which processes to
> migrate) out of the kernel and allows the user some flexibility in what
> order operations are performed as well as other functions that may go
> along with this migration request.  (The actual function we are trying
> to implement is to support >>job<< migration from one set of NUMA nodes to
> another, and a job may consist of several processes.)

We already have scheduler code which has some knowledge of when a
process is dragged from one node to another.  Combined with the per-node
RSS, could we make a decision about when a process needs to have
migration performed on its pages on a more automatic basis, without the
syscalls?

We could have a tunable for how aggressive this mechanism is, so that
the process wouldn't start running again on the more strict SGI machines
until a very large number of the pages are pulled over.  However, on
machines where process latency is more of an issue, the tunable could be
set to a much less aggressive value.

This would give normal, somewhat less exotic, NUMA machines the benefits
of page migration without the need for the process owner to do anything
manually to them, while also making sure that we keep the number of
interfaces to the migration code to a relative minimum.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
