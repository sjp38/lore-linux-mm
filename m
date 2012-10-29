Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 71BEC6B006C
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 15:07:05 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2/3] ext4: introduce ext4_error_remove_page
References: <1351177969-893-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1351177969-893-3-git-send-email-n-horiguchi@ah.jp.nec.com>
	<20121026061206.GA31139@thunk.org>
	<3908561D78D1C84285E8C5FCA982C28F19D5A13B@ORSMSX108.amr.corp.intel.com>
	<20121026184649.GA8614@thunk.org>
	<3908561D78D1C84285E8C5FCA982C28F19D5A388@ORSMSX108.amr.corp.intel.com>
	<20121027221626.GA9161@thunk.org> <20121029011632.GN29378@dastard>
	<20121029024024.GC9365@thunk.org> <m27gq9r2cu.fsf@firstfloor.org>
	<20121029182455.GA7098@thunk.org>
Date: Mon, 29 Oct 2012 12:07:04 -0700
In-Reply-To: <20121029182455.GA7098@thunk.org> (Theodore Ts'o's message of
	"Mon, 29 Oct 2012 14:24:56 -0400")
Message-ID: <m21ughksh3.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Dave Chinner <david@fromorbit.com>, "Luck, Tony" <tony.luck@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kleen, Andi" <andi.kleen@intel.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Akira Fujita <a-fujita@rs.jp.nec.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

Theodore Ts'o <tytso@mit.edu> writes:
>
> It's actually pretty easy to test this particular one, 

Note the error can happen at any time.

> and certainly
> one of the things I'd strongly encourage in this patch series is the
> introduction of an interface via madvise

It already exists of course.

I would suggest to study the existing framework before more 
suggestions.

> simulate an ECC hard error event.  So I don't think "it's hard to
> test" is a reason not to do the right thing.  Let's make it easy to

What you can't test doesn't work. It's that simple.

And memory error handling is extremly hard to test. The errors
can happen at any time. It's not a well defined event.
There are test suites for it of course (mce-test, mce-inject[1]),
but they needed a lot of engineering effort to be at where
they are.

[1] despite the best efforts of some current RAS developers
at breaking it.

> Note that the problem that we're dealing with is buffered writes; so
> it's quite possible that the process which wrote the file, thus
> dirtying the page cache, has already exited; so there's no way we can
> guarantee we can inform the process which wrote the file via a signal
> or a error code return.

Is that any different from other IO errors? It doesn't need to 
be better.

> Also, if you're going to keep this state in memory, what happens if
> the inode gets pushed out of memory? 

You lose the error, just like you do today with any other IO error.

We had a lot of discussions on this when the memory error handling
was originally introduced, that was the conclusuion.

I don't think a special panic knob for this makes sense either.
We already have multiple panic knobs for memory errors, that
can be used.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
