Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id EE7406B0031
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 00:32:04 -0400 (EDT)
Date: Mon, 9 Sep 2013 13:32:18 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [REPOST PATCH 3/4] slab: introduce byte sized index for the
 freelist of a slab
Message-ID: <20130909043217.GB22390@lge.com>
References: <1378447067-19832-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1378447067-19832-4-git-send-email-iamjoonsoo.kim@lge.com>
 <00000140f3fed229-f49b95d4-7087-476f-b2c9-37846749aad6-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00000140f3fed229-f49b95d4-7087-476f-b2c9-37846749aad6-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 06, 2013 at 03:58:18PM +0000, Christoph Lameter wrote:
> On Fri, 6 Sep 2013, Joonsoo Kim wrote:
> 
> > Currently, the freelist of a slab consist of unsigned int sized indexes.
> > Most of slabs have less number of objects than 256, since restriction
> > for page order is at most 1 in default configuration. For example,
> > consider a slab consisting of 32 byte sized objects on two continous
> > pages. In this case, 256 objects is possible and these number fit to byte
> > sized indexes. 256 objects is maximum possible value in default
> > configuration, since 32 byte is minimum object size in the SLAB.
> > (8192 / 32 = 256). Therefore, if we use byte sized index, we can save
> > 3 bytes for each object.
> 
> Ok then why is the patch making slab do either byte sized or int sized
> indexes? Seems that you could do a clean cutover?
> 
> 
> As you said: The mininum object size is 32 bytes for slab. 32 * 256 =
> 8k. So we are fine unless the page size is > 8k. This is true for IA64 and
> powerpc only I believe. The page size can be determined at compile time
> and depending on that page size you could then choose a different size for
> the indexes. Or the alternative is to increase the minimum slab object size.
> A 16k page size would require a 64 byte minimum allocation. But thats no
> good I guess. byte sized or short int sized index support would be enough.

Sorry for misleading commit message.

32 byte is not minimum object size, minimum *kmalloc* object size
in default configuration. There are some slabs that their object size is
less than 32 byte. If we have a 8 byte sized kmem_cache, it has 512 objects
in 4K page.

Moreover, we can configure slab_max_order in boot time so that we can't know
how many object are in a certain slab in compile time. Therefore we can't
decide the size of the index in compile time.

I think that byte and short int sized index support would be enough, but
it should be determined at runtime.

> 
> > This introduce one likely branch to functions used for setting/getting
> > objects to/from the freelist, but we may get more benefits from
> > this change.
> 
> Lets not do that.

IMHO, this is as best as we can. Do you have any better idea?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
