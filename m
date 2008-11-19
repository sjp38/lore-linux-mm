Date: Wed, 19 Nov 2008 17:58:19 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Corruption with O_DIRECT and unaligned user buffers
Message-ID: <20081119165819.GE19209@random.random>
References: <491DAF8E.4080506@quantum.com> <200811191526.00036.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200811191526.00036.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Tim LaBerge <tim.laberge@quantum.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 19, 2008 at 03:25:59PM +1100, Nick Piggin wrote:
> The solution either involves synchronising forks and get_user_pages,
> or probably better, to do copy on fork rather than COW in the case
> that we detect a page is subject to get_user_pages. The trick is in
> the details :)

We already have a patch that works.

The only trouble here is get_user_pages_fast, it breaks the fix for
fork, the current ksm (that is safe against get_user_pages but can't
be safe against get_user_pages_fast) and even migrate.c
memory-corrupts against O_DIRECT after the introduction of
get_user_pages_fast.

So I recommend focusing on how to fix get_user_pages_fast for any of
the 3 broken pieces, then hopefully the same fix will work for the
other two.

fork is special in that it even breaks against get_user_pages but
again we've a fix for that. The only problem without a solution is how
to serialize against get_user_pages_fast. A brlock was my proposal,
not nice but still better than backing out get_user_pages_fast.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
