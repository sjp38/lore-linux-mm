Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 939506B0039
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 18:27:54 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id jt11so5030506pbb.11
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 15:27:54 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTP id sj5si12102404pab.313.2014.01.31.15.27.53
        for <linux-mm@kvack.org>;
        Fri, 31 Jan 2014 15:27:53 -0800 (PST)
Message-ID: <1391210864.2172.61.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [LSF/MM TOPIC] Fixing large block devices on 32 bit
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Fri, 31 Jan 2014 15:27:44 -0800
In-Reply-To: <52EC19E6.9010509@intel.com>
References: <1391194978.2172.20.camel@dabdike.int.hansenpartnership.com>
	 <52EC19E6.9010509@intel.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-scsi <linux-scsi@vger.kernel.org>, linux-ide <linux-ide@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Fri, 2014-01-31 at 13:47 -0800, Dave Hansen wrote:
> On 01/31/2014 11:02 AM, James Bottomley wrote:
> >      3. Increase pgoff_t and the radix tree indexes to u64 for
> >         CONFIG_LBDAF.  This will blow out the size of struct page on 32
> >         bits by 4 bytes and may have other knock on effects, but at
> >         least it will be transparent.
> 
> I'm not sure how many acrobatics we want to go through for 32-bit, but...

That's partly the question: 32 bits was dying in the x86 space (at least
until quark), but it's still predominant in embedded.

> Between page->mapping and page->index, we have 64 bits of space, which
> *should* be plenty to uniquely identify a block.  We could easily add a
> second-level lookup somewhere so that we store some cookie for the
> address_space instead of a direct pointer.  How many devices would need,
> practically?  8 bits worth?

That might work.  8 bits would get us up to 4PB, which is looking a bit
high for single disk spinning rust.  However, how would the cookie work
efficiently? remember we'll be doing this lookup every time we pull a
page out of the page cache.  And the problem is that most of our lookups
will be on file inodes, which won't be > 16TB, so it's a lot of overhead
in the generic machinery for a problem that only occurs on buffer
related page cache lookups.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
