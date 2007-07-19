Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6JH81K6015203
	for <linux-mm@kvack.org>; Thu, 19 Jul 2007 13:08:01 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6JH80Fa387972
	for <linux-mm@kvack.org>; Thu, 19 Jul 2007 13:08:00 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6JH80W6029108
	for <linux-mm@kvack.org>; Thu, 19 Jul 2007 13:08:00 -0400
Date: Thu, 19 Jul 2007 10:07:59 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] hugetlbfs read() support
Message-ID: <20070719170759.GE2083@us.ibm.com>
References: <1184376214.15968.9.camel@dyn9047017100.beaverton.ibm.com> <20070718221950.35bbdb76.akpm@linux-foundation.org> <1184860309.18188.90.camel@dyn9047017100.beaverton.ibm.com> <20070719095850.6e09b0e8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070719095850.6e09b0e8.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Bill Irwin <bill.irwin@oracle.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On 19.07.2007 [09:58:50 -0700], Andrew Morton wrote:
> On Thu, 19 Jul 2007 08:51:49 -0700 Badari Pulavarty <pbadari@us.ibm.com> wrote:
> 
> > > > +		}
> > > > +
> > > > +		offset += ret;
> > > > +		retval += ret;
> > > > +		len -= ret;
> > > > +		index += offset >> HPAGE_SHIFT;
> > > > +		offset &= ~HPAGE_MASK;
> > > > +
> > > > +		page_cache_release(page);
> > > > +		if (ret == nr && len)
> > > > +			continue;
> > > > +		goto out;
> > > > +	}
> > > > +out:
> > > > +	return retval;
> > > > +}
> > > 
> > > This code doesn't have all the ghastly tricks which we deploy to
> > > handle concurrent truncate.
> > 
> > Do I need to ? Baaahh!!  I don't want to deal with them. 
> 
> Nick, can you think of any serious consequences of a read/truncate
> race in there?  I can't..
> 
> > All I want is a simple read() to get my oprofile working.  Please
> > advise.
> 
> Did you consider changing oprofile userspace to read the executable
> with mmap?

It's not actually oprofile's code, though, it's libbfd (used by
oprofile). And it works fine (presumably) for other binaries. Just not
for libhugetlbfs-relinked binaries because hugetlbfs doesn't behave like
a normal ramfs (perhaps it shouldn't, but that's a different argument).

But I do think a second reason to do this is to make hugetlbfs behave
like a normal fs -- that is read(), write(), etc. work on files in the
mountpoint. But that is simply my opinion.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
