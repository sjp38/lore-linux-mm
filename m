Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id ACA426B0087
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 02:58:41 -0500 (EST)
From: Lubos Lunak <l.lunak@suse.cz>
Subject: Re: Improving OOM killer
Date: Thu, 4 Feb 2010 08:58:32 +0100
References: <201002012302.37380.l.lunak@suse.cz> <201002032355.01260.l.lunak@suse.cz> <alpine.DEB.2.00.1002031600490.27918@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1002031600490.27918@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <201002040858.33046.l.lunak@suse.cz>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Thursday 04 of February 2010, David Rientjes wrote:
> On Wed, 3 Feb 2010, Lubos Lunak wrote:
> >  As far as I'm concerned, this is a huge improvement over the current
> > code (and, incidentally :), quite close to what I originally wanted). I'd
> > be willing to test it in few real-world desktop cases if you provide a
> > patch.
>
> There're some things that still need to be worked out,

 Ok. Just please do not let the perfect stand in the way of the good for way 
too long.

> Do you have any comments about the forkbomb detector or its threshold that
> I've put in my heuristic?  I think detecting these scenarios is still an
> important issue that we need to address instead of simply removing it from
> consideration entirely.

 I think before finding out the answer it should be first figured out what the 
question is :). Besides the vague "forkbomb" description I still don't know 
what realistic scenarios this is supposed to handle. IMO trying to cover 
intentional abuse is a lost fight, so I think the purpose of this code should 
be just to handle cases when there's a mistake leading to relatively fast 
spawning of children of a specific parent that'll lead to OOM. The shape of 
the children subtree doesn't matter, it can be either a parent with many 
direct children, or children being created recursively, I think any case is 
possible here. A realistic example would be e.g. by mistake 
typing 'make -j22' instead of 'make -j2' and overloading the machine by too 
many g++ instances. That would be actually a non-trivial tree of children, 
with recursive make and sh processes in it.

 A good way to detect this would be checking in badness() if the process has 
any children with relatively low CPU and real time values (let's say 
something less than a minute). If yes, the badness score should also account 
for all these children, recursively. I'm not sure about the exact formula, 
just summing up the memory usage like it is done now does not fit your 0-1000 
score idea, and it's also wrong because it doesn't take sharing of memory 
into consideration (e.g. a KDE app with several kdelibs-based children could 
achieve a massive score here because of extensive sharing, even though the 
actual memory usage increase caused by them could be insignificant). I don't 
know kernel internals, so I don't know how feasible it would be, but one 
naive idea would be to simply count how big portion of the total memory all 
these considered processes occupy.

 This indeed would not handle the case when a tree of processes would slowly 
leak, for example there being a bug in Apache and all the forked children of 
the master process leaking memory equally, but none of the single children 
leaking enough to score more than a single unrelated innocent process. Here I 
question how realistic such scenario actually would be, and mainly the actual 
possibility of detecting such case. I do not see how code could distinguish 
this from the case of using Konsole or XTerm to launch a number of unrelated 
KDE/X applications each of which would occupy a considerable amount of 
memory. Here clearly killing the Konsole/XTerm and all the spawned 
applications with it is incorrect, so with no obvious offender the OOM killer 
would simply have to pick something. And since you now probably feel the urge 
to point out oom_adj again, I want to point out again that it's not a very 
good solution for the desktop and that Konsole/XTerm should not have such 
protection, unless the user explicitly does it themselves - e.g. Konsole can 
be set to infinite scrollback, so when accidentally running something that 
produces a huge amount of output Konsole actually could be the only right 
process to kill. So I think the case of slowly leaking group of children 
cannot be reasonably solved in code.

-- 
 Lubos Lunak
 openSUSE Boosters team, KDE developer
 l.lunak@suse.cz , l.lunak@kde.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
