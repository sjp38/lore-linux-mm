Date: Tue, 22 Nov 2005 04:23:21 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] properly account readahead file major faults
Message-ID: <20051122062321.GA30413@logos.cnet>
References: <20051121140038.GA27349@logos.cnet> <20051122042443.GA4588@mail.ustc.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051122042443.GA4588@mail.ustc.edu.cn>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Wu Fengguang <wfg@mail.ustc.edu.cn>, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Wu!

On Tue, Nov 22, 2005 at 12:24:43PM +0800, Wu Fengguang wrote:
> Hi,
> 
> On Mon, Nov 21, 2005 at 12:00:38PM -0200, Marcelo Tosatti wrote:
> > Hi,
> > 
> > The fault accounting of filemap_dopage() is currently unable to account
> > for readahead pages as major faults.
> 
> Sorry, I don't know much about the definition of major/minor page faults.
> So I googled one that explains the old behavior:
> 
> --> Page Faults <--
> These come in two varieties. Minor and Major faults. A Major fault results
> when an application tries to access a memory page that has been swapped out to
> disk. The page must be swapped back in. A Minor fault results when an
> application tries to access a memory page that is still in memory, but the
> physical location of which is not immediately known. The address must be
> looked up.

Yep, just that "swapped out"/"swappin in" can be though of as "read
in/"read out".

> With the current accounting logic:
> - major faults reflect the times one has to wait for real I/O.
> - the more success read-ahead, the less major faults.
> - anyway, major+minor faults remain the same for the same benchmark.
> 
> With your patch:
> - major faults are expected to remain the same with whatever read-ahead.
> - but what's the new meaning of minor faults?

With the patch minor faults are only those faults which can be serviced
by the pagecache, requiring no I/O.

Pages which hit the first time in cache due to readahead _have_ caused
IO, and as such they should be counted as major faults.

I suppose that if you want to count readahead hits it should be done
separately (which is now "sort of" available with the "majflt" field).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
