From: Wolfgang Wander <wwc@rentec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17035.30820.347382.9137@gargle.gargle.HOWL>
Date: Wed, 18 May 2005 13:16:20 -0400
Subject: RE: [PATCH] Avoiding mmap fragmentation - clean rev
In-Reply-To: <200505181618.j4IGI0g09238@unix-os.sc.intel.com>
References: <17035.25471.122512.658772@gargle.gargle.HOWL>
	<200505181618.j4IGI0g09238@unix-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Wolfgang Wander' <wwc@rentec.com>, =?iso-8859-1?Q?Herv=E9_Piedvache?= <herve@elma.fr>, 'Andrew Morton' <akpm@osdl.org>, mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I don't think that a truly random mmap/munmap works well the current
cache approach.  By filling any request into the first fitting hole
(and first being the first from the current cache pointer) all large
holes are going to be filled inefficiently.(*)

Ideally you would want to have a sorted list of holes and fit new
requests in there on a best match basis.  But this patch would be even
more complex than my one.

My goal was to place small requests close to the base while leaving
larger holes open as long as possible and far from the base. 2.4
kernels did this inadvertently by always starting to search from the
base, my patch starts searching from the base (upward or downward)
if the new request is known to fit between base and current cache
pointer, thus it maintains the 2.4 quality of mixing small and large
requests and maintains the huge speedups Ingo introduced with the
cache pointer.

One way or another I believe we need to address the issue of mixed
small and large map requests.  Either via my earlier approach or by
maintaining an index of holes.  If you feel the latter is needed I'd
certainly volunteer to provide a patch for this one as well...
Likewise if there are issues with my earlier patch, I hope I can
address them as well.

              Wolfgang



(*) Sidenote: in 2.4 (and my approach) large holes close to the base
              are still not going to be cluttered with smaller
              requests, however the large ones far from the base
              are going to stay there until they are needed.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
