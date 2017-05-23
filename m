Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 421726B0292
	for <linux-mm@kvack.org>; Tue, 23 May 2017 13:12:12 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id g72so107445328ywe.1
        for <linux-mm@kvack.org>; Tue, 23 May 2017 10:12:12 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s5sor939092ywb.226.2017.05.23.10.12.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 May 2017 10:12:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170523165608.GN141096@google.com>
References: <20170519210036.146880-1-mka@chromium.org> <20170519210036.146880-2-mka@chromium.org>
 <alpine.DEB.2.10.1705221338100.30407@chino.kir.corp.google.com>
 <20170522205621.GL141096@google.com> <20170522144501.2d02b5799e07167dc5aecf3e@linux-foundation.org>
 <alpine.DEB.2.10.1705221834440.13805@chino.kir.corp.google.com> <20170523165608.GN141096@google.com>
From: Doug Anderson <dianders@chromium.org>
Date: Tue, 23 May 2017 10:12:09 -0700
Message-ID: <CAD=FV=WfrtOCOmt_aT+ZPiPUWqoZLB=j=K53E73DkvEUUrzsmA@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm/slub: Only define kmalloc_large_node_hook() for
 NUMA systems
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Kaehlcke <mka@chromium.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi,

On Tue, May 23, 2017 at 9:56 AM, Matthias Kaehlcke <mka@chromium.org> wrote:
> Hi David,
>
> El Mon, May 22, 2017 at 06:35:23PM -0700 David Rientjes ha dit:
>
>> On Mon, 22 May 2017, Andrew Morton wrote:
>>
>> > > > Is clang not inlining kmalloc_large_node_hook() for some reason?  I don't
>> > > > think this should ever warn on gcc.
>> > >
>> > > clang warns about unused static inline functions outside of header
>> > > files, in difference to gcc.
>> >
>> > I wish it wouldn't.  These patches just add clutter.
>> >
>>
>> Matthias, what breaks if you do this?
>>
>> diff --git a/include/linux/compiler-clang.h b/include/linux/compiler-clang.h
>> index de179993e039..e1895ce6fa1b 100644
>> --- a/include/linux/compiler-clang.h
>> +++ b/include/linux/compiler-clang.h
>> @@ -15,3 +15,8 @@
>>   * with any version that can compile the kernel
>>   */
>>  #define __UNIQUE_ID(prefix) __PASTE(__PASTE(__UNIQUE_ID_, prefix), __COUNTER__)
>> +
>> +#ifdef inline
>> +#undef inline
>> +#define inline __attribute__((unused))
>> +#endif
>
> Thanks for the suggestion!

Wow, I totally didn't think of this either when talking with Matthias
about this.  I guess it makes the assumption that nobody else is
hacking "inline" like we are, but "what are the chances of someone
doing that (TM)"  ;-)


> Nothing breaks and the warnings are silenced. It seems we could use
> this if there is a stong opposition against having warnings on unused
> static inline functions in .c files.
>
> Still I am not convinced that gcc's behavior is preferable in this
> case. True, it saves us from adding a bunch of __maybe_unused or
> #ifdefs, on the other hand the warning is a useful tool to spot truly
> unused code. So far about 50% of the warnings I looked into fall into
> this category.

Personally I actually prefer clang's behavior to gcc's here and I
think Matthias's patches are actually doing a service to the
community.  As he points out, many of the patches he's posted have
removed totally dead code from the kernel.  This code has often
existed for many years but never been noticed.  While the code wasn't
hurting anyone (it was dead and the compiler wasn't generating any
code for it), it would certainly add confusion to anyone reading the
source code.

Obviously my opinion isn't as important as the opinion of upstream
maintainers, but hopefully you'll consider it anyway.  :)  If you
still want to just make clang behave like gcc then I think David's
suggestion is a great one.


-Doug

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
