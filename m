Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id DA2B26B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 12:46:43 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id l4so7513301wer.39
        for <linux-mm@kvack.org>; Mon, 06 Feb 2012 09:46:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120130202013.GJ30782@redhat.com>
References: <1327557574-6125-1-git-send-email-roland@kernel.org>
 <alpine.LSU.2.00.1201261133230.1369@eggly.anvils> <CAG4TOxNEV2VY9wOE86p9RnKGqpruB32ci9Wq3yBt8O2zc7f05w@mail.gmail.com>
 <alpine.LSU.2.00.1201271458130.3402@eggly.anvils> <CAL1RGDXqguZ2QKV=yjLXtk2n_Ag4Nf3CW+kF2BFQFR4ySTNaRA@mail.gmail.com>
 <20120130202013.GJ30782@redhat.com>
From: Roland Dreier <roland@kernel.org>
Date: Mon, 6 Feb 2012 09:46:23 -0800
Message-ID: <CAL1RGDUzYTVJJNwYzraObNvkZmOT=1oR4gBL2hKhB2harAiLLw@mail.gmail.com>
Subject: Re: [PATCH/RFC G-U-P experts] IB/umem: Modernize our get_user_pages() parameters
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, linux-rdma@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Andrea, sorry for the slow reply, had to work on other stuff for a bit.

On Mon, Jan 30, 2012 at 12:20 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> If you map it with an mmap(PROT_READ|PROT_WRITE), force or not force
> won't change a thing in terms of cows. Just make sure you map your
> control memory right, then safely remove force=1 and you won't get the
> control page cowed by mistake. Then if you map it with MAP_SHARED it
> won't be mapped read-only by fork() (leading to either parent or child
> losing the control on the device), Hugh already suggested you to use
> MAP_SHARED instead of MAP_PRIVATE.

Actually this isn't about control memory for the RDMA adapter...
as you mentioned that typically is MMIO and mapped with remap_pfn
stuff, without using any GUP stuff.

I'm talking about the registration of other memory for reading/writing
by a remote system via RDMA.

The reason I'm talking about exporting kernel memory is that I wanted
to do a debugging trick where a kernel module exposed some state
into an mmap'able buffer.  And I wanted to be able to read that state
even if my broken module killed the whole system (in fact exactly
when things crash I want to be able to read the state to figure out
why I crashed!).

So I wrote a trivial userspace program that does nothing but mmap
the buffer, accept RDMA connections from remote systems, and
map the buffer for reading over those connections.  Then I can have
a second system that connects to that process and polls the buffer.

Because all the RDMA state is setup in advance, I can keep polling
even after the first system panics.  It's sort of like that firewire remote
debugging, except I only get access to a limited memory buffer.

The only difficulty is the problem that started this thread, ie a bogus
COW so the remote system ends up polling the wrong pages.  So with
my original patch, I'm able to debug but I guess we agree it's the
wrong fix for the general problem, and I'll write up a patch that adds
what I think is the correct fix (the new FOLL flag) soon.

 - R.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
