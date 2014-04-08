Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A0C2A6B0036
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 23:38:13 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so403808pad.21
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 20:38:13 -0700 (PDT)
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
        by mx.google.com with ESMTPS id ep2si375199pbb.31.2014.04.07.20.38.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 20:38:12 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id p10so392994pdj.3
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 20:38:12 -0700 (PDT)
Message-ID: <53436F20.7000305@linaro.org>
Date: Mon, 07 Apr 2014 20:38:08 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org> <20140401212102.GM4407@cmpxchg.org> <533B313E.5000403@zytor.com> <533B4555.3000608@sr71.net> <533B8E3C.3090606@linaro.org> <20140402163638.GQ14688@cmpxchg.org> <CALAqxLUNKJQs+q__fwqggaRtqLz5sJtuxKdVPja8X0htDyaT6A@mail.gmail.com> <20140408043233.GA11711@chicago.guarana.org>
In-Reply-To: <20140408043233.GA11711@chicago.guarana.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kevin Easton <kevin@guarana.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04/07/2014 09:32 PM, Kevin Easton wrote:
> On Wed, Apr 02, 2014 at 10:40:16AM -0700, John Stultz wrote:
>> On Wed, Apr 2, 2014 at 9:36 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>>> I'm just dying to hear a "normal" use case then. :)
>> So the more "normal" use cause would be marking objects volatile and
>> then non-volatile w/o accessing them in-between. In this case the
>> zero-fill vs SIGBUS semantics don't really matter, its really just a
>> trade off in how we handle applications deviating (intentionally or
>> not) from this use case.
>>
>> So to maybe flesh out the context here for folks who are following
>> along (but weren't in the hallway at LSF :),  Johannes made a fairly
>> interesting proposal (Johannes: Please correct me here where I'm maybe
>> slightly off here) to use only the dirty bits of the ptes to mark a
>> page as volatile. Then the kernel could reclaim these clean pages as
>> it needed, and when we marked the range as non-volatile, the pages
>> would be re-dirtied and if any of the pages were missing, we could
>> return a flag with the purged state.  This had some different
>> semantics then what I've been working with for awhile (for example,
>> any writes to pages would implicitly clear volatility), so I wasn't
>> completely comfortable with it, but figured I'd think about it to see
>> if it could be done. Particularly since it would in some ways simplify
>> tmpfs/shm shared volatility that I'd eventually like to do.
> ...
>> Now, while for the case I'm personally most interested in (ashmem),
>> zero-fill would technically be ok, since that's what Android does.
>> Even so, I don't think its the best approach for the interface, since
>> applications may end up quite surprised by the results when they
>> accidentally don't follow the "don't touch volatile pages" rule.
>>
>> That point beside, I think the other problem with the page-cleaning
>> volatility approach is that there are other awkward side effects. For
>> example: Say an application marks a range as volatile. One page in the
>> range is then purged. The application, due to a bug or otherwise,
>> reads the volatile range. This causes the page to be zero-filled in,
>> and the application silently uses the corrupted data (which isn't
>> great). More problematic though, is that by faulting the page in,
>> they've in effect lost the purge state for that page. When the
>> application then goes to mark the range as non-volatile, all pages are
>> present, so we'd return that no pages were purged.  From an
>> application perspective this is pretty ugly.
> The write-implicitly-clears-volatile semantics would actually be
> an advantage for some use cases.  If you have a volatile cache of
> many sub-page-size objects, the application can just include at
> the start of each page "int present, in_use;".  "present" is set
> to non-zero before marking volatile, and when the application wants
> unmark as volatile it writes to "in_use" and tests the value of 
> "present".  No need for a syscall at all, although it does take a
> minor fault.
>
> The syscall would be better for the case of large objects, though.
>
> Or is that fatally flawed?

Well, as you note, each object would then have to be page size or
smaller, which limits some of the potential use cases.

However, these semantics would match better to the MADV_FREE proposal
Minchan is pushing. So this method would work fine there.

thanks
-john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
