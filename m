Message-ID: <466E6051.1080500@suse.cz>
Date: Tue, 12 Jun 2007 10:58:57 +0200
From: Petr Tesarik <ptesarik@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 16] OOM related fixes
References: <patchbomb.1181332978@v2.random> <20070608212610.GA11773@holomorphy.com> <20070609145547.GC7130@v2.random>
In-Reply-To: <20070609145547.GC7130@v2.random>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andrea Arcangeli wrote:
> Hi Wil,
> 
> On Fri, Jun 08, 2007 at 02:26:10PM -0700, William Lee Irwin III wrote:
>> Interesting. This seems to demonstrate a need for file IO to handle
>> fatal signals, beyond just people wanting faster responses to kill -9.
>> Perhaps it's the case that fatal signals should always be handled, and
>> there should be no waiting primitives excluding them. __GFP_NOFAIL is
>> also "interesting."
> 
> Clearly the sooner we respond to a SIGKILL the better. We tried to
> catch the two critical points to solve the evil read(huge)->oom. BTW,
> the first suggestion that we had to also break out of read to make
> progress substantially quicker, was from Petr so I'm cc'ing him. I'm

Late as always... :((
It's not only about getting it quicker - the loop wouldn't break until
the whole chunk has been read, which couldn't be accomplished until some
memory was freed first, but the memory would be freed by killing this
task which wouldn't terminate until everything is read, and so on... We
obviously need to break the vicious circle somewhere.

If we want to resolve all such cases we would have to ensure that
delivering a SIGKILL can't fail on OOM conditions, i.e. that SIGKILL can
always be handled without memory allocation. I'm planning to do some
investigations on which places in the kernel are (worst) affected and
then think about ways of fixing them. I don't expect we can fix them
all, or at least not in the first round, but this looks like the only
way to go...

Cheers,
Petr Tesarik

> unsure what else of more generic we could do to solve more of those
> troubles at the same time without having to pollute the code with
> sigkill checks. For example we're not yet covering the o-direct paths
> but I did the minimal changes to resolve the current workload and that
> used buffered io of course ;). BTW, I could have checked the
> TIF_MEMDIE instead of seeing if sigkill was pending, but since I had
> to check the task structure anyway, I preferred to check for the
> sigkill so that kill -9 will now work for the first time against a
> large read/write syscall, besides allowing the TIF_MEMDIE task to exit
> in reasonable time without triggering the deadlock detection in the
> later patches.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFGbmBRjpY2ODFi2ogRAseoAKCV+rX+PTmdGdjmjdObBwmdYDlqXACfXI9f
BT5dOXg5qPVhH7Wj/DlHCP4=
=ZlW9
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
