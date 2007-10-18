Date: Wed, 17 Oct 2007 21:32:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH] block: Isolate the buffer cache in it's own
 mappings.
Message-Id: <20071017213216.b2d0c4bd.akpm@linux-foundation.org>
In-Reply-To: <m1tzopaxa1.fsf_-_@ebiederm.dsl.xmission.com>
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
	<1192665785.15717.34.camel@think.oraclecorp.com>
	<m1tzopaxa1.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Chris Mason <chris.mason@oracle.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Oct 2007 21:59:02 -0600 ebiederm@xmission.com (Eric W. Biederman) wrote:

> If filesystems care at all they want absolute control over the buffer
> cache.  Controlling which buffers are dirty and when.  Because we
> keep the buffer cache in the page cache for the block device we have
> not quite been giving filesystems that control leading to really weird
> bugs.
> 
> In addition this tieing of the implemetation of block device caching
> and the buffer cache has resulted in a much more complicated and
> limited implementation then necessary.  Block devices for example
> don't need buffer_heads, and it is perfectly reasonable to cache
> block devices in high memory.
> 
> To start untangling the worst of this mess this patch introduces a
> second block device inode for the buffer cache.  All buffer cache
> operations are diverted to that use the new bd_metadata_inode, which
> keeps the weirdness of the metadata requirements isolated in their
> own little world.

I don't think we little angels want to tread here.  There are so many
weirdo things out there which will break if we bust the coherence between
the fs and /dev/hda1.  Online resize, online fs checkers, various local
tools which people have hacked up to look at metadata in a live fs,
direct-io access to the underlying fs, heaven knows how many boot loader
installers, etc.  Cerainly I couldn't enumerate tham all.

The mere thought of all this scares the crap out of me.


I don't actually see what the conceptual problem is with the existing
implementation.  The buffer_head is a finer-grained view onto the
blockdev's pagecache: it provides additional states and additional locking
against a finer-grained section of the page.   It works well.

Yeah, the highmem thing is a bit of a problem (but waning in importance). 
But we can fix that by teaching individual filesystems about kmap and then
tweak the blockdev's caching policy with mapping_set_gfp_mask() at mount
time.  If anyone cares, which they don't.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
