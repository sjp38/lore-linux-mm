Subject: Re: speeding up swapoff
From: Daniel Drake <ddrake@brontes3d.com>
In-Reply-To: <Pine.LNX.4.64.0708301132470.26365@blonde.wat.veritas.com>
References: <1188394172.22156.67.camel@localhost>
	 <Pine.LNX.4.64.0708291558480.27467@blonde.wat.veritas.com>
	 <m1d4x52zri.fsf@ebiederm.dsl.xmission.com>
	 <Pine.LNX.4.64.0708301132470.26365@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Thu, 30 Aug 2007 11:05:16 -0400
Message-Id: <1188486316.13361.23.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-30 at 11:36 +0100, Hugh Dickins wrote:
> Regarding Daniel's use of swapoff: it's a very heavy sledgehammer
> for cracking that nut, I strongly agree with those who have pointed
> him to mlock and mlockall instead.

There are some issues with us using mlockall. Admittedly, most/all of
them are not the kernels problem (but a fast swapoff would be a good
workaround):

We're using python 2.4, so mlock() itself isn't really an option (we
don't realistically have access to the address regions hidden behind the
language). mlockall() is a possibility, but the fact that all
allocations above a particular limit will fail would potentially cause
us problems given that it's hard to control python's memory usage for a
long-running application.

Additionally, choosing that limit is hard given that we have this
real-time and non-real-time processing balance, plus an interactive
python-based application that runs all the time (which is the thing we
would be locking). python 2.4 never returns memory to the OS, so at
whatever point the memory usage of the application peaks, all that
memory remains locked permanently.

In addition we have the non-real-time processing task which does benefit
from having more memory available, so in that case, we would want it to
swap out parts of the application. I guess we could ask the application
to do munlockall() here, but things start getting scary and
overcomplicated at this point...

So, our arguments against mlockall() are not strong, but you can see why
fast swapoff would be mighty convenient.

Thanks for all the info so far. It does sound like my earlier idea
wouldn't be any faster in the general case due to excess disk seeking.
Oh well...

-- 
Daniel Drake
Brontes Technologies, A 3M Company
http://www.brontes3d.com/opensource

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
