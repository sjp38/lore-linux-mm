Date: Sat, 4 Aug 2007 09:17:44 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
In-Reply-To: <20070804103347.GA1956@elte.hu>
Message-ID: <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
References: <20070803123712.987126000@chello.nl>
 <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>
 <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu>
 <20070804103347.GA1956@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>


On Sat, 4 Aug 2007, Ingo Molnar wrote:

> > [ my personal interest in this is the following regression: every time 
> >   i start a large kernel build with DEBUG_INFO on a quad-core 4GB RAM 
> >   box, i get up to 30 seconds complete pauses in Vim (and most other 
> >   tasks), during plain editing of the source code. (which happens when 
> >   Vim tries to write() to its swap/undo-file.) ]
> 
> hm, it turns out that it's due to vim doing an occasional fsync not only 
> on writeout, but during normal use too. "set nofsync" in the .vimrc 
> solves this problem.

Yes, that's independent. The fact is, ext3 *sucks* at fsync. I hate hate 
hate it. It's totally unusable, imnsho.

The whole point of fsync() is that it should sync only that one file, and 
avoid syncing all the other stuff that is going on, and ext3 violates 
that, because it ends up having to sync the whole log, or something like 
that. So even if vim really wants to sync a small file, you end up waiting 
for megabytes of data being written out.

I detest logging filesystems. 

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
