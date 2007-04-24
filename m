Date: Tue, 24 Apr 2007 03:00:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 10/10] mm: per device dirty threshold
Message-Id: <20070424030021.a091018d.akpm@linux-foundation.org>
In-Reply-To: <E1HgHcG-0000J5-00@dorka.pomaz.szeredi.hu>
References: <20070420155154.898600123@chello.nl>
	<20070420155503.608300342@chello.nl>
	<17965.29252.950216.971096@notabene.brown>
	<1177398589.26937.40.camel@twins>
	<E1HgGF4-00008p-00@dorka.pomaz.szeredi.hu>
	<1177403494.26937.59.camel@twins>
	<E1HgH69-0000Fl-00@dorka.pomaz.szeredi.hu>
	<1177406817.26937.65.camel@twins>
	<E1HgHcG-0000J5-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: a.p.zijlstra@chello.nl, neilb@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 24 Apr 2007 11:47:20 +0200 Miklos Szeredi <miklos@szeredi.hu> wrote:

> > Ahh, now I see; I had totally blocked out these few lines:
> > 
> > 			pages_written += write_chunk - wbc.nr_to_write;
> > 			if (pages_written >= write_chunk)
> > 				break;		/* We've done our duty */
> > 
> > yeah, those look dubious indeed... And reading back Neil's comments, I
> > think he agrees.
> > 
> > Shall we just kill those?
> 
> I think we should.
> 
> Athough I'm a little afraid, that Akpm will tell me again, that I'm a
> stupid git, and that those lines are in fact vitally important ;)
> 

It depends what they're replaced with.

That code is there, iirc, to prevent a process from getting stuck in
balance_dirty_pages() forever due to the dirtying activity of other
processes.

hm, we ask the process to write write_chunk pages each go around the loop.
So if it wrote write-chunk/2 pages on the first pass it might end up writing
write_chunk*1.5 pages total.  I guess that's rare and doesn't matter much
if it does happen - the upper bound is write_chunk*2-1, I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
