Date: Thu, 18 Sep 2003 14:15:50 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: swapping to death by stressing mlock
Message-ID: <20030918211550.GW14079@holomorphy.com>
References: <200309182021.h8IKLnqX006918@penguin.co.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200309182021.h8IKLnqX006918@penguin.co.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Lynch <rusty@linux.co.intel.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 18, 2003 at 01:21:49PM -0700, Rusty Lynch wrote:
> While getting more familiar with the vm subsystem I discovered that it is
> fairly easy to lockup my system by mlocking enough memory. I believe what 
> is happening is that I am reducing the amount of swappable physical ram
> to the point that try_to_free_pages() will go into an endless loop waiting
> for bdflush to free up some pages.
> I'm guessing this is not a valid condition for a properly configured server,
> but since I'm not feeling very confident about my above explanation, I'm not
> so sure this isn't something to look into.
> On my 2.6.0-test5 kernel I run a little utility that attempts to allocate 
> a large enough chunk of memory, touch all pages in the buffer, and then 
> mlock the buffer.  Just setting vm.overcommit_memory=2 and a real low
> vm.overcommit_ratio doesn't help a lot since all I have to do is squeeze out
> the available physical ram that can be swapped out.
> This is what I see for my offending process if I meta-sysrq-t.

(a) mlock_fixup() ignores the return value of make_pages_present();
	it might be a good idea to hand back -ENOMEM if it fail
(b) get_user_pages() (and hence make_pages_present() etc.) should fail
	when bad things would otherwise happen.
(c) apart from these two observations, the best I can tell is that
	you're thrashing

So, you've seen that wakeup_bdflush() is done repeatedly; is there any
indication such as, say, the address in get_user_pages() to tell you
whether you're making forward progress? Just the fact that's repeatedly
called isn't really enough to make the distinction between livelock and
just being slow.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
