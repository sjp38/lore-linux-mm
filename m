From: Kevin Easton <kevin@guarana.org>
Subject: Re: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
Date: Tue, 8 Apr 2014 14:32:33 +1000
Message-ID: <20140408043233.GA11711@chicago.guarana.org>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org>
 <20140401212102.GM4407@cmpxchg.org>
 <533B313E.5000403@zytor.com>
 <533B4555.3000608@sr71.net>
 <533B8E3C.3090606@linaro.org>
 <20140402163638.GQ14688@cmpxchg.org>
 <CALAqxLUNKJQs+q__fwqggaRtqLz5sJtuxKdVPja8X0htDyaT6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALAqxLUNKJQs+q__fwqggaRtqLz5sJtuxKdVPja8X0htDyaT6A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: John Stultz <john.stultz@linaro.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

On Wed, Apr 02, 2014 at 10:40:16AM -0700, John Stultz wrote:
> On Wed, Apr 2, 2014 at 9:36 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > I'm just dying to hear a "normal" use case then. :)
> 
> So the more "normal" use cause would be marking objects volatile and
> then non-volatile w/o accessing them in-between. In this case the
> zero-fill vs SIGBUS semantics don't really matter, its really just a
> trade off in how we handle applications deviating (intentionally or
> not) from this use case.
> 
> So to maybe flesh out the context here for folks who are following
> along (but weren't in the hallway at LSF :),  Johannes made a fairly
> interesting proposal (Johannes: Please correct me here where I'm maybe
> slightly off here) to use only the dirty bits of the ptes to mark a
> page as volatile. Then the kernel could reclaim these clean pages as
> it needed, and when we marked the range as non-volatile, the pages
> would be re-dirtied and if any of the pages were missing, we could
> return a flag with the purged state.  This had some different
> semantics then what I've been working with for awhile (for example,
> any writes to pages would implicitly clear volatility), so I wasn't
> completely comfortable with it, but figured I'd think about it to see
> if it could be done. Particularly since it would in some ways simplify
> tmpfs/shm shared volatility that I'd eventually like to do.
...
> Now, while for the case I'm personally most interested in (ashmem),
> zero-fill would technically be ok, since that's what Android does.
> Even so, I don't think its the best approach for the interface, since
> applications may end up quite surprised by the results when they
> accidentally don't follow the "don't touch volatile pages" rule.
> 
> That point beside, I think the other problem with the page-cleaning
> volatility approach is that there are other awkward side effects. For
> example: Say an application marks a range as volatile. One page in the
> range is then purged. The application, due to a bug or otherwise,
> reads the volatile range. This causes the page to be zero-filled in,
> and the application silently uses the corrupted data (which isn't
> great). More problematic though, is that by faulting the page in,
> they've in effect lost the purge state for that page. When the
> application then goes to mark the range as non-volatile, all pages are
> present, so we'd return that no pages were purged.  From an
> application perspective this is pretty ugly.

The write-implicitly-clears-volatile semantics would actually be
an advantage for some use cases.  If you have a volatile cache of
many sub-page-size objects, the application can just include at
the start of each page "int present, in_use;".  "present" is set
to non-zero before marking volatile, and when the application wants
unmark as volatile it writes to "in_use" and tests the value of 
"present".  No need for a syscall at all, although it does take a
minor fault.

The syscall would be better for the case of large objects, though.

Or is that fatally flawed?

    - Kevin
