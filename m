Date: Wed, 23 Apr 2003 14:47:32 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.5.68-mm2
Message-ID: <1565150000.1051134452@flay>
In-Reply-To: <20030423144648.5ce68d11.akpm@digeo.com>
References: <20030423012046.0535e4fd.akpm@digeo.com><18400000.1051109459@[10.10.2.4]> <20030423144648.5ce68d11.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> > . I got tired of the objrmap code going BUG under stress, so it is now in
>> >   disgrace in the experimental/ directory.
>> 
>> Any chance of some more info on that? BUG at what point in the code,
>> and with what test to reproduce?
> 
> A bash-shared-mapping (from ext3 CVS) will quickly knock it over.  It gets
> its PageAnon/page->mapping state tangled up.

OK, will try to reproduce that.
 
> - nasty, nasty problems with remap_file_pages().  I'd rather not have to
>   nobble remap_file_pages() functionality for this reason.

I don't see having to predeclare the thing as non-linear as a serious 
imposition .... I don't think memlocking them is necessary, AFAICS if
we have that.
 
> and what do we gain from it all?  The small fork/exec boost isn't very
> significant.  What we gain is more lowmem space on
> going-away-real-soon-now-we-sincerely-hope highmem boxes.

They're not going away soon (unfortunately) - even if Intel stopped producing
the chips today, the machines based on them are still in the marketplace for
years.

The performance improvement was about 25% of systime according to my 
measurements - I don't call that insignificant.

> Ingo-rmap seems a better solution to me.  It would be a fairly large change
> though - we'd have to hold the four atomic kmaps across an entire pte page
> in copy_page_range(), for example.  But it will then have good locality of
> reference between adjacent pages and may well be quicker than pte_chains.

If there was an existing implementation we could actually measure, I'd
be more impressed. From what I can see currently, it'll just introduce
masses of kmap thrashing crap with no obvious way to fix it. And it 
triples the PTE overhead. Maybe it'd work better in conjunction with 
shared pagetables.

M.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
