Date: Mon, 31 Jan 2005 10:51:48 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: test_root reorder(Re: [patch] ext2: Apply Jack's ext3 speedups)
Message-ID: <20050131095148.GB2482@atrey.karlin.mff.cuni.cz>
References: <200501270722.XAA10830@allur.sanmateo.akamai.com> <20050127205233.GB9225@thunk.org> <41FAED57.DFCF1D22@akamai.com> <41FAFEF1.B13D59BA@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41FAFEF1.B13D59BA@akamai.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Prasanna Meda <pmeda@akamai.com>
Cc: Theodore Ts'o <tytso@mit.edu>, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Prasanna Meda wrote:
> 
> >   - Folded all three root checkings for 3,  5 and 7 into one loop.
> >   -  Short cut the loop with 3**n < 5 **n < 7**n logic.
> >   -  Even numbers can be ruled out.
> 
> Without going to that complicated path, the better performance
> is achieved with just reordering  of the tests from 3,5,7 to 7,5.3, so
> that average case becomes better. This is more simpler than
>  folding  patch.
  I like a bit more just to reorder the tests (though I agree that your
joined tests for 3,5,7 are probably faster) - it looks much more
readable...

>  Reorder test_root testing from 3,5,7 to 7,5,3 so
>  that average case becomes good. Even number check
>  is added. 
> 
>  Signed-off-by: Prasanna Meda <pmeda@akamai.com>
> 
> --- a/fs/ext3/balloc.c	Fri Jan 28 22:21:45 2005
> +++ b/fs/ext3/balloc.c	Sat Jan 29 02:51:39 2005
> @@ -1451,8 +1451,10 @@
>  {
>  	if (group <= 1)
>  		return 1;
> -	return (test_root(group, 3) || test_root(group, 5) ||
> -		test_root(group, 7));
> +	if (!(group & 1))
> +		return 0;
> +	return (test_root(group, 7) || test_root(group, 5) ||
> +		test_root(group, 3));
>  }
>  
>  /**

								Honza

-- 
Jan Kara <jack@suse.cz>
SuSE CR Labs
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
