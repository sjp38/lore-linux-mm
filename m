Date: Fri, 1 Oct 2004 20:42:00 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
Message-ID: <20041001234200.GA4635@logos.cnet>
References: <20041001182221.GA3191@logos.cnet> <20041001131147.3780722b.akpm@osdl.org> <20041001190430.GA4372@logos.cnet> <1096667823.3684.1299.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1096667823.3684.1299.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, piggin@cyberone.com.au, Arjan van de Ven <arjanv@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 01, 2004 at 02:57:03PM -0700, Dave Hansen wrote:
> On Fri, 2004-10-01 at 12:04, Marcelo Tosatti wrote:
> > On Fri, Oct 01, 2004 at 01:11:47PM -0700, Andrew Morton wrote:
> > > Presumably this duplicates some of the memory hot-remove patches.
> > 
> > As far as I have researched, the memory moving/remapping code 
> > on the hot remove patches dont work correctly. Please correct me.
> 
> I definitely see some commonality, but Marcelo's approach has handling
> for the different kinds of pages broken out much more nicely.  Can't
> tell yet if this produces extra code, or is just plain better.  
> 
> We worked pretty hard to try and copy as little code as possible.  Was
> there any reason that there was so much stuff copied out of rmap.c? 
> Just for proof-of-concept?

Just proof of concept really, to have an equivalent of "try_to_unmap()" - 
which you call from the migrate page code. 

Just that "try_to_remap_{file,anon}" do the pte clearing + remapping in
one function.

> Here's one of the recent patch sets that we're working on:
> 
> http://sprucegoose.sr71.net/patches/2.6.9-rc2-mm4-mhp-test2/
> 
> In that directory, the K* patches hijack some of the swap code (but
> require memory pressure to work last time I tried), and the p000*
> patches (by Hirokazu Takahashi) actively migrate pages around.  Both
> approaches work, but the K* one is smaller and less intrusive, while the
> p000* one is much more complete.  They may end up being able to coexist
> in the end.  

The page migration code (p000*) looks nice - quite complete indeed (nice error
handling, etc) but somewhat specific to the migration procedure, which is more 
critical (cannot fail so easily as) then the remapping for high-order allocations.

For example this in migrate_page_common


+		switch (ret) {
+		case 0:
+		case -ENOENT:
+			copy_highpage(newpage, page);
+			return ret;
+		case -EBUSY:
+			return ret;
+		case -EAGAIN:
+			writeback_and_free_buffers(page);
+			unlock_page(page);
+			msleep(10);
+			timeout -= 10;
+			lock_page(page);
+			continue;

Which retries undefinately to migrate the page

For the "defragmentation" operation we want to do an "easy" try - ie if we
can't remap giveup.

I feel we should try to "untie" the code which checks for remapping availability / 
does the remapping from the page migration - so to be able to share the most 
code between it and other users of the same functionality. 

Curiosity: How did you guys test the migration operation? Several threads on 
several processors operating on the memory, etc? 

> I don't work for Fujitsu :)  Please take a look at the patches in the
> above directory and see what you think.  I'm sure you have some very
> good stuff in your patch, but I need to take a closer look.
> 
> I'm just about to head out of town for the weekend, but I'll take a much
> more detailed look on Monday.  

Cool. I'll take a closer look at the relevant parts of memory hotplug patches 
this weekend, hopefully. See if I can help with testing of these patches too.

Andrew, what are your thoughts wrt merging this to mainline?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
