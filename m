Date: Wed, 7 Nov 2007 17:41:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] radix-tree: avoid atomic allocations for preloaded
 insertions
Message-Id: <20071107174114.ff922fec.akpm@linux-foundation.org>
In-Reply-To: <20071107.173419.22426986.davem@davemloft.net>
References: <20071108004304.GD3227@wotan.suse.de>
	<20071107170923.6cf3c389.akpm@linux-foundation.org>
	<20071107.173419.22426986.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Wed, 07 Nov 2007 17:34:19 -0800 (PST) David Miller <davem@davemloft.net> wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Wed, 7 Nov 2007 17:09:23 -0800
> 
> > Why not just stomp the warning with __GFP_NOWARN?
> > 
> > Did you consider turning off __GFP_HIGH?  (Dunno why)
> > 
> > This change will slow things down - has this been quantified?  Probably
> > it's unmeasurable, but it's still there.
> > 
> > I'd have thought that a superior approach would be to just set
> > __GFP_NOWARN?
> 
> I've rerun my test case which triggers this on Niagara 2
> and I no longer get the messages.

With Nick's patch, I assume?

> For reference I first create N 16GB sparse files with
> a script such as:
> 
> #!/bin/sh
> #
> # Usage: create_sparse NUM_FILES
> 
> for i in $(seq $1)
> do
>    dd if=/dev/zero of=sparse_file_$i bs=1MB count=1 seek=$((16 * 1024))
> done
> 
> And then I fork off N threads, each running dd over one of
> those sparse files with a script like:
> 
> #!/bin/sh
> #
> # Usage: thread_sparse NUM_THREADS
> 
> for i in $(seq $1)
> do
>     dd bs=1M if=sparse_file_$i of=/dev/null &
> done
> 
> wait
> 
> On my Niagara 2 box I use '64' for 'N', so I go:
> 
> create_sparse 64
> thread_sparse 64

Yeah, draining the GFP_ATOMIC reserves is bad.  Setting __GFP_NOWARN and
clearing __GFP_HIGH should plug this, but which appropach is the best? 
Unsure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
