Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id C13C46B00C6
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 13:40:17 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id q108so538074qgd.23
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 10:40:17 -0700 (PDT)
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
        by mx.google.com with ESMTPS id d4si1082267qar.248.2014.04.02.10.40.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 10:40:17 -0700 (PDT)
Received: by mail-qa0-f46.google.com with SMTP id i13so488185qae.19
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 10:40:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140402163638.GQ14688@cmpxchg.org>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org>
	<20140401212102.GM4407@cmpxchg.org>
	<533B313E.5000403@zytor.com>
	<533B4555.3000608@sr71.net>
	<533B8E3C.3090606@linaro.org>
	<20140402163638.GQ14688@cmpxchg.org>
Date: Wed, 2 Apr 2014 10:40:16 -0700
Message-ID: <CALAqxLUNKJQs+q__fwqggaRtqLz5sJtuxKdVPja8X0htDyaT6A@mail.gmail.com>
Subject: Re: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
From: John Stultz <john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Hansen <dave@sr71.net>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Apr 2, 2014 at 9:36 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Tue, Apr 01, 2014 at 09:12:44PM -0700, John Stultz wrote:
>> On 04/01/2014 04:01 PM, Dave Hansen wrote:
>> > On 04/01/2014 02:35 PM, H. Peter Anvin wrote:
>> >> On 04/01/2014 02:21 PM, Johannes Weiner wrote:
>> > John, this was something that the Mozilla guys asked for, right?  Any
>> > idea why this isn't ever a problem for them?
>> So one of their use cases for it is for library text. Basically they
>> want to decompress a compressed library file into memory. Then they plan
>> to mark the uncompressed pages volatile, and then be able to call into
>> it. Ideally for them, the kernel would only purge cold pages, leaving
>> the hot pages in memory. When they traverse a purged page, they handle
>> the SIGBUS and patch the page up.
>
> How big are these libraries compared to overall system size?

Mike or Taras would have to refresh my memory on this detail. My
recollection is it mostly has to do with keeping the on-disk size of
the library small, so it can load off of slow media very quickly.

>> Now.. this is not what I'd consider a normal use case, but was hoping to
>> illustrate some of the more interesting uses and demonstrate the
>> interfaces flexibility.
>
> I'm just dying to hear a "normal" use case then. :)

So the more "normal" use cause would be marking objects volatile and
then non-volatile w/o accessing them in-between. In this case the
zero-fill vs SIGBUS semantics don't really matter, its really just a
trade off in how we handle applications deviating (intentionally or
not) from this use case.

So to maybe flesh out the context here for folks who are following
along (but weren't in the hallway at LSF :),  Johannes made a fairly
interesting proposal (Johannes: Please correct me here where I'm maybe
slightly off here) to use only the dirty bits of the ptes to mark a
page as volatile. Then the kernel could reclaim these clean pages as
it needed, and when we marked the range as non-volatile, the pages
would be re-dirtied and if any of the pages were missing, we could
return a flag with the purged state.  This had some different
semantics then what I've been working with for awhile (for example,
any writes to pages would implicitly clear volatility), so I wasn't
completely comfortable with it, but figured I'd think about it to see
if it could be done. Particularly since it would in some ways simplify
tmpfs/shm shared volatility that I'd eventually like to do.

After thinking it over in the hallway, I talked some of the details w/
Johnnes and there was one issue that while w/ anonymous memory, we can
still add a VM_VOLATILE flag on the vma, so we can get SIGBUS
semantics, but since on shared volatile ranges, we don't have anything
to hang a volatile flag on w/o adding some new vma like structure to
the address_space structure (much as we did in the past w/ earlier
volatile range implementations). This would negate much of the point
of using the dirty bits to simplify the shared volatility
implementation.

Thus Johannes is reasonably questioning the need for SIGBUS semantics,
since if it wasn't needed, the simpler page-cleaning based volatility
could potentially be used.


Now, while for the case I'm personally most interested in (ashmem),
zero-fill would technically be ok, since that's what Android does.
Even so, I don't think its the best approach for the interface, since
applications may end up quite surprised by the results when they
accidentally don't follow the "don't touch volatile pages" rule.

That point beside, I think the other problem with the page-cleaning
volatility approach is that there are other awkward side effects. For
example: Say an application marks a range as volatile. One page in the
range is then purged. The application, due to a bug or otherwise,
reads the volatile range. This causes the page to be zero-filled in,
and the application silently uses the corrupted data (which isn't
great). More problematic though, is that by faulting the page in,
they've in effect lost the purge state for that page. When the
application then goes to mark the range as non-volatile, all pages are
present, so we'd return that no pages were purged.  From an
application perspective this is pretty ugly.

Johannes: Any thoughts on this potential issue with your proposal? Am
I missing something else?

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
