Date: Fri, 22 Oct 2004 19:04:03 +0200
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: [PATCH] zap_pte_range should not mark non-uptodate pages dirty
Message-ID: <20041022170403.GI14325@dualathlon.random>
References: <1098393346.7157.112.camel@localhost> <20041021144531.22dd0d54.akpm@osdl.org> <20041021223613.GA8756@dualathlon.random> <20041021160233.68a84971.akpm@osdl.org> <20041021232059.GE8756@dualathlon.random> <20041021164245.4abec5d2.akpm@osdl.org> <20041022003004.GA14325@dualathlon.random> <20041022012211.GD14325@dualathlon.random> <20041021190320.02dccda7.akpm@osdl.org> <20041022161744.GF14325@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041022161744.GF14325@dualathlon.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: shaggy@austin.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 22, 2004 at 06:17:44PM +0200, Andrea Arcangeli wrote:
> So let's forget the mmapped case and let's fix the bh screwup in 2.6.

I propose a solution to fix the coherency problem that afflicts 2.6 if
invalidate_complete_page fails. If the page is still PagePrivate despite
we called try_to_release_page (which means clearing the uptodate bitflag
wouldn't help), we should simply return an error to the O_DIRECT writes.
That way the error would not be overlooked by the database writing. This
is a minium guarantee we have to provide: if we fail invalidate cause
the O_DIRECT write to fail.

Of course we should return write failures as well in the mmapped case,
but let's ignore the mmapped case for now.

The real showstopper bug is try_to_release_page failing and preventing
the coherency protocol to work even without mmaps. This could never
happen in 2.4, in 2.4 as worse ext3 would get an hearth attack, which is
much better than silent corruption in the backup.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
