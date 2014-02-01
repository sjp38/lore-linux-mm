Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2E56B0031
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 19:19:53 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id lj1so5013808pab.26
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 16:19:52 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id x3si12266666pbf.31.2014.01.31.16.19.51
        for <linux-mm@kvack.org>;
        Fri, 31 Jan 2014 16:19:52 -0800 (PST)
Message-ID: <52EC3D9F.8040702@intel.com>
Date: Fri, 31 Jan 2014 16:19:43 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC] Fixing large block devices on 32 bit
References: <1391194978.2172.20.camel@dabdike.int.hansenpartnership.com>	 <52EC19E6.9010509@intel.com> <1391210864.2172.61.camel@dabdike.int.hansenpartnership.com>
In-Reply-To: <1391210864.2172.61.camel@dabdike.int.hansenpartnership.com>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: linux-scsi <linux-scsi@vger.kernel.org>, linux-ide <linux-ide@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On 01/31/2014 03:27 PM, James Bottomley wrote:
> On Fri, 2014-01-31 at 13:47 -0800, Dave Hansen wrote:
>> On 01/31/2014 11:02 AM, James Bottomley wrote:
>>>      3. Increase pgoff_t and the radix tree indexes to u64 for
>>>         CONFIG_LBDAF.  This will blow out the size of struct page on 32
>>>         bits by 4 bytes and may have other knock on effects, but at
>>>         least it will be transparent.
>>
>> I'm not sure how many acrobatics we want to go through for 32-bit, but...
> 
> That's partly the question: 32 bits was dying in the x86 space (at least
> until quark), but it's still predominant in embedded.
> 
>> Between page->mapping and page->index, we have 64 bits of space, which
>> *should* be plenty to uniquely identify a block.  We could easily add a
>> second-level lookup somewhere so that we store some cookie for the
>> address_space instead of a direct pointer.  How many devices would need,
>> practically?  8 bits worth?
> 
> That might work.  8 bits would get us up to 4PB, which is looking a bit
> high for single disk spinning rust.  However, how would the cookie work
> efficiently? remember we'll be doing this lookup every time we pull a
> page out of the page cache.  And the problem is that most of our lookups
> will be on file inodes, which won't be > 16TB, so it's a lot of overhead
> in the generic machinery for a problem that only occurs on buffer
> related page cache lookups.

I think all we have to do is set a low bit in page->mapping (or in
page->flags, but its more constrained) to say: "this isn't a direct
pointer".  We only set the bit for the buffer cache pages, and thus only
go to the slow(er) lookup path for those.  Whatever we use for the
lookups (radix tree or whatever) uses the remaining bits for an index.
We'd probably also need a last-lookup cache like mm->mmap_cache, but
probably not much more than that.

We already have page_mapping() in place to redirect folks away from
using page->mapping directly, so there shouldn't be too much code impact.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
