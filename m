Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 995826B0279
	for <linux-mm@kvack.org>; Fri, 26 May 2017 13:05:22 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id b28so1287231wrb.2
        for <linux-mm@kvack.org>; Fri, 26 May 2017 10:05:22 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o83sor5696wmo.44.2017.05.26.10.05.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 May 2017 10:05:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170524220949.GS141096@google.com>
References: <20170519210036.146880-1-mka@chromium.org> <20170519210036.146880-2-mka@chromium.org>
 <alpine.DEB.2.10.1705221338100.30407@chino.kir.corp.google.com>
 <20170522205621.GL141096@google.com> <20170522144501.2d02b5799e07167dc5aecf3e@linux-foundation.org>
 <alpine.DEB.2.10.1705221834440.13805@chino.kir.corp.google.com>
 <20170523165608.GN141096@google.com> <alpine.DEB.2.10.1705241326200.49680@chino.kir.corp.google.com>
 <20170524220949.GS141096@google.com>
From: Doug Anderson <dianders@chromium.org>
Date: Fri, 26 May 2017 10:05:18 -0700
Message-ID: <CAD=FV=VFih02J1D-fOrpVEO9qDtLOusyqP3dHdeM7h0Etrrn2A@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm/slub: Only define kmalloc_large_node_hook() for
 NUMA systems
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Kaehlcke <mka@chromium.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi,

On Wed, May 24, 2017 at 3:09 PM, Matthias Kaehlcke <mka@chromium.org> wrote:
> Hi David,
>
> El Wed, May 24, 2017 at 01:36:21PM -0700 David Rientjes ha dit:
>
>> On Tue, 23 May 2017, Matthias Kaehlcke wrote:
>>
>> > > diff --git a/include/linux/compiler-clang.h b/include/linux/compiler-clang.h
>> > > index de179993e039..e1895ce6fa1b 100644
>> > > --- a/include/linux/compiler-clang.h
>> > > +++ b/include/linux/compiler-clang.h
>> > > @@ -15,3 +15,8 @@
>> > >   * with any version that can compile the kernel
>> > >   */
>> > >  #define __UNIQUE_ID(prefix) __PASTE(__PASTE(__UNIQUE_ID_, prefix), __COUNTER__)
>> > > +
>> > > +#ifdef inline
>> > > +#undef inline
>> > > +#define inline __attribute__((unused))
>> > > +#endif
>> >
>> > Thanks for the suggestion!
>> >
>> > Nothing breaks and the warnings are silenced. It seems we could use
>> > this if there is a stong opposition against having warnings on unused
>> > static inline functions in .c files.
>> >
>>
>> It would be slightly different, it would be:
>>
>> #define inline inline __attribute__((unused))
>>
>> to still inline the functions, I was just seeing if there was anything
>> else that clang was warning about that was unrelated to a function's
>> inlining.
>>
>> > Still I am not convinced that gcc's behavior is preferable in this
>> > case. True, it saves us from adding a bunch of __maybe_unused or
>> > #ifdefs, on the other hand the warning is a useful tool to spot truly
>> > unused code. So far about 50% of the warnings I looked into fall into
>> > this category.
>> >
>>
>> I think gcc's behavior is a result of how it does preprocessing and is a
>> clearly defined and long-standing semantic given in the gcc manual
>> regarding -Wunused-function.
>>
>> #define IS_PAGE_ALIGNED(__size)       (!(__size & ((size_t)PAGE_SIZE - 1)))
>> static inline int is_page_aligned(size_t size)
>> {
>>       return !(size & ((size_t)PAGE_SIZE - 1));
>> }
>>
>> Gcc will not warn about either of these being unused, regardless of -Wall,
>> -Wunused-function, or -pedantic.  Clang, correct me if I'm wrong, will
>> only warn about is_page_aligned().
>
> Indeed, clang does not warn about unused defines.
>
>> So the argument could be made that one of the additional benefits of
>> static inline functions is that a subset of compilers, heavily in the
>> minority, will detect whether it's unused and we'll get patches that
>> remove them.  Functionally, it would only result in LOC reduction.  But,
>> isn't adding #ifdef's to silence the warning just adding more LOC?
>
> The LOC reduction comes from the removal of the actual dead code that
> is spotted because the warning was enabled and pointed it out :)
>
> Using #ifdef is one option, in most cases the function can be marked as
> __maybe_unused, which technically doesn't (necessarily) increase
> LOC. However some maintainers prefer the use of #ifdef over
> __maybe_unused in certain cases.
>
>> I have no preference either way, I think it would be up to the person who
>> is maintaining the code and has to deal with the patches.
>
> I think it would be good to have a general policy/agreement, to either
> disable the warning completely (not my preference) or 'allow' the use
> of one of the available mechanism to suppress the warning for
> functions that are not used in some configurations or only kept around
> for reference/debugging/symmetry.

I would tend to agree with Matthias that we need some type of general
policy / agreement with enough maintainers.  It's nice to consider all
warnings as important and if there are a few outliers it makes it
easier to ignore all warnings.

BTW: just as extra motivation showing the usefulness of this work, see
a patch I just posted that deletes a bunch of unneeded code in an ASoC
driver:

https://patchwork.kernel.org/patch/9750813/

I don't know anything about this driver but the clang warning made it
obvious that something was wrong.  Either we were doing a bit of
useless saving or (perhaps) the restore was actually supposed to be
called somewhere and we had a bug.

-Doug

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
