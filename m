Date: Wed, 29 Jan 2003 18:00:07 -0800
From: Richard Henderson <rth@twiddle.net>
Subject: Re: Linus rollup
Message-ID: <20030129180007.B19969@twiddle.net>
References: <20030129022617.62800a6e.akpm@digeo.com> <1043879752.10150.387.camel@dell_ss3.pdx.osdl.net> <20030129151206.269290ff.akpm@digeo.com> <20030129.163034.130834202.davem@redhat.com> <20030129172743.1e11d566.akpm@digeo.com> <20030130013522.GP1237@dualathlon.random> <20030129180054.03ac0d48.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030129180054.03ac0d48.akpm@digeo.com>; from akpm@digeo.com on Wed, Jan 29, 2003 at 06:00:54PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Andrea Arcangeli <andrea@suse.de>, davem@redhat.com, shemminger@osdl.org, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 29, 2003 at 06:00:54PM -0800, Andrew Morton wrote:
>  * Expected reader usage:
>  * 	do {
>  *	    seq = fr_read_begin();
>  * 	...
>  *      } while (seq != fr_read_end());

I think perhaps

	do {
	  seq = fr_read_begin(&lock);
	  ...
	} while (fr_read_end(&lock, seq))

would be a better interface.  This would allow you to change
the implementation as well.  E.g.

	unsigned fr_read_begin(frlock_t *lock)
	{
	  unsigned s;

	  do
	    {
	      barrier ();
	      s = lock->sequence;
	    }
	  while (s & 1);
	  rmb();

	  return s;
	}

	int fr_read_end(frlock_t *lock, unsigned s)
	{
	  rmb();
	  return s == lock->sequence;
	}

	void fr_write_begin(frlock_t *rw)
	{
	  rw->sequence++;
	  wmb();
	}

	void fr_write_begin(frlock_t *rw)
	{
	  wmb();
	  rw->sequence++;
	}

which doesn't require as much memory.


r~
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
