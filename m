Date: Sat, 4 Aug 2007 08:32:17 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070804063217.GA25069@elte.hu>
References: <20070803123712.987126000@chello.nl> <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Fri, 3 Aug 2007, Peter Zijlstra wrote:
> > 
> > These patches aim to improve balance_dirty_pages() and directly address three
> > issues:
> >   1) inter device starvation
> >   2) stacked device deadlocks
> >   3) inter process starvation
> 
> Ok, the patches certainly look pretty enough, and you fixed the only 
> thing I complained about last time (naming), so as far as I'm 
> concerned it's now just a matter of whether it *works* or not. I guess 
> being in -mm will help somewhat, but it would be good to have people 
> with several disks etc actively test this out.

There are positive reports in the never-ending "my system crawls like an 
XT when copying large files" bugzilla entry:

 http://bugzilla.kernel.org/show_bug.cgi?id=7372

 " vfs_cache_pressure=1
   TCQ   nr_requests
   8     128    not that bad
   1     128    snappiest configuration, almost no pauses
                (or unnoticable ones) "
 
 " 1) vfs_cache_pressure at 100, 2.6.21.5+per bdi throttling patch 
   Result is good, not as snappier as I'd want during a large copy but 
   still usable. No process seems stuck for agen, but there seems to be 
   some short (second or subsecond) moment where everything is stuck 
   (like if you run a top d 0.5, the screen is not updated on a regular
   basis).

   2) vfs_cache_pressure at 1, 2.6.21.5+per bdi throttling patch Result
   is at 2.6.17 level. It is the better combination since 2.6.17. "

 " 1) I've applied the patches posted by Peter Zijlstra in comment #76 
   to the 2.6.21-mm2 kernel to check if it removes the problem. My
   impression is that the problem is still there with those patches,
   although less visible then with the clean 2.6.21 kernel. "

so the whole problem area seems to be a "perfect storm" created by a 
combination of TCQ, IO scheduling and VM dirty handling weaknesses. Per 
device dirty throttling is a good step forward and it makes a very 
visible positive difference.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
