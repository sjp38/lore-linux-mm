Subject: Re: differences between MADV_FREE and MADV_DONTNEED
From: Nicholas Miell <nmiell@comcast.net>
In-Reply-To: <43CC3922.2070205@FreeBSD.org>
References: <20051102014321.GG24051@opteron.random>
	 <1130947957.24503.70.camel@localhost.localdomain>
	 <20051111162511.57ee1af3.akpm@osdl.org>
	 <1131755660.25354.81.camel@localhost.localdomain>
	 <20051111174309.5d544de4.akpm@osdl.org> <43757263.2030401@us.ibm.com>
	 <20060116130649.GE15897@opteron.random> <43CBC37F.60002@FreeBSD.org>
	 <20060116162808.GG15897@opteron.random> <43CBD1C4.5020002@FreeBSD.org>
	 <20060116172449.GL15897@opteron.random>
	 <m1r777rgq4.fsf@ebiederm.dsl.xmission.com>  <43CC3922.2070205@FreeBSD.org>
Content-Type: text/plain
Date: Mon, 16 Jan 2006 17:04:07 -0800
Message-Id: <1137459847.2842.6.camel@entropy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Cc: Ulrich Drepper <drepper@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andrea Arcangeli <andrea@suse.de>, Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, hugh@veritas.com, dvhltc@us.ibm.com, linux-mm@kvack.org, blaisorblade@yahoo.it, jdike@addtoit.com
List-ID: <linux-mm.kvack.org>

On Mon, 2006-01-16 at 16:24 -0800, Suleiman Souhlal wrote:
> Eric W. Biederman wrote:
> > As I recall the logic with DONTNEED was to mark the mapping of
> > the page clean so the page didn't need to be swapped out, it could
> > just be dropped.
> > 
> > That is why they anonymous and the file backed cases differ.
> > 
> > Part of the point is to avoid the case of swapping the pages out if
> > the application doesn't care what is on them anymore.
> 
> Well, imho, MADV_DONTNEED should mean "I won't need this anytime soon", 
> and MADV_FREE "I will never need this again".
> 

POSIX doesn't have a madvise(), but it does have a posix_madvise(), with
flags defined as follows:

POSIX_MADV_NORMAL
   Specifies that the application has no advice to give on its behavior
with respect to the specified range. It is the default characteristic if
no advice is given for a range of memory.
POSIX_MADV_SEQUENTIAL
   Specifies that the application expects to access the specified range
sequentially from lower addresses to higher addresses.
POSIX_MADV_RANDOM
   Specifies that the application expects to access the specified range
in a random order.
POSIX_MADV_WILLNEED
   Specifies that the application expects to access the specified range
in the near future.
POSIX_MADV_DONTNEED
   Specifies that the application expects that it will not access the
specified range in the near future.

Note that glibc forwards posix_madvise() directly to madvise(2), which
means that right now, POSIX conformant apps which use
posix_madvise(addr, len, POSIX_MADV_DONTNEED) are silently corrupting
data on Linux systems.

-- 
Nicholas Miell <nmiell@comcast.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
