Subject: Re: [PATCH] rd: Mark ramdisk buffers heads dirty
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <m16415cocs.fsf@ebiederm.dsl.xmission.com>
References: <200710151028.34407.borntraeger@de.ibm.com>
	 <m1zlykj8zl.fsf_-_@ebiederm.dsl.xmission.com>
	 <200710160956.58061.borntraeger@de.ibm.com>
	 <200710171814.01717.borntraeger@de.ibm.com>
	 <m1sl49ei8x.fsf@ebiederm.dsl.xmission.com>
	 <1192648456.15717.7.camel@think.oraclecorp.com>
	 <m17illeb8f.fsf@ebiederm.dsl.xmission.com>
	 <1192654481.15717.16.camel@think.oraclecorp.com>
	 <m1ve95ctuc.fsf@ebiederm.dsl.xmission.com>
	 <1192661889.15717.27.camel@think.oraclecorp.com>
	 <m16415cocs.fsf@ebiederm.dsl.xmission.com>
Content-Type: text/plain
Date: Wed, 17 Oct 2007 20:03:05 -0400
Message-Id: <1192665785.15717.34.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-17 at 17:28 -0600, Eric W. Biederman wrote:
> Chris Mason <chris.mason@oracle.com> writes:
> 
> > So, the problem is using the Dirty bit to indicate pinned.  You're
> > completely right that our current setup of buffer heads and pages and
> > filesystpem metadata is complex and difficult.
> >
> > But, moving the buffer heads off of the page cache pages isn't going to
> > make it any easier to use dirty as pinned, especially in the face of
> > buffer_head users for file data pages.
> 
> Let me specific.  Not moving buffer_heads off of page cache pages,
> moving buffer_heads off of the block devices page cache pages.
> 
> My problem is the coupling of how block devices are cached and the
> implementation of buffer heads, and by removing that coupling
> we can generally make things better.  Currently that coupling
> means silly things like all block devices are cached in low memory.
> Which probably isn't what you want if you actually have a use
> for block devices.
> 
> For the ramdisk case in particular what this means is that there
> are no more users that create buffer_head mappings on the block
> device cache so using the dirty bit will be safe.

Ok, we move the buffer heads off to a different inode, and that indoe
has pages.  The pages on the inode still need to get pinned, how does
that pinning happen?

The problem you described where someone cleans a page because the buffer
heads are clean happens already without help from userland.  So, keeping
the pages away from userland won't save them from cleaning.

Sorry if I'm reading your suggestion wrong...

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
