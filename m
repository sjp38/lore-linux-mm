Date: Wed, 4 Apr 2007 22:37:29 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [rfc] no ZERO_PAGE?
Message-ID: <20070405053729.GQ2986@holomorphy.com>
References: <20070329075805.GA6852@wotan.suse.de> <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com> <20070330024048.GG19407@wotan.suse.de> <20070404033726.GE18507@wotan.suse.de> <Pine.LNX.4.64.0704040830500.6730@woody.linux-foundation.org> <6701.1175724355@turing-police.cc.vt.edu> <Pine.LNX.4.64.0704041724280.6730@woody.linux-foundation.org> <20070405023026.GE11192@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070405023026.GE11192@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Valdis.Kletnieks@vt.edu, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Andrea Arcangeli <andrea@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 04, 2007 at 05:27:31PM -0700, Linus Torvalds wrote:
>> Good point. In fact, it doesn't need to be a malloc() - I remember people 
>> doing this with Fortran programs and just having an absolutely incredibly 
>> big BSS (with traditional Fortran, dymic memory allocations are just not 
>> done).

On Thu, Apr 05, 2007 at 04:30:26AM +0200, Nick Piggin wrote:
> Sparse matrices are one thing I worry about. I don't know enough about
> HPC code to know whether they will be a problem. I know there exist
> data structures to optimise sparse matrix storage...

\begin{admission-against-interest}

Sparse matrix code goes to extreme lengths to avoid ever looking at
substantial numbers of zero floating point matrix and vector entries.
In extreme cases, hashing and various sorts of heavyweight data
structures are used to represent highly irregular structures. At various
times the matrix is not even explicitly formed. Most typical are cases
like band diagonal matrices where storage is allocated only for the
nonzero diagonals. The entire purpose of sparse algorithms is to avoid
examining or even allocating zeros.

The actual phenomenon of concern here is dense matrix code with sparse
matrix inputs. The matrices will typically not be vast but may span 1MB
or so of RAM (1024x1024 is 1M*sizeof(double), and various dense matrix
algorithms target ca. 300x300). Most of the time this will arise from
the use of dense matrix code as black box solvers called as a library
by programs not terribly concerned about efficiency until something
gets explosively inefficient (and maybe not even then), or otherwise
numerically naive programs. This, however, is arguably the majority of
the usage cases by end-user invocations, so beware, though not too much.

I'd be more concerned about large hashtables sparsely used for the
purposes of adjacency detection and other cases where large time vs.
space tradeoffs are made for probabilistic reasons involving
collisions.

\end{admission-against-interest}


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
