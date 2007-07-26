Date: Thu, 26 Jul 2007 11:20:25 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: -mm merge plans for 2.6.23
Message-ID: <20070726092025.GA9157@elte.hu>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org> <200707102015.44004.kernel@kolivas.org> <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com> <46A57068.3070701@yahoo.com.au> <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com> <46A58B49.3050508@yahoo.com.au> <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com> <46A6CC56.6040307@yahoo.com.au> <p73abtkrz37.fsf@bingen.suse.de> <46A85D95.509@kingswood-consulting.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46A85D95.509@kingswood-consulting.co.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Frank Kingswood <frank@kingswood-consulting.co.uk>
Cc: Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Frank Kingswood <frank@kingswood-consulting.co.uk> wrote:

> > Disadvantage would be that the userland would need to be patched, 
> > but I guess it's better than adding very dubious heuristics to the 
> > kernel.
> 
> Are you going to change every single large memory application in the 
> world? As I wrote before, it is *not* about updatedb, but about all 
> applications that use a lot of memory, and then terminate.

it is about multiple problems, _one_ problem is updatedb. The _second_ 
problem is large memory applications.

note that updatedb is not a "large memory application". It simply scans 
through the filesystem and has pretty minimal memory footprint.

the _kernel_ ends up blowing up the dentry cache to a rather large size 
(because it has no idea that updatedb uses every dentry only once).

Once we give the kernel the knowledge that the dentry wont be used again 
by this app, the kernel can do a lot more intelligent decision and not 
baloon the dentry cache.

( we _do_ want to baloon the dentry cache otherwise - for things like 
  "find" - having a fast VFS is important. But known-use-once things 
  like the daily updatedb job can clearly be annotated properly. )

the 'large memory apps' are a second category of problems. And those are 
where swap-prefetch could indeed help. (as long as it only 'fills up' 
the free memory that a large-memory-exit left behind it.)

the 'morning after' phenomenon that the majority of testers complained 
about will likely be resolved by the updatedb change. The second 
category is likely an improvement too, for swap-happy desktop (and 
server) workloads.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
