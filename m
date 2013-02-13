Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id A76236B0002
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 17:49:44 -0500 (EST)
Date: Thu, 14 Feb 2013 09:19:31 +1030
From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: OOM triggered with plenty of memory free
Message-ID: <20130213224931.GA23154@marvin.atrad.com.au>
References: <20130213031056.GA32135@marvin.atrad.com.au>
 <alpine.DEB.2.02.1302121917020.11158@chino.kir.corp.google.com>
 <20130213042552.GC32135@marvin.atrad.com.au>
 <511BADEA.3070403@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <511BADEA.3070403@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Jonathan Woithe <jwoithe@atrad.com.au>

On Wed, Feb 13, 2013 at 07:14:50AM -0800, Dave Hansen wrote:
> On 02/12/2013 08:25 PM, Jonathan Woithe wrote:
> > I will see whether I can gain access to a test system and if so, try a more
> > recent kernel to see if it makes any difference.
> > 
> > I'll advise which of these options proves practical as soon as possible and
> > report any findings which come out of them.
> 
> Are there any non-upstream bits in the kernel?  Any third-party drivers
> or filesystems?

No to all three questions.  The kernel is a plain unpatched kernel.org
2.6.35.11 kernel compiled with the configuration I included in the original
email.  No third party modules have been loaded.

I should add that I have managed to get access to a test system and over the
next few days I will run tests on a number of kernels to try to narrow down
some of the unknowns associated with this problem.

> David's analysis looks spot-on.  The only other thing I'll add is that
> it just looks weird that all three kmalloc() caches are so _even_:
> 
> >> kmalloc-128       1234556 1235168    128   32    1 : tunables    0    0    0 : slabdata  38599  38599      0
> >> kmalloc-64        1238117 1238144     64   64    1 : tunables    0    0    0 : slabdata  19346  19346      0
> >> kmalloc-32        1236600 1236608     32  128    1 : tunables    0    0    0 : slabdata   9661   9661      0
> 
> It's almost like something goes and does 3 allocations in series and
> leaks them all.
> 
> There are also quite a few buffer_heads:
> 
> > buffer_head       496273 640794     56   73    1 : tunables    0    0    0 : slabdata   8778   8778      0
> 
> which seem out-of-whack for the small amount of memory being used for
> I/O-related stuff.  That kinda points in the direction of I/O or
> filesystems.

As previously stated, there is a lot of network I/O going on (input to the
tune of 20 MBytes/s) but I don't know if this is the I/O class you're
referring to.  We are also writing data to disc periodically, but since this
is post-process the amount is *much* less than the raw input rate (for the
data acquisition system we're talking of the order of 5 MBytes per minute or
less).

Regards
  jonathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
