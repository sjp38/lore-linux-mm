Date: Tue, 2 Dec 2008 08:06:08 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] fs: shrink struct dentry
Message-ID: <20081202070608.GA28080@wotan.suse.de>
References: <20081201083343.GC2529@wotan.suse.de> <20081201175113.GA16828@totally.trollied.org.uk> <20081201180455.GJ10790@wotan.suse.de> <20081201193818.GB16828@totally.trollied.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081201193818.GB16828@totally.trollied.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Levon <levon@movementarian.org>
Cc: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, robert.richter@amd.com, oprofile-list@lists.sf.net
List-ID: <linux-mm.kvack.org>

On Mon, Dec 01, 2008 at 07:38:18PM +0000, John Levon wrote:
> On Mon, Dec 01, 2008 at 07:04:55PM +0100, Nick Piggin wrote:
> 
> > On Mon, Dec 01, 2008 at 05:51:13PM +0000, John Levon wrote:
> > > On Mon, Dec 01, 2008 at 09:33:43AM +0100, Nick Piggin wrote:
> > > 
> > > > I then got rid of the d_cookie pointer. This shrinks it to 192 bytes. Rant:
> > > > why was this ever a good idea? The cookie system should increase its hash
> > > > size or use a tree or something if lookups are a problem.
> > > 
> > > Are you saying you've made this change without even testing its
> > > performance impact?
> > 
> > For oprofile case (maybe if you are profiling hundreds of vmas and
> > overflow the 4096 byte hash table), no. That case is uncommon and
> > must be fixed in the dcookie code (as I said, trivial with changing
> > data structure). I don't want this pointer in struct dentry
> > regardless of a possible tiny benefit for oprofile.
> 
> Don't you even have a differential profile showing the impact of
> removing d_cookie? This hash table lookup will now happen on *every*
> userspace sample that's processed. That's, uh, a lot.

I don't know what you mean by every sample that's processed, but
won't the hash lookup only happen for the *first* time that a given
name is asked for a dcookie (ie. fast_get_dcookie, which, as I said,
should actually be moved to fs/dcookies.c).

If get_dcookie is called "a lot" of times, then this profiling code
is broken anyway. There is a global mutex in that function. It's bad
enough that it takes mmap_sem and does find_vma...


> (By all means make your change, but I don't get how it's OK to regress
> other code, and provide no evidence at all as to its impact.)

Tradeoffs are made all the time. This is obviously a good one, and
I provided evidence of the impact of the improvement in the common
case. I also acknowledge it can slow down the uncommon case, but
showed ways that can easily be improved. Do you want me to just try
to make an artificial case where I mmap thousands of tiny shared
libraries and try to overflow the hash and try to detect a difference?

Did you add d_cookie? If so, then surely at the time you must have
justified that with some numbers to show a significant improvement
to outweigh the clear downsides. Care to share? Then I might be able
to just reuse your test case.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
