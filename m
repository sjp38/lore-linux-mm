Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id AAA24451
	for <linux-mm@kvack.org>; Wed, 5 Feb 2003 00:48:01 -0800 (PST)
Date: Wed, 5 Feb 2003 00:48:23 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Doubt in pagefault handler..!
Message-Id: <20030205004823.30acdfe0.akpm@digeo.com>
In-Reply-To: <20030204174944.GA836@192.168.3.73>
References: <20030204174944.GA836@192.168.3.73>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Navil Joseph <cs99185@nitc.ac.in>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

John Navil Joseph <cs99185@nitc.ac.in> wrote:
>
> 	1) add the current process to a wait queue 
> 	2) invoke schedule() from the page fault handler
> 	3) wake up the process after the transfer has been completed.

You probably don't need to do all that by hand - you should be calling
non-blocking functions in the network layer, and waking the faulting process
up on completion of network I/O (based on interrupt-time networking
callbacks).

Looking at the NFS and SMB client code may help.

> i tried to trace pagefault handler all the way down to where the acutal IO
> takes palce incase of the transfer of page from swap to memory..But i never
> saw schedule() anywhere. But i know that process sleeps on page I/O .. then
> how and where does this sleeping takes place.?

The faulting process will sleep in wait_on_page() or lock_page().  See
filemap_nopage(), around the page_not_uptodate label.

The filesystem's responsibility is to run unlock_page() against the page once
its contents have been filled in from the backing medium (disk, network,
etc).  it will typically do this from interrupt context.  The unlock_page()
will wake up the faulting process.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
